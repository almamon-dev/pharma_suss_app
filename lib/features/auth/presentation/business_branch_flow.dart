import 'package:material_ui/material_ui.dart';
import 'package:pharmacy_saas_mobile/core/config/app_config.dart';
import 'package:pharmacy_saas_mobile/core/widgets/brand_logo.dart';
import 'package:pharmacy_saas_mobile/core/widgets/surface_card.dart';
import 'package:pharmacy_saas_mobile/features/workspace/domain/workspace_session.dart';

class SelectBusinessScreen extends StatefulWidget {
  const SelectBusinessScreen({
    super.key,
    required this.session,
    required this.onContinue,
    required this.onBack,
  });

  final WorkspaceSession session;
  final ValueChanged<TenantWorkspace> onContinue;
  final VoidCallback onBack;

  @override
  State<SelectBusinessScreen> createState() => _SelectBusinessScreenState();
}

class _SelectBusinessScreenState extends State<SelectBusinessScreen> {
  late TenantWorkspace _selectedWorkspace;

  @override
  void initState() {
    super.initState();
    _selectedWorkspace = widget.session.currentWorkspace ??
        TenantWorkspace(
          id: 1,
          name: widget.session.tenantName,
          domain: widget.session.tenantDomain,
          city: 'Dhaka',
          licenseNumber: widget.session.licenseNumber,
          planName: widget.session.planName,
          branches: const [
            BranchInfo(
              id: 1,
              code: 'DHK-01',
              name: 'Main Branch (Head Office)',
              location: 'Dhanmondi, Dhaka',
              isHeadOffice: true,
            ),
          ],
        );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final workspaces = widget.session.availableWorkspaces.isNotEmpty
        ? widget.session.availableWorkspaces
        : [_selectedWorkspace];

    return Scaffold(
      backgroundColor: isDark ? AppConfig.canvasDark : Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 8, 4),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: IconButton(
                      tooltip: 'Back',
                      onPressed: widget.onBack,
                      icon: const Icon(Icons.arrow_back_rounded),
                    ),
                  ),
                  const BrandLogo(size: 38, showWordmark: false),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 14, 20, 20),
                children: [
                  Text(
                    'Select Business',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.4,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'You have access to multiple businesses',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontSize: 13,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 22),
                  ...workspaces.map((ws) {
                    final selected = ws.domain == _selectedWorkspace.domain;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: SurfaceCard(
                        padding: const EdgeInsets.all(14),
                        borderRadius: 5,
                        backgroundColor: selected
                            ? (isDark
                                ? AppConfig.brandSoftDark
                                : AppConfig.brandSoftLight)
                            : (isDark
                                ? AppConfig.cardDark
                                : const Color(0xFFF8FAFC)),
                        onTap: () => setState(() => _selectedWorkspace = ws),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              height: 44,
                              width: 44,
                              decoration: BoxDecoration(
                                color: selected
                                    ? AppConfig.brandPrimary.withValues(
                                        alpha: 0.14,
                                      )
                                    : (isDark
                                        ? AppConfig.elevatedDark
                                        : const Color(0xFFF3F4F6)),
                                borderRadius: BorderRadius.circular(5),
                              ),
                              child: Icon(
                                Icons.local_pharmacy_rounded,
                                color: selected
                                    ? AppConfig.brandPrimary
                                    : theme.colorScheme.onSurfaceVariant,
                                size: 22,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    ws.name,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    ws.domain,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: theme.colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                  if (selected) ...[
                                    const SizedBox(height: 8),
                                    const StatusPill(
                                      label: 'Active',
                                      tone: StatusTone.emerald,
                                    ),
                                  ],
                                ],
                              ),
                            ),
                            const SizedBox(width: 10),
                            Padding(
                              padding: const EdgeInsets.only(top: 10),
                              child: Icon(
                                selected
                                    ? Icons.check_circle_rounded
                                    : Icons.radio_button_unchecked_rounded,
                                color: selected
                                    ? AppConfig.brandPrimary
                                    : theme.colorScheme.outline,
                                size: 24,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
              child: FilledButton(
                onPressed: () => widget.onContinue(_selectedWorkspace),
                child: const Text('Continue'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SelectBranchScreen extends StatefulWidget {
  const SelectBranchScreen({
    super.key,
    required this.workspace,
    required this.initialBranchId,
    required this.onContinue,
    required this.onBack,
  });

  final TenantWorkspace workspace;
  final int initialBranchId;
  final ValueChanged<BranchInfo> onContinue;
  final VoidCallback onBack;

  @override
  State<SelectBranchScreen> createState() => _SelectBranchScreenState();
}

class _SelectBranchScreenState extends State<SelectBranchScreen> {
  late BranchInfo _selectedBranch;

  @override
  void initState() {
    super.initState();
    _selectedBranch = widget.workspace.branches.firstWhere(
      (b) => b.id == widget.initialBranchId,
      orElse: () => widget.workspace.branches.first,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppConfig.canvasDark : Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 8, 4),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: IconButton(
                      tooltip: 'Back',
                      onPressed: widget.onBack,
                      icon: const Icon(Icons.arrow_back_rounded),
                    ),
                  ),
                  const BrandLogo(size: 38, showWordmark: false),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 14, 20, 20),
                children: [
                  Text(
                    'Select Branch',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.4,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Choose a branch to continue',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontSize: 13,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 22),
                  ...widget.workspace.branches.map((branch) {
                    final selected = branch.id == _selectedBranch.id;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: SurfaceCard(
                        padding: const EdgeInsets.all(14),
                        borderRadius: 5,
                        backgroundColor: selected
                            ? (isDark
                                ? AppConfig.brandSoftDark
                                : AppConfig.brandSoftLight)
                            : (isDark
                                ? AppConfig.cardDark
                                : const Color(0xFFF8FAFC)),
                        onTap: () => setState(() => _selectedBranch = branch),
                        child: Row(
                          children: [
                            Container(
                              height: 40,
                              width: 40,
                              decoration: BoxDecoration(
                                color: selected
                                    ? AppConfig.brandPrimary.withValues(
                                        alpha: 0.14,
                                      )
                                    : (isDark
                                        ? AppConfig.elevatedDark
                                        : const Color(0xFFF3F4F6)),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.location_on_outlined,
                                color: selected
                                    ? AppConfig.brandPrimary
                                    : theme.colorScheme.onSurfaceVariant,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    branch.name,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 14.5,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    branch.location,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: theme.colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 10),
                            Icon(
                              selected
                                  ? Icons.radio_button_checked_rounded
                                  : Icons.radio_button_off_rounded,
                              color: selected
                                  ? AppConfig.brandPrimary
                                  : theme.colorScheme.outline,
                              size: 22,
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
              child: FilledButton(
                onPressed: () => widget.onContinue(_selectedBranch),
                child: const Text('Continue'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

