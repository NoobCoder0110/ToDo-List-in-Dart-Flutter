import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class AddTodoPage extends StatefulWidget {
  final Map? todo;
  const AddTodoPage({super.key, this.todo,});

  @override
  State<AddTodoPage> createState() => _AddTodoPageState();
}

class _AddTodoPageState extends State<AddTodoPage> {

  TextEditingController titleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  bool isEdit = false;

  @override
  void initState() {
    super.initState();
    final todo = widget.todo;
    if (todo != null){
      isEdit = true;
      final title = todo['title'];
      final description = todo['description'];
      titleController.text = title;
      descriptionController.text = description;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          isEdit ? 'Edit Todo' : 'Add Todo'
          ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          TextField(
            controller: titleController,
            decoration: const InputDecoration(hintText: 'Title'),
          ),
          const SizedBox(height: 20,),
          TextField(
            controller: descriptionController,
            decoration: const InputDecoration(hintText: 'Description'),
            keyboardType: TextInputType.multiline,
            minLines: 5,
            maxLines: 8,
          ),
          const SizedBox(height: 20,),
          ElevatedButton(
            onPressed: isEdit ? updatedata : submitData, 
            child: const Text('Submit')
            ),
        ],
      ),
    );
  }

  Future<void> updatedata () async {
    final todo = widget.todo;
    if (todo == null) {
      print('you cannot call updated without todo data');
      return;
    }
    final id = todo['id'];
    final title = titleController.text;
    final description = descriptionController.text;
    final body = {
    "title": title,
    "description": description,
    "is_completed": false,
    };

    final url = 'http://127.0.0.1:8000/todo/task/$id/';
    final uri = Uri.parse(url);
    final response = await http.put(
      uri, 
      body: jsonEncode(body),
      headers: {
        'Content-Type': 'application/json'
      }
      );
      
      if (response.statusCode == 201 || response.statusCode == 200) {
      showSuccessMessage("Updated Data Entered");
    } else {
      showErrorMessage("Updated Data Failed to Enter");
    }

  }


  Future<void> submitData () async {
    try{
    final title = titleController.text;
    final description = descriptionController.text;
    final body = {
    "title": title,
    "description": description,
    "is_completed": false,
    };

    final url = 'http://127.0.0.1:8000/todo/task/';
    final uri = Uri.parse(url);
    final response = await http.post(
      uri, 
      body: jsonEncode(body),
      headers: {
        'Content-Type': 'application/json'
      }
      );

    if (response.statusCode == 201 || response.statusCode == 200) {
      titleController.text = '';
      descriptionController.text = '';
      showSuccessMessage("Data Entered");
    } else {
      showErrorMessage("Data Failed to Enter");
    }
    }
    catch (e){
      print("Error is $e");
    }
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