import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/menu_item.dart';
import '../providers/cart_provider.dart';

class MenuCard extends StatelessWidget {
  final MenuItem menuItem;

  const MenuCard({
    super.key,
    required this.menuItem,
  });

  @override
  Widget build(BuildContext context) {
    // Formatter untuk menampilkan harga dalam format Rupiah
    final formatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    return Card(
      elevation: 4,
      clipBehavior: Clip.antiAlias, // Memastikan gambar mengikuti bentuk rounded card
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          // Menambahkan item ke keranjang saat kartu ditekan
          context.read<CartProvider>().addItem(menuItem);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${menuItem.name} ditambahkan ke keranjang'),
              duration: const Duration(seconds: 1),
              behavior: SnackBarBehavior.floating,
            ),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Bagian untuk menampilkan gambar
            Expanded(
              flex: 3,
              child: Hero(
                tag: 'menu_item_${menuItem.id}', // Tag unik untuk animasi
                child: menuItem.imagePath.isNotEmpty && File(menuItem.imagePath).existsSync()
                    ? Image.file(
                        File(menuItem.imagePath),
                        fit: BoxFit.cover,
                      )
                    // Tampilan placeholder jika gambar tidak ada/gagal dimuat
                    : Container(
                        color: Colors.grey[200],
                        child: Icon(
                          Icons.fastfood,
                          size: 48,
                          color: Colors.grey[400],
                        ),
                      ),
              ),
            ),
            // Bagian untuk menampilkan teks nama dan harga
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      menuItem.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const Spacer(),
                    Text(
                      formatter.format(menuItem.price),
                      style: TextStyle(
                        fontSize: 14,
                        color: Theme.of(context).primaryColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}