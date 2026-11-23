class BranchInfo {
  const BranchInfo({
    required this.id,
    required this.code,
    required this.name,
    required this.location,
    this.isHeadOffice = false,
  });

  final int id;
  final String code;
  final String name;
  final String location;
  final bool isHeadOffice;
}

class TenantWorkspace {
  const TenantWorkspace({
    required this.id,
    required this.name,
    required this.domain,
    required this.city,
    required this.licenseNumber,
    required this.planName,
    required this.branches,
    this.currencySymbol = '৳',
  });

  final int id;
  final String name;
  final String domain;
  final String city;
  final String licenseNumber;
  final String planName;
  final List<BranchInfo> branches;
  final String currencySymbol;
}

class DemoAccountPreset {
  const DemoAccountPreset({
    required this.label,
    required this.badge,
    required this.email,
    required this.password,
    required this.userName,
    required this.roleTitle,
  });

  final String label;
  final String badge;
  final String email;
  final String password;
  final String userName;
  final String roleTitle;
}

class WorkspaceSession {
  const WorkspaceSession({
    required this.tenantDomain,
    required this.userEmail,
    this.userName = 'Mamon Hasan',
    this.userPhone = '+880 1712-345678',
    this.roleLabel = 'Store Owner',
    this.tenantName = 'Mamon Pharmacy',
    this.licenseNumber = 'DGDA-DHK-2026-4418',
    this.planName = 'Growth Plan',
    this.branchId = 1,
    this.branchName = 'Main Branch (Head Office)',
    this.branchShortName = 'Main Branch',
    this.branchCode = 'DHK-01',
    this.currencySymbol = '৳',
    this.availableWorkspaces = const [],
    this.apiConnected = false,
  });

  final String tenantDomain;
  final String userEmail;
  final String userName;
  final String userPhone;
  final String roleLabel;
  final String tenantName;
  final String licenseNumber;
  final String planName;
  final int branchId;
  final String branchName;
  final String branchShortName;
  final String branchCode;
  final String currencySymbol;
  final List<TenantWorkspace> availableWorkspaces;
  final bool apiConnected;

  TenantWorkspace? get currentWorkspace {
    for (final workspace in availableWorkspaces) {
      if (workspace.domain == tenantDomain) {
        return workspace;
      }
    }
    return availableWorkspaces.isNotEmpty ? availableWorkspaces.first : null;
  }

  List<BranchInfo> get currentBranches =>
      currentWorkspace?.branches ?? const [];

  WorkspaceSession copyWith({
    String? tenantDomain,
    String? userEmail,
    String? userName,
    String? userPhone,
    String? roleLabel,
    String? tenantName,
    String? licenseNumber,
    String? planName,
    int? branchId,
    String? branchName,
    String? branchShortName,
    String? branchCode,
    String? currencySymbol,
    List<TenantWorkspace>? availableWorkspaces,
    bool? apiConnected,
  }) {
    return WorkspaceSession(
      tenantDomain: tenantDomain ?? this.tenantDomain,
      userEmail: userEmail ?? this.userEmail,
      userName: userName ?? this.userName,
      userPhone: userPhone ?? this.userPhone,
      roleLabel: roleLabel ?? this.roleLabel,
      tenantName: tenantName ?? this.tenantName,
      licenseNumber: licenseNumber ?? this.licenseNumber,
      planName: planName ?? this.planName,
      branchId: branchId ?? this.branchId,
      branchName: branchName ?? this.branchName,
      branchShortName: branchShortName ?? this.branchShortName,
      branchCode: branchCode ?? this.branchCode,
      currencySymbol: currencySymbol ?? this.currencySymbol,
      availableWorkspaces: availableWorkspaces ?? this.availableWorkspaces,
      apiConnected: apiConnected ?? this.apiConnected,
    );
  }
}
