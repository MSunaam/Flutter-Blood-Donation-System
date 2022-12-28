import 'package:fluttertoast/fluttertoast.dart';

import 'package:db_app/sql/dbSql.dart';
import '../models/bloodBank.dart';

import 'package:flutter/material.dart';
import 'package:mysql1/mysql1.dart';
import 'bloodBankView.dart';
import 'searchBloodBanks.dart';
import 'patientView.dart';

class adminPage extends StatefulWidget {
  final adminName;
  const adminPage({
    super.key,
    required this.adminName,
  });

  @override
  State<adminPage> createState() => _adminPageState();
}

class _adminPageState extends State<adminPage> {
  final db = MySql();
  String? numberPatients = '';
  String? numberDonors = '';
  List bloodBanks = [];
  bool? checkIfBankExists = null;
  bool bankAdded = false;
  late MySqlConnection connection;

  void getNumberPatient() async {
    db.getConnection().then((conn) async {
      var results = await conn.query('select count(*) from Patient');
      print(results);
      var count = results.toString();
      setState(() {
        numberPatients = count.replaceAll(RegExp(r'[^0-9]'), '');
      });
    });
  }

  void getNumberDonor() async {
    db.getConnection().then((conn) async {
      var results = await conn.query('select count(*) from Donor');
      print(results);
      var count = results.toString();
      setState(() {
        numberDonors = count.replaceAll(RegExp(r'[^0-9]'), '');
      });
    });
  }

  void getBloodbanks() async {
    bloodBanks.clear();
    db.getConnection().then((conn) async {
      var results = await conn.query(
          'select BloodBankName, BloodBankAddress, BloodBankContact, BloodBankId from BloodBank');

      setState(() {
        for (var row in results) {
          bloodBanks.add(BloodBank(
              BloodBankName: row[0],
              BloodBankAddress: row[1],
              BloodBankContact: row[2],
              BloodBankId: row[3]));
        }
      });
    });
  }

  Future<bool?> checkBank(
      {required TextEditingController nameController,
      required TextEditingController addressController,
      required TextEditingController contactController}) async {
    var result = await connection.query(
        'select BloodBankName, BloodBankAddress, BloodBankAddress from BloodBank where BloodBankName = \'${nameController.text}\' and BloodBankAddress = \'${addressController.text}\' and BloodBankContact = \'${contactController.text}\'');
    if (result.isNotEmpty) {
      setState(() {
        checkIfBankExists = true;
      });
    }
  }

  void insertBank(
      {required TextEditingController nameController,
      required TextEditingController addressController,
      required TextEditingController contactController}) async {
    db.getConnection().then((conn) async {
      conn.query(
          'insert into BloodBank (BloodBankName, BloodBankAddress, BloodBankContact) values(\'${nameController.text}\', \'${addressController.text}\', \'${contactController.text}\')');
    });
  }

  void makeConnection() async {
    var conn = await db.getConnection();
    setState(() {
      connection = conn;
    });
  }

