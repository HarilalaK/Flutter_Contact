import 'package:flutter/material.dart';
import 'database_helper.dart';
import 'contact.dart';

// Point d'entrée de l'application
void main() {
  runApp(MyApp());
}

// Widget racine de l'application
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Contact App',
      home: ContactList(),
    );
  }
}

// Widget de liste des contacts avec état
class ContactList extends StatefulWidget {
  @override
  _ContactListState createState() => _ContactListState();
}

class _ContactListState extends State<ContactList> {
  // Instance du helper pour la base de données
  final DatabaseHelper _dbHelper = DatabaseHelper();
  // Liste pour stocker les contacts
  List<Contact> _contacts = [];

  @override
  void initState() {
    super.initState();
    _loadContacts(); // Chargement initial des contacts
  }

  // Méthode pour charger les contacts depuis la base de données
  void _loadContacts() async {
    _contacts = await _dbHelper.getContacts();
    print('Contacts chargés: ${_contacts.length}');
    setState(() {}); // Déclenche la reconstruction du widget
  }

  // Méthode pour ajouter un nouveau contact
  void _addContact() async {
    // Affiche une boîte de dialogue pour saisir les informations
    final contact = await showDialog<Contact>(
      context: context,
      builder: (context) {
        String name = '';
        String phone = '';
        return AlertDialog(
          title: Text('Ajouter un contact'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: InputDecoration(labelText: 'Nom'),
                onChanged: (value) => name = value,
              ),
              TextField(
                decoration: InputDecoration(labelText: 'Téléphone'),
                onChanged: (value) => phone = value,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                if (name.isNotEmpty && phone.isNotEmpty) {
                  Navigator.of(context).pop(Contact(name: name, phone: phone));
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Veuillez remplir tous les champs')),
                  );
                }
              },
              child: Text('Ajouter'),
            ),
          ],
        );
      },
    );

    // Si un contact a été créé, l'insérer dans la base de données
    if (contact != null) {
      await _dbHelper.insertContact(contact);
      _loadContacts(); // Recharge la liste
    }
  }

  // Méthode pour modifier un contact existant
  void _editContact(Contact contact) async {
    // Affiche une boîte de dialogue pré-remplie avec les informations actuelles
    final updatedContact = await showDialog<Contact>(
      context: context,
      builder: (context) {
        String name = contact.name;
        String phone = contact.phone;
        return AlertDialog(
          title: Text('Modifier le contact'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: InputDecoration(labelText: 'Nom'),
                onChanged: (value) => name = value,
                controller: TextEditingController(text: contact.name),
              ),
              TextField(
                decoration: InputDecoration(labelText: 'Téléphone'),
                onChanged: (value) => phone = value,
                controller: TextEditingController(text: contact.phone),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(Contact(id: contact.id, name: name, phone: phone));
              },
              child: Text('Modifier'),
            ),
          ],
        );
      },
    );

    // Si le contact a été modifié, mettre à jour la base de données
    if (updatedContact != null) {
      await _dbHelper.updateContact(updatedContact);
      _loadContacts(); // Recharge la liste
    }
  }

  // Méthode pour supprimer un contact
  void _deleteContact(int id) async {
    await _dbHelper.deleteContact(id);
    _loadContacts(); // Recharge la liste
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Contacts')),
      // Construction de la liste des contacts
      body: ListView.builder(
        itemCount: _contacts.length,
        itemBuilder: (context, index) {
          final contact = _contacts[index];
          return ListTile(
            title: Text(contact.name),
            subtitle: Text(contact.phone),
            onTap: () => _editContact(contact), // Modification au tap
            trailing: IconButton(
              icon: Icon(Icons.delete),
              onPressed: () => _deleteContact(contact.id!), // Suppression
            ),
          );
        },
      ),
      // Bouton d'ajout de contact
      floatingActionButton: FloatingActionButton(
        onPressed: _addContact,
        child: Icon(Icons.add),
      ),
    );
  }
}
