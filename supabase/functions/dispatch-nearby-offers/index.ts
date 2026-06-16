import "jsr:@supabase/functions-js/edge-runtime.d.ts";
import { createClient } from "npm:@supabase/supabase-js@2";
import { json } from "../_shared/http.ts";

const supabaseUrl = Deno.env.get("SUPABASE_URL")!;
const serviceRoleKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;

const supabase = createClient(supabaseUrl, serviceRoleKey, {
  auth: { persistSession: false, autoRefreshToken: false },
});

// Earth radius in km
const EARTH_RADIUS_KM = 6371;

function haversineDistance(
  lat1: number,
  lon1: number,
  lat2: number,
  lon2: number,
): number {
  const toRad = (deg: number) => (deg * Math.PI) / 180;
  const dLat = toRad(lat2 - lat1);
  const dLon = toRad(lon2 - lon1);
  const a =
    Math.sin(dLat / 2) ** 2 +
    Math.cos(toRad(lat1)) * Math.cos(toRad(lat2)) * Math.sin(dLon / 2) ** 2;
  return EARTH_RADIUS_KM * 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
}

interface BusinessLocation {
  id: string;
  business_id: string;
  latitude: number;
  longitude: number;
}

interface Offer {
  id: string;
  business_id: string;
  title: string;
  category: string | null;
  discounted_price: number;
  original_price: number;
  stock: number;
  pickup_end: string;
}

interface UserPref {
  user_id: string;
  notification_radius_km: number;
  favorite_categories: string[];
}

interface NotifPref {
  user_id: string;
  push_enabled: boolean;
  favorite_alerts_enabled: boolean;
  last_minute_deals_enabled: boolean;
}

interface Business {
  id: string;
  name: string;
  slug: string;
}

async function sendPush(
  userIds: string[],
  title: string,
  body: string,
  data: Record<string, string>,
) {
  const { error } = await supabase.functions.invoke("send-push-notification", {
    body: {
      user_ids: userIds,
      title,
      body,
      data,
      type: "nearby_offer",
      channel: "push",
      pref_table: "consumer_notification_preferences",
    },
  });

  if (error) {
    console.error("Failed to invoke send-push-notification:", error.message);
  }
}

function isLastMinuteOffer(offer: Offer): boolean {
  const now = Date.now();
  const pickupEnd = new Date(offer.pickup_end).getTime();
  const diffMinutes = (pickupEnd - now) / 1000 / 60;
  return diffMinutes <= 120; // 2 hours or less to pickup
}

