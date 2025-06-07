import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../providers/cart_provider.dart';

// Nama widget diubah menjadi CartItemWidget untuk menghindari konflik nama dengan model CartItem
class CartItemWidget extends StatelessWidget {
  final CartItem cartItem;

  const CartItemWidget({
    super.key,
    required this.cartItem,
  });

  @override
  Widget build(BuildContext context) {
    final cartProvider = context.read<CartProvider>();
    final formatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            // Gambar kecil
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: SizedBox(
                width: 60,
                height: 60,
                child: cartItem.menuItem.imagePath.isNotEmpty && File(cartItem.menuItem.imagePath).existsSync()
                    ? Image.file(
                        File(cartItem.menuItem.imagePath),
                        fit: BoxFit.cover,
                      )
                    : Container(
                        color: Colors.grey[200],
                        child: Icon(Icons.fastfood, color: Colors.grey[400]),
                      ),
              ),
            ),
            const SizedBox(width: 12),
            // Nama dan Harga
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    cartItem.menuItem.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(formatter.format(cartItem.menuItem.price)),
                ],
              ),
            ),
            // Kontrol Kuantitas (+ dan -)
            Row(
              children: [
                IconButton(
                  onPressed: () => cartProvider.removeItem(cartItem.menuItem),
                  icon: const Icon(Icons.remove_circle_outline),
                  color: Colors.red,
                ),
                Text(
                  '${cartItem.quantity}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  onPressed: () => cartProvider.addItem(cartItem.menuItem),
                  icon: const Icon(Icons.add_circle_outline),
                  color: Colors.green,
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}