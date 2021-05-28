import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

// fungsi main dalam aplikasi, titik utama untuk menjalankan aplikasi
void main() {
  runApp(App());
}

Future<List<Task>> fetchTask() async {
  // Menjalankan API GET
  http.Response response = await http.get('https://flask-flutter-todo-api.herokuapp.com/api/tasks');
  // decode response string menjadi map
  var responseJson = json.decode(response.body);
  // return list of Task
  return (responseJson['data'] as List)
      .map((p) => Task.fromJson(p))
      .toList();
  
}

// Function untuk menjalankan API DELETE
Future<void> deleteTask(String taskId) async {
  // Menjalankan API untuk menghapus task berdasarkan id
  final http.Response response = await http.delete(
    Uri.parse('https://flask-flutter-todo-api.herokuapp.com/api/tasks/$taskId'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
  );


  // Respone handler
  if (response.statusCode == 200) {
    // Logging buat memastikan delete berhasil
    log('Delete success');
    
  } else {
    // Jika server tidak merespon "200 OK response",
    // program akan menjalankan pengecualian disini.
    throw Exception('Failed to delete task.');
  }
}

// Function untuk membuat task, menjalankan API POST
Future<Task> createTask(String title) async{
  final response = await http.post(
    Uri.parse('https://flask-flutter-todo-api.herokuapp.com/api/tasks'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
    body: jsonEncode(<String, String>{
      'task': title,
    }),
  );

  if (response.statusCode == 200) {
    // mengembalikan data
    var responseJson = json.decode(response.body);
    return Task.fromJson(responseJson['data']);
  } else {
    // Jika server tidak merespon "200 OK response",
    // program akan menjalankan pengecualian disini.
    throw Exception('Failed to create task.');
  }
}

// Definisi class untuk object task dari API
class Task {
  // Properties
  final String id, task;

  // Constructor
  Task({
    this.id,
    this.task
  });

  // factory Method untuk convert json ke object task
  factory Task.fromJson(Map<String, dynamic> json) {
    return new Task(
      id: json['id'].toString(),
      task: json['task'].toString(),
    );
  }
}

// base aplikasi untuk mendifinisikan konfigurasi aplikasi.
class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Aplikasi menggunakan Material Widget (android)
    return MaterialApp(
      // Nama Aplikasi yang akan terinstall
      title: 'uas_185411193',
      // Halaman home aplikasi adalah widget dengan nama TodoList
      home: TodoList(),
      // Konfigurasi warna dan font aplikasi
      theme: ThemeData(
        primaryColor: Colors.black,
        fontFamily: 'Roboto'
      ),
    );
  }
}

// widget statefull dimana memiliki konten dinamis.
class TodoList extends StatefulWidget {

  // definisi state yang berisi tentang data kegiatan (to-do)
  @override
  _TodoListState createState() => _TodoListState();
}


// detail handler state
class _TodoListState extends State<TodoList> {

  // Penampungan data dari fetchAPI
  Future<List<Task>> futureTask;

  // Text field
  final TextEditingController _textFieldController = TextEditingController();

  @override
  void initState() {
    super.initState();
    futureTask = fetchTask();
  }

  @override
  Widget build(BuildContext context) {
    // Halaman widget to-do, menggunakan widget scaffold.
    return Scaffold(
      // bar aplikasi dengan judulnya.
      appBar: AppBar(title: const Text('Agenda Kegiatan')),
      // konten aplikasi berisi dengan list kegiatan
      body:  FutureBuilder<List<Task>>(
        // Membuat widget berdasarkan snapshot terakhir dari futureTask yang menjalankan fetchAPI secara berkala
        future: futureTask,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return ListView.builder(
              itemCount: snapshot.data.length,
              itemBuilder: (context, index) {
                final item = snapshot.data[index];
                // widget untuk menghapus data dengan cara slide ke data.
                return Dismissible(
                  // key untuk mengunci mana data untuk dihapus
                  key: Key(item.id), 
                  child: _buildTodoItem(item.task),
                  // fungsi menghapus data
                  onDismissed: (direction) {
                    // Menjalankan async function dalam sync function. 
                    deleteTask(item.id).then((value) =>  snapshot.data.removeAt(index));
                  }
                );
              },
            );
          } else if (snapshot.hasError) {
            return Text("${snapshot.error}");
          }

          // By default, show a loading spinner.
          return  Container(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [CircularProgressIndicator()],
              ),
            ],
          ));

        },
      ),
      // Button untuk menambahkan data kegiatan
      floatingActionButton: FloatingActionButton(
          onPressed: () => _displayDialog(context),
          tooltip: 'Menambah Item',
          child: Icon(Icons.add)),
    );
  }

  // Fungsi untuk menambahkan data todo
  void _addTodoItem(String task) {
    // Menjalankan async function dalam sync function. 
    createTask(task).then(
      (value) => setState((){
        log("data berhasil ditambah");
        // fetch kembali data online
        futureTask = fetchTask();
      })
    );
    
    // Membersihkan data dari text field setelah ditambahkan
    _textFieldController.clear();
  }

  // Menghasilkan widget dari setiap data kegiatan berupa list card.
  Widget _buildTodoItem(String title) {
    return Card(
      child: ListTile(
        title: Text(title)
      )
    );
  }

  // Widget asyncronous untuk menambahkan data
  // Widget berupa modal pop-up
  Future<AlertDialog> _displayDialog(BuildContext context) async {
    return showDialog(
        // context merupakan parameter yang dibutuhkan, berasal dari aplikasi.
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            // judul modal
            title: const Text('Menambahkan Tugas'),
            // konten modal
            content: TextField(
              controller: _textFieldController,
              decoration: const InputDecoration(hintText: 'Masukan nama tugas'),
            ),
            actions: <Widget>[
              FlatButton(
                child: const Text('Tambah'),
                onPressed: () {
                  Navigator.of(context).pop();
                  // menambahkan data ketika klik Tambah
                  _addTodoItem(_textFieldController.text);
                },
              ),
              FlatButton(
                child: const Text('Batal'),
                onPressed: () {
                  Navigator.of(context).pop();
                  // Data diabaikan ketika klik Batal
                },
              )
            ],
          );
        });
  }
}

