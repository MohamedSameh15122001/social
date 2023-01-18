import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../models/user_model.dart';
import 'states.dart';

class MainCubit extends Cubit<MainStates> {
  MainCubit() : super(MainInitial());

  static MainCubit get(context) => BlocProvider.of(context);

  // Future<QuerySnapshot<Map<String, dynamic>>> userData =
  //     FirebaseFirestore.instance
  //         .collection('users')
  //         .where(
  //           'userId',
  //           isEqualTo: FirebaseAuth.instance.currentUser?.uid,
  //         )
  //         .get();
  // getHomeData() async {
  //   List data = [];
  //   await FirebaseFirestore.instance
  //       .collection('users')
  //       .where(
  //         'userId',
  //         isEqualTo: FirebaseAuth.instance.currentUser?.uid,
  //       )
  //       .get()
  //       .then((value) {
  //     for (var element in value.docs) {
  //       element.data().map((key, value) {
  //         data.add(value);
  //         return value;
  //       });
  //     }
  //   });
  //   return data;
  // }

  UserModel? model;
  void getUserData() {
    try {
      emit(UserLoadingState());
      FirebaseFirestore.instance
          .collection('users')
          .doc('bIynFb6roz5brIbcN1Bx')
          .snapshots()
          .listen((event) {
        model = null;
        model = UserModel.fromMap(event.data()!);
        print(model?.userName);
        print('------------------------');
        emit(UserSuccessState());
      });
    } on FirebaseFirestore catch (e) {
      print('$e');
    }
  }

  // bool OnBoarding = false;
}

// //botton nav bar
//   int currentIndex = 0;
//   List<Widget> bottomNavScreens = [
//     HomeScreen(),
//     CategoriesScreen(),
//     FavoritesScreen(),
//     CartScreen(),
//   ];
//   void changeBottomNavScreen(index) {
//     currentIndex = index;
//     emit(ChangeBottomNavState());
//   }
//   //botton nav bar

//   //dark mode
//   bool isDark = CacheHelper.getData('isDark') ?? false;
//   void switchValue() {
//     isDark = !isDark;
//     CacheHelper.saveData(key: 'isDark', value: isDark);
//     emit(ChangeDarkModeState());
//   }
//   //dark mode

//   //change country
//   dynamic valueChoose = CacheHelper.getData('country') ?? 'Egypt';
//   List countryItems = const [
//     'Egypt',
//     'Saudi',
//     'Jordan',
//     'Kuwait',
//     'Libya',
//   ];
//   void changeCountry() {
//     CacheHelper.saveData(key: 'country', value: valueChoose);
//     emit(ChangeCountryState());
//   }
//   //change country