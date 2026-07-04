import 'dart:collection';
import 'dart:io';
import 'dart:math';

import 'package:collection/collection.dart' show IterableExtension;
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';
import 'package:hourglass/blocs/projects/bloc.dart';
import 'package:hourglass/blocs/timers/bloc.dart';
import 'package:hourglass/models/project.dart';
import 'package:hourglass/models/timer_entry.dart';
import 'package:path/path.dart' as p;

import 'Legend.dart';

class WeeklyProductivityDashboard extends StatefulWidget {
  final DateTime? startDate;
  final DateTime? endDate;
  final List<Project?> selectedProjects;

  const WeeklyProductivityDashboard({
    Key? key,
    required this.startDate,
    required this.endDate,
    required this.selectedProjects,
  }) : super(key: key);

  @override
  State<WeeklyProductivityDashboard> createState() =>
      _WeeklyProductivityDashboardState();
}

class _WeeklyProductivityDashboardState
    extends State<WeeklyProductivityDashboard> {
  int? _touchedPieIndex = -1;

  // Helper structure to hold pre-calculated dashboard metrics
  late double _totalHours;
  late int _activeDaysCount;
  late double _dailyAvg;
  late String _mostActiveDayName;
  late List<double> _dailyHours; // Mon to Sun: 0 to 6
  late LinkedHashMap<int?, double> _projectHours;
  late List<String> _weekdayNames;

  @override
  void initState() {
    super.initState();
    _touchedPieIndex = -1;
  }

  void _calculateMetrics(BuildContext context) {
    final timers = BlocProvider.of<TimersBloc>(context);
    final locale = Localizations.localeOf(context).toString();

    // Setup weekday names based on locale
    final dayFormat = DateFormat.E(locale);
    _weekdayNames = [];
    // Standard Mon to Sun
    for (int i = 1; i <= 7; i++) {
      // 2026-06-01 is a Monday
      _weekdayNames.add(dayFormat.format(DateTime(2026, 6, i)));
    }

    _projectHours = LinkedHashMap();
    _dailyHours = List.filled(7, 0.0);
    Set<String> activeDays = {};

    List<TimerEntry> filteredTimers = timers.state.timers
        .where((t) => t.endTime != null)
        .where((t) => widget.selectedProjects.any((p) => p?.id == t.projectID))
        .where((t) => widget.startDate == null
            ? true
            : t.startTime.isAfter(widget.startDate!))
        .where((t) => widget.endDate == null
            ? true
            : t.startTime.isBefore(widget.endDate!))
        .toList();

    _totalHours = 0.0;
    for (var timer in filteredTimers) {
      double hours =
          timer.endTime!.difference(timer.startTime).inSeconds.toDouble() /
              3600.0;
      _totalHours += hours;

      // Project aggregation
      _projectHours.update(timer.projectID, (sum) => sum + hours,
          ifAbsent: () => hours);

      // Active days & daily hours
      // Get weekday index (1 = Mon, 7 = Sun) -> convert to 0-6
      int weekdayIdx = timer.startTime.weekday - 1;
      if (weekdayIdx >= 0 && weekdayIdx < 7) {
        _dailyHours[weekdayIdx] += hours;
      }

      String dateString = DateFormat('yyyy-MM-dd').format(timer.startTime);
      activeDays.add(dateString);
    }

    _activeDaysCount = activeDays.length;
    _dailyAvg = _activeDaysCount > 0 ? _totalHours / _activeDaysCount : 0.0;

    // Find most active day
    double maxHours = -1.0;
    int maxIdx = 0;
    for (int i = 0; i < 7; i++) {
      if (_dailyHours[i] > maxHours) {
        maxHours = _dailyHours[i];
        maxIdx = i;
      }
    }
    _mostActiveDayName = maxHours > 0 ? _weekdayNames[maxIdx] : "-";
  }

  Future<void> _exportPdfReport(BuildContext context) async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final theme = Theme.of(context);
    final projects = BlocProvider.of<ProjectsBloc>(context);

    try {
      final doc = pw.Document();
      final regularFont =
          pw.Font.ttf(await rootBundle.load('fonts/PublicSans-Regular.ttf'));
      final boldFont =
          pw.Font.ttf(await rootBundle.load('fonts/PublicSans-Bold.ttf'));

      final textStyleBody = pw.TextStyle(
          font: regularFont, fontSize: 11, color: PdfColor.fromHex("#333333"));
      final textStyleBodyBold = textStyleBody.copyWith(font: boldFont);
      final textStyleHeader = pw.TextStyle(
          font: boldFont, fontSize: 20, color: PdfColor.fromHex("#1A1A1A"));
      final textStyleSubHeader = pw.TextStyle(
          font: boldFont, fontSize: 14, color: PdfColor.fromHex("#555555"));

      doc.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          orientation: pw.PageOrientation.portrait,
          build: (pw.Context pdfCtx) {
            return [
              pw.Header(
                level: 0,
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text("Weekly Productivity Report",
                        style: textStyleHeader),
                    pw.Text(
                      DateFormat.yMMMd().format(DateTime.now()),
                      style: textStyleBody.copyWith(
                          color: PdfColor.fromHex("#777777")),
                    ),
                  ],
                ),
              ),
              pw.SizedBox(height: 15),

              // Date Range and overall total
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  if (widget.startDate != null && widget.endDate != null)
                    pw.Text(
                      "Period: ${DateFormat.yMMMd().format(widget.startDate!)} - ${DateFormat.yMMMd().format(widget.endDate!)}",
                      style: textStyleBodyBold,
                    ),
                  pw.Text(
                    "Total Tracked Time: ${_totalHours.toStringAsFixed(1)} hrs",
                    style: textStyleBodyBold.copyWith(
                        color: PdfColor.fromHex("#007ACC")),
                  ),
                ],
              ),
              pw.SizedBox(height: 20),

              // KPI Grid in PDF
              pw.Text("Key Performance Indicators", style: textStyleSubHeader),
              pw.SizedBox(height: 8),
              pw.Table(
                border: pw.TableBorder.all(
                    color: PdfColor.fromHex("#E0E0E0"), width: 1),
                children: [
                  pw.TableRow(
                    decoration:
                        pw.BoxDecoration(color: PdfColor.fromHex("#F5F5F5")),
                    children: [
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text("Metric", style: textStyleBodyBold),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text("Value", style: textStyleBodyBold),
                      ),
                    ],
                  ),
                  pw.TableRow(
                    children: [
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text("Total Hours Tracked", style: textStyleBody),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text("${_totalHours.toStringAsFixed(1)} hrs",
                            style: textStyleBodyBold),
                      ),
                    ],
                  ),
                  pw.TableRow(
                    children: [
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text("Active Tracking Days", style: textStyleBody),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text("$_activeDaysCount / 7 days",
                            style: textStyleBodyBold),
                      ),
                    ],
                  ),
                  pw.TableRow(
                    children: [
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text("Daily Average Hours", style: textStyleBody),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text("${_dailyAvg.toStringAsFixed(1)} hrs/day",
                            style: textStyleBodyBold),
                      ),
                    ],
                  ),
                  pw.TableRow(
                    children: [
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text("Most Active Day", style: textStyleBody),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text(_mostActiveDayName, style: textStyleBodyBold),
                      ),
                    ],
                  ),
                ],
              ),
              pw.SizedBox(height: 25),

              // Project Breakdown table
              pw.Text("Project Distribution", style: textStyleSubHeader),
              pw.SizedBox(height: 8),
              pw.Table(
                border: pw.TableBorder.all(
                    color: PdfColor.fromHex("#E0E0E0"), width: 1),
                children: [
                  pw.TableRow(
                    decoration:
                        pw.BoxDecoration(color: PdfColor.fromHex("#F5F5F5")),
                    children: [
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text("Project", style: textStyleBodyBold),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text("Hours Spent", style: textStyleBodyBold),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text("Share Ratio", style: textStyleBodyBold),
                      ),
                    ],
                  ),
                  ..._projectHours.entries.map((entry) {
                    Project? p = projects.state.projects
                        .firstWhereOrNull((proj) => proj.id == entry.key);
                    double ratio = _totalHours > 0 ? entry.value / _totalHours : 0.0;
                    return pw.TableRow(
                      children: [
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Text(p?.name ?? "No Project",
                              style: textStyleBody),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Text("${entry.value.toStringAsFixed(1)} hrs",
                              style: textStyleBody),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Text("${(ratio * 100.0).toStringAsFixed(1)}%",
                              style: textStyleBodyBold),
                        ),
                      ],
                    );
                  }).toList(),
                ],
              ),
              pw.SizedBox(height: 25),

              // Daily totals table
              pw.Text("Daily Activity Breakdown", style: textStyleSubHeader),
              pw.SizedBox(height: 8),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: List.generate(7, (i) {
                  return pw.Container(
                    width: 60,
                    padding: const pw.EdgeInsets.all(6),
                    decoration: pw.BoxDecoration(
                      border: pw.Border.all(color: PdfColor.fromHex("#CCCCCC")),
                      borderRadius:
                          const pw.BorderRadius.all(pw.Radius.circular(4)),
                      color: _dailyHours[i] > 0
                          ? PdfColor.fromHex("#EAF6FF")
                          : PdfColor.fromHex("#FFFFFF"),
                    ),
                    child: pw.Column(
                      children: [
                        pw.Text(_weekdayNames[i],
                            style: textStyleBodyBold.copyWith(fontSize: 9)),
                        pw.SizedBox(height: 4),
                        pw.Text("${_dailyHours[i].toStringAsFixed(1)}h",
                            style: textStyleBody.copyWith(fontSize: 10)),
                      ],
                    ),
                  );
                }),
              ),
            ];
          },
        ),
      );

      final tempDir = await getTemporaryDirectory();
      final pdfFile = File(p.join(tempDir.path, "Weekly_Productivity_Report.pdf"));
      await pdfFile.writeAsBytes(await doc.save());

      await Share.shareXFiles(
        [XFile(pdfFile.path, mimeType: "application/pdf")],
        subject: "Visual Productivity Report",
      );
    } catch (e) {
      scaffoldMessenger.showSnackBar(
        SnackBar(
          backgroundColor: theme.colorScheme.error,
          content: Text("Error generating report PDF: $e",
              style: TextStyle(color: theme.colorScheme.onError)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    _calculateMetrics(context);

    final theme = Theme.of(context);
    final projects = BlocProvider.of<ProjectsBloc>(context);

    if (_totalHours == 0.0) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.analytics_outlined,
                size: 64, color: theme.disabledColor),
            const SizedBox(height: 16),
            Text(
              "No completed entries in selected range",
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.disabledColor,
              ),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 64),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Top Section with Title and PDF share button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Weekly Productivity",
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Visual Report Dashboard",
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.disabledColor,
                        ),
                      ),
                    ],
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () => _exportPdfReport(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: theme.colorScheme.onPrimary,
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: const Icon(Icons.share, size: 16),
                  label: const Text("Export PDF"),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Modern Metrics Grid
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.6,
              children: [
                _buildMetricCard(
                  context,
                  title: "Total Tracked",
                  value: "${_totalHours.toStringAsFixed(1)}h",
                  subtitle: "Tracked Hours",
                  icon: Icons.access_time_filled_rounded,
                  iconColor: Colors.blue,
                ),
                _buildMetricCard(
                  context,
                  title: "Active Days",
                  value: "$_activeDaysCount / 7",
                  subtitle: "Days of Week",
                  icon: Icons.calendar_today_rounded,
                  iconColor: Colors.orange,
                ),
                _buildMetricCard(
                  context,
                  title: "Daily Average",
                  value: "${_dailyAvg.toStringAsFixed(1)}h",
                  subtitle: "Tracked / Day",
                  icon: Icons.speed_rounded,
                  iconColor: Colors.green,
                ),
                _buildMetricCard(
                  context,
                  title: "Most Active",
                  value: _mostActiveDayName,
                  subtitle: "Peak Day",
                  icon: Icons.star_rounded,
                  iconColor: Colors.purple,
                ),
              ],
            ),
            const SizedBox(height: 28),

            // Daily bar chart
            Text(
              "Daily Tracked Hours",
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 180,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: (_dailyHours.reduce(max) + 1.0).clamp(5.0, 100.0),
                  barTouchData: BarTouchData(
                    touchTooltipData: BarTouchTooltipData(
                      tooltipBgColor: theme.cardColor,
                      getTooltipItem: (group, groupIndex, rod, rodIndex) {
                        return BarTooltipItem(
                          "${_weekdayNames[group.x.toInt()]}\n${rod.toY.toStringAsFixed(1)} hrs",
                          theme.textTheme.bodySmall!.copyWith(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        );
                      },
                    ),
                  ),
                  titlesData: FlTitlesData(
                    show: true,
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (double value, TitleMeta meta) {
                          int index = value.toInt();
                          if (index >= 0 && index < 7) {
                            return SideTitleWidget(
                              axisSide: meta.axisSide,
                              space: 8,
                              child: Text(
                                _weekdayNames[index][0], // First letter
                                style: theme.textTheme.bodySmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            );
                          }
                          return const SizedBox();
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 32,
                        getTitlesWidget: (double value, TitleMeta meta) {
                          return SideTitleWidget(
                            axisSide: meta.axisSide,
                            space: 4,
                            child: Text(
                              value.toStringAsFixed(0),
                              style: theme.textTheme.bodySmall,
                            ),
                          );
                        },
                      ),
                    ),
                    topTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false)),
                  ),
                  gridData: const FlGridData(show: false),
                  borderData: FlBorderData(show: false),
                  barGroups: List.generate(7, (index) {
                    return BarChartGroupData(
                      x: index,
                      barRods: [
                        BarChartRodData(
                          toY: _dailyHours[index],
                          color: _dailyHours[index] > 0
                              ? theme.colorScheme.primary
                              // ignore: deprecated_member_use
                              : theme.disabledColor.withOpacity(0.2),
                          width: 16,
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(6),
                            topRight: Radius.circular(6),
                          ),
                        )
                      ],
                    );
                  }),
                ),
              ),
            ),
            const SizedBox(height: 28),

            // Project distribution Pie chart
            Text(
              "Project Distribution Share",
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 180,
              child: PieChart(
                PieChartData(
                  borderData: FlBorderData(show: false),
                  sectionsSpace: 4,
                  centerSpaceRadius: 40,
                  pieTouchData: PieTouchData(
                    touchCallback: (flTouchEvent, pieTouchResponse) {
                      setState(() {
                        if (flTouchEvent is FlLongPressEnd ||
                            flTouchEvent is FlPanEndEvent) {
                          _touchedPieIndex = -1;
                        } else {
                          _touchedPieIndex = pieTouchResponse
                              ?.touchedSection?.touchedSectionIndex;
                        }
                      });
                    },
                  ),
                  sections: List.generate(_projectHours.length, (index) {
                    final entry = _projectHours.entries.elementAt(index);
                    Project? p = projects.state.projects
                        .firstWhereOrNull((proj) => proj.id == entry.key);
                    final isTouched = index == _touchedPieIndex;
                    final double radius = isTouched ? 60.0 : 45.0;
                    final double ratio = entry.value / _totalHours;

                    return PieChartSectionData(
                      color: p?.colour ?? Colors.grey,
                      value: entry.value,
                      title: isTouched
                          ? "${(ratio * 100).toStringAsFixed(0)}%"
                          : "",
                      radius: radius,
                      titleStyle: theme.textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    );
                  }),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Legend
            Legend(
              projects: widget.selectedProjects.where((project) =>
                  _projectHours.keys.any((id) => project?.id == id)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricCard(
    BuildContext context, {
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
  }) {
    final theme = Theme.of(context);
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          // ignore: deprecated_member_use
          color: theme.dividerColor.withOpacity(0.1),
          width: 1,
        ),
      ),
      // ignore: deprecated_member_use
      color: theme.cardColor.withOpacity(0.5),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                // ignore: deprecated_member_use
                color: iconColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: iconColor, size: 24),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.disabledColor,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    value,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
