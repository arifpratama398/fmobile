import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

// fungsi main dalam aplikasi, titik utama untuk menjalankan aplikasi
void main() {
  runApp(App());
}

// base aplikasi untuk mendifinisikan konfigurasi aplikasi.
class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Aplikasi menggunakan Material Widget (android)
    return MaterialApp(
      // Nama Aplikasi yang akan terinstall
      title: 'uts_185411193',
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
  // List string data kegiatan yang sudah diinput.
  final List<String> _todoList = <String>[];

  // Text field
  final TextEditingController _textFieldController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    // Halaman widget to-do, menggunakan widget scaffold.
    return Scaffold(
      // bar aplikasi dengan judulnya.
      appBar: AppBar(title: const Text('Agenda Kegiatan')),
      // konten aplikasi berisi dengan list kegiatan
      body: ListView.builder(
        itemCount: _todoList.length,
        itemBuilder: (context, index) {
          final item = _todoList[index];

          // widget untuk menghapus data dengan cara slide ke data.
          return Dismissible(
            // key untuk mengunci mana data untuk dihapus
            key: Key(item), 
            child: _buildTodoItem(item),
            // fungsi menghapus data
            onDismissed: (direction) {
              setState(() {
                _todoList.removeAt(index);
              });
            },
          );
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
  void _addTodoItem(String title) {
    // Menambah data kegiatan kedalam state
    setState(() {
      _todoList.add(title);
    });

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

  // Fungsi untuk mendapatkan list data kegiatan.
  List<Widget> _getItems() {
    final List<Widget> _todoWidgets = <Widget>[];
    for (String title in _todoList) {
      // proses generate card widget
      _todoWidgets.add(_buildTodoItem(title));
    }
    return _todoWidgets;
  }
}