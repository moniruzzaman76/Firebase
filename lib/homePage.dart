import 'package:firebase_1/cloud_store_helper.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'book.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  final TextEditingController nameTextEditingController = TextEditingController();
  final TextEditingController typeTextEditingController = TextEditingController();
  final TextEditingController priceTextEditingController = TextEditingController();
  final TextEditingController dateTextEditingController = TextEditingController();

  bool inProgress = true;
  List<Book> listOfBooks = [];

  final cloudStoreHelper = CloudStoreHelper();

  @override
  void initState() {
    // cloudStoreHelper.GetAllBooks().then((value) {
    //   listOfBooks = value;
    //   inProgress = false;
    //   setState(() {});
    // });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Book List'),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () async{
            showModalBottomSheet(context: context, builder: (context){
              return Padding(
                padding:EdgeInsets.only(
                  bottom:MediaQuery.of(context).viewInsets.bottom
                ),
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      const SizedBox(height: 20,),
                      const Text('Add new book'),
                      const SizedBox(height: 20,),
                      TextField(
                        controller: nameTextEditingController,
                        decoration: InputDecoration(
                          hintText: 'Name'
                        ),
                      ),

                      TextField(
                        controller: typeTextEditingController,
                        decoration: InputDecoration(
                            hintText: 'Type'
                        ),
                      ),

                      TextField(
                        controller: priceTextEditingController,
                        decoration: InputDecoration(
                            hintText: 'Price'
                        ),
                      ),

                      TextField(
                        controller: dateTextEditingController,
                        decoration: InputDecoration(
                            hintText: 'Date'
                        ),
                      ),
                      ElevatedButton(
                          onPressed: ()async{
                        Book book = Book(
                            nameTextEditingController.text,
                            typeTextEditingController.text,
                            dateTextEditingController.text,
                            double.tryParse(priceTextEditingController.text)??0
                        );
                        await cloudStoreHelper.addNewBook(book).then((value){
                          nameTextEditingController.clear();
                          typeTextEditingController.clear();
                          priceTextEditingController.clear();
                          dateTextEditingController.clear();
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('New Book Added')));
                        });
                      },
                          child: const Text('Add'))
                    ],
                  ),
                ),
              );
            });
          },
          child: const Icon(Icons.add),
        ),
        body: StreamBuilder(
            stream: cloudStoreHelper.ListenAllBooksCollection(),
            builder: (context, snapshot) {
              /// in progress
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }

              /// error state
              if (snapshot.hasError) {
                return Center(
                  child: Text(snapshot.error.toString()),
                );
              }
              if (snapshot.hasData) {
                listOfBooks.clear();
                for (var element in snapshot.data!.docs) {
                  Book book = Book(
                    element.get('name'),
                    element.get('type'),
                    element.get('date').toString(),
                    double.tryParse(element.get('price').toString()) ?? 0,
                  );
                  listOfBooks.add(book);
                }
                return ListView.builder(
                    itemCount: listOfBooks.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        title: Text(listOfBooks[index].name),
                        trailing: Text(listOfBooks[index].category),
                        subtitle: Text(listOfBooks[index].date),
                        leading: Text(listOfBooks[index].price.toString()),
                      );
                    });
              } else {
                return const Center(
                  child: Text('No data available'),
                );
              }
            }));
  }
}

