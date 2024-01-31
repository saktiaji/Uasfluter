import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class HalamanInventaris extends StatefulWidget {
  final String uid;

  HalamanInventaris({required this.uid});

  @override
  _HalamanInventarisState createState() => _HalamanInventarisState();
}

class _HalamanInventarisState extends State<HalamanInventaris> {
  late TextEditingController _namaItemController = TextEditingController();
  late TextEditingController _jumlahItemController = TextEditingController();
  late TextEditingController _hargaItemController = TextEditingController();
  late CollectionReference<Map<String, dynamic>> _inventaris;

  @override
  void initState() {
    super.initState();

    _namaItemController = TextEditingController();
    _jumlahItemController = TextEditingController();
    _hargaItemController = TextEditingController();

    _inventaris = FirebaseFirestore.instance
        .collection('inventaris')
        .doc(widget.uid)
        .collection('items');
  }

  Future<void> tambahItem() {
    return _inventaris
        .add({
          'namaItem': _namaItemController.text,
          'jumlahItem': int.parse(_jumlahItemController.text),
          'hargaItem': double.parse(_hargaItemController.text),
          'timestamp': FieldValue.serverTimestamp(),
        })
        .then((value) => print("Item Ditambahkan"))
        .catchError((error) => print("Gagal menambahkan item: $error"));
  }

  Future<void> perbaruiItem(DocumentSnapshot<Object?> item) {
    return _inventaris
        .doc(item.id)
        .update({
          'namaItem': _namaItemController.text,
          'jumlahItem': int.parse(_jumlahItemController.text),
          'hargaItem': double.parse(_hargaItemController.text),
          'timestamp': FieldValue.serverTimestamp(),
        })
        .then((value) => print("Item Diperbarui"))
        .catchError((error) => print("Gagal memperbarui item: $error"));
  }

  Future<void> hapusItem(DocumentSnapshot<Object?> item) {
    return _inventaris
        .doc(item.id)
        .delete()
        .then((value) => print("Item Dihapus"))
        .catchError((error) => print("Gagal menghapus item: $error"));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Manajemen Inventaris'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _namaItemController,
              decoration: InputDecoration(labelText: 'Nama Item'),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _jumlahItemController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: 'Jumlah Item'),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _hargaItemController,
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(labelText: 'Harga Item'),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              tambahItem();
            },
            child: Text('Tambah Item'),
          ),
          StreamBuilder(
            stream: _inventaris
                .orderBy('timestamp', descending: true)
                .snapshots(),
            builder: (context,
                AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
              if (!snapshot.hasData) {
                return CircularProgressIndicator();
              }

              return Expanded(
                child: ListView(
                  children: snapshot.data!.docs
                      .map((DocumentSnapshot<Map<String, dynamic>> document) {
                    Map<String, dynamic> data =
                        document.data() as Map<String, dynamic>;

                    return ListTile(
                      title: Text(data['namaItem']),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Jumlah: ${data['jumlahItem']}'),
                          Text('Harga: ${data['hargaItem']}'),
                        ],
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            onPressed: () {
                              _namaItemController.text = data['namaItem'];
                              _jumlahItemController.text =
                                  data['jumlahItem'].toString();
                              _hargaItemController.text =
                                  data['hargaItem'].toString();
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: Text('Edit Item'),
                                    content: SingleChildScrollView(
                                      child: Column(
                                        children: [
                                          TextField(
                                            controller: _namaItemController,
                                            decoration: InputDecoration(
                                                labelText: 'Nama Item'),
                                          ),
                                          TextField(
                                            controller: _jumlahItemController,
                                            keyboardType:
                                                TextInputType.number,
                                            decoration: InputDecoration(
                                                labelText: 'Jumlah Item'),
                                          ),
                                          TextField(
                                            controller: _hargaItemController,
                                            keyboardType:
                                                TextInputType.numberWithOptions(
                                                    decimal: true),
                                            decoration: InputDecoration(
                                                labelText: 'Harga Item'),
                                          ),
                                        ],
                                      ),
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                        child: Text('Batal'),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          perbaruiItem(document);
                                          Navigator.of(context).pop();
                                        },
                                        child: Text('Simpan'),
                                      ),
                                    ],
                                  );
                                },
                              );
                            },
                            icon: Icon(Icons.edit),
                          ),
                          IconButton(
                            onPressed: () {
                              hapusItem(document);
                            },
                            icon: Icon(Icons.delete),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
