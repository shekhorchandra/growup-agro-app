// import 'package:flutter/material.dart';
// import 'package:growup_agro/views/wallet_history.dart';
//
// import 'MenuMainPage.dart';
//
// class MenuContainerPage extends StatefulWidget {
//   static final GlobalKey<_MenuContainerPageState> globalKey =
//   GlobalKey<_MenuContainerPageState>();
//
//   MenuContainerPage({Key? key}) : super(key: globalKey);
//
//   static void showWalletPage() {
//     globalKey.currentState?.showWalletHistory();
//   }
//
//   @override
//   State<MenuContainerPage> createState() => _MenuContainerPageState();
// }
//
// class _MenuContainerPageState extends State<MenuContainerPage> {
//   Widget _currentPage = const MenuMainPage(); // default page in menu tab
//
//   void showWalletHistory() {
//     setState(() {
//       _currentPage = const WalletHistoryPage();
//     });
//   }
//
//   void showMenuMain() {
//     setState(() {
//       _currentPage = const MenuMainPage();
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return _currentPage;
//   }
// }
