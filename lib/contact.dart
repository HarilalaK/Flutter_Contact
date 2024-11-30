// Classe modèle représentant un contact
class Contact {
  // Identifiant unique du contact (null pour un nouveau contact)
  final int? id;
  // Nom du contact
  final String name;
  // Numéro de téléphone du contact
  final String phone;

  // Constructeur avec paramètres nommés
  Contact({this.id, required this.name, required this.phone});

  // Conversion d'un contact en Map pour la base de données
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
    };
  }

  // Création d'un contact à partir d'une Map de la base de données
  static Contact fromMap(Map<String, dynamic> map) {
    return Contact(
      id: map['id'],
      name: map['name'],
      phone: map['phone'],
    );
  }
}
