import 'package:flutter/material.dart';
import '../app/theme.dart';
import '../app/routes.dart';
import '../models/cart_item.dart';
import '../models/order.dart';
import '../services/cart_service.dart';

/// Helper formatting mata uang Rupiah
String formatRupiah(int amount) {
  final str = amount.toString();
  final buffer = StringBuffer();
  for (int i = 0; i < str.length; i++) {
    if (i > 0 && (str.length - i) % 3 == 0) {
      buffer.write('.');
    }
    buffer.write(str[i]);
  }
  return 'Rp${buffer.toString()}';
}

/// Helper resolve icon obat
IconData resolveMedicineIcon(String? iconType) {
  switch (iconType) {
    case 'pill':
      return Icons.medication_rounded;
    case 'capsule':
      return Icons.vaccines_rounded;
    case 'syrup':
      return Icons.liquor_rounded;
    case 'tablet':
      return Icons.circle_outlined;
    case 'cream':
      return Icons.clean_hands_rounded;
    default:
      return Icons.medication_liquid_rounded;
  }
}

// ─── Cart Badge Icon di AppBar ────────────────────────────────────────────────
class CartBadgeIcon extends StatelessWidget {
  final Color iconColor;
  final VoidCallback? onTap;

  const CartBadgeIcon({
    super.key,
    this.iconColor = AppColors.textPrimary,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cartService = CartService();

    return ListenableBuilder(
      listenable: cartService,
      builder: (context, _) {
        final count = cartService.totalItemCount;

        return Stack(
          alignment: Alignment.center,
          children: [
            IconButton(
              icon: Icon(Icons.shopping_cart_outlined, color: iconColor),
              tooltip: 'Keranjang Belanja',
              onPressed: onTap ?? () => Navigator.of(context).pushNamed(AppRoutes.cart),
            ),
            if (count > 0)
              Positioned(
                top: 6,
                right: 6,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: AppColors.error,
                    shape: BoxShape.circle,
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 18,
                    minHeight: 18,
                  ),
                  child: Center(
                    child: Text(
                      count > 99 ? '99+' : '$count',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        height: 1,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

// ─── Cart Item Card ───────────────────────────────────────────────────────────
class CartItemCard extends StatelessWidget {
  final CartItem item;
  final ValueChanged<int> onQuantityChanged;
  final VoidCallback onDelete;

  const CartItemCard({
    super.key,
    required this.item,
    required this.onQuantityChanged,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final bool isMaxStock = item.quantity >= item.stock;
    final bool isMinQuantity = item.quantity <= 1;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Icon obat
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              gradient: AppColors.brandGradient,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              resolveMedicineIcon(item.imageIcon),
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(width: 12),

          // Detail info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.medicineName,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  item.unit,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  formatRupiah(item.price),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: AppColors.green,
                  ),
                ),
              ],
            ),
          ),

          // Controls (minus, quantity, plus, delete)
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // Tombol Delete
              IconButton(
                icon: const Icon(Icons.delete_outline_rounded,
                    size: 20, color: AppColors.error),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                onPressed: onDelete,
                tooltip: 'Hapus Item',
              ),
              const SizedBox(height: 8),

              // Quantity Stepper
              Container(
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Minus button
                    InkWell(
                      onTap: isMinQuantity
                          ? null
                          : () => onQuantityChanged(item.quantity - 1),
                      borderRadius: const BorderRadius.horizontal(
                          left: Radius.circular(20)),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        child: Icon(
                          Icons.remove_rounded,
                          size: 16,
                          color: isMinQuantity
                              ? AppColors.textHint
                              : AppColors.textPrimary,
                        ),
                      ),
                    ),

                    // Quantity text
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 6),
                      child: Text(
                        '${item.quantity}',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),

                    // Plus button
                    InkWell(
                      onTap: isMaxStock
                          ? null
                          : () => onQuantityChanged(item.quantity + 1),
                      borderRadius: const BorderRadius.horizontal(
                          right: Radius.circular(20)),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        child: Icon(
                          Icons.add_rounded,
                          size: 16,
                          color: isMaxStock
                              ? AppColors.textHint
                              : AppColors.green,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Order Card (Daftar Pesanan) ──────────────────────────────────────────────
class OrderCard extends StatelessWidget {
  final Order order;
  final VoidCallback onTap;

  const OrderCard({
    super.key,
    required this.order,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final status = order.orderStatus;
    final firstItem = order.items.isNotEmpty ? order.items.first : null;
    final extraCount = order.items.length - 1;

    final date = order.createdAt;
    final formattedDate =
        '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Row: Order ID & Status Badge
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      order.pickupMethod.icon,
                      size: 16,
                      color: AppColors.cyan,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      order.id,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: status.color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: status.color.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(status.icon, size: 12, color: status.color),
                      const SizedBox(width: 4),
                      Text(
                        status.label,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: status.color,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 6),
            Text(
              formattedDate,
              style: const TextStyle(
                fontSize: 11,
                color: AppColors.textHint,
              ),
            ),

            const Divider(height: 20, color: AppColors.border),

            // Item Preview
            if (firstItem != null)
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Icon(
                      resolveMedicineIcon(firstItem.imageIcon),
                      color: AppColors.green,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          firstItem.medicineName,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          '${firstItem.quantity}x • ${formatRupiah(firstItem.price)}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (extraCount > 0)
                    Text(
                      '+$extraCount item lain',
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.cyan,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                ],
              ),

            const SizedBox(height: 12),

            // Bottom: Total & Chevron
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Total Pembayaran',
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    Text(
                      formatRupiah(order.total),
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: AppColors.green,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: const [
                    Text(
                      'Lihat Detail',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.cyan,
                      ),
                    ),
                    SizedBox(width: 4),
                    Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 12,
                      color: AppColors.cyan,
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Timeline Status Pesanan ──────────────────────────────────────────────────
class OrderStatusTimeline extends StatelessWidget {
  final Order order;

  const OrderStatusTimeline({
    super.key,
    required this.order,
  });

  @override
  Widget build(BuildContext context) {
    final isPickup = order.pickupMethod == PickupMethod.pickup;
    final status = order.orderStatus;
    final isCancelled = status == OrderStatus.cancelled;

    if (isCancelled) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.error.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.error.withValues(alpha: 0.2)),
        ),
        child: const Row(
          children: [
            Icon(Icons.cancel_rounded, color: AppColors.error, size: 24),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                'Pesanan ini telah dibatalkan.',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.error,
                ),
              ),
            ),
          ],
        ),
      );
    }

    // Steps list
    final List<_StepItem> steps = [
      const _StepItem(title: 'Pesanan Dibuat', subtitle: 'Pesanan diterima'),
      _StepItem(
        title: 'Pembayaran',
        subtitle: order.paymentStatus == PaymentStatus.paid
            ? 'Pembayaran Berhasil'
            : (order.paymentMethod == PaymentMethod.payAtPharmacy
                ? 'Bayar di Apotek'
                : 'Menunggu Pembayaran'),
      ),
      const _StepItem(
          title: 'Diproses', subtitle: 'Obat disiapkan apoteker'),
      _StepItem(
        title: isPickup ? 'Siap Diambil' : 'Sedang Dikirim',
        subtitle: isPickup
            ? 'Dapat diambil di apotek'
            : 'Dalam perjalanan oleh kurir',
      ),
      const _StepItem(
          title: 'Selesai', subtitle: 'Pesanan telah diterima'),
    ];

    // Determine active step index (0 to 4)
    int activeIndex = 0;
    switch (status) {
      case OrderStatus.pending:
        activeIndex = (order.paymentStatus == PaymentStatus.paid) ? 2 : 1;
        break;
      case OrderStatus.processing:
        activeIndex = 2;
        break;
      case OrderStatus.ready:
      case OrderStatus.shipping:
        activeIndex = 3;
        break;
      case OrderStatus.completed:
        activeIndex = 4;
        break;
      case OrderStatus.cancelled:
        activeIndex = 0;
        break;
    }

    return Column(
      children: List.generate(steps.length, (index) {
        final step = steps[index];
        final isCompleted = index <= activeIndex;
        final isCurrent = index == activeIndex;
        final isLast = index == steps.length - 1;

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Indicator and Line
            Column(
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: isCompleted
                        ? (isCurrent ? AppColors.green : AppColors.cyan)
                        : AppColors.background,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isCompleted ? Colors.transparent : AppColors.border,
                      width: 2,
                    ),
                  ),
                  child: Center(
                    child: isCompleted
                        ? const Icon(Icons.check, size: 14, color: Colors.white)
                        : Text(
                            '${index + 1}',
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textHint,
                            ),
                          ),
                  ),
                ),
                if (!isLast)
                  Container(
                    width: 2,
                    height: 36,
                    color: index < activeIndex
                        ? AppColors.cyan
                        : AppColors.border,
                  ),
              ],
            ),
            const SizedBox(width: 14),

            // Text
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      step.title,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight:
                            isCurrent ? FontWeight.w800 : FontWeight.w600,
                        color: isCompleted
                            ? AppColors.textPrimary
                            : AppColors.textHint,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      step.subtitle,
                      style: TextStyle(
                        fontSize: 11,
                        color: isCompleted
                            ? AppColors.textSecondary
                            : AppColors.textHint,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      }),
    );
  }
}

class _StepItem {
  final String title;
  final String subtitle;
  const _StepItem({required this.title, required this.subtitle});
}
