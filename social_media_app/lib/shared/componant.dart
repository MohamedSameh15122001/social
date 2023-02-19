import 'package:firebase_auth/firebase_auth.dart';
import 'package:social_media_app/modules/main_page/auth_page.dart';

import 'constants.dart';

Future signOut(context) async {
  await FirebaseAuth.instance.signOut();
  navigateAndFinish(context, const AuthPage());
}

String currentUserId = FirebaseAuth.instance.currentUser!.uid;
