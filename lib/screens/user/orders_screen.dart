import 'package:flutter/material.dart';
import '../../app/theme.dart';
import '../../app/routes.dart';
import '../../models/order.dart';
import '../../services/order_service.dart';
import '../../widgets/order_widgets.dart';

/// Halaman Riwayat & Daftar Pesanan Saya
class OrdersScreen extends StatefulWidget {
  final bool isTab;

  const OrdersScreen({super.key, this.isTab = false});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  int _selectedFilterIndex = 0;

  static const List<String> _filters = [
    'Semua',
    'Menunggu Bayar',
    'Diproses',
    'Siap / Dikirim',
    'Selesai',
    'Dibatalkan',
  ];

  @override
  Widget build(BuildContext context) {
    final orderService = OrderService();

    final bodyContent = ListenableBuilder(
      listenable: orderService,
      builder: (context, _) {
        final allOrders = orderService.orders;

        final filteredOrders = allOrders.where((order) {
          switch (_selectedFilterIndex) {
            case 0: // Semua
              return true;
            case 1: // Menunggu Bayar
              return order.orderStatus == OrderStatus.pending;
            case 2: // Diproses
              return order.orderStatus == OrderStatus.processing;
            case 3: // Siap / Dikirim
              return order.orderStatus == OrderStatus.ready ||
                  order.orderStatus == OrderStatus.shipping;
            case 4: // Selesai
              return order.orderStatus == OrderStatus.completed;
            case 5: // Dibatalkan
              return order.orderStatus == OrderStatus.cancelled;
            default:
              return true;
          }
        }).toList();

        return Column(
          children: [
            // ── Horizontal Filter Chips ────────────────────────────────────
            SizedBox(
              height: 48,
              child: ListView.separated(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                scrollDirection: Axis.horizontal,
                itemCount: _filters.length,
                separatorBuilder: (context, index) => const SizedBox(width: 8),
                itemBuilder: (context, i) {
                  final isSelected = _selectedFilterIndex == i;
                  return InkWell(
                    onTap: () => setState(() => _selectedFilterIndex = i),
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.green
                            : AppColors.surface,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSelected
                              ? AppColors.green
                              : AppColors.border,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          _filters[i],
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: isSelected
                                ? FontWeight.w700
                                : FontWeight.w500,
                            color: isSelected
                                ? Colors.white
                                : AppColors.textPrimary,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            // ── List of Orders ─────────────────────────────────────────────
            Expanded(
              child: filteredOrders.isEmpty
                  ? _buildEmptyState(context)
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: filteredOrders.length,
                      itemBuilder: (context, index) {
                        final order = filteredOrders[index];
                        return OrderCard(
                          order: order,
                          onTap: () {
                            Navigator.of(context).pushNamed(
                              AppRoutes.orderDetail,
                              arguments: order.id,
                            );
                          },
                        );
                      },
                    ),
            ),
          ],
        );
      },
    );

    if (widget.isTab) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const Text('Pesanan Saya'),
          automaticallyImplyLeading: false,
          actions: const [
            CartBadgeIcon(),
            SizedBox(width: 8),
          ],
        ),
        body: bodyContent,
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Pesanan Saya'),
        actions: const [
          CartBadgeIcon(),
          SizedBox(width: 8),
        ],
      ),
      body: bodyContent,
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.cyan.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.receipt_long_outlined,
                size: 64,
                color: AppColors.cyan,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Belum ada pesanan',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),
            const Text(
              'Pesanan yang kamu buat akan muncul di sini.',
              style: TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.of(context).pushNamed(AppRoutes.catalog);
              },
              icon: const Icon(Icons.shopping_bag_outlined, size: 18),
              label: const Text('Mulai Belanja'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.green,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                textStyle: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
