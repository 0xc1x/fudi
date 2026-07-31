-- Convert seed offer prices from COP to USD (÷4000) and extend pickup windows
-- into the future so the offers keep showing in the app.

update offers
set
  original_price = case id
    when 'e0000000-0000-0000-0000-000000000004' then 8.00   -- Bowl Poke Salmón
    when 'e0000000-0000-0000-0000-000000000008' then 7.00   -- Lasagna Boloñesa
    when 'e0000000-0000-0000-0000-000000000001' then 4.50   -- Paquete de Pan Artesanal
    when 'e0000000-0000-0000-0000-000000000005' then 5.50   -- Desayuno Completo Café
    when 'e0000000-0000-0000-0000-000000000007' then 9.50   -- Pizza Margherita Mediana
    when 'e0000000-0000-0000-0000-000000000002' then 8.75   -- Caja de Pastelería Variada
    when 'e0000000-0000-0000-0000-000000000003' then 13.75  -- Combo Sushi 24 Piezas
    when 'e0000000-0000-0000-0000-000000000006' then 4.00   -- Torta de Chocolate + Café
    else original_price
  end,
  discounted_price = case id
    when 'e0000000-0000-0000-0000-000000000004' then 4.00
    when 'e0000000-0000-0000-0000-000000000008' then 3.50
    when 'e0000000-0000-0000-0000-000000000001' then 2.25
    when 'e0000000-0000-0000-0000-000000000005' then 2.75
    when 'e0000000-0000-0000-0000-000000000007' then 4.75
    when 'e0000000-0000-0000-0000-000000000002' then 4.40
    when 'e0000000-0000-0000-0000-000000000003' then 6.25
    when 'e0000000-0000-0000-0000-000000000006' then 2.00
    else discounted_price
  end
where id in (
  'e0000000-0000-0000-0000-000000000001',
  'e0000000-0000-0000-0000-000000000002',
  'e0000000-0000-0000-0000-000000000003',
  'e0000000-0000-0000-0000-000000000004',
  'e0000000-0000-0000-0000-000000000005',
  'e0000000-0000-0000-0000-000000000006',
  'e0000000-0000-0000-0000-000000000007',
  'e0000000-0000-0000-0000-000000000008'
);

-- Extend the pickup window of every already-expired offer.
update offers
set pickup_end = '2026-12-31 22:00:00+00'
where pickup_end < now();
