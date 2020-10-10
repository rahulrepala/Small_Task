import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:task/models/rate.dart';
import 'package:task/utils/database_helper.dart';


void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Task',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  var rates;
  int load=0;
  TextEditingController con;
  int val=1;
  String date="";
  List<Map> rt = [];

  @override
  void initState() {
    con=new TextEditingController();
    _load();
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:  Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(3.0),
              child: Text("EURO",),
            ),
            Padding(
              padding: const EdgeInsets.all(3.0),
              child: Text(date),
            )
         ],
        ),
        actions: <Widget>[
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: RaisedButton(
            onPressed: ()async{
            var db = new DataBaseHelper();
            await db.deleteAllRates();         
               setState(() {
                 load=0;
               });
                 _load();
            },
            child: Text("Refresh"),
        ),
          ),
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
                  child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Card(
                  child: Container(
                    height: MediaQuery.of(context).size.height*0.25,
                    child: Column(
                      children: <Widget>[
                         Padding(
                           padding: const EdgeInsets.all(20.0),
                           child: TextField(
                              controller: con,
                              keyboardType: TextInputType.number,
                              decoration: new InputDecoration(
                              border: new OutlineInputBorder(
                              borderRadius: const BorderRadius.all(
                              const Radius.circular(10.0),
                              ),
                             ),
                             filled: true,
                             hintStyle: new TextStyle(color: Colors.grey[800]),
                             hintText: "Type in your text",
                             fillColor: Colors.white70),
                            ),
                         ),
                         Padding(
                           padding: const EdgeInsets.all(8.0),
                           child: RaisedButton(
                             child: Text("Convert"),
                             onPressed: (){
                                 setState(() {
                                   val=int.parse(con.text.toString());
                                 });
                             },
                             ),
                         )
                      ],
                    ),
                    ),
                  ),
              ),

             load==1? Container(
               height: MediaQuery.of(context).size.height*0.55,
               child: ListView.builder
                  (
                    itemCount: rt.length,
                    itemBuilder: (BuildContext ctxt, int index) {
                  //    Map rt = rt[index];
                      return Card(
                       child:Padding(
                         padding: const EdgeInsets.all(8.0),
                         child: Row(
                           mainAxisAlignment: MainAxisAlignment.center,
                           children: <Widget>[
                              Text(rt[index]['name']+"  :  "),
                              Text((rt[index]['rate']*val).toString())
                            ],
                           ),
                       )
                       );
                    }
                ),
             ):Container(child: Text("Loading..."),)



            ],
          ),
        ),
      ),
    );
  }

  void _load() async{

      SharedPreferences prefs = await SharedPreferences.getInstance();        
        setState(() {
           date = prefs.getString('date') ?? "2020-10-10";
        });

      var db = new DataBaseHelper();
      int cnt=await db.getCount();  
      print(cnt.toString());
      if(cnt==0){

        var url = 'https://api.exchangeratesapi.io/latest';
        var resp = await http.get(url);
        var result = json.decode(resp.body);
        var _result=result['rates'];
        var now = new DateTime.now();
        prefs.setString('date',now.toString().substring(0,19));
         
        rates = _result.entries.toList();
       
        for(int i=0;i<rates.length;i++){

         int savedRate =await db.saveRate(new Rate(rates[i].key.toString(),rates[i].value));
         print(savedRate);
         rt.add(
           {'name':rates[i].key.toString(),
            'rate':rates[i].value 
           });
       }

      setState(() {
        load=1;
      });
      
      }
      else{
   
      print("else block");
       for(int i=1;i<cnt+1;i++){

         Rate rat =await db.getRate(i);
         rt.add(
           {'name':rat.name,
            'rate':rat.rate 
           });
       }
      
      setState(() {
        load=1;
      });
      

      }
        
  }

}
