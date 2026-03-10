import 'package:flutter/material.dart';

class CategoryModel {
  final String name;
  final String label;
  final String icon;
  final Color color;

  CategoryModel({
    required this.name,
    required this.label,
    required this.icon,
    required this.color,
  });
}

final List<CategoryModel> categories = [
  CategoryModel(
    name: "Breakfast",
    label: "Bữa sáng",
    icon: "🍳",
    color: Color(0xFFFFF3E0),
  ),
  CategoryModel(
    name: "Chicken",
    label: "Món gà",
    icon: "🍗",
    color: Color(0xFFFFEBEE),
  ),
  CategoryModel(
    name: "Beef",
    label: "Thịt bò",
    icon: "🥩",
    color: Color(0xFFFFEBEE),
  ),
  CategoryModel(
    name: "Fish",
    label: "Món cá",
    icon: "🐟",
    color: Color(0xFFE3F2FD),
  ),
  CategoryModel(
    name: "Pasta",
    label: "Món mì",
    icon: "🍜",
    color: Color(0xFFFFF8E1),
  ),
  CategoryModel(
    name: "Salad",
    label: "Salad",
    icon: "🥗",
    color: Color(0xFFE8F5E9),
  ),
  CategoryModel(
    name: "Rice",
    label: "Cơm",
    icon: "🍚",
    color: Color(0xFFFCE4EC),
  ),
  CategoryModel(
    name: "Vegan",
    label: "Món chay",
    icon: "🥬",
    color: Color(0xFFE8F5E9),
  ),
  CategoryModel(
    name: "Pizza",
    label: "Pizza",
    icon: "🍕",
    color: Color(0xFFFFF3E0),
  ),
];