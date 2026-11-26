import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:uuid/uuid.dart';

import '../../core/models/enums.dart';
import '../../core/models/space.dart';
import '../../core/providers/app_providers.dart';
import '../../core/services/reference_service.dart';
import '../../core/theme/app_icons.dart';
import '../../core/utils/l10n.dart';
import '../../core/widgets/category_avatar.dart';
import '../../core/widgets/common.dart';

class SpacesScreen extends ConsumerWidget {
  const SpacesScreen({super.key});

  Future<void> _openEditor(BuildContext context, {Space? space}) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (sheetContext) => _SpaceEditorSheet(space: space),
    );
  }

  Future<void> _toggleArchive(
    BuildContext context,
    WidgetRef ref,
    Space space,
  ) async {
    final l10n = context.l10n;
    final spaces = ref.read(spacesProvider).value ?? const <Space>[];
    final archiving = !space.archived;
    if (archiving &&
        spaces.where((item) => !item.archived).length <= 1) {
      showAppSnack(context, l10n.lastSpaceRequired);
      return;
    }
    await ref
        .read(spacesRepositoryProvider)
        .put(space.copyWith(archived: archiving));
    if (archiving &&
        ref.read(settingsProvider).activeSpaceId == space.id) {
      await ref.read(settingsProvider.notifier).setActiveSpace('all');
    }
    if (context.mounted) {
      showAppSnack(
        context,
        archiving ? l10n.spaceArchived : l10n.spaceRestored,
      );
    }
  }

  Future<void> _delete(
    BuildContext context,
    WidgetRef ref,
    Space space,
  ) async {
    final l10n = context.l10n;
    if (space.isSystem) {
      showAppSnack(context, l10n.spaceSystemProtected);
      return;
    }
    final spaces = ref.read(spacesProvider).value ?? const <Space>[];
    if (!space.archived &&
        spaces.where((item) => !item.archived).length <= 1) {
      showAppSnack(context, l10n.lastSpaceRequired);
      return;
    }

    final counts = ReferenceService.forSpace(
      spaceId: space.id,
      transactions: ref.read(transactionsProvider).value ?? const [],
      budgets: ref.read(budgetsProvider).value ?? const [],
      recurring: ref.read(recurringProvider).value ?? const [],
    );
    if (counts.isUsed) {
      final archive = await showConfirmDialog(
        context,
        title: l10n.spaceInUseTitle,
        message: l10n.spaceInUseMessage(counts.total),
        confirmLabel: l10n.archiveSpace,
        destructive: false,
      );
      if (archive && context.mounted) {
        await _toggleArchive(context, ref, space);
      }
      return;
    }

    final confirmed = await showConfirmDialog(
      context,
      title: l10n.deleteSpaceTitle,
      message: l10n.deleteSpaceMessage,
      confirmLabel: l10n.delete,
    );
    if (!confirmed || !context.mounted) {
      return;
    }
    await ref.read(spacesRepositoryProvider).delete(space.id);
    if (ref.read(settingsProvider).activeSpaceId == space.id) {
      await ref.read(settingsProvider.notifier).setActiveSpace('all');
    }
    if (context.mounted) {
      showAppSnack(context, l10n.spaceDeleted);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final locale = context.localeCode;
    final theme = Theme.of(context);
    final spaces = ref.watch(sortedSpacesProvider);
    final allSpaces = ref.watch(spacesProvider).value ?? const <Space>[];
    final archivedSpaces = allSpaces
        .where((space) => space.archived)
        .toList(growable: false)
      ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    final transactions = ref.watch(transactionsProvider).value ?? const [];
    final budgets = ref.watch(budgetsProvider).value ?? const [];

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.spaces),
        actions: <Widget>[
          IconButton(
            tooltip: l10n.addSpace,
            onPressed: () => _openEditor(context),
            icon: const Icon(Icons.add),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 32),
        children: <Widget>[
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.secondaryContainer.withValues(
                alpha: theme.brightness == Brightness.dark ? 0.55 : 1,
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Icon(
                  Icons.workspaces_outline,
                  color: theme.colorScheme.onSecondaryContainer,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    l10n.spacesHint,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSecondaryContainer,
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          for (final space in spaces) ...<Widget>[
            _SpaceTile(
              space: space,
              locale: locale,
              transactionCount: transactions
                  .where((txn) => txn.spaceId == space.id)
                  .length,
              hasBudgets: budgets.any(
                (budget) => budget.spaceId == space.id,
              ),
              onEdit: () => _openEditor(context, space: space),
              onArchive: () => _toggleArchive(context, ref, space),
              onDelete: () => _delete(context, ref, space),
            ),
            const SizedBox(height: 10),
          ],
          if (archivedSpaces.isNotEmpty) ...<Widget>[
            const SizedBox(height: 14),
            SectionTitle(title: l10n.archived),
            for (final space in archivedSpaces) ...<Widget>[
              _SpaceTile(
                space: space,
                locale: locale,
                transactionCount: transactions
                    .where((txn) => txn.spaceId == space.id)
                    .length,
                hasBudgets: budgets.any(
                  (budget) => budget.spaceId == space.id,
                ),
                onEdit: () => _openEditor(context, space: space),
                onArchive: () => _toggleArchive(context, ref, space),
                onDelete: () => _delete(context, ref, space),
              ),
              const SizedBox(height: 10),
            ],
          ],
        ],
      ),
    );
  }
}

