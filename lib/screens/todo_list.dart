import 'package:flutter/material.dart';
import 'package:todo/screens/add_page.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class TodoListPage extends StatefulWidget {
  const TodoListPage({Key? key}) : super(key: key);

  @override
  State<TodoListPage> createState() => _TodoListPageState();
}

class _TodoListPageState extends State<TodoListPage> {
  bool isLoading = true;
  List items = [];

  @override
  initState() {
    super.initState();
    fetchTodo();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Todo List"),
        centerTitle: true,
      ),
      body: Visibility(
        visible: isLoading,
        child: Center(child: CircularProgressIndicator()),
        replacement: RefreshIndicator(
          onRefresh: fetchTodo,
          child: ListView.builder(
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index] as Map;
              final id = item["_id"] as String;
              return ListTile(
                leading: CircleAvatar(
                  child: Text("${index + 1}"),
                ),
                title: Text(item["title"]),
                subtitle: Text(item["description"]),
                trailing: PopupMenuButton(
                  onSelected: (value) {
                    if (value == "Edit") {
                      // Handle Edit action
                      navigateTodoEditPage(item);
                    } else if (value == "Delete") {
                      deleteById(id); // Corrected method name
                    }
                  },
                  itemBuilder: (context) {
                    return [
                      PopupMenuItem(
                        child: Text("Edit"),
                        value: "Edit",
                      ),
                      PopupMenuItem(
                        child: Text("Delete"),
                        value: "Delete",
                      ),
                    ];
                  },
                ),
              );
            },
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: navigateTodoAddPage,
        label: Text("Add Todo"),
      ),
    );
  }

  void navigateTodoEditPage(Map item) {
    final route = MaterialPageRoute(builder: (context) => AddTodoPage(todo:item));
    Navigator.push(context, route);
  }
  Future<void> navigateTodoAddPage() async{
    final route = MaterialPageRoute(builder: (context) => AddTodoPage());
   await Navigator.push(context, route);
   setState(() {
     isLoading = true;
   });
   fetchTodo();
  }

  Future<void> deleteById(String id) async {
    final url = "https://api.nstack.in/v1/todos/$id";
    final uri = Uri.parse(url);

    final response = await http.delete(uri);
    if (response.statusCode == 200) {
      // Successfully deleted
   final filtered=   items.where((element) => element ["_id"] != id).toList();
      setState(() {
        items = filtered;
      });
    } else {
      showErrorMessage ("Deletion Failed");
    }
  }

  Future<void> fetchTodo() async {
    final url = "https://api.nstack.in/v1/todos?page=1&limit=10";
    final uri = Uri.parse(url);
    final response = await http.get(uri);
    if (response.statusCode == 200) {
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      final result = json["items"] as List<dynamic>;
      setState(() {
        items = result;
      });
    } else {
      // Handle error here
    }

    setState(() {
      isLoading = false; // Set isLoading to false after data is fetched.
    });
  }

  void showErrorMessage(String message){
    final snackbar = SnackBar(content: Text(message,style: TextStyle(backgroundColor: Colors.red),));
    ScaffoldMessenger.of(context).showSnackBar(snackbar);
  }
}