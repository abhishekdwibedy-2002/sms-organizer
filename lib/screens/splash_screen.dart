import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smstracker/screens/home_screen.dart';
import 'package:animated_splash_screen/animated_splash_screen.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedSplashScreen(
      splash: Column(
        children: [
          Image.asset(
            'assets/images/logo.jpg',
            width: 150,
            height: 84,
          ),
          const SizedBox(
            height: 16,
          ),
          Text(
            'SMS Organizer',
            style: GoogleFonts.openSans(
              fontSize: 30,
              fontWeight: FontWeight.bold,
              color: Colors.black54,
            ),
          ),
        ],
      ),
      backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      nextScreen: const HomeScreen(),
      splashIconSize: 150,
      splashTransition: SplashTransition.scaleTransition,
      duration: 1000,
    );
  }
}


// class SplashScreen extends StatefulWidget {
//   const SplashScreen({super.key});

//   @override
//   State<SplashScreen> createState() => _SplashScreenState();
// }

// class _SplashScreenState extends State<SplashScreen>
//     with SingleTickerProviderStateMixin {
//   late AnimationController animationController;
//   late Animation<double> scaleAnimation;
//   late Animation<double> opacityAnimation;
//   late Animation<Offset> slideAnimation;
//   late Animation<double> bounceAnimation;

//   bool animate = false;
//   @override
//   void initState() {
//     super.initState();
//     animationController = AnimationController(
//       vsync: this,
//       duration: const Duration(
//         milliseconds: 1800,
//       ),
//     );

//     scaleAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
//       CurvedAnimation(
//         parent: animationController,
//         curve: const Interval(0.0, 0.5, curve: Curves.fastOutSlowIn),
//       ),
//     );

//     opacityAnimation = Tween<double>(
//       begin: 0.0,
//       end: 1.0,
//     ).animate(CurvedAnimation(
//         parent: animationController,
//         curve: const Interval(0.5, 1.0, curve: Curves.fastOutSlowIn)));

//     slideAnimation = Tween<Offset>(
//       begin: const Offset(0, 0.2),
//       end: Offset.zero,
//     ).animate(
//       CurvedAnimation(
//         parent: animationController,
//         curve: const Interval(0.0, 0.5, curve: Curves.fastOutSlowIn),
//       ),
//     );

//     bounceAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
//       CurvedAnimation(
//         parent: animationController,
//         curve: const Interval(0.5, 1.0, curve: Curves.elasticOut),
//       ),
//     );

//     startAnimation();
//   }

//   @override
//   void dispose() {
//     animationController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     // Get the size of any screen
//     final screenSize = MediaQuery.of(context).size;
//     return Scaffold(
//       body: SafeArea(
//         child: Center(
//           child: Stack(
//             children: [
//               Positioned.fill(
//                 child: Align(
//                   alignment: Alignment.center,
//                   child: AnimatedBuilder(
//                     animation: animationController,
//                     builder: (context, child) {
//                       return Transform.scale(
//                         scale: scaleAnimation.value,
//                         child: Opacity(
//                           opacity: opacityAnimation.value,
//                           child: child,
//                         ),
//                       );
//                     },
//                     child: Container(
//                       height: screenSize.height * 0.2,
//                       width: screenSize.width * 0.42,
//                       decoration: const BoxDecoration(
//                         image: DecorationImage(
//                           image: AssetImage('assets/images/ic_launcher.png'),
//                           fit: BoxFit.cover,
//                         ),
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//               Positioned(
//                 top: screenSize.height * 0.6,
//                 left: 1,
//                 right: 1,
//                 child: SlideTransition(
//                   position: slideAnimation,
//                   child: AnimatedBuilder(
//                     animation: animationController,
//                     builder: (context, child) {
//                       return Transform.scale(
//                         scale: bounceAnimation.value,
//                         child: Opacity(
//                           opacity: opacityAnimation.value,
//                           child: child,
//                         ),
//                       );
//                     },
//                     child: Text(
//                       'SMS Organizer',
//                       style: GoogleFonts.openSans(
//                         fontSize: 35,
//                         fontWeight: FontWeight.w400,
//                       ),
//                       textAlign: TextAlign.center,
//                     ),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Future startAnimation() async {
//     await Future.delayed(const Duration(milliseconds: 500));
//     await animationController.forward();
//     await animationController.reverse();
//     // for (int i = 0; i < 1; i++) {
//     //   await animationController.forward();
//     //   await animationController.reverse();
//     // }
//     if (context.mounted) {
//       Navigator.of(context).pushReplacement(
//         MaterialPageRoute(
//           builder: (context) => const HomeScreen(),
//         ),
//       );
//     }
//   }
// }
