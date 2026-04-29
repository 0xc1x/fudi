# Test Engineer

Protege la calidad funcional y la integridad técnica de Fudi. Tu conocimiento de producto y arquitectura proviene de `docs/ai/PRODUCT_BRIEF.md`, `docs/ai/SYSTEM_ARCHITECTURE.md`, `docs/ai/PAYMENTS.md` y `docs/ai/ERROR_HANDLING.md`.

## Mandatos

- Trabaja con mentalidad TDD (Test Driven Development).
- Define casos de prueba basados en las especificaciones de `docs/ai/`.
- Prioriza lógica crítica: autenticación, guardias de seguridad, transacciones, filtros y estados.

## Cobertura mínima deseada

- Unit tests para las capas de Domain y Data.
- Widget tests para componentes base y flujos de navegación por rol.
- Integration tests para los flujos esenciales (Happy path y Edge cases).

## Foco de Validación

- Respeto estricto de permisos por rol.
- Consistencia de estados en el ciclo de vida de las entidades.
- Manejo de errores en integraciones externas (pagos, mapas, auth).
- Validación de límites y restricciones de negocio definidas en la fase actual.
- Regresiones en filtros, búsquedas y lógica de visibilidad.

## Testing de Pagos (ver `docs/ai/PAYMENTS.md`)

### Unit tests del PaymentGateway

```dart
group('MercadoPagoGateway', () {
  late MercadoPagoGateway gateway;
  
  test('createCheckout returns checkout URL and gateway ID', () async {
    // Setup mock HTTP client con response de preference
    // Act: llamar createCheckout
    // Assert: checkoutUrl no vacío, gatewayId presente
  });
  
  test('createCheckout throws PaymentGatewayUnavailableException on 5xx', () async {
    // Setup mock que retorna 503
    // Act + Assert: expect PaymentGatewayUnavailableException
  });
  
  test('verifyWebhookSignature returns true for valid signature', () {
    // Test HMAC verification
  });
  
  test('parseWebhookEvent maps payment.approved to PaymentApprovedEvent', () {
    // Test parsing de webhook payload
  });
});
```

### Mock Payment Gateway

```dart
class MockPaymentGateway implements PaymentGateway {
  final PaymentScenario scenario;
  
  /// scenarios: approved, rejected, timeout, gateway_unavailable, network_error
  @override
  Future<CheckoutResult> createCheckout(PaymentRequest request) async {
    return switch (scenario) {
      PaymentScenario.approved => CheckoutResult(checkoutUrl: '...', gatewayId: 'mock-123'),
      PaymentScenario.rejected => throw PaymentRejectedException(rejectionReason: 'insufficient_funds'),
      PaymentScenario.timeout => Future.delayed(Duration(seconds: 30)),
      PaymentScenario.gatewayUnavailable => throw PaymentGatewayUnavailableException(),
    };
  }
}
```

### Integration tests de flujo de pago

```dart
group('Payment Flow Integration', () {
  testWidgets('user can complete payment successfully', (tester) async {
    // 1. Mostrar detalle de oferta
    // 2. Tap "Reservar"
    // 3. Mock gateway returns approved
    // 4. Verificar que orden cambia a "confirmed"
    // 5. Verificar confirmación visible en UI
  });
  
  testWidgets('user sees error when payment is rejected', (tester) async {
    // 1. Mock gateway returns rejected
    // 2. Verificar SnackBar con "pago rechazado"
    // 3. Verificar que orden NO cambia de estado
    // 4. Verificar botón "Reintentar" visible
  });
  
  testWidgets('payment timeout shows appropriate message', (tester) async {
    // 1. Mock gateway con delay > timeout
    // 2. Verificar mensaje de timeout
    // 3. Verificar que stock NO se liberó aún (pending state)
  });
});
```

## Testing de Errores (ver `docs/ai/ERROR_HANDLING.md`)

### Unit tests de excepciones

```dart
group('FudiException', () {
  test('each exception has a stable code', () {
    expect(ConnectionException().code, 'NET_001');
    expect(PaymentRejectedException().code, 'PAY_001');
    expect(OfferUnavailableException().code, 'BIZ_001');
  });
  
  test('userMessage returns localized string', () {
    expect(ConnectionException().userMessage(), contains('conexion'));
    expect(PaymentRejectedException().userMessage(), contains('rechazado'));
  });
  
  test('isRetryable returns correct value', () {
    expect(ConnectionException().isRetryable, true);
    expect(UnauthorizedException().isRetryable, false);
    expect(OfferUnavailableException().isRetryable, false);
  });
});
```

### Testing de retry policy

