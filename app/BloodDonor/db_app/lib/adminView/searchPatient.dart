import 'package:flutter/material.dart';
import 'individualPatient.dart';

class SearchPatient extends StatefulWidget {
  List patients;
  SearchPatient({super.key, required this.patients});
  @override
  State<SearchPatient> createState() => _SearchPatientState();
}

class _SearchPatientState extends State<SearchPatient> {
  TextEditingController editingController = TextEditingController();
  List searchList = [];
  bool emptySearch = false;

  void filterSearchResults(String? search) {
    emptySearch = false;
    searchList.clear();
    if (search == null || search.isEmpty || search == '') {
    } else {
      search = search.toLowerCase();
      for (var element in widget.patients) {
        if (element.name.toLowerCase().contains(search) ||
            element.disease.toLowerCase().contains(search) ||
            element.bloodGroup.toLowerCase().contains(search)) {
          searchList.add(element);
        }
      }
      if (searchList.isEmpty) {
        //no results were found
        emptySearch = true;
      }
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Search Patients'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ),
        body: Container(
          height: MediaQuery.of(context).size.height - 100,
          margin: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
          child: Column(
            children: [
              TextField(
                onChanged: (value) {
                  filterSearchResults(value);
                },
                controller: editingController,
                decoration: const InputDecoration(
                    labelText: "Search",
                    hintText: "Search",
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(25.0)))),
              ),
              Container(
                height: MediaQuery.of(context).size.height * 0.7,
                child: searchList.isEmpty && emptySearch == false
                    ? ListView.builder(
                        itemCount: widget.patients.length,
                        shrinkWrap: true,
                        itemBuilder: ((context, index) {
                          return GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: ((context) => IndividualPatient(
                                      patient: widget.patients[index])),
                                ),
                              ).then((value) {
                                setState(() {});
                              });
                            },
                            child: Container(
                              margin: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 1),
                              child: Card(
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10)),
                                  elevation: 4,
                                  child: ListTile(
                                    leading: const Icon(
                                      Icons.bloodtype,
                                      size: 40,
                                    ),
                                    title: Text(widget.patients[index].name),
                                    subtitle:
                                        Text(widget.patients[index].disease),
                                    trailing:
                                        Text(widget.patients[index].bloodGroup),
                                  )),
                            ),
                          );
                        }))
                    : searchList.isEmpty && emptySearch == true
                        ? Container(
                            margin: const EdgeInsets.all(10),
                            child: const Text('No results Found'),
                          )
                        : ListView.builder(
                            itemCount: searchList.length,
                            shrinkWrap: true,
                            itemBuilder: ((context, index) {
                              return GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: ((context) => IndividualPatient(
                                          patient: searchList[index])),
                                    ),
                                  ).then((value) {
                                    setState(() {});
                                  });
                                },
                                child: Container(
                                  margin: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 1),
                                  child: Card(
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(10)),
                                      elevation: 4,
                                      child: ListTile(
                                        leading: const Icon(
                                          Icons.bloodtype,
                                          size: 40,
                                        ),
                                        title: Text(searchList[index].name),
                                        subtitle:
                                            Text(searchList[index].disease),
                                        trailing:
                                            Text(searchList[index].bloodGroup),
                                      )),
                                ),
                              );
                            })),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
