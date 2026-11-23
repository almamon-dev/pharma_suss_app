import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';
import 'package:pharmacy_saas_mobile/core/config/app_config.dart';
import 'package:pharmacy_saas_mobile/core/utils/formatters.dart';
import 'package:pharmacy_saas_mobile/core/widgets/surface_card.dart';
import 'package:pharmacy_saas_mobile/features/workspace/data/pharmacy_store_controller.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({
    super.key,
    required this.store,
    this.reportTitle = 'Business Overview',
  });

  final PharmacyStoreController store;
  final String reportTitle;

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  String _selectedPeriod = 'Last 30 Days';

  static const _periods = [
    'Last 7 Days',
    'Last 30 Days',
    'This Quarter',
  ];

  void _showExportMessage() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Exported ${widget.reportTitle} ($_selectedPeriod) PDF summary.',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final store = widget.store;
    final symbol = store.session.currencySymbol;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return ListenableBuilder(
      listenable: store,
      builder: (context, _) {
        final data = store.analyticsForPeriod(_selectedPeriod);
        return Scaffold(
          appBar: AppBar(
            titleSpacing: 0,
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Analytics',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
                ),
                Text(
                  widget.reportTitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
            actions: [
              IconButton(
                tooltip: 'Export PDF',
                onPressed: _showExportMessage,
                icon: const Icon(Icons.ios_share_rounded, size: 20),
              ),
              PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'export') {
                    _showExportMessage();
                  } else {
                    setState(() => _selectedPeriod = value);
                  }
                },
                itemBuilder: (_) => [
                  const PopupMenuItem(
                    value: 'export',
                    child: Text('Export Report Summary'),
                  ),
                  ..._periods.map(
                    (p) => PopupMenuItem(
                      value: p,
                      child: Text('View $p'),
                    ),
                  ),
                ],
              ),
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 28),
            children: [
              // Period Dropdown matching Screen 10
              DropdownButtonFormField<String>(
                initialValue: _selectedPeriod,
                decoration: InputDecoration(
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                  filled: true,
                  fillColor: isDark ? AppConfig.cardDark : Colors.white,
                ),
                items: _periods
                    .map(
                      (period) => DropdownMenuItem<String>(
                        value: period,
                        child: Text(
                          period,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _selectedPeriod = value);
                  }
                },
              ),
              const SizedBox(height: 14),
              // 2x2 Pastel Analytics KPI Cards matching Screen 10
              Row(
                children: [
                  Expanded(
                    child: _AnalyticsKpiCard(
                      label: 'Total Revenue',
                      value: Formatters.currency(
                        data.totalRevenue,
                        symbol: symbol,
                      ),
                      icon: Icons.show_chart_rounded,
                      accentColor: AppConfig.brandPrimary,
                      backgroundColor: isDark
                          ? AppConfig.brandSoftDark
                          : AppConfig.emeraldSoftLight,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _AnalyticsKpiCard(
                      label: 'Net Profit',
                      value: Formatters.currency(
                        data.netProfit,
                        symbol: symbol,
                      ),
                      icon: Icons.account_balance_wallet_outlined,
                      accentColor: AppConfig.purple,
                      backgroundColor: isDark
                          ? const Color(0xFF211738)
                          : AppConfig.purpleSoftLight,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: _AnalyticsKpiCard(
                      label: 'Purchase Cost',
                      value: Formatters.currency(
                        data.purchaseCost,
                        symbol: symbol,
                      ),
                      icon: Icons.shopping_bag_outlined,
                      accentColor: AppConfig.blue,
                      backgroundColor: isDark
                          ? const Color(0xFF14213B)
                          : AppConfig.blueSoftLight,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _AnalyticsKpiCard(
                      label: 'Expenses',
                      value: Formatters.currency(
                        data.expenses,
                        symbol: symbol,
                      ),
                      icon: Icons.receipt_long_outlined,
                      accentColor: AppConfig.amber,
                      backgroundColor: isDark
                          ? const Color(0xFF2C1F0E)
                          : AppConfig.amberSoftLight,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              // Sales Trend Chart Card matching Screen 10
              SurfaceCard(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Expanded(
                          child: Text(
                            'Sales Trend',
                            style: TextStyle(
                              fontSize: 15.5,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.2,
                            ),
                          ),
                        ),
                        const _LegendDot(
                          color: AppConfig.brandPrimary,
                          label: 'Sales',
                        ),
                        const SizedBox(width: 12),
                        const _LegendDot(
                          color: AppConfig.purple,
                          label: 'Profit',
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 196,
                      width: double.infinity,
                      child: CustomPaint(
                        painter: _SalesTrendPainter(
                          salesPoints: data.salesPoints,
                          profitPoints: data.profitPoints,
                          xLabels: data.xLabels,
                          gridColor: isDark
                              ? AppConfig.slateBorderDark
                              : AppConfig.slateBorderLight,
                          labelColor: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              // Focused live branch insight card
              SurfaceCard(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.insights_rounded,
                          size: 18,
                          color: AppConfig.brandPrimary,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            '${store.session.branchShortName} Live Snapshot',
                            style: const TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 14,
                            ),
                          ),
                        ),
                        StatusPill(
                          label: store.session.tenantName,
                          tone: StatusTone.emerald,
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _SnapshotRow(
                      label: 'Inventory Valuation',
                      value: Formatters.currency(
                        store.inventoryValuation,
                        symbol: symbol,
                      ),
                    ),
                    const SizedBox(height: 6),
                    _SnapshotRow(
                      label: 'Customer Receivables',
                      value: Formatters.currency(
                        store.totalCustomerDue,
                        symbol: symbol,
                      ),
                    ),
                    const SizedBox(height: 6),
                    _SnapshotRow(
                      label: 'Supplier Payables',
                      value: Formatters.currency(
                        store.totalSupplierPayable,
                        symbol: symbol,
                      ),
                    ),
                    const SizedBox(height: 6),
                    _SnapshotRow(
                      label: 'Branches Connected',
                      value:
                          '${store.session.currentBranches.length} locations',
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _AnalyticsKpiCard extends StatelessWidget {
  const _AnalyticsKpiCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.accentColor,
    required this.backgroundColor,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color accentColor;
  final Color backgroundColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SurfaceCard(
      backgroundColor: backgroundColor,
      elevated: false,
      padding: const EdgeInsets.all(13),
      child: Row(
        children: [
          Container(
            height: 36,
            width: 36,
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(5),
            ),
            child: Icon(icon, size: 19, color: accentColor),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    value,
                    maxLines: 1,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.4,
                    ),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
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

class _LegendDot extends StatelessWidget {
  const _LegendDot({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 3,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(999),
          ),
        ),
        const SizedBox(width: 5),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
      ],
    );
  }
}

class _SnapshotRow extends StatelessWidget {
  const _SnapshotRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ),
        const SizedBox(width: 10),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 13.5,
          ),
        ),
      ],
    );
  }
}

class _SalesTrendPainter extends CustomPainter {
  _SalesTrendPainter({
    required this.salesPoints,
    required this.profitPoints,
    required this.xLabels,
    required this.gridColor,
    required this.labelColor,
  });

  final List<double> salesPoints;
  final List<double> profitPoints;
  final List<String> xLabels;
  final Color gridColor;
  final Color labelColor;

  @override
  void paint(Canvas canvas, Size size) {
    if (salesPoints.isEmpty) {
      return;
    }

    const leftPad = 40.0;
    const rightPad = 10.0;
    const topPad = 10.0;
    const bottomPad = 24.0;

    final chartWidth = size.width - leftPad - rightPad;
    final chartHeight = size.height - topPad - bottomPad;
    if (chartWidth <= 0 || chartHeight <= 0) {
      return;
    }

    final rawMax = salesPoints.reduce(math.max);
    final maxY = math.max(500000.0, (rawMax / 100000).ceil() * 100000.0);

    final gridPaint = Paint()
      ..color = gridColor
      ..strokeWidth = 1;

    // 5 horizontal gridlines (100K..500K / 0..maxY)
    const steps = 5;
    for (var i = 0; i <= steps; i++) {
      final frac = i / steps;
      final y = topPad + chartHeight - (frac * chartHeight);
      canvas.drawLine(
        Offset(leftPad, y),
        Offset(size.width - rightPad, y),
        gridPaint,
      );

      final val = (maxY * frac).round();
      final labelText = val == 0
          ? '0'
          : (val >= 1000 ? '${(val / 1000).round()}K' : '$val');
      final tp = TextPainter(
        text: TextSpan(
          text: labelText,
          style: TextStyle(color: labelColor, fontSize: 10.5),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(0, y - tp.height / 2));
    }

    // X-axis labels evenly spread
    if (xLabels.isNotEmpty) {
      for (var i = 0; i < xLabels.length; i++) {
        final t = xLabels.length == 1 ? 0.5 : i / (xLabels.length - 1);
        final x = leftPad + t * chartWidth;
        final tp = TextPainter(
          text: TextSpan(
            text: xLabels[i],
            style: TextStyle(color: labelColor, fontSize: 10.5),
          ),
          textDirection: TextDirection.ltr,
        )..layout();
        final dx = (x - tp.width / 2).clamp(
          leftPad,
          size.width - tp.width,
        );
        tp.paint(canvas, Offset(dx, size.height - bottomPad + 6));
      }
    }

    List<Offset> toOffsets(List<double> values) {
      final count = values.length;
      return List.generate(count, (i) {
        final t = count == 1 ? 0.5 : i / (count - 1);
        final x = leftPad + t * chartWidth;
        final normalized = (values[i] / maxY).clamp(0.0, 1.0);
        final y = topPad + chartHeight - normalized * chartHeight;
        return Offset(x, y);
      });
    }

    final salesOffsets = toOffsets(salesPoints);
    final profitOffsets = toOffsets(profitPoints);

    // Emerald area fill under Sales
    if (salesOffsets.length >= 2) {
      final areaPath = Path()
        ..moveTo(salesOffsets.first.dx, topPad + chartHeight);
      for (final p in salesOffsets) {
        areaPath.lineTo(p.dx, p.dy);
      }
      areaPath
        ..lineTo(salesOffsets.last.dx, topPad + chartHeight)
        ..close();

      final fillPaint = Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppConfig.brandPrimary.withValues(alpha: 0.20),
            AppConfig.brandPrimary.withValues(alpha: 0.01),
          ],
        ).createShader(
          Rect.fromLTWH(leftPad, topPad, chartWidth, chartHeight),
        );
      canvas.drawPath(areaPath, fillPaint);
    }

    _drawSeries(canvas, salesOffsets, AppConfig.brandPrimary);
    if (profitOffsets.isNotEmpty) {
      _drawSeries(canvas, profitOffsets, AppConfig.purple);
    }
  }

  void _drawSeries(Canvas canvas, List<Offset> points, Color color) {
    final linePaint = Paint()
      ..color = color
      ..strokeWidth = 2.4
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final path = Path()..moveTo(points.first.dx, points.first.dy);
    for (var i = 1; i < points.length; i++) {
      path.lineTo(points[i].dx, points[i].dy);
    }
    canvas.drawPath(path, linePaint);

    final dotOuter = Paint()..color = color;
    final dotInner = Paint()..color = Colors.white;
    for (final p in points) {
      canvas.drawCircle(p, 3.6, dotOuter);
      canvas.drawCircle(p, 1.8, dotInner);
    }
  }

  @override
  bool shouldRepaint(covariant _SalesTrendPainter oldDelegate) {
    return oldDelegate.salesPoints != salesPoints ||
        oldDelegate.profitPoints != profitPoints ||
        oldDelegate.gridColor != gridColor;
  }
}