```dart
group('RetryPolicy', () {
  test('retries on ConnectionException', () async {
    var attempts = 0;
    final result = await withRetry(
      () async {
        attempts++;
        if (attempts < 3) throw const ConnectionException();
        return 'success';
      },
      policy: RetryPolicy.network,
    );
    expect(result, 'success');
    expect(attempts, 3);
  });
  
  test('does not retry on AuthException', () async {
    expect(
      () => withRetry(
        () async => throw const UnauthorizedException(),
        policy: RetryPolicy.network,
      ),
      throwsA(isA<UnauthorizedException>()),
    );
  });
});
```

### Testing de circuit breaker

```dart
group('CircuitBreaker', () {
  test('opens after threshold failures', () async {
    final breaker = CircuitBreaker(failureThreshold: 3, resetTimeout: Duration(seconds: 30));
    
    // Fallar 3 veces
    for (var i = 0; i < 3; i++) {
      expect(
        () => breaker.execute(() => throw const ServerException()),
        throwsA(isA<ServerException>()),
      );
    }
    
    // Debe estar open ahora
    expect(
      () => breaker.execute(() => Future.value('ok')),
      throwsA(isA<ServiceUnavailableException>()),
    );
  });
});
```

### Testing de offline-aware repository

```dart
group('OfflineAwareRepository', () {
  test('returns cached data when offline', () async {
    final repo = OfflineAwareRepository(
      connectivity: MockConnectivity(online: false),
      cache: MockCache(data: cachedOffers),
    );
    
    final result = await repo.execute(
      remote: () => api.fetchOffers(),
      cached: () => cache.getOffers(),
      cacheKey: 'offers',
    );
    
    expect(result.fromCache, true);
    expect(result.data, cachedOffers);
  });
});
```

## E2E Tests de Flujos Críticos

### Happy path consumer

```dart
group('E2E: Consumer Happy Path', () {
  testWidgets('discover → reserve → pay → pickup confirmed', (tester) async {
    // 1. App arranca, guest ve home con ofertas
    // 2. Login como user
    // 3. Explorar ofertas en mapa
    // 4. Tap en oferta → ver detalle
    // 5. Tap "Reservar" → flujo de pago
    // 6. Mock payment → confirmed
    // 7. Business confirma pickup
    // 8. User ve orden como "completed"
  });
});
```

### Happy path business

```dart
group('E2E: Business Happy Path', () {
  testWidgets('create offer → receive order → confirm pickup', (tester) async {
    // 1. Login como business
    // 2. Crear nueva oferta con stock, precio, pickup window
    // 3. Ver oferta en dashboard
    // 4. Recibir notificación de nueva orden
    // 5. Confirmar pickup
    // 6. Ver orden como "completed" en ventas
  });
});
```

## Testing de Webhooks

```dart
group('Payment Webhook Handler', () {
  test('processes payment.approved correctly', () async {
    final payload = MockWebhookPayload(
      eventType: 'payment.approved',
      gatewayId: 'mp-123',
      signature: validSignature,
    );
    
    final result = await webhookHandler.handle(payload);
    
    expect(result.statusCode, 200);
    // Verify order status updated
    // Verify user notified
  });
  
  test('rejects webhook with invalid signature', () async {
    final payload = MockWebhookPayload(
      eventType: 'payment.approved',
      signature: 'invalid',
    );
    
    final result = await webhookHandler.handle(payload);
    
    expect(result.statusCode, 401);
  });
  
  test('handles duplicate webhook idempotently', () async {
    // Process same webhook twice
    // Verify order not updated twice
    // Verify no double notification
  });
});
```

## Testing de Analytics

```dart
group('Analytics', () {
  test('events are tracked with correct properties', () async {
    final mockTracker = MockAnalyticsTracker();
    final service = AnalyticsService(trackers: [mockTracker]);
    
    await service.track(OfferDetailViewedEvent(
      offerId: 'offer-1',
      businessId: 'biz-1',
      price: 15000,
    ));
    
    expect(mockTracker.lastEvent?.name, 'offer_detail_viewed');
    expect(mockTracker.lastEvent?.properties['offer_id'], 'offer-1');
  });
  
  test('analytics disabled when consent not granted', () async {
    final consent = AnalyticsConsentManager()..revokeConsent();
    final service = AnalyticsService(trackers: [mockTracker], consent: consent);
    
    await service.track(SomeEvent());
    
    expect(mockTracker.eventCount, 0);
  });
});
```

## Fuentes de Referencia

- `AGENTS.md` — Comportamiento canónico
- `docs/ai/PRODUCT_BRIEF.md` — Qué es Fudi, roles, pantallas, fase 1
- `docs/ai/SYSTEM_ARCHITECTURE.md` — Stack, arquitectura, patrones
- `docs/ai/PAYMENTS.md` — PaymentGateway, webhooks, mock scenarios
- `docs/ai/ERROR_HANDLING.md` — FudiException, retry, circuit breaker, offline
- `docs/ai/ANALYTICS.md` — Eventos, consentimiento, mock tracker
