import 'package:vetsync/models/pet.dart';

class PetRepository{

  static const List<Pet> pets = [

     Pet(
          id: "pet001", 
          name: "Bruno", 
          species: "Dog", 
          breed: "Golden Retriver", 
          age: 3
        ),
         Pet(
          id: "pet002", 
          name: "Milo", 
          species: "Cat", 
          breed: "Persian", 
          age: 2
        ),
         Pet(
          id: "pet003", 
          name: "Tommy", 
          species: "Dog", 
          breed: "Labrador", 
          age: 5
        ),
         Pet(
          id: "pet004", 
          name: "Tetee", 
          species: "Cat", 
          breed: "Lesbian", 
          age: 1
        ),
         Pet(
          id: "pet005", 
          name: "Heraaa Beta", 
          species: "Dog", 
          breed: "Gay", 
          age: 9
        ),

  ];

}