// lib/screens/cart_screen.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/cart_provider.dart';
import '../providers/transaction_provider.dart';
import '../models/transaction.dart';
import '../models/transaction_detail.dart';
import 'package:intl/intl.dart';
import '../widgets/cart_item.dart'; // Pastikan import widget yang benar

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final TextEditingController _cashController = TextEditingController();
  final NumberFormat _formatter =
      NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Keranjang'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Consumer<CartProvider>(
        builder: (context, cartProvider, child) {
          if (cartProvider.items.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.shopping_cart_outlined,
                      size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'Keranjang kosong',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Pilih menu untuk menambahkan ke keranjang',
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: cartProvider.items.length,
                  itemBuilder: (context, index) {
                    final cartItem = cartProvider.items[index];
                    // PERBAIKAN DI SINI: Menggunakan widget CartItemWidget yang sudah dibuat
                    return CartItemWidget(cartItem: cartItem);
                  },
                ),
              ),
              // Bagian Summary
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.3),
                      spreadRadius: 1,
                      blurRadius: 5,
                      offset: const Offset(0, -3),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Total Harga:',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          _formatter.format(cartProvider.totalPrice),
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _cashController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Uang Tunai',
                        hintText: 'Masukkan jumlah uang tunai',
                        prefixText: 'Rp ',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: () => _processPayment(context, cartProvider),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text(
                          'BAYAR',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _processPayment(BuildContext context, CartProvider cartProvider) async {
    if (_cashController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Masukkan jumlah uang tunai'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final cashReceived =
        int.tryParse(_cashController.text.replaceAll('.', '').replaceAll(',', ''));
    if (cashReceived == null || cashReceived < cartProvider.totalPrice) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Jumlah uang tunai tidak mencukupi'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final change = cashReceived - cartProvider.totalPrice;

    // Buat transaksi
    final transaction = Transaction(
      totalAmount: cartProvider.totalPrice,
      cashReceived: cashReceived,
      changeGiven: change,
      createdAt: DateTime.now().toIso8601String(),
    );

    // Buat detail transaksi
    final details = cartProvider.items.map((cartItem) {
      return TransactionDetail(
        transactionId: 0, // Akan diperbarui setelah penyisipan
        menuItemId: cartItem.menuItem.id!,
        quantity: cartItem.quantity,
        pricePerItem: cartItem.menuItem.price,
      );
    }).toList();

    try {
      await context.read<TransactionProvider>().addTransaction(transaction, details);

      // Tampilkan dialog sukses
      if (context.mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return AlertDialog(
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.check_circle,
                    color: Colors.green,
                    size: 64,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Pembayaran Berhasil!',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Kembalian: ${_formatter.format(change)}',
                    style: const TextStyle(fontSize: 16),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    cartProvider.clearCart();
                    _cashController.clear();
                  },
                  child: const Text('OK'),
                ),
              ],
            );
          },
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal memproses pembayaran: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _cashController.dispose();
    super.dispose();
  }
}