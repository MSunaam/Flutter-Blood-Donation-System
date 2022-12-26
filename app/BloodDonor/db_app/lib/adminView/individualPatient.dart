import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:mysql1/mysql1.dart';
import '../models/patient.dart';
import '../sql/dbSql.dart';
import 'package:intl/intl.dart';
import 'package:flutter/cupertino.dart';

class TranfusionHistory {
  String blood_bank_name;
  int QuantityRecieved;
  DateTime DateRecieved;
  int BloodBankFK;
  int PatientFK;
  TranfusionHistory(
      {required this.blood_bank_name,
      required this.QuantityRecieved,
      required this.DateRecieved,
      required this.BloodBankFK,
      required this.PatientFK});
}

class BloodBank {
  String name;
  int ID;
  BloodBank({required this.ID, required this.name});
}

class IndividualPatient extends StatefulWidget {
  Patient patient;

  IndividualPatient({super.key, required this.patient});

  @override
  State<IndividualPatient> createState() => _IndividualPatientState();
}

class _IndividualPatientState extends State<IndividualPatient> {
  late MySqlConnection connection;
  List bloodBanks = [];
  var db = MySql();
  List transfusionHistory = [];
  bool emptyResult = false;

  void makeConnection() async {
    var conn = await db.getConnection();
    setState(() {
      connection = conn;
    });
    getHistory();
    getBloodBanks();
  }

  void sendData(
      String date, int quantityController, int bloodBank, int patient) async {
    connection.query(
        'insert into BloodBankToPatient(DateRecieved, QuantityRecieved, BloodBankFK, PatientFK) values(\'${date}\', $quantityController, ${bloodBank}, ${patient})');
  }

  void getBloodBanks() async {
    bloodBanks.clear();
    var results = await connection
        .query('select BloodBankID, BloodBankName from BloodBank');
    if (results.isNotEmpty) {
      for (var row in results) {
        bloodBanks.add(BloodBank(ID: row[0], name: row[1]));
      }
    }
  }

  void _showDialog(Widget child) {
    showCupertinoModalPopup<void>(
        context: context,
        builder: (BuildContext context) => Container(
              height: 216,
              padding: const EdgeInsets.only(top: 6.0),
              // The Bottom margin is provided to align the popup above the system navigation bar.
              margin: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              // Provide a background color for the popup.
              color: CupertinoColors.systemBackground.resolveFrom(context),
              // Use a SafeArea widget to avoid system overlaps.
              child: SafeArea(
                top: false,
                child: child,
              ),
            ));
  }

