import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:route_store_module/entity/store_entity.dart';
import 'package:route_store_module/logic_data/realtime_data.dart';
import 'package:route_store_module/logic_uc/search_store_uc.dart';
import 'package:core/theme/theme.dart';

class StoreListView extends ConsumerWidget {
  final VoidCallback? onAdd;
  final Function(StoreEntity)? onEdit;
  final VoidCallback? onBack;

  const StoreListView({super.key, this.onAdd, this.onEdit, this.onBack});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final storesAsync = ref.watch(realtimeStoresProvider);
    final searchQuery = ref.watch(searchQueryProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.onSurface, size: 20),
          onPressed: () {
            if (onBack != null) {
              onBack!();
            } else {
              Navigator.maybePop(context);
            }
          },
        ),
        title: Text(
          'Cửa hàng',
          style: AppTextStyles.headlineSm.copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: false,
      ),
      body: RefreshIndicator(
        color: AppColors.secondary,
        onRefresh: () async {
          ref.invalidate(realtimeStoresProvider);
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.only(
            top: AppSpacing.lg,
            left: AppSpacing.containerMargin,
            right: AppSpacing.containerMargin,
            bottom: 100,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Search Bar
              _buildSearchBar(ref, searchQuery),
              const SizedBox(height: AppSpacing.xxl),

              // Stats Cards
              storesAsync.maybeWhen(
                data: (stores) => _buildStatsRow(stores.length),
                orElse: () => _buildStatsRow(0),
              ),
              const SizedBox(height: AppSpacing.xxl),

                        // Store List
                        storesAsync.when(
                          loading: () => const Center(
                            child: Padding(
                              padding: EdgeInsets.only(top: 40),
                              child: CircularProgressIndicator(),
                            ),
                          ),
                          error: (err, _) => Center(
                            child: Padding(
                              padding: const EdgeInsets.only(top: 40),
                              child: Text('Lỗi: $err'),
                            ),
                          ),
                          data: (stores) {
                            if (stores.isEmpty) {
                              return const Center(
                                child: Padding(
                                  padding: EdgeInsets.only(top: 40),
                                  child: Text('Không tìm thấy cửa hàng nào'),
                                ),
                              );
                            }
                            return ListView.separated(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: stores.length,
                              separatorBuilder: (_, __) =>
                                  const SizedBox(height: 16),
                              itemBuilder: (context, index) {
                                return _StoreCard(
                                  store: stores[index],
                                  onEdit: onEdit,
                                );
                              },
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: onAdd,
        backgroundColor: AppColors.primary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
        ),
        child: const Icon(Icons.add_rounded, color: AppColors.white),
      ),
    );
  }

  Widget _buildSearchBar(WidgetRef ref, String query) {
    return Container(
      width: double.infinity,
      height: 48,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        boxShadow: AppShadows.level1,
      ),
      child: TextField(
        onChanged: (value) {
          ref.read(searchQueryProvider.notifier).state = value;
        },
        controller: TextEditingController(text: query)..selection = TextSelection.fromPosition(TextPosition(offset: query.length)),
        style: AppTextStyles.bodyLg.copyWith(color: AppColors.onSurface),
        decoration: InputDecoration(
          hintText: 'Tìm kiếm cửa hàng...',
          hintStyle: AppTextStyles.bodyLg.copyWith(color: AppColors.onSurfaceVariant),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 12),
          prefixIcon: const Icon(Icons.search_rounded, color: AppColors.onSurfaceVariant, size: 20),
        ),
      ),
    );
  }

  Widget _buildStatsRow(int totalStores) {
    final visitedCount = (totalStores * 0.35).round(); // Mockup visited stats

    return Row(
      children: [
        // Left Card — Tổng cửa hàng
        Expanded(
          child: Container(
            height: 90,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
            ),
            child: Stack(
              children: [
                Positioned(
                  right: -8,
                  bottom: -8,
                  child: Icon(
                    Icons.storefront_outlined,
                    color: AppColors.white.withValues(alpha: 0.15),
                    size: 56,
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'TỔNG CỬA HÀNG',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.white.withValues(alpha: 0.7),
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                    Text(
                      '$totalStores',
                      style: AppTextStyles.headlineLg.copyWith(
                        color: AppColors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.gridGutter),
        // Right Card — Đã viếng thăm
        Expanded(
          child: Container(
            height: 90,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLow,
              borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
            ),
            child: Stack(
              children: [
                Positioned(
                  right: -8,
                  bottom: -8,
                  child: Icon(
                    Icons.check_circle_outline,
                    color: AppColors.secondary.withValues(alpha: 0.1),
                    size: 56,
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'ĐÃ VIẾNG THĂM',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.onSurfaceVariant,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                    Text(
                      '$visitedCount/$totalStores',
                      style: AppTextStyles.headlineLg.copyWith(
                        color: AppColors.secondary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _StoreCard extends StatelessWidget {
  final StoreEntity store;
  final Function(StoreEntity)? onEdit;

  const _StoreCard({required this.store, this.onEdit});

  @override
  Widget build(BuildContext context) {
    // Generate dynamic badge based on store ID
    final int storeId = store.id ?? 0;
    final Widget statusBadge;
    if (storeId % 3 == 0) {
      statusBadge = Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        decoration: BoxDecoration(
          color: AppColors.statusRejectedBg,
          borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
        ),
        child: Text(
          'NỢ QUÁ HẠN',
          style: AppTextStyles.labelMd.copyWith(
            color: AppColors.statusRejectedText,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    } else if (storeId % 3 == 1) {
      statusBadge = Text(
        'Cửa hàng trọng điểm',
        style: AppTextStyles.labelMd.copyWith(
          color: AppColors.secondary,
          fontWeight: FontWeight.w600,
        ),
      );
    } else {
      statusBadge = Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainer,
          borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
        ),
        child: Text(
          'KHÁCH HÀNG MỚI',
          style: AppTextStyles.labelMd.copyWith(
            color: AppColors.secondary,
            fontWeight: FontWeight.w600,
          ),
        ),
      );
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        boxShadow: AppShadows.level1,
      ),
      child: Stack(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            store.storeName,
                            style: AppTextStyles.bodyLg.copyWith(
                              color: AppColors.onSurface,
                              fontWeight: FontWeight.w600,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.location_on_outlined, size: 16, color: AppColors.secondary),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            store.address,
                            style: AppTextStyles.bodyMd.copyWith(
                              color: AppColors.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: AppSpacing.md,
                      runSpacing: AppSpacing.xs,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceContainerLow,
                            borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.sensors_outlined,
                                size: 14,
                                color: AppColors.secondary,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${store.latitude.toStringAsFixed(4)}° N, ${store.longitude.toStringAsFixed(4)}° E',
                                style: AppTextStyles.caption.copyWith(
                                  color: AppColors.onSurfaceVariant,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                        statusBadge,
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 32), // space for popup menu button
            ],
          ),
          Positioned(
            right: -8,
            top: -8,
            child: PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert_rounded, color: AppColors.onSurfaceVariant, size: 20),
              onSelected: (value) {
                if (value == 'edit') {
                  if (onEdit != null) onEdit!(store);
                } else if (value == 'hide') {
                  // Implement hide logic if needed
                }
              },
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: 'edit',
                  child: Row(
                    children: [
                      const Icon(Icons.edit_outlined, size: 20, color: AppColors.onSurface),
                      const SizedBox(width: 8),
                      Text('Sửa cửa hàng', style: AppTextStyles.bodyMd.copyWith(color: AppColors.onSurface)),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'hide',
                  child: Row(
                    children: [
                      const Icon(Icons.visibility_off_outlined, size: 20, color: AppColors.error),
                      const SizedBox(width: 8),
                      Text('Ẩn cửa hàng', style: AppTextStyles.bodyMd.copyWith(color: AppColors.error)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
