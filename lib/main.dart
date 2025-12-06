import 'package:firebase_bloc_auth/call_firebase_auth.dart';
import 'package:firebase_bloc_auth/firebase_options.dart';
import 'package:firebase_bloc_auth/src/authentication/auth_services/firebase_service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(
    CallFirebaseAuth(
      privateWidget: const MyApp(),
      themeData: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
      ),
      createUserCollection: true, // Enable automatic user collection creation
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'My App',
      home: Scaffold(
        appBar: AppBar(
          title: const Text('My App Home'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ProfileUpdatePage(),
                    ),
                  );
                },
                child: const Text('Go to Profile'),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SubcollectionExample(),
                    ),
                  );
                },
                child: const Text('Subcollection Example'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Example of how to use subcollections in your project
class SubcollectionExample extends StatelessWidget {
  const SubcollectionExample({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Subcollection Example')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () async {
                // Get reference to user's document
                final userRef = FirestoreService().getCurrentUserDocRef();

                // Create a subcollection called 'tasks'
                final tasksCollection = userRef.collection('tasks');

                // Add a document to the subcollection
                await tasksCollection.add({
                  'title': 'My First Task',
                  'completed': false,
                  'createdAt': DateTime.now(),
                });

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Task added to subcollection!')),
                );
              },
              child: const Text('Add Task to Subcollection'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                // Alternative way using getUserSubcollection helper
                final notesCollection =
                    FirestoreService().getUserSubcollection('notes');

                await notesCollection.add({
                  'content': 'This is a note',
                  'createdAt': DateTime.now(),
                });

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Note added!')),
                );
              },
              child: const Text('Add Note (Alternative Method)'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                // Get user document data
                final userDoc = await FirestoreService().getCurrentUserDoc();
                final userData = userDoc.data() as Map<String, dynamic>?;

                if (userData != null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Email: ${userData['email']}')),
                  );
                }
              },
              child: const Text('Get User Data'),
            ),
          ],
        ),
      ),
    );
  }
}

/// Example of creating a complex data structure
/// users/{uid}/tasks/{taskId}
/// users/{uid}/notes/{noteId}
/// users/{uid}/settings/preferences
class ComplexDataExample extends StatelessWidget {
  const ComplexDataExample({super.key});

  Future<void> createComplexStructure() async {
    final userRef = FirestoreService().getCurrentUserDocRef();

    // Create tasks subcollection
    final tasksCollection = userRef.collection('tasks');
    await tasksCollection.add({
      'title': 'Complete project',
      'priority': 'high',
      'dueDate': DateTime.now().add(const Duration(days: 7)),
      'tags': ['work', 'important'],
    });

    // Create notes subcollection
    final notesCollection = userRef.collection('notes');
    await notesCollection.add({
      'title': 'Meeting Notes',
      'content': 'Discussed project timeline',
      'createdAt': DateTime.now(),
    });

    // Create settings document
    await userRef.collection('settings').doc('preferences').set({
      'theme': 'dark',
      'notifications': true,
      'language': 'en',
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Complex Data Example')),
      body: Center(
        child: ElevatedButton(
          onPressed: () async {
            await createComplexStructure();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Complex structure created!')),
            );
          },
          child: const Text('Create Complex Data Structure'),
        ),
      ),
    );
  }
}
