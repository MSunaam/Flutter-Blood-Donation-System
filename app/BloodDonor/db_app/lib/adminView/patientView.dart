import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'searchPatient.dart';
import '../sql/dbSql.dart';
import '../models/patient.dart';
import 'individualPatient.dart';
import 'package:flutter/cupertino.dart';

class PatientView extends StatefulWidget {
  const PatientView({super.key});

  @override
  State<PatientView> createState() => _PatientViewState();
}

class _PatientViewState extends State<PatientView> {
  var db = MySql();
  var connection;
  List patients = [];

  void makeConnection() async {
    var conn = await db.getConnection();
    setState(() {
      connection = conn;
    });
    getPatients();
  }

  @override
  void initState() {
    // TODO: implement initState
    makeConnection();
    // getPatients();
    super.initState();
  }

  void getPatients() async {
    patients.clear();
    var results = await connection.query(
        'select PatientName, BloodGroup, PatientDisease, PatientID from Patient');
    setState(() {
      for (var row in results) {
        patients.add(Patient(
            name: row[0], bloodGroup: row[1], disease: row[2], id: row[3]));
      }
    });
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

  void addPatient(TextEditingController name, TextEditingController disease,
      String bloodGroup) async {
    await connection.query(
        'insert into Patient(PatientName, PatientDisease, BloodGroup) values (\'${name.text}\',\'${disease.text}\',\'${bloodGroup}\')');
  }

  void showModalSheet(BuildContext ctx) {
    TextEditingController nameController = TextEditingController();
    TextEditingController diseaseController = TextEditingController();
    List<String> bloodGroups = [
      'A+',
      'A-',
      'B+',
      'B-',
      'AB+',
      'AB-',
      'O+',
      'O-',
    ];
    String selectedBloodGroup = 'A+';
    final formKey = GlobalKey<FormState>();

    showModalBottomSheet(
      context: ctx,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      builder: ((context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Container(
              margin: const EdgeInsets.all(15),
              child: Column(children: [
                const Text('Add New Patient',
                    style:
                        TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
                Form(
                  key: formKey,
                  child: Column(
                    children: [
                      Container(
                        margin: const EdgeInsets.symmetric(vertical: 10),
                        child: TextFormField(
                          controller: nameController,
                          decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              label: Text('Patient Name')),
                          onChanged: ((value) => setState(() {})),
                          validator: ((value) {
                            if (value == '' || value == null) {
                              return 'Name can not be blank';
                            }
                          }),
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.symmetric(vertical: 10),
                        child: TextFormField(
                          validator: (value) {
                            if (value == '' || value == null) {
                              return 'Disease can not be blank';
                            }
                          },
                          controller: diseaseController,
                          decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              label: Text('Patient Disease')),
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            'Blood Group:',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          Container(
                            margin: const EdgeInsets.symmetric(vertical: 10),
                            child: CupertinoButton(
                              onPressed: (() {
                                _showDialog(CupertinoPicker(
                                  itemExtent: 32,
                                  magnification: 1.22,
                                  useMagnifier: true,
                                  onSelectedItemChanged: ((value) {
                                    setState(
                                      () {
                                        selectedBloodGroup = bloodGroups[value];
                                      },
                                    );
                                  }),
                                  children: List.generate(
                                    bloodGroups.length,
                                    (index) => Text(bloodGroups[index]),
                                  ),
                                ));
                              }),
                              child: Text(selectedBloodGroup),
                            ),
                          ),
                        ],
                      ),
                      ElevatedButton(
                          onPressed: (() {
                            if (formKey.currentState!.validate()) {
                              addPatient(nameController, diseaseController,
                                  selectedBloodGroup);
                              Navigator.pop(context);
                              Fluttertoast.showToast(msg: 'Patient Added');
                            }
                          }),
                          child: const Text('Add Patient'))
                    ],
                  ),
                )
              ]),
            );
          },
        );
      }),
    ).whenComplete(() {
      setState(() {
        getPatients();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        floatingActionButton: FloatingActionButton(
          onPressed: (() {
            showModalSheet(context);
          }),
          child: const Icon(Icons.add),
        ),
        appBar: AppBar(
          actions: [
            IconButton(
                onPressed: (() {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) {
                        return SearchPatient(patients: patients);
                      },
                    ),
                  ).then((value) {
                    setState(() {});
                  });
                }),
                icon: const Icon(Icons.search))
          ],
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          title: const Text('Patient View'),
        ),
        body: SingleChildScrollView(
            child: RefreshIndicator(
          onRefresh: (() {
            return Future.delayed(const Duration(seconds: 1), () {
              setState(() {
                getPatients();
              });
            });
          }),
          child: Container(
            height: MediaQuery.of(context).size.height * 0.8,
            margin: const EdgeInsets.symmetric(vertical: 10),
            child: ListView.builder(
                shrinkWrap: true,
                scrollDirection: Axis.vertical,
                itemCount: patients.length,
                itemBuilder: ((context, index) {
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(context,
                          MaterialPageRoute(builder: ((context) {
                        return IndividualPatient(
                          patient: patients[index],
                        );
                      }))).then((value) => setState(
                            () {},
                          ));
                    },
                    child: Card(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      elevation: 10,
                      child: ListTile(
                        leading: const Icon(
                          Icons.account_circle_rounded,
                          size: 50,
                        ),
                        title: Text(patients[index].name),
                        subtitle: Text(patients[index].disease),
                      ),
                    ),
                  );
                })),
          ),
        )),
      ),
    );
  }
}
