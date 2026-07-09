import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/colors.dart';
import '../screens/test_library_screen.dart';

class InteractiveBodyMap extends StatefulWidget {
  const InteractiveBodyMap({super.key});

  @override
  State<InteractiveBodyMap> createState() => _InteractiveBodyMapState();
}

class _InteractiveBodyMapState extends State<InteractiveBodyMap> {
  String _selectedRegion = 'Select a region';

  final List<BodyHotspot> _hotspots = [
    BodyHotspot(name: 'Cervical spine', label: 'Cervical Spine', top: 0.15, left: 0.5),
    BodyHotspot(name: 'Shoulder', label: 'Shoulders', top: 0.23, left: 0.32),
    BodyHotspot(name: 'Shoulder', label: 'Shoulders', top: 0.23, left: 0.68),
    BodyHotspot(name: 'Elbow', label: 'Elbows', top: 0.38, left: 0.25),
    BodyHotspot(name: 'Elbow', label: 'Elbows', top: 0.38, left: 0.75),
    BodyHotspot(name: 'Wrist and hand', label: 'Wrists & Hands', top: 0.52, left: 0.21),
    BodyHotspot(name: 'Wrist and hand', label: 'Wrists & Hands', top: 0.52, left: 0.79),
    BodyHotspot(name: 'Pelvis', label: 'Pelvis & SIJ', top: 0.5),
    BodyHotspot(name: 'Hip', label: 'Hips', top: 0.56, left: 0.4),
    BodyHotspot(name: 'Hip', label: 'Hips', top: 0.56, left: 0.6),
    BodyHotspot(name: 'Knee', label: 'Knees', top: 0.72, left: 0.38),
    BodyHotspot(name: 'Knee', label: 'Knees', top: 0.72, left: 0.62),
    BodyHotspot(name: 'Ankle and foot', label: 'Ankles & Feet', top: 0.88, left: 0.36),
    BodyHotspot(name: 'Ankle and foot', label: 'Ankles & Feet', top: 0.88, left: 0.64),
  ];

