import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

enum DateRange {
  days_3,
  week_1,
  week_3,
  month_1,
  month_3,
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final List<SamplesData> chartData = [
    SamplesData(DateTime.utc(2021, 9, 1), 80, 10),
    SamplesData(DateTime.utc(2021, 9, 3), 90, 20),
    SamplesData(DateTime.utc(2021, 9, 5), 85, 30),
    SamplesData(DateTime.utc(2021, 9, 7), 95, 10),
    SamplesData(DateTime.utc(2021, 9, 10), 60, 10),
    SamplesData(DateTime.utc(2021, 9, 18), 75, 20),
    SamplesData(DateTime.utc(2021, 9, 25), 90, 30),
    SamplesData(DateTime.utc(2021, 9, 29), 78, 10),
    SamplesData(DateTime.utc(2021, 10, 1), 90, 30),
    SamplesData(DateTime.utc(2021, 10, 2), 85, 20),
  ];

  late List<SamplesData> _chartData;
  late TooltipBehavior _tooltipBehavior;
  late DateRange _dateRangeToDisplay = DateRange.week_3;

  List<SamplesData> getChartData() {
    DateTime now = DateTime.now();
    int days;
    switch (_dateRangeToDisplay) {
      case DateRange.days_3:
        days = 3;
        break;
      case DateRange.week_1:
        days = 7;
        break;
      case DateRange.week_3:
        days = 21;
        break;
      case DateRange.month_1:
        days = 30;
        break;
      case DateRange.month_3:
        days = 90;
        break;
      default:
        days = 21;
    }
    return chartData
        .where(
          (sample) => sample.dateTime.isAfter(
            now.subtract(
              Duration(days: days),
            ),
          ),
        )
        .toList();
  }

  Widget buildDateRangeButton(
    String title,
    DateRange dateRange,
  ) {
    return Flexible(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 5),
        child: SizedBox(
          height: 40,
          width: 200,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              primary: _dateRangeToDisplay == dateRange
                  ? Colors.purpleAccent.shade100
                  : Colors.purple,
            ),
            onPressed: () {
              setState(() {
                _dateRangeToDisplay = dateRange;
              });
            },
            child: FittedBox(
              child: Text(title),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void initState() {
    _tooltipBehavior = TooltipBehavior(enable: true);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    _chartData = getChartData();
    final DateFormat dateFormat = DateFormat('yyyy-MM-dd');
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Flexible(
              child: SfCartesianChart(
                title: ChartTitle(text: 'Sessions History'),
                legend: Legend(isVisible: true),
                tooltipBehavior: _tooltipBehavior,
                enableAxisAnimation: true,
                onTooltipRender: (tooltipArgs) {
                  var dateAndRate = tooltipArgs.text!.split(':');
                  tooltipArgs.text =
                      '${dateAndRate[0]}\nRate: ${int.parse(dateAndRate[1])}';
                },
                series: _chartData.isEmpty
                    ? null
                    : [
                        StackedLineSeries(
                          dataSource: _chartData,
                          xValueMapper: (SamplesData sample, _) =>
                              dateFormat.format(sample.dateTime),
                          yValueMapper: (SamplesData sample, _) =>
                              sample.respirationRate,
                          name: 'Respiration Rate',
                          markerSettings: const MarkerSettings(isVisible: true),
                        ),
                        StackedLineSeries(
                          dataSource: _chartData,
                          xValueMapper: (SamplesData sample, _) =>
                              dateFormat.format(sample.dateTime),
                          yValueMapper: (SamplesData sample, _) =>
                              sample.heartRate - sample.respirationRate,
                          name: 'Heart Rate',
                          markerSettings: const MarkerSettings(isVisible: true),
                        ),
                      ],
                primaryXAxis: CategoryAxis(),
                primaryYAxis: NumericAxis(),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  buildDateRangeButton('3 days', DateRange.days_3),
                  buildDateRangeButton('1 week', DateRange.week_1),
                  buildDateRangeButton('3 weeks', DateRange.week_3),
                  buildDateRangeButton('1 month', DateRange.month_1),
                  buildDateRangeButton('3 months', DateRange.month_3),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SamplesData {
  final DateTime dateTime;
  final int heartRate;
  final int respirationRate;

  SamplesData(
    this.dateTime,
    this.heartRate,
    this.respirationRate,
  );
}
