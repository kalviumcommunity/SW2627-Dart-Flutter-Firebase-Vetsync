import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class SignupScreen extends StatefulWidget{
  const SignupScreen({super.key});

  @override
  State<StatefulWidget> createState() => _SignupScreenState();

}

class _SignupScreenState extends State<SignupScreen> {

  final FirebaseAuth _auth = FirebaseAuth.instance;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();

  final TextEditingController _emailController = TextEditingController();

  final TextEditingController _passwordController = TextEditingController();

  final TextEditingController _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _signup() async{
    if(_formKey.currentState!.validate()){
      
      final UserCredential userCredential = 
        await _auth.createUserWithEmailAndPassword(
          email: _emailController.text, 
          password: _passwordController.text
        );
        
      final User? user = userCredential.user;

      if(user != null){

        await _firestore.collection("vets").doc(user.uid).set({

          "name": _nameController.text,
          "email": _emailController.text,
          "branchID" : "BRANCH_DELHI"
        });

      }

      print(user?.uid);
      print("Signup Sucessfully");

    }
  }
  

  @override
  Widget build(BuildContext context) {
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Signup'),
      ),

      body:Padding(
        padding: const EdgeInsets.all(24),
        child:Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Welcome Back',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 32),

              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Full Name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if(value == null || value.isEmpty){
                    return 'Please Enter your name';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if(value == null || value.isEmpty){
                    return 'Please enter your email';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              TextFormField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder()
                ),
                validator: (value) {
                  if(value == null || value.isEmpty){
                    return 'Please enter your Password';
                  }
                  
                  return null;
                },
              ),

              const SizedBox(height: 16),

              TextFormField(
                controller: _confirmPasswordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Confirm Password',
                  border: OutlineInputBorder()
                ),
                validator: (value) {
                  if(value == null || value.isEmpty){
                    return 'Please enter your Password';
                  }
                  if(value != _passwordController.text){
                    return 'Please match password';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 32),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _signup,
                  child: const Text('SignUp'),
                ),
              ),

              const SizedBox(height: 16),

              TextButton(
                onPressed: (){
                  Navigator.pop(context);
                },
                child: const Text(
                  'Already have a account? Login',
                ),
              )

            ],
          ),
        )
      )
    );
  }
}