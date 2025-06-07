import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/table_provider.dart';
import '../models/restaurant_table.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final TextEditingController _tableNameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manajemen Meja'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Consumer<TableProvider>(
        builder: (context, tableProvider, child) {
          if (tableProvider.tables.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.table_restaurant, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'Belum ada meja tersedia',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: tableProvider.tables.length,
            itemBuilder: (context, index) {
              final table = tableProvider.tables[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: _getStatusColor(table.status),
                    child: const Icon(
                      Icons.table_restaurant,
                      color: Colors.white,
                    ),
                  ),
                  title: Text(
                    table.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Text(
                    table.status,
                    style: TextStyle(
                      color: _getStatusColor(table.status),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  trailing: PopupMenuButton<String>(
                    onSelected: (String value) {
                      if (value == 'delete') {
                        _deleteTable(context, tableProvider, table);
                      } else {
                        _updateTableStatus(tableProvider, table, value);
                      }
                    },
                    itemBuilder: (BuildContext context) => [
                      const PopupMenuItem<String>(
                        value: 'Kosong',
                        child: Text('Kosong'),
                      ),
                      const PopupMenuItem<String>(
                        value: 'Belum Bayar',
                        child: Text('Belum Bayar'),
                      ),
                      const PopupMenuItem<String>(
                        value: 'Sudah Bayar',
                        child: Text('Sudah Bayar'),
                      ),
                      const PopupMenuDivider(),
                      const PopupMenuItem<String>(
                        value: 'delete',
                        child: Text(
                          'Hapus Meja',
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddTableDialog(context),
        backgroundColor: Colors.blue,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Kosong':
        return Colors.green;
      case 'Belum Bayar':
        return Colors.orange;
      case 'Sudah Bayar':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  void _updateTableStatus(TableProvider provider, RestaurantTable table, String newStatus) {
    final updatedTable = RestaurantTable(
      id: table.id,
      name: table.name,
      status: newStatus,
    );
    provider.updateTable(updatedTable);
  }

  void _deleteTable(BuildContext context, TableProvider provider, RestaurantTable table) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Hapus Meja'),
          content: Text('Apakah Anda yakin ingin menghapus ${table.name}?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Batal'),
            ),
            TextButton(
              onPressed: () {
                provider.deleteTable(table.id!);
                Navigator.of(context).pop();
              },
              child: const Text('Hapus', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  void _showAddTableDialog(BuildContext context) {
    _tableNameController.clear();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Tambah Meja Baru'),
          content: TextField(
            controller: _tableNameController,
            decoration: const InputDecoration(
              labelText: 'Nama Meja',
              hintText: 'Contoh: Meja 3',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Batal'),
            ),
            TextButton(
              onPressed: () {
                if (_tableNameController.text.trim().isNotEmpty) {
                  final newTable = RestaurantTable(
                    name: _tableNameController.text.trim(),
                    status: 'Kosong',
                  );
                  context.read<TableProvider>().addTable(newTable);
                  Navigator.of(context).pop();
                }
              },
              child: const Text('Tambah'),
            ),
          ],
        );
      },
    );
  }
}