  void showBottomSheet() {
    int bloodBankController = 0;
    int quantityController = 120;
    var myFormat = DateFormat('dd-MM-yyyy');
    var dateController = DateTime.now();
    showModalBottomSheet(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        context: context,
        builder: ((context) {
          return StatefulBuilder(builder: ((context, setState) {
            return Container(
              height: MediaQuery.of(context).size.height * 0.5 +
                  MediaQuery.of(context).viewInsets.bottom,
              child: Card(
                child: Form(
                  key: GlobalKey<FormState>(),
                  child: Container(
                    margin: const EdgeInsets.all(10),
                    height: MediaQuery.of(context).size.height * 0.45,
                    child: Column(
                      children: [
                        Container(
                          margin: const EdgeInsets.all(10),
                          child: const Text(
                            'New Tranfusion Entry',
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ),
                        // TextFormField(
                        //   decoration: const InputDecoration(
                        //     border: OutlineInputBorder(),
                        //     label: Text('Blood Bank'),
                        //   ),
                        //   validator: (value) {
                        //     if (value == '' || value == null) {
                        //       return 'Cannot be empty';
                        //     }
                        //   },
                        //   controller: bloodBankController,
                        // ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              'Blood Bank: ',
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.w600),
                            ),
                            CupertinoButton(
                              onPressed: (() {
                                _showDialog(CupertinoPicker(
                                  itemExtent: 32,
                                  magnification: 1.22,
                                  useMagnifier: true,
                                  onSelectedItemChanged: ((value) {
                                    setState(
                                      () {
                                        bloodBankController = value;
                                      },
                                    );
                                  }),
                                  children: List.generate(
                                    bloodBanks.length - 1,
                                    (int index) =>
                                        Text('${bloodBanks[index].name}'),
                                  ),
                                ));
                              }),
                              child: Text(bloodBanks[bloodBankController].name),
                            ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              'Quantity: ',
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.w600),
                            ),
                            CupertinoButton(
                              onPressed: (() {
                                _showDialog(CupertinoPicker(
                                  itemExtent: 32,
                                  magnification: 1.22,
                                  useMagnifier: true,
                                  onSelectedItemChanged: ((value) {
                                    setState(
                                      () {
                                        quantityController = value * 10 + 120;
                                      },
                                    );
                                  }),
                                  children: List.generate(
                                    19,
                                    (int index) => Text('${120 + index * 10}'),
                                  ),
                                ));
                              }),
                              child:
                                  Text('${quantityController.toString()} mL'),
                            ),
                          ],
                        ),
                        Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text('Date: ',
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600)),
                              CupertinoButton(
                                  onPressed: (() {
                                    _showDialog(CupertinoDatePicker(
                                      initialDateTime: dateController,
                                      mode: CupertinoDatePickerMode.date,
                                      use24hFormat: false,
                                      onDateTimeChanged: (value) {
                                        setState(
                                          () {
                                            dateController = value;
                                          },
                                        );
                                      },
                                    ));
                                  }),
                                  child: Text(myFormat.format(dateController)))
                            ]),
                        Container(
                          margin: const EdgeInsets.all(10),
                          child: ElevatedButton(
                            child: const Text('Add Entry'),
                            onPressed: (() {
                              sendData(
                                  DateFormat('yyyy-M-dd')
                                      .format(dateController),
                                  quantityController,
                                  bloodBanks[bloodBankController].ID,
                                  widget.patient.id);
                              Fluttertoast.showToast(msg: 'Entry Added');
                              Navigator.of(context).pop();
                            }),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }));
        })).whenComplete(() {
      setState(() {
        getHistory();
      });
    });
  }

  void getHistory() async {
    transfusionHistory.clear();
    var results = await connection.query(
        'select BloodBankName, QuantityRecieved, DateRecieved, BloodBankFK, PatientFK from bloodbanktopatientview where PatientFK = ${widget.patient.id}');
    if (results.isEmpty) {
      setState(() {
        emptyResult = true;
      });
    } else {
      setState(() {
        for (var row in results) {
          transfusionHistory.add(
            TranfusionHistory(
              blood_bank_name: row[0],
              QuantityRecieved: row[1],
              DateRecieved: row[2],
              BloodBankFK: row[3],
              PatientFK: row[4],
            ),
          );
        }
      });
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    makeConnection();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        floatingActionButton: FloatingActionButton(
          onPressed: () => showBottomSheet(),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          child: const Text('New'),
        ),
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          title: Text(widget.patient.name),
        ),
        body: Container(
          margin: const EdgeInsets.all(10),
          height: MediaQuery.of(context).size.height * 0.9,
          child: Column(
            children: [
              Card(
                elevation: 10,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                child: Container(
                  margin: const EdgeInsets.all(10),
                  child: ListTile(
                    title: Text(
                      widget.patient.name,
                      style: const TextStyle(fontSize: 20),
                    ),
                    leading: const Icon(
                      Icons.account_circle_rounded,
                      size: 50,
                    ),
                    subtitle: Text(widget.patient.disease),
                    trailing: Text(widget.patient.bloodGroup,
                        style: const TextStyle(fontSize: 18)),
                  ),
                ),
              ),
              Container(
                margin: const EdgeInsets.all(10),
                child: const Text(
                  'Transfusion History',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
              emptyResult
                  ? Container(
                      margin: const EdgeInsets.all(5),
                      child: const Text(
                        'No Results Found',
                        style: TextStyle(
                            fontSize: 15, fontWeight: FontWeight.w500),
                      ),
                    )
                  : ListView.builder(
                      itemCount: transfusionHistory.length,
                      shrinkWrap: true,
                      itemBuilder: (context, index) {
                        return Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          elevation: 10,
                          child: ListTile(
                            title:
                                Text(transfusionHistory[index].blood_bank_name),
                            subtitle: Text(
                                '${transfusionHistory[index].QuantityRecieved.toString()} mL'),
                            trailing: Text(
                                '${transfusionHistory[index].DateRecieved.day}-${transfusionHistory[index].DateRecieved.month}-${transfusionHistory[index].DateRecieved.year}'),
                          ),
                        );
                      },
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
