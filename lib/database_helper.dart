import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'contact.dart';

// Classe utilitaire pour gérer la base de données SQLite
class DatabaseHelper {
  // Instance singleton pour éviter plusieurs instances de la base de données
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;

  DatabaseHelper._internal();

  // Instance de la base de données
  Database? _database;

  // Getter pour accéder à la base de données, l'initialise si nécessaire
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  // Initialisation de la base de données
  Future<Database> _initDB() async {
    String path = join(await getDatabasesPath(), 'contacts.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) {
        // Création de la table contacts lors de la première initialisation
        return db.execute(
          'CREATE TABLE contacts(id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT, phone TEXT)',
        );
      },
    );
  }

  // Insertion d'un nouveau contact dans la base de données
  Future<void> insertContact(Contact contact) async {
    final db = await database;
    await db.insert('contacts', contact.toMap());
  }

  // Récupération de tous les contacts
  Future<List<Contact>> getContacts() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('contacts');
    return List.generate(maps.length, (i) {
      return Contact.fromMap(maps[i]);
    });
  }

  // Mise à jour d'un contact existant
  Future<void> updateContact(Contact contact) async {
    final db = await database;
    await db.update(
      'contacts',
      contact.toMap(),
      where: 'id = ?',
      whereArgs: [contact.id],
    );
  }

  // Suppression d'un contact par son ID
  Future<void> deleteContact(int id) async {
    final db = await database;
    await db.delete(
      'contacts',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