Deno.serve(async () => {
  // 1. Get all active offers that are still within pickup window
  const now = new Date().toISOString();
  const { data: offers, error: offersError } = await supabase
    .from("offers")
    .select("id, business_id, title, category, discounted_price, original_price, stock, pickup_end")
    .eq("is_active", true)
    .gt("stock", 0)
    .lt("pickup_start", now)
    .gt("pickup_end", now);

  if (offersError || !offers?.length) {
    return json({ success: true, notified: 0 });
  }

  const offerIds = offers.map((o: Offer) => o.id);
  const businessIds = [...new Set(offers.map((o: Offer) => o.business_id))];

  // 2. Get business names and locations
  const { data: businesses } = await supabase
    .from("businesses")
    .select("id, name, slug")
    .in("id", businessIds);

  const businessMap = new Map<string, Business>();
  for (const b of businesses ?? []) {
    businessMap.set(b.id, b as Business);
  }

  const { data: locations } = await supabase
    .from("business_locations")
    .select("id, business_id, latitude, longitude")
    .in("business_id", businessIds)
    .eq("is_active", true);

  // 3. Get users with push enabled from notification preferences
  const { data: notifPrefs } = await supabase
    .from("consumer_notification_preferences")
    .select("user_id, push_enabled, favorite_alerts_enabled, last_minute_deals_enabled")
    .eq("push_enabled", true);

  if (!notifPrefs?.length) {
    return json({ success: true, notified: 0 });
  }

  // 4. Get UI preferences (radius, categories) for these users
  const enabledUserIds = notifPrefs.map((n: NotifPref) => n.user_id);

  const { data: userPrefs } = await supabase
    .from("user_preferences")
    .select("user_id, notification_radius_km, favorite_categories")
    .in("user_id", enabledUserIds);

  if (!userPrefs?.length) {
    return json({ success: true, notified: 0 });
  }

  // 5. Build a combined preferences map
  const notifPrefMap = new Map<string, NotifPref>();
  for (const np of notifPrefs as NotifPref[]) {
    notifPrefMap.set(np.user_id, np);
  }

  const userIds = userPrefs.map((u: UserPref) => u.user_id);

  const { data: addresses } = await supabase
    .from("saved_addresses")
    .select("user_id, latitude, longitude")
    .in("user_id", userIds)
    .eq("is_default", true);

  const userAddressMap = new Map<string, { lat: number; lon: number }>();
  for (const addr of addresses ?? []) {
    userAddressMap.set(addr.user_id, {
      lat: Number(addr.latitude),
      lon: Number(addr.longitude),
    });
  }

  // 6. For each user, find nearby offers respecting their notification preferences
  let totalNotified = 0;

  for (const user of userPrefs as UserPref[]) {
    const notifPref = notifPrefMap.get(user.user_id);
    if (!notifPref) continue;

    const userAddr = userAddressMap.get(user.user_id);
    if (!userAddr) continue;

    const radiusKm = user.notification_radius_km;
    const favCategories = new Set(
      (user.favorite_categories ?? []).map((c: string) => c.toLowerCase()),
    );

    const matchingOffers: Array<{ offer: Offer; business: Business; distance: number }> = [];

    for (const offer of offers as Offer[]) {
      // Check last-minute deals preference
      const isLastMinute = isLastMinuteOffer(offer);
      if (isLastMinute && !notifPref.last_minute_deals_enabled) {
        continue;
      }

      // Check favorite alerts preference
      const hasFavCategory = offer.category &&
        favCategories.size > 0 &&
        favCategories.has(offer.category.toLowerCase());

      if (hasFavCategory && !notifPref.favorite_alerts_enabled) {
        continue;
      }

      // If not a favorite category and not last-minute, skip
      if (!hasFavCategory && !isLastMinute) {
        continue;
      }

      const business = businessMap.get(offer.business_id);
      if (!business) continue;

      // Find the nearest location of this business to the user
      const businessLocations = (locations ?? []).filter(
        (l: BusinessLocation) => l.business_id === offer.business_id,
      );

      if (businessLocations.length === 0) continue;

      let minDistance = Infinity;
      for (const loc of businessLocations as BusinessLocation[]) {
        const dist = haversineDistance(
          userAddr.lat,
          userAddr.lon,
          Number(loc.latitude),
          Number(loc.longitude),
        );
        if (dist < minDistance) minDistance = dist;
      }

      if (minDistance <= radiusKm) {
        matchingOffers.push({ offer, business, distance: Math.round(minDistance) });
      }
    }

    if (matchingOffers.length === 0) continue;

    // Send one notification with the best offer
    const best = matchingOffers.sort((a, b) => a.distance - b.distance)[0];

    const discount = Math.round(
      ((best.offer.original_price - best.offer.discounted_price) /
        best.offer.original_price) *
        100,
    );

    await sendPush(
      [user.user_id],
      "${best.business.name} — ¡${discount}% OFF!",
      "${best.offer.title} a ${best.offer.discounted_price} — A ${best.distance}km de ti.",
      {
        type: "nearby_offer",
        offer_id: best.offer.id,
        business_id: best.business.id,
        business_slug: best.business.slug,
        link: "/product/${best.offer.id}",
      },
    );

    totalNotified++;
  }

  return json({
    success: true,
    notified: totalNotified,
    total_offers: offers.length,
    total_users: userPrefs.length,
  });
});
