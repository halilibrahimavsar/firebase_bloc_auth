import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_bloc_auth/src/authentication/auth_blc/auth_bloc.dart';
import 'package:firebase_bloc_auth/src/authentication/auth_services/providers/shared_auth_providr.dart';
import 'package:firebase_bloc_auth/src/views/public_pages/custom_alert_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:restart_app/restart_app.dart';

class ProfileUpdatePage extends StatefulWidget {
  const ProfileUpdatePage({super.key});

  @override
  ProfileUpdatePageState createState() => ProfileUpdatePageState();
}

class ProfileUpdatePageState extends State<ProfileUpdatePage>
    with SingleTickerProviderStateMixin {
  late TextEditingController nameController;
  late TextEditingController passwordController1;
  late TextEditingController passwordController2;
  late AnimationController animationController;
  late Animation<double> animation;
  String? _errorText;

  bool showNamePanel = false;
  bool showPasswordPanel = false;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController();
    passwordController1 = TextEditingController();
    passwordController2 = TextEditingController();
    animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    animation =
        Tween<double>(begin: 0.0, end: 1.0).animate(animationController);

    //
  }

  @override
  void dispose() {
    nameController.dispose();
    passwordController1.dispose();
    passwordController2.dispose();
    animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    nameController.text = FirebaseAuth.instance.currentUser!.displayName!;

    return BlocConsumer<AuthBloc, AuthState>(
      // not building correctly in name updating
      listener: (context, state) {
        if (state is AuthUpdateErrorState) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.toString())),
          );
        }
      },
      builder: (context, state) {
        if (state is NameUpdatedState) {
          nameController.text = state.newName;
        }
        return SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 100),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.black38),
                    borderRadius: BorderRadius.circular(25),
                    color: Colors.grey.shade50,
                  ),
                  child: Text(
                    CustomSharedAuthProvider.currentUsr!.email,
                    style: const TextStyle(fontStyle: FontStyle.italic),
                  ),
                ),
                const SizedBox(height: 32.0),
                ExpansionPanelList(
                  expansionCallback: (int index, bool isExpanded) {
                    setState(() {
                      showNamePanel = !showNamePanel;
                    });
                  },
                  children: [
                    ExpansionPanel(
                      headerBuilder: (BuildContext context, bool isExpanded) {
                        return const ListTile(
                          title: Text("Update Name"),
                        );
                      },
                      body: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.black38),
                          borderRadius: BorderRadius.circular(25),
                          color: Colors.grey.shade50,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            TextField(
                              controller: nameController,
                              decoration: const InputDecoration(
                                labelText: 'New Name',
                              ),
                            ),
                            const SizedBox(height: 16.0),
                            ElevatedButton(
                              onPressed: () async {
                                bool result = await showCustmDialog(
                                  context,
                                  title: "UPDATE",
                                  msg: "Do you want to update your name?",
                                  cancelButton: "Cancel",
                                  confirmButton: "Yes",
                                  color: Colors.blue,
                                  functionWhenConfirm: () {},
                                );
                                if (result && context.mounted) {
                                  context.read<AuthBloc>().add(UpdateNameEvent(
                                        name: nameController.text,
                                      ));
                                }
                                await Future.delayed(const Duration(seconds: 1))
                                    .then((value) {
                                  Restart.restartApp();
                                });
                              },
                              child: const Text('Update Name'),
                            ),
                          ],
                        ),
                      ),
                      isExpanded: showNamePanel,
                    ),
                  ],
                ),
                const SizedBox(height: 32.0),
                ExpansionPanelList(
                  expansionCallback: (int index, bool isExpanded) {
                    setState(() {
                      showPasswordPanel = !showPasswordPanel;
                    });
                  },
                  children: [
                    ExpansionPanel(
                      headerBuilder: (BuildContext context, bool isExpanded) {
                        return const ListTile(
                          title: Text("Update Password"),
                        );
                      },
                      body: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.black38),
                          borderRadius: BorderRadius.circular(25),
                          color: Colors.grey.shade50,
                        ),
                        child: Column(
                          children: [
                            TextField(
                              controller: passwordController1,
                              obscureText: true,
                              decoration: const InputDecoration(
                                labelText: 'New Password',
                              ),
                              onChanged: (value) {
                                _isPasswdMatch(value, passwordController2);
                              },
                            ),
                            const SizedBox(height: 16.0),
                            TextField(
                              controller: passwordController2,
                              obscureText: true,
                              decoration: InputDecoration(
                                labelText: 'Confirm New Password',
                                errorText: _errorText,
                              ),
                              onChanged: (value) {
                                _isPasswdMatch(value, passwordController1);
                              },
                            ),
                            const SizedBox(height: 16.0),
                            ElevatedButton(
                              onPressed: () async {
                                if (_errorText == null) {
                                  bool result = await showCustmDialog(
                                    context,
                                    title: "UPDATE",
                                    msg: "Do you want to update your password?",
                                    cancelButton: "Cancel",
                                    confirmButton: "Yes",
                                    color: Colors.blue,
                                    functionWhenConfirm: () {},
                                  );
                                  // TODO : its accepting event if password 4 digits
                                  if (result && context.mounted) {
                                    context.read<AuthBloc>().add(
                                        UpdatePasswdEvent(
                                            passwd: passwordController1.text));
                                  }
                                  await Future.delayed(
                                          const Duration(seconds: 1))
                                      .then((value) {
                                    Restart.restartApp();
                                  });
                                }
                              },
                              child: const Text('Update Password'),
                            ),
                          ],
                        ),
                      ),
                      isExpanded: showPasswordPanel,
                    ),
                  ],
                ),
                const SizedBox(height: 32.0),
                ElevatedButton.icon(
                  onPressed: () async {
                    bool result = await showCustmDialog(
                      context,
                      title: "Log Out",
                      msg: "Do you want to log out?",
                      cancelButton: "Cancel",
                      confirmButton: "Yes",
                      color: Colors.blue,
                      functionWhenConfirm: () {},
                    );
                    if (context.mounted && result) {
                      context.read<AuthBloc>().add(LogoutEvent());
                    }
                    await Future.delayed(const Duration(seconds: 1))
                        .then((value) {
                      Restart.restartApp();
                    });
                  },
                  icon: const Icon(Icons.exit_to_app),
                  label: const Text("LOG OUT"),
                  style: const ButtonStyle(
                    iconColor: WidgetStatePropertyAll(Colors.red),
                    foregroundColor: WidgetStatePropertyAll(Colors.red),
                  ),
                )
              ],
            ),
          ),
        );
      },
    );
  }

  void _isPasswdMatch(String value1, TextEditingController value2) {
    setState(() {
      if ((value1.length == value2.text.length) && (value1 != value2.text)) {
        _errorText = 'Passwords do not match';
      } else if (value1.length < value2.text.length) {
        _errorText = 'Write something, maybe it can match';
      } else if (value1.length > value2.text.length) {
        _errorText = 'Stooopp, its getting worse';
      } else {
        _errorText = null;
      }
    });
  }
}
