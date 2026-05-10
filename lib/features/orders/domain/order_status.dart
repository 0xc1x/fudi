enum OrderStatus {
  pending,
  confirmed,
  readyForPickup,
  pickedUp,
  completed,
  cancelled,
  expired;

  static OrderStatus fromString(String? value) {
    if (value == null) return OrderStatus.pending;
    switch (value) {
      case 'pending':
        return OrderStatus.pending;
      case 'confirmed':
        return OrderStatus.confirmed;
      case 'ready_for_pickup':
        return OrderStatus.readyForPickup;
      case 'picked_up':
        return OrderStatus.pickedUp;
      case 'completed':
        return OrderStatus.completed;
      case 'cancelled':
        return OrderStatus.cancelled;
      case 'expired':
        return OrderStatus.expired;
      default:
        return OrderStatus.pending;
    }
  }

  String get dbValue {
    switch (this) {
      case OrderStatus.readyForPickup:
        return 'ready_for_pickup';
      case OrderStatus.pickedUp:
        return 'picked_up';
      default:
        return name;
    }
  }

  bool canTransitionTo(OrderStatus next) {
    switch (this) {
      case OrderStatus.pending:
        return next == OrderStatus.confirmed ||
            next == OrderStatus.cancelled ||
            next == OrderStatus.expired;
      case OrderStatus.confirmed:
        return next == OrderStatus.readyForPickup ||
            next == OrderStatus.cancelled ||
            next == OrderStatus.expired;
      case OrderStatus.readyForPickup:
        return next == OrderStatus.pickedUp ||
            next == OrderStatus.cancelled ||
            next == OrderStatus.expired;
      case OrderStatus.pickedUp:
        return next == OrderStatus.completed;
      case OrderStatus.completed:
      case OrderStatus.cancelled:
      case OrderStatus.expired:
        return false;
    }
  }

  String get label {
    switch (this) {
      case OrderStatus.pending:
        return 'Pendiente';
      case OrderStatus.confirmed:
        return 'Confirmado';
      case OrderStatus.readyForPickup:
        return 'Listo para recoger';
      case OrderStatus.pickedUp:
        return 'Recogido';
      case OrderStatus.completed:
        return 'Completado';
      case OrderStatus.cancelled:
        return 'Cancelado';
      case OrderStatus.expired:
        return 'Expirado';
    }
  }

  bool get isTerminal =>
      this == OrderStatus.completed ||
      this == OrderStatus.cancelled ||
      this == OrderStatus.expired;

  bool get isActive =>
      !isTerminal;
}
