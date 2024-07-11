import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:todo_list/screen/add_list.dart';
import 'package:http/http.dart' as http;

class TodoList extends StatefulWidget {
  const TodoList({super.key});

  @override
  State<TodoList> createState() => _TodoListState();
}

class _TodoListState extends State<TodoList> {

  bool isLoading = true;

  List items= [];

  @override
  void initState() {
    super.initState();
    fetchTodoList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Todo List')
        ),
        body: Visibility(
          visible: isLoading,
          child: Center(child: CircularProgressIndicator()),
          replacement: RefreshIndicator(
            onRefresh: fetchTodoList,
            child: Visibility(
              visible: items.isNotEmpty,
              replacement: Center(
                child: Text(
                  'No Todo Item',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
              ),
              child: ListView.builder(
                itemCount: items.length,
                padding: EdgeInsets.all(8),
                itemBuilder: (context, index) {
                  final item = items[index];
                  final id = item['id'] as int; 
                return Card(
                  child: ListTile(
                    leading: CircleAvatar(child: Text('${index + 1}')),
                    title: Text(item['title']),
                    subtitle: Text(item['description']),
                    trailing: PopupMenuButton(
                      onSelected: (value) {
                        if (value == 'edit') {
                          navigateToEditPage(item);
                                
                        } else if (value == 'delete') {
                          deleteById(id);
                        }
                      },
                      itemBuilder: (context) {
                        return[
                          const PopupMenuItem(
                            value: 'edit',
                            child: Text("Edit"),
                            ),
                          const PopupMenuItem(
                            value: 'delete',
                            child: Text("Delete"),
                            ),
                        ];
                      },
                      ),
                  ),
                );
              }, ),
            ),
          ),
        ),
        floatingActionButton: FloatingActionButton.extended(onPressed: navigateToAddPage, label: const Text('Add Data')),
    );
  }

  Future<void> navigateToEditPage(Map item) async {
    final route = MaterialPageRoute(builder: (context) => AddTodoPage(todo: item));
    await Navigator.push(context, route);
    setState(() {
      isLoading = true;
    });
    fetchTodoList();
  }

  Future<void>navigateToAddPage() async {
    final route = MaterialPageRoute(builder: (context) => const AddTodoPage());
    await Navigator.push(context, route);
    setState(() {
      isLoading = true;
    });
    fetchTodoList();
  }

  Future <void> deleteById (int id) async {
    try{
     final url = 'http://127.0.0.1:8000/todo/task/$id/';
     final uri = Uri.parse(url);
     final response = await http.delete(uri);
     if (response.statusCode == 200 || response.statusCode == 204 ) {
      final filtered = items.where((element) => element['id'] != id).toList();
      setState(() {
        items = filtered;
      });
     } else {
      showErrorMessage('Delete Failed');
     }
    }
    catch (e){
      print("Error is $e");
    }
  }

  Future <void> fetchTodoList () async {
    final url = 'http://127.0.0.1:8000/todo/task/';
    final uri = Uri.parse(url);
    final response = await http.get(uri);
    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      final result = json;
      setState(() {
        items = result;
      });
    }
    setState(() {
      isLoading = false;
    });
  }

  void showSuccessMessage(String message) {
    final snackBar = SnackBar(
      content: Text(message),
      backgroundColor: Colors.green,
      );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  void showErrorMessage(String message) {
    final snackBar = SnackBar(
      content: Text(
        message,
        style: const TextStyle(color: Colors.white),
        ),
      backgroundColor: Colors.red,
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

}