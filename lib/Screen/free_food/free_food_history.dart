import 'package:eshop_multivendor/Helper/Color.dart';
import 'package:eshop_multivendor/Helper/String.dart';
import 'package:eshop_multivendor/api/globalApi/api.dart';
import 'package:flutter/material.dart';

class FreeFoodHistory extends StatefulWidget {
  const FreeFoodHistory({Key? key}) : super(key: key);

  @override
  State<FreeFoodHistory> createState() => _FreeFoodHistoryState();
}

class _FreeFoodHistoryState extends State<FreeFoodHistory> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: colors.primary,
        title: Text("History"),
      ),
      body: FutureBuilder(
          future: freeFoodHistory(CUR_USERID),
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            if (snapshot.hasData) {
              return ListView.builder(
                itemCount: snapshot.data.data.length,
                itemBuilder: (BuildContext context, int index) {
                  var data = snapshot.data.data;
                  return Column(
                    children: [
                      ListTile(
                        title:
                            Text("Person Name : ${data[index].donatePersonName}"),
                        subtitle: data[index].status == "0"
                            ? Text(
                                "Status : Pending",
                                style: TextStyle(color: Colors.orange),
                              )
                            : data[index].status == "1"
                                ? Text(
                                    "Status : Accepted",
                                    style: TextStyle(color: Colors.green),
                                  )
                                : Text(
                                    "Status : Rejected",
                                    style: TextStyle(color: Colors.red),
                                  ),
                      ),
                      Divider()
                    ],
                  );
                },
              );
            } else if (snapshot.hasError) {
              return Icon(Icons.error_outline);
            } else {
              return CircularProgressIndicator();
            }
          }),
    );
  }
}
