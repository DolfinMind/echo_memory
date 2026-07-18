/// Power-up model for Echo Memory
/// Defines power-ups with their effects and costs
library;

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import '../../config/theme/app_colors.dart';

enum PowerUpType { slowMotion, hint, shield, timeFreeze, doublePoints }

class PowerUp {
  final PowerUpType type;
  final String name;
  final String description;
  final IconData icon;
  final Color color;
  final int cost;
  final int durationSeconds;
  final int quantity;

  const PowerUp({
    required this.type,
    required this.name,
    required this.description,
    required this.icon,
    required this.color,
    required this.cost,
    this.durationSeconds = 0,
    this.quantity = 0,
  });

  PowerUp copyWith({int? quantity}) {
    return PowerUp(
      type: type,
      name: name,
      description: description,
      icon: icon,
      color: color,
      cost: cost,
      durationSeconds: durationSeconds,
      quantity: quantity ?? this.quantity,
    );
  }

  /// All available power-ups
  static List<PowerUp> get allPowerUps => [
    const PowerUp(
      type: PowerUpType.slowMotion,
      name: 'Slow Motion',
      description: 'Slows pattern display by 50%',
      icon: LucideIcons.gauge,
      color: AppColors.powerUpSlowMo,
      cost: 100,
      durationSeconds: 10,
    ),
    const PowerUp(
      type: PowerUpType.hint,
      name: 'Hint',
      description: 'Highlights next 2 colors',
      icon: LucideIcons.lightbulb,
      color: AppColors.powerUpHint,
      cost: 150,
    ),
    const PowerUp(
      type: PowerUpType.shield,
      name: 'Shield',
      description: 'Prevents one mistake',
      icon: LucideIcons.shield,
      color: AppColors.powerUpShield,
      cost: 200,
    ),
    const PowerUp(
      type: PowerUpType.timeFreeze,
      name: 'Time Freeze',
      description: 'Pauses timer for 5 seconds',
      icon: LucideIcons.snowflake,
      color: AppColors.powerUpFreeze,
      cost: 250,
      durationSeconds: 5,
    ),
    const PowerUp(
      type: PowerUpType.doublePoints,
      name: 'Double Points',
      description: '2x points for next sequence',
      icon: LucideIcons.star,
      color: AppColors.powerUpDouble,
      cost: 300,
      durationSeconds: 15,
    ),
  ];

  /// Get power-up by type
  static PowerUp getByType(PowerUpType type) {
    return allPowerUps.firstWhere((p) => p.type == type);
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {'type': type.index, 'quantity': quantity};
  }

  /// Create from JSON
  factory PowerUp.fromJson(Map<String, dynamic> json) {
    final type = PowerUpType.values[json['type'] ?? 0];
    final basePowerUp = getByType(type);
    return basePowerUp.copyWith(quantity: json['quantity'] ?? 0);
  }
}

/// Player's power-up inventory
class PowerUpInventory {
  final Map<PowerUpType, int> quantities;

  const PowerUpInventory({this.quantities = const {}});

  /// Get quantity of a specific power-up
  int getQuantity(PowerUpType type) => quantities[type] ?? 0;

  /// Check if player has a power-up
  bool hasPowerUp(PowerUpType type) => getQuantity(type) > 0;

  /// Add power-up to inventory
  PowerUpInventory addPowerUp(PowerUpType type, {int count = 1}) {
    final newQuantities = Map<PowerUpType, int>.from(quantities);
    newQuantities[type] = (newQuantities[type] ?? 0) + count;
    return PowerUpInventory(quantities: newQuantities);
  }

  /// Use a power-up (decrements count)
  PowerUpInventory usePowerUp(PowerUpType type) {
    if (!hasPowerUp(type)) return this;
    final newQuantities = Map<PowerUpType, int>.from(quantities);
    newQuantities[type] = newQuantities[type]! - 1;
    if (newQuantities[type]! <= 0) {
      newQuantities.remove(type);
    }
    return PowerUpInventory(quantities: newQuantities);
  }

  /// Get total power-ups count
  int get totalCount => quantities.values.fold(0, (a, b) => a + b);

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return quantities.map(
      (key, value) => MapEntry(key.index.toString(), value),
    );
  }

  /// Create from JSON
  factory PowerUpInventory.fromJson(Map<String, dynamic> json) {
    final quantities = <PowerUpType, int>{};
    json.forEach((key, value) {
      final index = int.tryParse(key);
      if (index != null && index < PowerUpType.values.length) {
        quantities[PowerUpType.values[index]] = value as int;
      }
    });
    return PowerUpInventory(quantities: quantities);
  }

  /// Encode to string
  String encode() => jsonEncode(toJson());

  /// Decode from string
  factory PowerUpInventory.decode(String source) {
    return PowerUpInventory.fromJson(jsonDecode(source));
  }
}
