import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app/theme.dart';
import 'app/routes.dart';
import 'app/auth_gate.dart';

// Phase 1 — Authentication
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/auth/forgot_password_screen.dart';
import 'screens/auth/change_password_screen.dart';

// Phase 1 — Home
import 'screens/user/home_screen.dart';

// Phase 2 — Katalog & Informasi Obat
import 'screens/user/catalog_screen.dart';
import 'screens/user/medicine_detail_screen.dart';
import 'screens/user/drug_interaction_screen.dart';
import 'screens/user/education_screen.dart';
import 'screens/user/article_detail_screen.dart';

// Phase 3 — Pembelian & Pesanan
import 'screens/user/cart_screen.dart';
import 'screens/user/checkout_screen.dart';
import 'screens/user/order_success_screen.dart';
import 'screens/user/orders_screen.dart';
import 'screens/user/order_detail_screen.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Kunci orientasi ke portrait only
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Status bar transparan agar splash native menyatu
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
  ));

  try {
    await Firebase.initializeApp();
  } catch (e) {
    debugPrint('Firebase init notice: $e');
  }

  runApp(const ApoteKitaApp());
}

class ApoteKitaApp extends StatelessWidget {
  const ApoteKitaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'ApoteKita',
      theme: AppTheme.light,
      // ── AuthGate sebagai home: menangani semua redirect auth secara reaktif
      home: const AuthGate(),
      routes: {
        // Auth
        AppRoutes.login: (_) => const LoginScreen(),
        AppRoutes.register: (_) => const RegisterScreen(),
        AppRoutes.forgotPassword: (_) => const ForgotPasswordScreen(),
        AppRoutes.changePassword: (_) => const ChangePasswordScreen(),
        AppRoutes.home: (_) => const HomeScreen(),

        // Phase 2 — tanpa arguments
        AppRoutes.drugInteraction: (_) => const DrugInteractionScreen(),
        AppRoutes.education: (_) => const EducationScreen(),

        // Phase 3 — tanpa arguments
        AppRoutes.cart: (_) => const CartScreen(),
        AppRoutes.checkout: (_) => const CheckoutScreen(),
        AppRoutes.orders: (_) => const OrdersScreen(),
      },
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case AppRoutes.catalog:
            final category = settings.arguments as String?;
            return MaterialPageRoute(
              builder: (_) => CatalogScreen(initialCategory: category),
              settings: settings,
            );

          case AppRoutes.medicineDetail:
            return MaterialPageRoute(
              builder: (_) => const MedicineDetailScreen(),
              settings: settings,
            );

          case AppRoutes.articleDetail:
            return MaterialPageRoute(
              builder: (_) => const ArticleDetailScreen(),
              settings: settings,
            );

          case AppRoutes.orderSuccess:
            return MaterialPageRoute(
              builder: (_) => const OrderSuccessScreen(),
              settings: settings,
            );

          case AppRoutes.orderDetail:
            return MaterialPageRoute(
              builder: (_) => const OrderDetailScreen(),
              settings: settings,
            );

          default:
            return null;
        }
      },
    );
  }
}
