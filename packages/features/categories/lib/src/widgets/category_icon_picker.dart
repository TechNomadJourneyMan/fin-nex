// Grid picker for the icon assigned to a category.
//
// Uses a fixed Material icon subset so the same key/icon mapping is
// portable across Web and mobile (no asset bundling required).

import 'package:flutter/material.dart';
import 'package:fnx_core_widgets/fnx_core_widgets.dart';

/// Maps an icon key to its [IconData] glyph.
IconData fnxCategoryIconFor(String key) =>
    fnxCategoryIcons[key] ?? Icons.category_outlined;

/// All keys and icons offered by [CategoryIconPicker], in display order.
const Map<String, IconData> fnxCategoryIcons = <String, IconData>{
  'category': Icons.category_outlined,
  'restaurant': Icons.restaurant,
  'fastfood': Icons.fastfood,
  'local_cafe': Icons.local_cafe,
  'local_bar': Icons.local_bar,
  'local_pizza': Icons.local_pizza,
  'local_grocery_store': Icons.local_grocery_store,
  'shopping_cart': Icons.shopping_cart,
  'shopping_bag': Icons.shopping_bag,
  'storefront': Icons.storefront,
  'checkroom': Icons.checkroom,
  'directions_car': Icons.directions_car,
  'local_taxi': Icons.local_taxi,
  'directions_bus': Icons.directions_bus,
  'directions_subway': Icons.directions_subway,
  'directions_bike': Icons.directions_bike,
  'two_wheeler': Icons.two_wheeler,
  'local_gas_station': Icons.local_gas_station,
  'flight': Icons.flight,
  'train': Icons.train,
  'hotel': Icons.hotel,
  'beach_access': Icons.beach_access,
  'home': Icons.home,
  'apartment': Icons.apartment,
  'bed': Icons.bed,
  'chair': Icons.chair,
  'cleaning_services': Icons.cleaning_services,
  'electrical_services': Icons.electrical_services,
  'plumbing': Icons.plumbing,
  'water_drop': Icons.water_drop,
  'bolt': Icons.bolt,
  'phone': Icons.phone,
  'wifi': Icons.wifi,
  'router': Icons.router,
  'tv': Icons.tv,
  'computer': Icons.computer,
  'devices': Icons.devices,
  'subscriptions': Icons.subscriptions,
  'music_note': Icons.music_note,
  'movie': Icons.movie,
  'sports_esports': Icons.sports_esports,
  'fitness_center': Icons.fitness_center,
  'sports_soccer': Icons.sports_soccer,
  'spa': Icons.spa,
  'self_improvement': Icons.self_improvement,
  'cut': Icons.content_cut,
  'face': Icons.face,
  'medical_services': Icons.medical_services,
  'local_pharmacy': Icons.local_pharmacy,
  'local_hospital': Icons.local_hospital,
  'vaccines': Icons.vaccines,
  'school': Icons.school,
  'menu_book': Icons.menu_book,
  'work': Icons.work,
  'business_center': Icons.business_center,
  'savings': Icons.savings,
  'attach_money': Icons.attach_money,
  'paid': Icons.paid,
  'redeem': Icons.redeem,
  'card_giftcard': Icons.card_giftcard,
  'volunteer_activism': Icons.volunteer_activism,
  'pets': Icons.pets,
  'child_care': Icons.child_care,
  'toys': Icons.toys,
  'receipt_long': Icons.receipt_long,
  'request_quote': Icons.request_quote,
  'account_balance': Icons.account_balance,
  'account_balance_wallet': Icons.account_balance_wallet,
  'credit_card': Icons.credit_card,
};

/// Grid picker that lets the user choose an icon for a category.
class CategoryIconPicker extends StatelessWidget {
  /// Creates an icon picker.
  const CategoryIconPicker({
    super.key,
    required this.selectedKey,
    required this.onSelected,
  });

  /// The currently selected icon key.
  final String selectedKey;

  /// Called when an icon is tapped.
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    final colors = context.fnxColors;
    final radii = context.fnxRadii;
    final entries = fnxCategoryIcons.entries.toList(growable: false);

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 6,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
        childAspectRatio: 1,
      ),
      itemCount: entries.length,
      itemBuilder: (context, i) {
        final e = entries[i];
        final selected = e.key == selectedKey;
        return Semantics(
          button: true,
          selected: selected,
          label: e.key,
          child: Material(
            color: selected ? colors.brandSubtle : colors.surface,
            shape: RoundedRectangleBorder(
              side: BorderSide(
                color: selected ? colors.brand : colors.borderSubtle,
                width: selected ? 2 : 1,
              ),
              borderRadius: BorderRadius.circular(radii.r3),
            ),
            child: InkWell(
              borderRadius: BorderRadius.circular(radii.r3),
              onTap: () => onSelected(e.key),
              child: Center(
                child: Icon(
                  e.value,
                  color: selected ? colors.brand : colors.textPrimary,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
