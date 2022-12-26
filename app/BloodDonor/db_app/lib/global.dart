import 'package:flutter/material.dart';
import 'sql/dbSql.dart';

void insertData({
  required MySql db,
  required TextEditingController usernameController,
  required TextEditingController passwordController,
}) async {
  db.getConnection().then((conn) {
    String sqlQuery =
        'insert into admin_login (username, password) values (?, ?)';
    conn.query(sqlQuery, [usernameController.text, passwordController.text]);
    print("Data Added");
  });
}

Future<String?> printData({required MySql db}) async {
  db.getConnection().then((conn) async {
    var results = await conn.query('select count(*) from Patient');
    print(results);
    return results.toString();
  });
}
