import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:uuid/uuid.dart';

import '../../core/models/category.dart';
import '../../core/models/enums.dart';
import '../../core/providers/app_providers.dart';
import '../../core/theme/app_icons.dart';
import '../../core/utils/l10n.dart';
import '../../core/widgets/category_avatar.dart';
import '../../core/widgets/common.dart';
import '../../l10n/generated/app_localizations.dart';

class CategoriesScreen extends ConsumerStatefulWidget {
  const CategoriesScreen({super.key});

  @override
  ConsumerState<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends ConsumerState<CategoriesScreen> {
  CategoryKind _kind = CategoryKind.expense;

  Future<void> _openEditor({Category? category}) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (sheetContext) => _CategoryEditorSheet(
        category: category,
        initialKind: _kind,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final locale = context.localeCode;
    final theme = Theme.of(context);
    final categories = ref.watch(sortedCategoriesProvider);
    final filtered = categories
        .where((category) => category.kind == _kind)
        .toList(growable: false);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.categories),
        actions: <Widget>[
          IconButton(
            tooltip: l10n.addCategory,
            onPressed: () => _openEditor(),
            icon: const Icon(Icons.add),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
            child: SegmentedButton<CategoryKind>(
              showSelectedIcon: false,
              segments: <ButtonSegment<CategoryKind>>[
                ButtonSegment<CategoryKind>(
                  value: CategoryKind.expense,
                  label: Text(l10n.expenses),
                ),
                ButtonSegment<CategoryKind>(
                  value: CategoryKind.income,
                  label: Text(l10n.income),
                ),
              ],
              selected: <CategoryKind>{_kind},
              onSelectionChanged: (selection) =>
                  setState(() => _kind = selection.first),
            ),
          ),
          Expanded(
            child: filtered.isEmpty
                ? EmptyState(
                    icon: Icons.category_outlined,
                    title: l10n.noCategories,
                    body: l10n.noCategoriesBody,
                    actionLabel: l10n.addCategory,
                    onAction: () => _openEditor(),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 28),
                    itemCount: filtered.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final category = filtered[index];
                      return Card(
                        child: InkWell(
                          borderRadius: BorderRadius.circular(22),
                          onTap: () => _openEditor(category: category),
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
                            child: Row(
                              children: <Widget>[
                                CategoryAvatar(
                                  iconKey: category.iconKey,
                                  colorValue: category.color,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Row(
                                        children: <Widget>[
                                          Flexible(
                                            child: Text(
                                              category.localizedName(locale),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style:
                                                  theme.textTheme.titleSmall,
                                            ),
                                          ),
                                          if (category.isSystem) ...<Widget>[
                                            const SizedBox(width: 8),
                                            TypeBadge(
                                              label: l10n.systemCategory,
                                              color: theme
                                                  .colorScheme.onSurfaceVariant,
                                            ),
                                          ],
                                        ],
                                      ),
                                      const SizedBox(height: 3),
                                      Text(
                                        _scopeLabel(l10n, category.scope),
                                        style: theme.textTheme.labelSmall
                                            ?.copyWith(
                                          color: theme
                                              .colorScheme.onSurfaceVariant,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Icon(
                                  Icons.chevron_right,
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  String _scopeLabel(AppLocalizations l10n, CategoryScope scope) {
    return switch (scope) {
      CategoryScope.personal => l10n.scopePersonal,
      CategoryScope.business => l10n.scopeBusiness,
      CategoryScope.both => l10n.scopeBoth,
    };
  }
}

class _CategoryEditorSheet extends ConsumerStatefulWidget {
  const _CategoryEditorSheet({
    this.category,
    required this.initialKind,
  });

  final Category? category;
  final CategoryKind initialKind;

  @override
  ConsumerState<_CategoryEditorSheet> createState() =>
      _CategoryEditorSheetState();
}

class _CategoryEditorSheetState extends ConsumerState<_CategoryEditorSheet> {
  static const Uuid _uuid = Uuid();
  static const List<int> _colors = <int>[
    0xFF0F766E,
    0xFF15803D,
    0xFF3B6EA8,
    0xFF7C3AED,
    0xFFDB2777,
    0xFFC2410C,
    0xFFC8A24A,
    0xFF64748B,
  ];

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _nameArController = TextEditingController();
  final TextEditingController _nameEnController = TextEditingController();

  bool _saving = false;
  String? _nameError;
  late CategoryKind _kind;
  late CategoryScope _scope;
  late String _iconKey;
  late int _color;

  bool get _isEditing => widget.category != null;
  bool get _isSystem => widget.category?.isSystem ?? false;

  @override
  void initState() {
    super.initState();
    final category = widget.category;
    _kind = category?.kind ?? widget.initialKind;
    _scope = category?.scope ?? CategoryScope.both;
    _iconKey = category?.iconKey ?? 'more';
    _color = category?.color ?? _colors.first;
    if (category != null) {
      _nameArController.text = category.nameAr;
      _nameEnController.text = category.nameEn;
    }
  }

  @override
  void dispose() {
    _nameArController.dispose();
    _nameEnController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_saving || !(_formKey.currentState?.validate() ?? false)) {
      return;
    }
    final nameAr = _nameArController.text.trim();
    final nameEn = _nameEnController.text.trim();
    if (nameAr.isEmpty && nameEn.isEmpty) {
      setState(() => _nameError = context.l10n.nameRequired);
      return;
    }
    setState(() {
      _saving = true;
      _nameError = null;
    });

    final categories = ref.read(categoriesRepositoryProvider).getAll();
    final existing = widget.category;
    final category = Category(
      id: existing?.id ?? 'cat_${_uuid.v4()}',
      nameAr: nameAr,
      nameEn: nameEn,
      kind: existing?.kind ?? _kind,
      scope: _scope,
      iconKey: _iconKey,
      color: _color,
      isSystem: existing?.isSystem ?? false,
      archived: existing?.archived ?? false,
      sortOrder: existing?.sortOrder ?? categories.length,
    );

    await ref.read(categoriesRepositoryProvider).put(category);
    if (!mounted) {
      return;
    }
    showAppSnack(context, context.l10n.categorySaved);
    Navigator.of(context).pop();
  }

  Future<void> _delete() async {
    final existing = widget.category;
    if (existing == null) {
      return;
    }
    final l10n = context.l10n;
    final confirmed = await showConfirmDialog(
      context,
      title: l10n.deleteCategoryTitle,
      message: l10n.deleteCategoryMessage,
      confirmLabel: l10n.delete,
    );
    if (!confirmed || !mounted) {
      return;
    }
    await ref.read(categoriesRepositoryProvider).delete(existing.id);
    if (!mounted) {
      return;
    }
    showAppSnack(context, l10n.categoryDeleted);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);

    return SheetScaffold(
      title: _isEditing ? l10n.editCategory : l10n.addCategory,
      trailing: _isEditing && !_isSystem
          ? IconButton(
              tooltip: l10n.delete,
              onPressed: _saving ? null : _delete,
              icon: Icon(Icons.delete_outline, color: theme.colorScheme.error),
            )
          : null,
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            TextFormField(
              controller: _nameArController,
              textDirection: TextDirection.rtl,
              textInputAction: TextInputAction.next,
              decoration: InputDecoration(
                labelText: l10n.categoryNameAr,
                prefixIcon: const Icon(Icons.language_outlined),
                errorText: _nameError,
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _nameEnController,
              textInputAction: TextInputAction.done,
              decoration: InputDecoration(
                labelText: l10n.categoryNameEn,
                prefixIcon: const Icon(Icons.text_fields_outlined),
              ),
            ),
            const SizedBox(height: 12),
            if (!_isEditing)
              SegmentedButton<CategoryKind>(
                showSelectedIcon: false,
                segments: <ButtonSegment<CategoryKind>>[
                  ButtonSegment<CategoryKind>(
                    value: CategoryKind.expense,
                    label: Text(l10n.expense),
                  ),
                  ButtonSegment<CategoryKind>(
                    value: CategoryKind.income,
                    label: Text(l10n.income),
                  ),
                ],
                selected: <CategoryKind>{_kind},
                onSelectionChanged: (selection) =>
                    setState(() => _kind = selection.first),
              ),
            const SizedBox(height: 12),
            DropdownButtonFormField<CategoryScope>(
              initialValue: _scope,
              isExpanded: true,
              decoration: InputDecoration(
                labelText: l10n.categoryScope,
                prefixIcon: const Icon(Icons.layers_outlined),
              ),
              items: <DropdownMenuItem<CategoryScope>>[
                DropdownMenuItem<CategoryScope>(
                  value: CategoryScope.personal,
                  child: Text(l10n.scopePersonal),
                ),
                DropdownMenuItem<CategoryScope>(
                  value: CategoryScope.business,
                  child: Text(l10n.scopeBusiness),
                ),
                DropdownMenuItem<CategoryScope>(
                  value: CategoryScope.both,
                  child: Text(l10n.scopeBoth),
                ),
              ],
              onChanged: (value) {
                if (value != null) {
                  setState(() => _scope = value);
                }
              },
            ),
            if (_isSystem) ...<Widget>[
              const SizedBox(height: 12),
              Text(
                l10n.systemCategoryHint,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
            const SizedBox(height: 18),
            Text(
              l10n.accountIcon,
              style: theme.textTheme.labelLarge?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: <Widget>[
                for (final key in AppIcons.categoryKeys)
                  _IconChoice(
                    icon: AppIcons.forKey(key),
                    selected: _iconKey == key,
                    color: Color(_color),
                    onTap: () => setState(() => _iconKey = key),
                  ),
              ],
            ),
            const SizedBox(height: 18),
            Text(
              l10n.accountColor,
              style: theme.textTheme.labelLarge?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: <Widget>[
                for (final colorValue in _colors)
                  _ColorChoice(
                    color: Color(colorValue),
                    selected: _color == colorValue,
                    onTap: () => setState(() => _color = colorValue),
                  ),
              ],
            ),
            const SizedBox(height: 22),
            FilledButton(
              onPressed: _saving ? null : _save,
              child: _saving
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(l10n.save),
            ),
          ],
        ),
      ),
    );
  }
}

class _IconChoice extends StatelessWidget {
  const _IconChoice({
    required this.icon,
    required this.selected,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final bool selected;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: selected
              ? color.withValues(alpha: 0.16)
              : theme.colorScheme.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? color : theme.colorScheme.outlineVariant,
            width: selected ? 1.6 : 1,
          ),
        ),
        child: Icon(
          icon,
          size: 21,
          color: selected ? color : theme.colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}

class _ColorChoice extends StatelessWidget {
  const _ColorChoice({
    required this.color,
    required this.selected,
    required this.onTap,
  });

  final Color color;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      customBorder: const CircleBorder(),
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(
            color: selected
                ? Theme.of(context).colorScheme.onSurface
                : Colors.transparent,
            width: 2.5,
          ),
        ),
        child: selected
            ? const Icon(Icons.check, size: 19, color: Colors.white)
            : null,
      ),
    );
  }
}
