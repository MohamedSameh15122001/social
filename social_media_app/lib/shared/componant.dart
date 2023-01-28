import 'package:firebase_auth/firebase_auth.dart';

import '../modules/login/login_screen.dart';
import 'constants.dart';

Future signOut(context) async {
  await FirebaseAuth.instance.signOut();
  navigateAndFinish(context, LoginScreen());
}

String currentUserId = FirebaseAuth.instance.currentUser!.uid;
