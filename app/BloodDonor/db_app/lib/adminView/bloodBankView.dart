import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../sql/dbSql.dart';
import '../models/bloodBank.dart';

class BloodBankView extends StatefulWidget {
  BloodBank bloodbank;
  BloodBankView({super.key, required this.bloodbank});

  @override
  State<BloodBankView> createState() => _BloodBankViewState();
}

class _BloodBankViewState extends State<BloodBankView> {
  late String name;
  late String address;
  late String contact;
  var connection;
  final db = MySql();
  final nameController = TextEditingController();
  final addressController = TextEditingController();
  final contactController = TextEditingController();

  void getConn() async {
    name = widget.bloodbank.BloodBankName;
    contact = widget.bloodbank.BloodBankContact;
    address = widget.bloodbank.BloodBankAddress;
    var con = await db.getConnection();
    setState(() {
      connection = con;
    });
  }

  var isChanged;

  Future<bool?> updateData() async {
    connection.query(
        'update BloodBank set BloodBankName = \'${nameController.text}\', BloodBankAddress = \'${addressController.text}\', BloodBankContact = \'${contactController.text}\' where BloodBankName = \'${widget.bloodbank.BloodBankName}\' and BloodBankAddress = \'${widget.bloodbank.BloodBankAddress}\' and BloodBankContact = \'${widget.bloodbank.BloodBankContact}\'');
    return null;
  }

  void changeBloodBank() async {
    var temp = await updateData();
    isChanged = false;
  }

  @override
  void initState() {
    // TODO: implement initState
    getConn();
    super.initState();
  }

  void updateScreen() {
    setState(() {
      widget.bloodbank.BloodBankContact = contactController.text;
      widget.bloodbank.BloodBankName = nameController.text;
      widget.bloodbank.BloodBankAddress = addressController.text;
    });
  }

  bool? updateBloodBank() {
    if (isChanged) {
      changeBloodBank();
      updateScreen();
      Navigator.pop(context);
      Fluttertoast.showToast(msg: 'Blood Bank Changed');
    } else {
      Fluttertoast.showToast(msg: 'Change Blood Bank details to save');
      return null;
    }
  }

  void showModalSheet() {
    final formKey = GlobalKey<FormState>();
    setState(() {
      nameController.text = widget.bloodbank.BloodBankName;
      addressController.text = widget.bloodbank.BloodBankAddress;
      contactController.text = widget.bloodbank.BloodBankContact;
      isChanged = false;
    });
    showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      builder: ((context) {
        return StatefulBuilder(builder: ((context, setState) {
          return Card(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            elevation: 10,
            child: Padding(
              padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom),
              child: Container(
                height: MediaQuery.of(context).size.height * 0.5,
                margin: const EdgeInsets.all(15),
                child: Column(
                  children: [
                    const Text(
                      'Edit Blood Bank',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    Form(
                      key: formKey,
                      child: Column(children: [
                        Container(
                          margin: const EdgeInsets.symmetric(vertical: 5),
                          child: TextFormField(
                            controller: nameController,
                            decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                                label: Text('Edit Name')),
                            validator: (value) {
                              if (value == null || value == '') {
                                return 'Name can not be empty';
                              }
                            },
                            onChanged: (value) {
                              isChanged = true;
                            },
                          ),
                        ),
                        Container(
                          margin: const EdgeInsets.symmetric(vertical: 5),
                          child: TextFormField(
                            controller: addressController,
                            decoration: const InputDecoration(
                              label: Text('Edit Address'),
                              border: OutlineInputBorder(),
                            ),
                            validator: (value) {
                              if (value == null || value == '') {
                                return 'Address can not be empty';
                              }
                            },
                            onChanged: (value) {
                              isChanged = true;
                            },
                          ),
                        ),
                        Container(
                          margin: const EdgeInsets.symmetric(vertical: 5),
                          child: TextFormField(
                            controller: contactController,
                            decoration: const InputDecoration(
                              label: Text('Edit Contact'),
                              border: OutlineInputBorder(),
                            ),
                            validator: (value) {
                              if (value == null || value == '') {
                                return 'Contact cannot be empty';
                              }
                            },
                            onChanged: ((value) {
                              isChanged = true;
                            }),
                          ),
                        ),
                        Container(
                          margin: const EdgeInsets.symmetric(vertical: 5),
                          child: ElevatedButton(
                            onPressed: (() {
                              if (formKey.currentState!.validate()) {
                                updateBloodBank();
                              }
                            }),
                            child: const Text('Edit Blood Bank'),
                          ),
                        ),
                      ]),
                    )
                  ],
                ),
              ),
            ),
          );
        }));
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        floatingActionButton: FloatingActionButton.extended(
          label: const Text('Edit'),
          onPressed: showModalSheet,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
        appBar: AppBar(
          leading: IconButton(
            onPressed: (() => Navigator.of(context).pop()),
            icon: const Icon(Icons.arrow_back),
          ),
          title: Text(widget.bloodbank.BloodBankName),
        ),
        body: Container(
          margin: const EdgeInsets.all(10),
          height: MediaQuery.of(context).size.height * 0.4,
          child: Card(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            elevation: 10,
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Location: ${widget.bloodbank.BloodBankAddress}',
                    textAlign: TextAlign.left,
                    style: const TextStyle(fontSize: 19),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Contact: ${widget.bloodbank.BloodBankContact}',
                        style: const TextStyle(fontSize: 19),
                      ),
                      const IconButton(
                        iconSize: 30,
                        onPressed: (null),
                        icon: Icon(Icons.call),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
