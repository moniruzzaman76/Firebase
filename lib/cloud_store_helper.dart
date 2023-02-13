import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_1/book.dart';

class CloudStoreHelper {
  final db = FirebaseFirestore.instance;

  Future<List<Book>> GetAllBooks() async {
    List<Book>listOfBooks = [];
    final result = await db.collection('books').get();
    print(result);
    for (var element in result.docs) {
      Book book = Book(
        element.get('name'),
        element.get('type'),
        element.get('date').toString(),
        double.tryParse(element.get('price').toString()) ?? 0,
      );
      listOfBooks.add(book);
    }
    return listOfBooks;
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> ListenAllBooksCollection() {
    return db.collection('books').snapshots();
  }

  Future<void>addNewBook(Book book)async{
    await db.collection('books').add(book.toMap());
  }
}
