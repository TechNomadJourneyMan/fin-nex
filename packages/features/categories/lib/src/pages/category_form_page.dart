// Create / edit page for a single category.
//
// Composes the name field, icon grid, and color swatches. The same page is
// reused for create and edit — passing an [id] populates the form.

import 'package:flutter/material.dart' hide Category;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fnx_core_l10n/fnx_core_l10n.dart';
import 'package:fnx_core_widgets/fnx_core_widgets.dart';
import 'package:fnx_domain/domain.dart';
import 'package:go_router/go_router.dart';

import '../controllers/categories_controller.dart';
import '../widgets/category_color_picker.dart';
import '../widgets/category_icon_picker.dart';

/// Create / edit a category. When [categoryId] is null the form creates a
/// new custom category.
class CategoryFormPage extends ConsumerStatefulWidget {
  /// Creates a category form page.
  const CategoryFormPage({super.key, this.categoryId});

  /// ULID string of the category being edited, or null for create.
  final String? categoryId;

  @override
  ConsumerState<CategoryFormPage> createState() => _CategoryFormPageState();
}

class _CategoryFormPageState extends ConsumerState<CategoryFormPage> {
  final TextEditingController _name = TextEditingController();
  String _iconKey = 'category';
  CategoryColor _color = CategoryColor(fnxCategorySwatches.first);
  Category? _editing;
  bool _initialised = false;

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  void _hydrate(List<Category> items) {
    if (_initialised || widget.categoryId == null) {
      _initialised = true;
      return;
    }
    Category? match;
    for (final c in items) {
      if (c.id.value == widget.categoryId) {
        match = c;
        break;
      }
    }
    if (match != null) {
      _editing = match;
      _name.text = match.name;
      _iconKey = match.iconKey;
      _color = match.color;
    }
    _initialised = true;
  }

  Future<void> _save() async {
    final name = _name.text.trim();
    if (name.isEmpty) {
      return;
    }
    final controller = ref.read(categoriesControllerProvider.notifier);
    if (_editing == null) {
      await controller.createCustom(
        name: name,
        iconKey: _iconKey,
        color: _color,
      );
    } else {
      await controller.upsert(
        _editing!.copyWith(
          name: name,
          iconKey: _iconKey,
          color: _color,
          updatedAt: DateTime.now().toUtc(),
        ),
      );
    }
    if (mounted) {
      context.pop();
    }
  }

  Future<void> _delete() async {
    final id = _editing?.id;
    if (id == null) {
      return;
    }
    await ref.read(categoriesControllerProvider.notifier).remove(id);
    if (mounted) {
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    final state = ref.watch(categoriesControllerProvider);
    final colors = context.fnxColors;
    final spacing = context.fnxSpacing;
    final isEdit = widget.categoryId != null;

    final items = state.valueOrNull;
    if (items != null && !_initialised) {
      _hydrate(items);
    }

    final isSystem = _editing?.isSystem == true;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        title: Text(isEdit ? l10n.commonEdit : l10n.catAdd),
        actions: <Widget>[
          if (isEdit && !isSystem)
            IconButton(
              tooltip: l10n.commonDelete,
              icon: const Icon(Icons.delete_outline),
              onPressed: _delete,
            ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.all(spacing.s5),
          children: <Widget>[
            FnxTextField(
              label: l10n.catFieldName,
              controller: _name,
              enabled: !isSystem,
            ),
            SizedBox(height: spacing.s6),
            Text(l10n.catFieldColor,
                style: context.fnxTypography.bodySm
                    .copyWith(color: colors.textSecondary)),
            SizedBox(height: spacing.s3),
            AbsorbPointer(
              absorbing: isSystem,
              child: CategoryColorPicker(
                selected: _color,
                onSelected: (c) => setState(() => _color = c),
              ),
            ),
            SizedBox(height: spacing.s6),
            Text(l10n.catFieldIcon,
                style: context.fnxTypography.bodySm
                    .copyWith(color: colors.textSecondary)),
            SizedBox(height: spacing.s3),
            AbsorbPointer(
              absorbing: isSystem,
              child: CategoryIconPicker(
                selectedKey: _iconKey,
                onSelected: (k) => setState(() => _iconKey = k),
              ),
            ),
            SizedBox(height: spacing.s7),
            FnxButton(
              label: l10n.commonSave,
              fullWidth: true,
              onPressed: isSystem ? null : _save,
            ),
            SizedBox(height: spacing.s3),
            FnxButton(
              label: l10n.commonCancel,
              variant: FnxButtonVariant.secondary,
              fullWidth: true,
              onPressed: () => context.pop(),
            ),
          ],
        ),
      ),
    );
  }
}
