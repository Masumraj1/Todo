import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart'as http;


class AddTodoPage extends StatefulWidget {
  final Map? todo;
  const AddTodoPage({super.key,this.todo});

  @override
  State<AddTodoPage> createState() => _AddTodoPageState();
}

class _AddTodoPageState extends State<AddTodoPage> {
  TextEditingController tittleController =TextEditingController();
  TextEditingController descriptionController =TextEditingController();
  bool isEdit = false;
  @override
  void initState(){
    super.initState();
    final todo = widget.todo;

    if(todo != null){
      isEdit = true;
      final title = todo["title"];
      final description = todo ["description"];
      tittleController.text=title;
      descriptionController.text = description;
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(isEdit ? " Edit Todo" : "Add Todo"),centerTitle: true,),
      body: ListView(
        padding: EdgeInsets.all(20),
        children:  [
          TextField(
            controller: tittleController,
            decoration: InputDecoration(
              hintText: "Title"
            ),
          ),  TextField(
            controller: descriptionController,
            decoration: InputDecoration(
              hintText: "Description",
            ),
            maxLines: 8,
          ),
          SizedBox(
            height: 25,
          ),
          ElevatedButton(onPressed: isEdit ? updateData : subMitData, child: Text(isEdit ? "Update":"Submit"))
        ],
      ),
    );
  }
  Future<void> updateData()async{
    final todo = widget.todo;
    if(todo == null){
      print(" You can not call update without todo data ");
      return ;
    }
    final id = todo["_id"];
    final title = tittleController.text;
    final description = descriptionController.text;
    final body  ={

      "title": title,
      "description": description,
      "is_completed": false
    };
    final url ="https://api.nstack.in/v1/todos/65de4f83ff73aeeeb2e09a2f";
    final uri =Uri.parse(url);
    final response = await http.put(
        uri,
        body: jsonEncode(body),
    headers: {
    "Content-Type": "application/json"
  },);
    if(response.statusCode ==200){
      showSuccessMessage("Update successfull");
    }
    else{
      // print("Creation successfully");
      showErrorMessage("Update Failed");
      print(response.body);

    }
  }

    Future<void> subMitData()async{
    final title = tittleController.text;
    final description = descriptionController.text;
    final body  ={

        "title": title,
        "description": description,
        "is_completed": false
    };
    final url ="https://api.nstack.in/v1/todos";
    final uri =Uri.parse(url);
    final response = await http.post(
      uri,
      body: jsonEncode(body),
      headers: {
        "Content-Type": "application/json"
      }
    );
    if(response.statusCode ==201){
      tittleController.text = "";
      descriptionController.text ="";
      showSuccessMessage("SuccessFully created");

    }

    else{
      // print("Creation successfully");
      showErrorMessage("Failed");
      print(response.body);

    }
  }
  void showSuccessMessage(String message){
    final snackbar = SnackBar(content: Text(message));
    ScaffoldMessenger.of(context).showSnackBar(snackbar);
  }
  void showErrorMessage(String message){
    final snackbar = SnackBar(content: Text(message,style: TextStyle(backgroundColor: Colors.red),));
    ScaffoldMessenger.of(context).showSnackBar(snackbar);
  }
}
