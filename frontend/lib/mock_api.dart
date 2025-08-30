import 'dart:async';
import 'models.dart';

class MockApi {
  // pretend this is fetched from server
  static final List<Product> products = [
    Product(
      id: 'p1',
      name: 'Margherita Pizza',
      description: 'Classic cheese pizza with basil.',
      price: 249.0,
      imageUrl: 'https://picsum.photos/seed/pizza/600/400',
      category: 'Pizza',
    ),
    Product(
      id: 'p2',
      name: 'Veggie Burger',
      description: 'Crispy patty with fresh veggies.',
      price: 179.0,
      imageUrl: 'https://picsum.photos/seed/burger/600/400',
      category: 'Burgers',
    ),
    Product(
      id: 'p3',
      name: 'Paneer Tikka Roll',
      description: 'Spiced paneer wrapped in soft roti.',
      price: 149.0,
      imageUrl: 'https://picsum.photos/seed/roll/600/400',
      category: 'Rolls',
    ),
    Product(
      id: 'p4',
      name: 'Masala Dosa',
      description: 'South Indian classic with chutneys.',
      price: 129.0,
      imageUrl: 'https://picsum.photos/seed/dosa/600/400',
      category: 'South Indian',
    ),
    Product(
      id: 'p5',
      name: 'Chicken Biryani',
      description: 'Aromatic basmati with chicken.',
      price: 299.0,
      imageUrl: 'https://picsum.photos/seed/biryani/600/400',
      category: 'Biryani',
    ),
    Product(
      id: 'p6',
      name: 'Cold Coffee',
      description: 'Iced coffee with cream.',
      price: 99.0,
      imageUrl: 'https://picsum.photos/seed/coffee/600/400',
      category: 'Beverages',
    ),
    Product(
      id: 'p7',
      name: 'French Fries',
      description: 'Crispy potato fries.',
      price: 79.0,
      imageUrl: 'https://picsum.photos/seed/fries/600/400',
      category: 'Snacks',
    ),
    Product(
      id: 'p8',
      name: 'Chole Bhature',
      description: 'Spicy chickpeas with fried bread.',
      price: 159.0,
      imageUrl: 'https://picsum.photos/seed/chole/600/400',
      category: 'North Indian',
    ),
    Product(
      id: 'p9',
      name: 'Pasta Alfredo',
      description: 'Creamy white sauce pasta.',
      price: 199.0,
      imageUrl: 'https://picsum.photos/seed/pasta/600/400',
      category: 'Italian',
    ),
    Product(
      id: 'p10',
      name: 'Momos',
      description: 'Steamed dumplings with dip.',
      price: 99.0,
      imageUrl: 'https://picsum.photos/seed/momos/600/400',
      category: 'Snacks',
    ),
    Product(
      id: 'p11',
      name: 'Tandoori Chicken',
      description: 'Smoky, spicy and juicy.',
      price: 329.0,
      imageUrl: 'https://picsum.photos/seed/tandoori/600/400',
      category: 'Grill',
    ),
    Product(
      id: 'p12',
      name: 'Falooda',
      description: 'Royal dessert drink.',
      price: 129.0,
      imageUrl: 'https://picsum.photos/seed/falooda/600/400',
      category: 'Dessert',
    ),
  ];

  static Future<List<Product>> fetchProducts() async {
    await Future.delayed(const Duration(milliseconds: 600));
    return products;
  }

  static Future<List<Product>> search(String query) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final q = query.toLowerCase().trim();
    if (q.isEmpty) return products;
    return products
        .where((p) =>
            p.name.toLowerCase().contains(q) ||
            p.category.toLowerCase().contains(q))
        .toList();
  }
}