//implement a check so that both a date and a weight count is in the input
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:intl/intl.dart';

class WeightLoggingPage extends StatefulWidget {
  const WeightLoggingPage({super.key});
  static TextEditingController weightinput = TextEditingController();
  static TextEditingController dateinput = TextEditingController();
  static double weightValue = 0.0;
  static String dateValue = '';
  @override
  State<WeightLoggingPage> createState() => _WeightLoggingPageImplementation();
}

DateTime dateToChoose = DateTime.now();
List<DateAndWeight> chartData = [];
String data = '';

class DateAndWeight {
  String date;
  double weight;

  DateAndWeight(this.date, this.weight);

  Map<String, dynamic> toJson() {
    return {
      "date": date,
      "weight": weight,
    };
  }
}

String currentYear = DateFormat('yyyy').format(DateTime.now());

class _WeightLoggingPageImplementation extends State<WeightLoggingPage> {
  ChartSeriesController? chartSeriesController;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Weight Tracker \n' 'Current Year: $currentYear'),
      ),
      body: Column(children: [
        Expanded(
          child: SfCartesianChart(
            primaryXAxis: CategoryAxis(
              edgeLabelPlacement: EdgeLabelPlacement.shift,
              interval: 1,
              majorGridLines: const MajorGridLines(width: 0),
              axisLine: const AxisLine(width: 0),
            ),
            primaryYAxis: NumericAxis(
              majorGridLines: const MajorGridLines(width: 0),
              axisLine: const AxisLine(width: 0),
            ),
            series: <ChartSeries>[
              LineSeries<DateAndWeight, String>(
                onRendererCreated: (ChartSeriesController controller) {
                  chartSeriesController = controller;
                },
                dataSource: chartData,
                dataLabelSettings: const DataLabelSettings(isVisible: true),
                markerSettings: const MarkerSettings(isVisible: true),
                xValueMapper: (DateAndWeight data, _) => data.date,
                yValueMapper: (DateAndWeight data, _) => data.weight,
              )
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.all(8.0),
          alignment: Alignment.bottomRight,
          child: FloatingActionButton(
              backgroundColor: Colors.blue,
              shape: const CircleBorder(),
              child: const Icon(
                Icons.add,
                color: Colors.white,
              ),
              onPressed: () {
                showModalBottomSheet<void>(
                    context: context,
                    builder: (BuildContext context) {
                      return Padding(
                        padding: EdgeInsets.only(
                            bottom: MediaQuery.of(context).viewInsets.bottom),
                        child: SizedBox(
                          height: 200,
                          width: double.maxFinite,
                          child: Column(
                            children: [
                              const Text(
                                "Create a new record:",
                                textAlign: TextAlign.start,
                              ),
                              Row(
                                children: [
                                  Expanded(
                                    child: TextField(
                                      decoration: const InputDecoration(
                                        border: OutlineInputBorder(),
                                        hintText: 'Weight',
                                      ),
                                      keyboardType: TextInputType.number,
                                      controller: WeightLoggingPage.weightinput,
                                    ),
                                  ),
                                ],
                              ),
                              Expanded(
                                child: TextField(
                                  controller: WeightLoggingPage.dateinput,
                                  decoration: const InputDecoration(
                                      icon: Icon(Icons.calendar_today),
                                      labelText: 'Enter Date'),
                                  readOnly: true,
                                  onTap: () async {
                                    DateTime? pickedDate = await showDatePicker(
                                        context: context,
                                        initialDate: DateTime.now(),
                                        firstDate: DateTime(2000),
                                        lastDate: DateTime(2101));
                                    if (pickedDate != null) {
                                      setState(() {
                                        WeightLoggingPage.dateinput.text =
                                            DateFormat('MM-dd')
                                                .format(pickedDate);
                                      });
                                    } else {
                                      //debug to be implemented here
                                    }
                                  },
                                ),
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  TextButton(
                                      onPressed: () => Navigator.pop(context),
                                      child: const Text('Cancel')),
                                  TextButton(
                                      onPressed: () {
                                        updateChart();
                                        saveData();
                                      },
                                      child: const Text('Submit')),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    });
              }),
        ),
      ]),
    );
  }

  void updateChart() {
    setState(() {
      if (WeightLoggingPage.weightinput.text.isNotEmpty) {
        WeightLoggingPage.weightValue =
            double.parse(WeightLoggingPage.weightinput.text);
        WeightLoggingPage.dateValue = WeightLoggingPage.dateinput.text;
        WeightLoggingPage.weightinput.clear();
        WeightLoggingPage.dateinput.clear();
        Navigator.pop(context);
        chartData.add(DateAndWeight(
            WeightLoggingPage.dateValue, WeightLoggingPage.weightValue));
        chartData.sort((a, b) => a.date.compareTo(b.date));
        data = jsonEncode(chartData);
        print(data);
        chartSeriesController
            ?.updateDataSource(addedDataIndexes: <int>[chartData.length - 1]);
      } else {
        null;
      }
    });
  }

  void saveData() async {
    final SharedPreferences save = await SharedPreferences.getInstance();
    await save.setString('userdata', data);
  }
}