class _SpaceTile extends StatelessWidget {
  const _SpaceTile({
    required this.space,
    required this.locale,
    required this.transactionCount,
    required this.hasBudgets,
    required this.onEdit,
    required this.onArchive,
    required this.onDelete,
  });

  final Space space;
  final String locale;
  final int transactionCount;
  final bool hasBudgets;
  final VoidCallback onEdit;
  final VoidCallback onArchive;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: onEdit,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 14, 4, 14),
          child: Row(
            children: <Widget>[
              CategoryAvatar(
                iconKey: space.iconKey,
                colorValue: space.color,
                size: 48,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Flexible(
                          child: Text(
                            space.localizedName(locale),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.titleSmall,
                          ),
                        ),
                        if (space.archived) ...<Widget>[
                          const SizedBox(width: 6),
                          TypeBadge(
                            label: l10n.archived,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: <Widget>[
                        TypeBadge(
                          label: space.kind == SpaceKind.business
                              ? l10n.business
                              : l10n.personal,
                          color: Color(space.color),
                        ),
                        Text(
                          l10n.transactionsCount(transactionCount),
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        if (hasBudgets)
                          Text(
                            '· ${l10n.budgets}',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                tooltip: l10n.edit,
                icon: Icon(
                  Icons.more_vert,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                onSelected: (value) {
                  switch (value) {
                    case 'edit':
                      onEdit();
                      break;
                    case 'archive':
                      onArchive();
                      break;
                    case 'delete':
                      onDelete();
                      break;
                  }
                },
                itemBuilder: (context) => <PopupMenuEntry<String>>[
                  PopupMenuItem<String>(
                    value: 'edit',
                    child: ListTile(
                      leading: const Icon(Icons.edit_outlined),
                      title: Text(l10n.edit),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                  PopupMenuItem<String>(
                    value: 'archive',
                    child: ListTile(
                      leading: Icon(
                        space.archived
                            ? Icons.unarchive_outlined
                            : Icons.archive_outlined,
                      ),
                      title: Text(
                        space.archived
                            ? l10n.unarchiveSpace
                            : l10n.archiveSpace,
                      ),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                  if (!space.isSystem)
                    PopupMenuItem<String>(
                      value: 'delete',
                      child: ListTile(
                        leading: Icon(
                          Icons.delete_outline,
                          color: theme.colorScheme.error,
                        ),
                        title: Text(
                          l10n.delete,
                          style: TextStyle(color: theme.colorScheme.error),
                        ),
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SpaceEditorSheet extends ConsumerStatefulWidget {
  const _SpaceEditorSheet({this.space});

  final Space? space;

  @override
  ConsumerState<_SpaceEditorSheet> createState() => _SpaceEditorSheetState();
}

class _SpaceEditorSheetState extends ConsumerState<_SpaceEditorSheet> {
  static const Uuid _uuid = Uuid();
  static const List<int> _colors = <int>[
    0xFF0F766E,
    0xFFC8A24A,
    0xFF3B6EA8,
    0xFF7C3AED,
    0xFFDB2777,
    0xFF15803D,
    0xFFC2410C,
    0xFF64748B,
  ];

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _nameArController = TextEditingController();
  final TextEditingController _nameEnController = TextEditingController();

  bool _saving = false;
  String? _nameError;
  late SpaceKind _kind;
  late String _iconKey;
  late int _color;

  bool get _isEditing => widget.space != null;

  @override
  void initState() {
    super.initState();
    final space = widget.space;
    _kind = space?.kind ?? SpaceKind.personal;
    _iconKey = space?.iconKey ??
        (_kind == SpaceKind.business ? 'store' : 'person');
    _color = space?.color ??
        (_kind == SpaceKind.business ? 0xFFC8A24A : 0xFF0F766E);
    if (space != null) {
      _nameArController.text = space.nameAr;
      _nameEnController.text = space.nameEn;
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
      _nameError = null;
      _saving = true;
    });

    final existing = widget.space;
    final spaces = ref.read(spacesRepositoryProvider).getAll();
    final space = Space(
      id: existing?.id ?? 'space_${_uuid.v4()}',
      nameAr: nameAr,
      nameEn: nameEn,
      kind: _kind,
      color: _color,
      iconKey: _iconKey,
      isSystem: existing?.isSystem ?? false,
      archived: existing?.archived ?? false,
      sortOrder: existing?.sortOrder ?? spaces.length,
    );

    await ref.read(spacesRepositoryProvider).put(space);
    if (!mounted) {
      return;
    }
    showAppSnack(context, context.l10n.spaceSaved);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);

    return SheetScaffold(
      title: _isEditing ? l10n.editSpace : l10n.addSpace,
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
                labelText: l10n.spaceNameAr,
                prefixIcon: const Icon(Icons.language_outlined),
                errorText: _nameError,
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _nameEnController,
              textInputAction: TextInputAction.done,
              decoration: InputDecoration(
                labelText: l10n.spaceNameEn,
                prefixIcon: const Icon(Icons.text_fields_outlined),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              l10n.spaceKind,
              style: theme.textTheme.labelLarge?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: <Widget>[
                Expanded(
                  child: _KindChoice(
                    selected: _kind == SpaceKind.personal,
                    icon: Icons.person_outline,
                    label: l10n.personal,
                    onTap: () => setState(() {
                      _kind = SpaceKind.personal;
                      if (_iconKey == 'store') {
                        _iconKey = 'person';
                      }
                      if (_color == 0xFFC8A24A) {
                        _color = 0xFF0F766E;
                      }
                    }),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _KindChoice(
                    selected: _kind == SpaceKind.business,
                    icon: Icons.storefront_outlined,
                    label: l10n.business,
                    onTap: () => setState(() {
                      _kind = SpaceKind.business;
                      if (_iconKey == 'person') {
                        _iconKey = 'store';
                      }
                      if (_color == 0xFF0F766E) {
                        _color = 0xFFC8A24A;
                      }
                    }),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              l10n.spaceKindHint,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              l10n.accountIcon,
              style: theme.textTheme.labelLarge?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: <Widget>[
                for (final key in <String>[
                  'person',
                  'store',
                  'cash',
                  'wallet',
                  'chart',
                ])
                  _IconChoice(
                    icon: AppIcons.forKey(key),
                    selected: _iconKey == key,
                    color: Color(_color),
                    onTap: () => setState(() => _iconKey = key),
                  ),
              ],
            ),
            const SizedBox(height: 20),
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
            const SizedBox(height: 24),
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

class _KindChoice extends StatelessWidget {
  const _KindChoice({
    required this.selected,
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final bool selected;
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: selected
              ? theme.colorScheme.primaryContainer
              : theme.colorScheme.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected
                ? theme.colorScheme.primary
                : theme.colorScheme.outlineVariant,
            width: selected ? 1.6 : 1,
          ),
        ),
        child: Row(
          children: <Widget>[
            Icon(
              icon,
              size: 20,
              color: selected
                  ? theme.colorScheme.onPrimaryContainer
                  : theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                label,
                style: theme.textTheme.labelLarge?.copyWith(
                  color: selected
                      ? theme.colorScheme.onPrimaryContainer
                      : theme.colorScheme.onSurface,
                ),
              ),
            ),
            if (selected)
              Icon(
                Icons.check_circle,
                size: 18,
                color: theme.colorScheme.primary,
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
