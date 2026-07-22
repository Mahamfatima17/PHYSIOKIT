import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../core/theme/colors.dart';
import '../screens/test_library_screen.dart';
import 'three_d_anatomy_painter.dart';

class InteractiveBodyMap extends StatefulWidget {
  const InteractiveBodyMap({super.key});

  @override
  State<InteractiveBodyMap> createState() => _InteractiveBodyMapState();
}

class _InteractiveBodyMapState extends State<InteractiveBodyMap>
    with SingleTickerProviderStateMixin {
  double _rotationY = 0.0;
  double _rotationX = 0.0;
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  void _navigateToRegion(String regionKey) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => TestLibraryScreen(region: regionKey),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      height: 420,
      decoration: BoxDecoration(
        color: isDark ? AppColors.glassBgDark : AppColors.glassBgLight,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark ? AppColors.glassBorderDark : AppColors.glassBorderLight,
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryPurple.withOpacity(isDark ? 0.08 : 0.04),
            blurRadius: 20,
            spreadRadius: 2,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final double containerW = constraints.maxWidth;
            final double containerH = 420.0;

            return GestureDetector(
              behavior: HitTestBehavior.opaque,
              onPanUpdate: (details) {
                setState(() {
                  _rotationY += details.delta.dx * 0.007;
                  _rotationX -= details.delta.dy * 0.007;
                  _rotationX = _rotationX.clamp(-0.4, 0.4);
                });
              },

              onTapUp: (details) {
                final tapPos = details.localPosition;
                final centerX = containerW / 2;
                final centerY = containerH / 2 - 20;

                // Define 3D positions of the clickable body regions
                final Map<String, Vector3> region3DCoords = {
                  'Cervical spine': const Vector3(0.0, -0.58, 0.0),
                  'Shoulder': const Vector3(0.18, -0.5, 0.0),
                  'Elbow': const Vector3(0.25, -0.22, 0.0),
                  'Wrist and hand': const Vector3(0.28, 0.05, 0.02),
                  'Pelvis': const Vector3(0.0, 0.06, 0.0),
                  'Hip': const Vector3(0.11, 0.08, 0.0),
                  'Knee': const Vector3(0.12, 0.44, 0.02),
                  'Ankle and foot': const Vector3(0.13, 0.78, -0.02),
                };

                double minDist = double.infinity;
                String? closestRegion;

                region3DCoords.forEach((regionKey, rawPt) {
                  // Mirror for left / right clicks
                  final pt = regionKey == 'Shoulder' || regionKey == 'Elbow' || regionKey == 'Wrist and hand' || regionKey == 'Hip' || regionKey == 'Knee' || regionKey == 'Ankle and foot'
                      ? Vector3(rawPt.x * (tapPos.dx < centerX ? -1 : 1), rawPt.y, rawPt.z)
                      : rawPt;

                  // Rotate and project point
                  final rotated = pt.rotateY(_rotationY).rotateX(_rotationX);
                  final proj = rotated.project(containerW, containerH, 0.9, centerX, centerY);
                  
                  final dist = (tapPos - proj).distance;
                  if (dist < minDist) {
                    minDist = dist;
                    closestRegion = regionKey;
                  }
                });

                if (closestRegion != null && minDist < 45.0) {
                  _navigateToRegion(closestRegion!);
                }
              },
              child: Stack(
                children: [
                  // Subtle radial gradient background
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: RadialGradient(
                          center: Alignment.center,
                          radius: 0.9,
                          colors: [
                            AppColors.primaryPurple.withOpacity(isDark ? 0.06 : 0.03),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Main 3D realistic skeleton model and muscle image with drag-to-rotate interaction
                  Center(
                    child: SizedBox(
                      width: containerW * 0.9,
                      height: containerH * 0.95,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // High-Resolution 3D Anatomical Skeleton Texture with 3D Perspective Rotation
                          Transform(
                            alignment: Alignment.center,
                            transform: Matrix4.identity()
                              ..setEntry(3, 2, 0.0012)
                              ..rotateY(_rotationY)
                              ..rotateX(_rotationX),
                            child: Image.asset(
                              ((_rotationY.abs() % (math.pi * 2)) > math.pi / 2 && (_rotationY.abs() % (math.pi * 2)) < 3 * math.pi / 2)
                                  ? 'assets/skeleton/skeleton_back_color.png'
                                  : 'assets/skeleton/skeleton_base_color.png',
                              fit: BoxFit.contain,
                              filterQuality: FilterQuality.high,
                            ),
                          ),

                          // 3D Projected Bioluminescent Hotspots & Layer Highlights
                          Positioned.fill(
                            child: RepaintBoundary(
                              child: AnimatedBuilder(
                                animation: _pulseController,
                                builder: (context, _) {
                                  return CustomPaint(
                                    size: Size(containerW * 0.9, containerH * 0.95),
                                    painter: ThreeDAnatomyPainter(
                                      rotationY: _rotationY,
                                      rotationX: _rotationX,
                                      zoom: 0.9,
                                      visibleLayers: const {'bone', 'muscle'},
                                      selectedId: null,
                                      pulse: _pulseController.value,
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),


                  // Floating helper controls
                  Positioned(
                    left: 16,
                    bottom: 14,
                    child: Row(
                      children: [
                        Icon(Icons.swipe,
                            size: 14,
                            color: isDark ? Colors.white38 : AppColors.lightTextSecondary),
                        const SizedBox(width: 6),
                        Text(
                          'Drag to rotate • Tap a region below',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: isDark ? Colors.white38 : AppColors.lightTextSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Left Column (Cervical Spine, Shoulder, Elbow, Wrist)
                  Positioned(
                    left: 10,
                    top: 30,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildRegionButton('Cervical spine', 'Cervical Spine', isDark,
                            icon: Icons.accessibility_new),
                        const SizedBox(height: 10),
                        _buildRegionButton('Shoulder', 'Shoulder Girdle', isDark,
                            icon: Icons.fitness_center),
                        const SizedBox(height: 10),
                        _buildRegionButton('Elbow', 'Elbow Joint', isDark,
                            icon: Icons.compare_arrows),
                        const SizedBox(height: 10),
                        _buildRegionButton('Wrist and hand', 'Wrist & Hand', isDark,
                            icon: Icons.pan_tool_alt),
                      ],
                    ),
                  ),

                  // Right Column (Pelvis, Hip, Knee, Ankle)
                  Positioned(
                    right: 10,
                    top: 30,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        _buildRegionButton('Pelvis', 'Pelvis & SIJ', isDark,
                            icon: Icons.ring_volume),
                        const SizedBox(height: 10),
                        _buildRegionButton('Hip', 'Hip Joint', isDark,
                            icon: Icons.directions_walk),
                        const SizedBox(height: 10),
                        _buildRegionButton('Knee', 'Knee Joint', isDark,
                            icon: Icons.airline_seat_legroom_normal),
                        const SizedBox(height: 10),
                        _buildRegionButton('Ankle and foot', 'Ankle & Foot', isDark,
                            icon: Icons.snowshoeing),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildRegionButton(String regionKey, String label, bool isDark,
      {IconData icon = Icons.link}) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _navigateToRegion(regionKey),
        borderRadius: BorderRadius.circular(14),
        splashColor: AppColors.primaryPink.withOpacity(0.15),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
          decoration: BoxDecoration(
            color: isDark ? AppColors.glassBgDark : Colors.white.withOpacity(0.75),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: AppColors.primaryPurple.withOpacity(0.18),
              width: 1.0,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryPurple.withOpacity(0.06),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 12, color: AppColors.primaryPink),
              const SizedBox(width: 5),
              Text(
                label,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.2,
                  color: isDark ? Colors.white70 : AppColors.lightTextPrimary,
                ),
              ),
              const SizedBox(width: 3),
              Icon(Icons.chevron_right, size: 12,
                  color: AppColors.primaryPink.withOpacity(0.6)),
            ],
          ),
        ),
      ),
    );
  }
}
