import 'package:flutter/material.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _busAnimation;

  @override
  void initState() {
    super.initState();

    // Animation controller for infinite smooth movement
    _controller = AnimationController(
      duration: const Duration(seconds: 12),
      vsync: this,
    )..repeat(); // Infinite loop

    // Bus moves from left (-1.0) to right (1.0) and repeats
    _busAnimation = Tween<double>(begin: -1.2, end: 1.2).animate(
      CurvedAnimation(parent: _controller, curve: Curves.linear),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF1E3C72), // Deep blue
              Color(0xFF2A5298),
              Color(0xFF00C2FF), // Bright cyan
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            stops: [0.0, 0.5, 1.0],
          ),
        ),
        child: Stack(
          children: [
            // Subtle animated road lines (moving background effect)
            AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return Align(
                  alignment: Alignment.bottomCenter,
                  child: Transform.translate(
                    offset: Offset(0, _controller.value * 200 - 100),
                    child: Opacity(
                      opacity: 0.15,
                      child: Image.asset(
                        "assets/images/bus_welcome.png", // Optional: add dashed road lines asset for extra effect
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                );
              },
            ),

            // Moving Bus Animation
            AnimatedBuilder(
              animation: _busAnimation,
              builder: (context, child) {
                return Align(
                  alignment: Alignment.bottomCenter,
                  child: FractionalTranslation(
                    translation: Offset(_busAnimation.value, 0.25), // Moves horizontally
                    child: Transform.scale(
                      scale: 1.1,
                      child: Image.asset(
                        "assets/images/bus_welcome.png",
                        width: 320,
                      ),
                    ),
                  ),
                );
              },
            ),

            // Text Content with Fade-in Animation
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 80),
                    FadeTransition(
                      opacity: _controller.drive(Tween(begin: 0.0, end: 1.0).chain(CurveTween(curve: const Interval(0.0, 0.4)))),
                      child: const Text(
                        "Welcome to",
                        style: TextStyle(
                          fontSize: 30,
                          color: Colors.white,
                          fontWeight: FontWeight.w400,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    FadeTransition(
                      opacity: _controller.drive(Tween(begin: 0.0, end: 1.0).chain(CurveTween(curve: const Interval(0.2, 0.6)))),
                      child: const Text(
                        "JUNAID MOVERS",
                        style: TextStyle(
                          fontSize: 44,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 3,
                          shadows: [
                            Shadow(
                              offset: Offset(0, 4),
                              blurRadius: 10,
                              color: Colors.black26,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    FadeTransition(
                      opacity: _controller.drive(Tween(begin: 0.0, end: 1.0).chain(CurveTween(curve: const Interval(0.4, 0.8)))),
                      child: const Text(
                        "Travel with Comfort & Style\nBook Your Journey Now!",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.white70,
                          height: 1.5,
                        ),
                      ),
                    ),
                    const Spacer(),
                    ScaleTransition(
                      scale: _controller.drive(Tween(begin: 0.9, end: 1.0).chain(CurveTween(curve: const Interval(0.7, 1.0, curve: Curves.easeOut)))),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: const Color(0xFF1E3C72),
                          padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 18),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          elevation: 12,
                          shadowColor: Colors.black38,
                        ),
                        onPressed: () {
                          Navigator.pushReplacementNamed(context, "/login");
                        },
                        child: const Text(
                          "Get Started",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 60),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}