  void _onTapHotspot(BodyHotspot hotspot) {
    setState(() {
      _selectedRegion = hotspot.label;
    });

    // Navigate to TestLibraryScreen directly
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => TestLibraryScreen(region: hotspot.name),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      children: [
        // Display selection indicator
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkBorder : AppColors.primaryLight,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.touch_app_outlined, size: 16, color: AppColors.primaryPurple),
              const SizedBox(width: 8),
              Text(
                _selectedRegion,
                style: theme.textTheme.labelLarge?.copyWith(
                  color: AppColors.primaryPurple,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        // Interactive Silhouette Canvas
        AspectRatio(
          aspectRatio: 0.75, // Standard vertical silhouette proportion
          child: LayoutBuilder(
            builder: (context, constraints) {
              final width = constraints.maxWidth;
              final height = constraints.maxHeight;

              return Stack(
                children: [
                  // Stylized Human Outline drawn with CustomPaint
                  Positioned.fill(
                    child: Opacity(
                      opacity: isDark ? 0.15 : 0.08,
                      child: CustomPaint(
                        painter: SilhouettePainter(themeColor: AppColors.primaryPurple),
                      ),
                    ),
                  ),
                  // Hotspot markers
                  ..._hotspots.map((hotspot) {
                    final double posX = hotspot.left * width;
                    final double posY = hotspot.top * height;

                    return Positioned(
                      left: posX - 20,
                      top: posY - 20,
                      child: GestureDetector(
                        onTap: () => _onTapHotspot(hotspot),
                        child: Container(
                          width: 40,
                          height: 40,
                          color: Colors.transparent, // expand touch area
                          child: Center(
                            child: Container(
                              width: 14,
                              height: 14,
                              decoration: BoxDecoration(
                                color: AppColors.primaryPurple,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.primaryPurple.withOpacity(0.5),
                                    blurRadius: 8,
                                    spreadRadius: 2,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      )
                          .animate(onPlay: (controller) => controller.repeat(reverse: true))
                          .scale(
                            begin: const Offset(0.9, 0.9),
                            end: const Offset(1.2, 1.2),
                            duration: 1000.ms,
                            curve: Curves.easeInOut,
                          ),
                    );
                  }),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}

class BodyHotspot {
  final String name; // DB key
  final String label; // UI display
  final double top; // y position as ratio (0.0 to 1.0)
  final double left; // x position as ratio (0.0 to 1.0)

  BodyHotspot({
    required this.name,
    required this.label,
    required this.top,
    this.left = 0.5,
  });
}

// Custom Painter to draw a modern, clean medical human silhouette
class SilhouettePainter extends CustomPainter {
  final Color themeColor;

  SilhouettePainter({required this.themeColor});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = themeColor
      ..style = PaintingStyle.fill;

    final w = size.width;
    final h = size.height;

    final path = Path();
    
    // Draw Head
    path.addOval(Rect.fromCircle(center: Offset(w * 0.5, h * 0.08), radius: w * 0.06));

    // Draw Neck
    path.moveTo(w * 0.47, h * 0.12);
    path.lineTo(w * 0.53, h * 0.12);
    path.lineTo(w * 0.53, h * 0.15);
    path.lineTo(w * 0.47, h * 0.15);
    path.close();

    // Draw Torso and Shoulders
    path.moveTo(w * 0.5, h * 0.15);
    // Left shoulder curve
    path.quadraticBezierTo(w * 0.35, h * 0.16, w * 0.32, h * 0.23);
    // Left arm down
    path.lineTo(w * 0.28, h * 0.38);
    path.lineTo(w * 0.22, h * 0.52);
    // Left fingers
    path.quadraticBezierTo(w * 0.20, h * 0.55, w * 0.22, h * 0.56);
    // Left inner arm up
    path.lineTo(w * 0.26, h * 0.52);
    path.lineTo(w * 0.32, h * 0.38);
    path.lineTo(w * 0.37, h * 0.27);
    
    // Left side of torso down
    path.lineTo(w * 0.38, h * 0.5);
    // Hips left
    path.lineTo(w * 0.38, h * 0.56);
    // Left leg down
    path.lineTo(w * 0.36, h * 0.72);
    path.lineTo(w * 0.34, h * 0.88);
    // Left foot
    path.quadraticBezierTo(w * 0.31, h * 0.92, w * 0.35, h * 0.93);
    path.lineTo(w * 0.41, h * 0.93);
    // Left inner leg up
    path.lineTo(w * 0.44, h * 0.88);
    path.lineTo(w * 0.46, h * 0.72);
    path.lineTo(w * 0.47, h * 0.58);
    
    // Crotch
    path.lineTo(w * 0.5, h * 0.58);
    
    // Right inner leg up (mirrored)
    path.lineTo(w * 0.53, h * 0.58);
    path.lineTo(w * 0.54, h * 0.72);
    path.lineTo(w * 0.56, h * 0.88);
    path.lineTo(w * 0.59, h * 0.93);
    // Right foot
    path.quadraticBezierTo(w * 0.69, h * 0.92, w * 0.66, h * 0.88);
    // Right outer leg up
    path.lineTo(w * 0.64, h * 0.72);
    path.lineTo(w * 0.62, h * 0.56);
    // Hips right
    path.lineTo(w * 0.62, h * 0.5);
    
    // Right side of torso down
    path.lineTo(w * 0.63, h * 0.27);
    path.lineTo(w * 0.68, h * 0.38);
    path.lineTo(w * 0.74, h * 0.52);
    // Right fingers
    path.quadraticBezierTo(w * 0.80, h * 0.55, w * 0.78, h * 0.56);
    // Right outer arm up
    path.lineTo(w * 0.72, h * 0.52);
    path.lineTo(w * 0.68, h * 0.38);
    path.lineTo(w * 0.68, h * 0.23);
    // Right shoulder curve
    path.quadraticBezierTo(w * 0.65, h * 0.16, w * 0.5, h * 0.15);

    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
