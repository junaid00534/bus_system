import 'dart:io';
import 'package:flutter/material.dart';

// DB
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

// AUTH SCREENS
import 'package:bus_ticket_system/screens/auth/welcome_screen.dart';
import 'package:bus_ticket_system/screens/auth/login_screen.dart';
import 'package:bus_ticket_system/screens/auth/signup_screen.dart';
import 'package:bus_ticket_system/screens/auth/welcome_login_screen.dart';

// USER SCREENS
import 'package:bus_ticket_system/user/screens/search_bus_screen.dart';
import 'package:bus_ticket_system/user/screens/available_buses_screen.dart';
import 'package:bus_ticket_system/user/screens/book_seat_screen.dart';
import 'package:bus_ticket_system/user/screens/passenger_detail_screen.dart';
import 'package:bus_ticket_system/user/screens/payment_screen.dart';
import 'package:bus_ticket_system/user/screens/view_ticket_screen.dart';

// ADMIN SCREENS
import 'package:bus_ticket_system/admin/screens/admin_login_screen.dart';
import 'package:bus_ticket_system/admin/screens/admin_dashboard_screen.dart';
import 'package:bus_ticket_system/admin/screens/buses/manage_buses_screen.dart';
import 'package:bus_ticket_system/admin/screens/buses/add_edit_bus_screen.dart';

// ROUTE MANAGEMENT
import 'package:bus_ticket_system/admin/screens/routes/manage_routes_screen.dart';
import 'package:bus_ticket_system/admin/screens/routes/add_edit_route_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (Platform.isWindows || Platform.isLinux) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Bus Ticket System',
      initialRoute: '/welcome',

      routes: {
        // AUTH
        '/welcome': (_) => WelcomeScreen(),
        '/login': (_) => const LoginScreen(),
        '/signup': (_) => const SignupScreen(),
        '/welcome_login': (_) => const WelcomeLoginScreen(),

        // USER
        '/search_bus': (_) => const SearchBusScreen(),

        // AVAILABLE BUSES
        '/available_buses': (context) {
          final args = ModalRoute.of(context)!.settings.arguments as Map;
          return AvailableBusesUserScreen(
            buses: args['buses'],
            selectedDate: args['selectedDate'], // String ("2025-02-01")
          );
        },

        // BOOK SEAT
        '/book_seat': (context) {
          final args = ModalRoute.of(context)!.settings.arguments as Map;
          return BookSeatScreen(
            bus: args['bus'],
            selectedDate: args['selectedDate'], // String
          );
        },

        // PASSENGER DETAILS
        '/passenger_details': (context) {
          final args = ModalRoute.of(context)!.settings.arguments as Map;
          return PassengerDetailScreen(
            bus: args['bus'],
            selectedSeats: List<int>.from(args['selectedSeats']),
            date: args['date'], // String
          );
        },

        // PAYMENT SCREEN
        '/payment': (context) {
          final args = ModalRoute.of(context)!.settings.arguments as Map;
          return PaymentScreen(
            bus: args['bus'],
            selectedSeats: List<int>.from(args['selectedSeats']),
            date: args['date'], // String
            passengerData: args['passengerData'], // Map
          );
        },

        // FINAL TICKET VIEW
        '/view_ticket': (context) {
          final args = ModalRoute.of(context)!.settings.arguments as Map;
          return ViewTicketScreen(ticketData: args['ticketData']); // Map
        },

        // ADMIN
        '/admin_login': (_) => const AdminLoginScreen(),
        '/admin_dashboard': (_) => const AdminDashboardScreen(),
        '/manage_buses': (_) => const ManageBusesScreen(),

        // ROUTES
        '/manage_routes': (_) => const ManageRoutesScreen(),
        '/add_edit_route': (_) => AddEditRouteScreen(),
        '/add_edit_bus': (_) => AddEditBusScreen(),
      },

      onUnknownRoute: (_) {
        return MaterialPageRoute(
          builder: (_) => const Scaffold(
            body: Center(
              child: Text(
                '404 - Page Not Found',
                style: TextStyle(fontSize: 24),
              ),
            ),
          ),
        );
      },
    );
  }
}