  bool? showBottomSheet(BuildContext ctx) {
    final formKey = GlobalKey<FormState>();
    var nameController = TextEditingController();
    var phoneNumcontroller = TextEditingController();
    var addressController = TextEditingController();
    showModalBottomSheet(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      isScrollControlled: true,
      context: context,
      builder: ((context) {
        return StatefulBuilder(
          builder: ((context, setState) {
            return Padding(
              padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom),
              child: Container(
                margin: const EdgeInsets.symmetric(vertical: 7, horizontal: 15),
                height: MediaQuery.of(context).size.height * 0.45,
                child: Form(
                  key: formKey,
                  child: Column(
                    children: [
                      Container(
                        margin: const EdgeInsets.all(7),
                        child: const Text(
                          'Blood Bank Entry',
                          style: TextStyle(
                              fontSize: 22, fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.symmetric(
                            vertical: 5, horizontal: 0),
                        child: TextFormField(
                          onChanged: (value) {
                            setState(
                              () {
                                checkIfBankExists = false;
                              },
                            );
                          },
                          validator: (value) {
                            if (value == '' || value == null) {
                              return 'Please Enter Name';
                            }
                          },
                          controller: nameController,
                          decoration: const InputDecoration(
                              icon: Icon(Icons.bloodtype),
                              label: Text('Name'),
                              hintText: 'Blood Bank Name',
                              border: OutlineInputBorder()),
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.symmetric(vertical: 5),
                        child: TextFormField(
                          onChanged: (value) {
                            setState(
                              () {
                                checkIfBankExists = false;
                              },
                            );
                          },
                          validator: (value) {
                            if (value == '' || value == null) {
                              return 'Please Enter Address';
                            }
                          },
                          controller: addressController,
                          decoration: const InputDecoration(
                              icon: Icon(Icons.location_city),
                              label: Text('Address'),
                              hintText: 'Blood Bank Address',
                              border: OutlineInputBorder()),
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.symmetric(vertical: 5),
                        child: TextFormField(
                          onChanged: (value) {
                            setState(
                              () {
                                checkIfBankExists = false;
                              },
                            );
                          },
                          validator: (value) {
                            if (value == '' || value == null) {
                              return 'Please Enter Contact';
                            }
                          },
                          controller: phoneNumcontroller,
                          decoration: const InputDecoration(
                              icon: Icon(Icons.phone),
                              label: Text('Contact'),
                              hintText: 'Blood Bank Contact',
                              border: OutlineInputBorder()),
                        ),
                      ),
                      Container(
                          child: ElevatedButton(
                        onPressed: (() async {
                          if (formKey.currentState!.validate()) {
                            var check = await checkBank(
                                nameController: nameController,
                                addressController: addressController,
                                contactController: phoneNumcontroller);
                            setState(() {
                              checkIfBankExists = checkIfBankExists;
                            });
                            if (checkIfBankExists == false) {
                              insertBank(
                                  nameController: nameController,
                                  addressController: addressController,
                                  contactController: phoneNumcontroller);
                              print('Data Added');
                              setState(() {
                                bankAdded = true;
                                Navigator.pop(context);
                              });
                              Fluttertoast.showToast(msg: 'Blood Bank Added');
                            }
                          }
                        }),
                        child: const Text('Enter Record'),
                      )),
                      checkIfBankExists ?? false
                          ? const Text('Bank Already Exists!',
                              style: TextStyle(color: Colors.red))
                          : const Text(''),
                    ],
                  ),
                ),
              ),
            );
          }),
        );
      }),
    ).whenComplete(() {
      setState(() {
        getBloodbanks();
      });
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    getNumberPatient();
    getNumberDonor();
    getBloodbanks();
    makeConnection();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: Scaffold(
      appBar: AppBar(
        leadingWidth: 100,
        leading: TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text(
              'Sign Out',
              style: TextStyle(color: Colors.white),
            )),
        title: const Text('Admin Page'),
        actions: [
          IconButton(
              onPressed: (() {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: ((context) => SearchWidget(
                          bloodBanks: bloodBanks,
                        )),
                  ),
                ).then((value) {
                  setState(() {});
                });
              }),
              icon: const Icon(Icons.search))
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showBottomSheet(context);
        },
        child: const Icon(Icons.add),
      ),
      body: SingleChildScrollView(
        child: RefreshIndicator(
          child: SizedBox(
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  SizedBox(
                      height: MediaQuery.of(context).size.height * 0.2,
                      child: Column(
                        children: [
                          const Text(
                            'Welcome!',
                            style: TextStyle(
                                fontSize: 40, fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                          ),
                          Text('admin: ${widget.adminName}',
                              style: const TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.w500)),
                          Flexible(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    Navigator.of(context).push(
                                        MaterialPageRoute(builder: ((context) {
                                      return PatientView();
                                    }))).then((value) {
                                      setState(() {});
                                    });
                                  },
                                  child: Container(
                                    decoration: BoxDecoration(
                                        color: Colors.amber,
                                        borderRadius:
                                            BorderRadius.circular(20)),
                                    width: MediaQuery.of(context).size.width *
                                        0.40,
                                    padding: const EdgeInsets.all(20),
                                    margin: const EdgeInsets.all(20),
                                    child: Column(
                                      children: [
                                        const Text('Total Patients:',
                                            style: TextStyle(
                                                fontSize: 17,
                                                fontWeight: FontWeight.w500)),
                                        Text(numberPatients ?? 'NaN'),
                                      ],
                                    ),
                                  ),
                                ),
                                Container(
                                  decoration: BoxDecoration(
                                      color: Colors.blue,
                                      borderRadius: BorderRadius.circular(20)),
                                  padding: const EdgeInsets.all(20),
                                  margin: const EdgeInsets.all(20),
                                  width:
                                      MediaQuery.of(context).size.width * 0.4,
                                  child: Column(
                                    children: [
                                      const Text(
                                        'Total Donors:',
                                        style: TextStyle(
                                            fontSize: 17,
                                            fontWeight: FontWeight.w500),
                                      ),
                                      Text(numberDonors ?? 'NaN'),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      )),
                  Container(
                    height: MediaQuery.of(context).size.height * 0.6,
                    child: ListView.builder(
                        itemCount: bloodBanks.length,
                        scrollDirection: Axis.vertical,
                        shrinkWrap: true,
                        itemBuilder: ((context, index) {
                          return GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: ((context) => BloodBankView(
                                        bloodbank: bloodBanks[index],
                                      )),
                                ),
                              ).then((value) {
                                setState(() {});
                              });
                            },
                            child: Card(
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10)),
                                elevation: 4,
                                child: ListTile(
                                  leading: const Icon(
                                    Icons.bloodtype,
                                    size: 40,
                                  ),
                                  title: Text(bloodBanks[index].BloodBankName),
                                  subtitle:
                                      Text(bloodBanks[index].BloodBankAddress),
                                )),
                          );
                        })),
                  ),
                ]),
          ),
          onRefresh: () {
            return Future.delayed(const Duration(seconds: 1), (() {
              setState(() {
                getBloodbanks();
              });
              Fluttertoast.showToast(msg: 'Page Refreshed');
            }));
          },
        ),
      ),
    ));
  }
}
