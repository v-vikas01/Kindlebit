import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserList extends StatefulWidget {
  UserList({Key? key}) : super(key: key);

  @override
  _UserListState createState() => _UserListState();
}

class _UserListState extends State<UserList> {
  late List<Map<String, dynamic>> todoData = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchTodoData();
  }

  Future<void> fetchTodoData() async {
    try {
      var collection = FirebaseFirestore.instance.collection('todo');
      var querySnapshot = await collection.get();
      List<Map<String, dynamic>> newData = [];
      for (var queryDocumentSnapshot in querySnapshot.docs) {
        Map<String, dynamic> data = queryDocumentSnapshot.data();
        var name = data['name'] ?? "";
        var email = data['email'] ?? "";
        var imageUrl = data['image'] ?? "";
        newData.add({'name': name, 'email': email, 'imageUrl': imageUrl});
      }
      setState(() {
        todoData = newData;
        isLoading = false;
      });
    } catch (e) {
      print("Error fetching todo data: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('User List'),
        centerTitle: true,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator()) // Show loading indicator
          : ListView.builder(
        itemCount: todoData.length,
        itemBuilder: (context, index) {
          return ListTile(
            leading: SizedBox(
              child: CircleAvatar(
                backgroundImage: NetworkImage(todoData[index]['imageUrl'],),
              ),
            ),
            title: Text(todoData[index]['name']),
            subtitle: Text(todoData[index]['email']),
          );
        },
      ),
    );
  }
}
