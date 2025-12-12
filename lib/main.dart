// lib/main.dart
import 'dart:io';
import 'package:flutter/material.dart';

// DB (for desktop FFI)
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
import 'package:bus_ticket_system/user/screens/cargo_tracking_screen.dart'; // Added Cargo Tracking

// ADMIN SCREENS
import 'package:bus_ticket_system/admin/screens/admin_login_screen.dart';
import 'package:bus_ticket_system/admin/screens/admin_dashboard_screen.dart';
import 'package:bus_ticket_system/admin/screens/buses/manage_buses_screen.dart';
import 'package:bus_ticket_system/admin/screens/buses/add_edit_bus_screen.dart';

// ROUTE MANAGEMENT
import 'package:bus_ticket_system/admin/screens/routes/manage_routes_screen.dart';
import 'package:bus_ticket_system/admin/screens/routes/add_edit_route_screen.dart';

// VIEW ALL BOOKINGS (admin)
import 'package:bus_ticket_system/admin/screens/bookings/view_all_booking_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (Platform.isWindows || Platform.isLinux) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Bus Ticket System',
      initialRoute: '/welcome',

      routes: {
        // AUTH
        '/welcome': (context) => WelcomeScreen(),
        '/login': (context) => LoginScreen(),
        '/signup': (context) => SignupScreen(),
        '/welcome_login': (context) => WelcomeLoginScreen(),

        // USER
        '/search_bus': (context) => SearchBusScreen(),
        '/cargo_tracking': (context) => CargoTrackingScreen(), // Added Cargo Tracking Route

        // AVAILABLE BUSES
        '/available_buses': (context) {
          final args = ModalRoute.of(context)!.settings.arguments as Map;
          return AvailableBusesUserScreen(
            buses: args['buses'],
            selectedDate: args['selectedDate'],
          );
        },

        // BOOK SEAT
        '/book_seat': (context) {
          final args = ModalRoute.of(context)!.settings.arguments as Map;
          return BookSeatScreen(
            bus: args['bus'],
            selectedDate: args['selectedDate'],
          );
        },

        // PASSENGER DETAILS
        '/passenger_details': (context) {
          final args = ModalRoute.of(context)!.settings.arguments as Map;
          return PassengerDetailScreen(
            bus: args['bus'],
            selectedSeats: List<int>.from(args['selectedSeats']),
            date: args['date'],
          );
        },

        // PAYMENT SCREEN
        '/payment': (context) {
          final args = ModalRoute.of(context)!.settings.arguments as Map;
          return PaymentScreen(
            bus: args['bus'],
            selectedSeats: List<int>.from(args['selectedSeats']),
            date: args['date'],
            passengerData: args['passengerData'],
          );
        },

        // FINAL TICKET VIEW
        '/view_ticket': (context) {
          final args = ModalRoute.of(context)!.settings.arguments as Map;
          return ViewTicketScreen(ticketData: args['ticketData']);
        },

        // ADMIN
        '/admin_login': (context) => AdminLoginScreen(),
        '/admin_dashboard': (context) => AdminDashboardScreen(),
        '/manage_buses': (context) => ManageBusesScreen(),

        // ROUTES
        '/manage_routes': (context) => ManageRoutesScreen(),
        '/add_edit_route': (context) => AddEditRouteScreen(),
        '/add_edit_bus': (context) => AddEditBusScreen(),

        // VIEW ALL BOOKINGS (admin)
        '/view_all_booking': (context) {
          final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>? ?? {};
          return ViewAllBookingScreen(
            busId: args['busId'],
            fromCity: args['fromCity'],
            toCity: args['toCity'],
            date: args['date'],
          );
        },
      },

      onUnknownRoute: (settings) {
        return MaterialPageRoute(
          builder: (context) => Scaffold(
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
