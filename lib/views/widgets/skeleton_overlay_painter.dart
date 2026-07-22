import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Defines a hotspot position on the skeleton image overlay.
class SkeletonHotspot {
  final String id;
  final String label;
  final String anatomicalName; // Latin / Medical name
  final Offset relativePosition; // 0.0-1.0 relative to container
  final Color color;
  final String layerType; // 'bone', 'muscle', 'nerve', 'ligament'
  final bool isAnterior; // True = Front, False = Back

  const SkeletonHotspot({
    required this.id,
    required this.label,
    required this.anatomicalName,
    required this.relativePosition,
    required this.color,
    required this.layerType,
    required this.isAnterior,
  });
}

/// Paints interactive anatomical hotspots, leader lines, and pulsing glows
/// over a skeleton texture image.
class SkeletonOverlayPainter extends CustomPainter {
  final List<SkeletonHotspot> hotspots;
  final String? selectedId;
  final double pulse; // 0.0 to 1.0 animation value
  final bool isAnterior;
  final Set<String> visibleLayers; // Which layers to show

  SkeletonOverlayPainter({
    required this.hotspots,
    this.selectedId,
    this.pulse = 0.0,
    required this.isAnterior,
    this.visibleLayers = const {'bone', 'muscle', 'nerve', 'ligament'},
  });

  static final Paint _glowPaint = Paint()
    ..style = PaintingStyle.fill
    ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5);
  static final Paint _corePaint = Paint()..style = PaintingStyle.fill;
  static final Paint _innerPaint = Paint()
    ..color = Colors.white
    ..style = PaintingStyle.fill;
  static final Paint _ringPaint = Paint()..style = PaintingStyle.stroke;
  static final Paint _linePaint = Paint()..style = PaintingStyle.stroke;

  @override
  void paint(Canvas canvas, Size size) {
    for (final hotspot in hotspots) {
      if (hotspot.isAnterior != isAnterior) continue;
      if (!visibleLayers.contains(hotspot.layerType)) continue;

      final pos = Offset(
        hotspot.relativePosition.dx * size.width,
        hotspot.relativePosition.dy * size.height,
      );

      final isSelected = hotspot.id == selectedId;
      final baseColor = hotspot.color;

      // Outer pulsing glow ring using biological pastel color scheme
      final glowRadius = isSelected
          ? 16.0 + 4.0 * math.sin(pulse * 2 * math.pi)
          : 10.0 + 2.0 * math.sin(pulse * 2 * math.pi);
      _glowPaint.color = baseColor.withOpacity(isSelected ? 0.35 : 0.15);
      canvas.drawCircle(pos, glowRadius, _glowPaint);

      // Core dot
      final coreRadius = isSelected ? 6.5 : 4.5;
      _corePaint.color = baseColor.withOpacity(isSelected ? 1.0 : 0.75);
      canvas.drawCircle(pos, coreRadius, _corePaint);

      // Inner white dot for medical precision look
      canvas.drawCircle(pos, isSelected ? 2.2 : 1.5, _innerPaint);

      // Draw leader line and label chip if selected
      if (isSelected) {
        // Draw selection ring
        _ringPaint
          ..color = baseColor
          ..strokeWidth = 1.5;
        canvas.drawCircle(pos, 11.0, _ringPaint);

        // Determine leader line direction (left or right based on position)
        final isLeftPart = hotspot.relativePosition.dx < 0.5;
        final lineEnd = Offset(
          isLeftPart ? pos.dx - 45 : pos.dx + 45,
          pos.dy - 20,
        );
        final lineExt = Offset(
          isLeftPart ? lineEnd.dx - 15 : lineEnd.dx + 15,
          lineEnd.dy,
        );

        _linePaint
          ..color = baseColor.withOpacity(0.8)
          ..strokeWidth = 1.2;

        // Draw thin medical leader line
        canvas.drawLine(pos, lineEnd, _linePaint);
        canvas.drawLine(lineEnd, lineExt, _linePaint);

        // Draw a tiny anchor dot at the label start
        _corePaint.color = baseColor;
        canvas.drawCircle(lineExt, 2.0, _corePaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant SkeletonOverlayPainter oldDelegate) {
    return oldDelegate.selectedId != selectedId ||
        oldDelegate.pulse != pulse ||
        oldDelegate.isAnterior != isAnterior ||
        oldDelegate.visibleLayers != visibleLayers;
  }
}

// Biological Medical Pastel Colors
class BioColors {
  static const Color bone = Color(0xFFE5D3B3);      // Soft Warm Ivory Bone
  static const Color muscle = Color(0xFFE57373);    // Pastel Terracotta Red
  static const Color nerve = Color(0xFFFBC02D);     // Clinical Amber Yellow
  static const Color ligament = Color(0xFF4DB6AC);  // Mint/Teal Collagen
}

/// Comprehensive list of hotspots mapping bones, muscles, nerves, and ligaments.
const List<SkeletonHotspot> anatomyScreenHotspots = [
  // ================= ANTERIOR (FRONT) VIEW =================
  // Bones (Anterior)
  SkeletonHotspot(
    id: 'skull',
    label: 'Skull',
    anatomicalName: 'Cranium & Mandible',
    relativePosition: Offset(0.50, 0.08),
    color: BioColors.bone,
    layerType: 'bone',
    isAnterior: true,
  ),
  SkeletonHotspot(
    id: 'spine',
    label: 'Cervical Spine',
    anatomicalName: 'Columna Vertebralis C1-C7',
    relativePosition: Offset(0.50, 0.15),
    color: BioColors.bone,
    layerType: 'bone',
    isAnterior: true,
  ),
  SkeletonHotspot(
    id: 'ribs',
    label: 'Rib Cage',
    anatomicalName: 'Cavea Thoracis',
    relativePosition: Offset(0.50, 0.28),
    color: BioColors.bone,
    layerType: 'bone',
    isAnterior: true,
  ),
  SkeletonHotspot(
    id: 'pelvis',
    label: 'Pelvic Girdle',
    anatomicalName: 'Cingulum Pelvicum',
    relativePosition: Offset(0.50, 0.49),
    color: BioColors.bone,
    layerType: 'bone',
    isAnterior: true,
  ),
  SkeletonHotspot(
    id: 'humerus',
    label: 'Humerus',
    anatomicalName: 'Humerus Anterior',
    relativePosition: Offset(0.70, 0.28),
    color: BioColors.bone,
    layerType: 'bone',
    isAnterior: true,
  ),
  SkeletonHotspot(
    id: 'radius_ulna',
    label: 'Forearm Bones',
    anatomicalName: 'Radius & Ulna',
    relativePosition: Offset(0.78, 0.38),
    color: BioColors.bone,
    layerType: 'bone',
    isAnterior: true,
  ),
  SkeletonHotspot(
    id: 'femur',
    label: 'Femur',
    anatomicalName: 'Os Femoris',
    relativePosition: Offset(0.58, 0.60),
    color: BioColors.bone,
    layerType: 'bone',
    isAnterior: true,
  ),
  SkeletonHotspot(
    id: 'tibia_fibula',
    label: 'Lower Leg Bones',
    anatomicalName: 'Tibia & Fibula',
    relativePosition: Offset(0.57, 0.79),
    color: BioColors.bone,
    layerType: 'bone',
    isAnterior: true,
  ),

  // Muscles (Anterior)
  SkeletonHotspot(
    id: 'deltoid',
    label: 'Deltoid',
    anatomicalName: 'M. deltoideus',
    relativePosition: Offset(0.28, 0.21),
    color: BioColors.muscle,
    layerType: 'muscle',
    isAnterior: true,
  ),
  SkeletonHotspot(
    id: 'pectoralis',
    label: 'Pectoralis Major',
    anatomicalName: 'M. pectoralis major',
    relativePosition: Offset(0.40, 0.24),
    color: BioColors.muscle,
    layerType: 'muscle',
    isAnterior: true,
  ),
  SkeletonHotspot(
    id: 'biceps',
    label: 'Biceps Brachii',
    anatomicalName: 'M. biceps brachii',
    relativePosition: Offset(0.23, 0.31),
    color: BioColors.muscle,
    layerType: 'muscle',
    isAnterior: true,
  ),
  SkeletonHotspot(
    id: 'abdominals',
    label: 'Rectus Abdominis',
    anatomicalName: 'M. rectus abdominis',
    relativePosition: Offset(0.50, 0.38),
    color: BioColors.muscle,
    layerType: 'muscle',
    isAnterior: true,
  ),
  SkeletonHotspot(
    id: 'quadriceps',
    label: 'Quadriceps',
    anatomicalName: 'M. quadriceps femoris',
    relativePosition: Offset(0.42, 0.61),
    color: BioColors.muscle,
    layerType: 'muscle',
    isAnterior: true,
  ),

  // Ligaments (Anterior)
  SkeletonHotspot(
    id: 'acl_pcl',
    label: 'Cruciate Ligaments',
    anatomicalName: 'Lig. cruciatum anterius/posterius',
    relativePosition: Offset(0.46, 0.71),
    color: BioColors.ligament,
    layerType: 'ligament',
    isAnterior: true,
  ),
  SkeletonHotspot(
    id: 'mcl_lcl',
    label: 'Collateral Ligaments',
    anatomicalName: 'Lig. collaterale mediale/laterale',
    relativePosition: Offset(0.54, 0.71),
    color: BioColors.ligament,
    layerType: 'ligament',
    isAnterior: true,
  ),
  SkeletonHotspot(
    id: 'glenohumeral',
    label: 'Glenohumeral Ligaments',
    anatomicalName: 'Ligg. glenohumeralia',
    relativePosition: Offset(0.68, 0.20),
    color: BioColors.ligament,
    layerType: 'ligament',
    isAnterior: true,
  ),

  // Nerves (Anterior)
  SkeletonHotspot(
    id: 'c6_nerve',
    label: 'C6 Nerve Root',
    anatomicalName: 'Radix C6 plexus brachialis',
    relativePosition: Offset(0.35, 0.16),
    color: BioColors.nerve,
    layerType: 'nerve',
    isAnterior: true,
  ),

  // ================= POSTERIOR (BACK) VIEW =================
  // Bones (Posterior)
  SkeletonHotspot(
    id: 'skull',
    label: 'Occipital Bone',
    anatomicalName: 'Os occipitale',
    relativePosition: Offset(0.50, 0.08),
    color: BioColors.bone,
    layerType: 'bone',
    isAnterior: false,
  ),
  SkeletonHotspot(
    id: 'spine',
    label: 'Thoracic & Lumbar Spine',
    anatomicalName: 'Spina Vertebralis T1-L5',
    relativePosition: Offset(0.50, 0.25),
    color: BioColors.bone,
    layerType: 'bone',
    isAnterior: false,
  ),
  SkeletonHotspot(
    id: 'pelvis',
    label: 'Sacrum & Coccyx',
    anatomicalName: 'Os sacrum',
    relativePosition: Offset(0.50, 0.49),
    color: BioColors.bone,
    layerType: 'bone',
    isAnterior: false,
  ),
  SkeletonHotspot(
    id: 'humerus',
    label: 'Humerus (Posterior)',
    anatomicalName: 'Humerus Posterior',
    relativePosition: Offset(0.30, 0.28),
    color: BioColors.bone,
    layerType: 'bone',
    isAnterior: false,
  ),
  SkeletonHotspot(
    id: 'radius_ulna',
    label: 'Forearm (Olecranon)',
    anatomicalName: 'Ulna & Radius',
    relativePosition: Offset(0.22, 0.38),
    color: BioColors.bone,
    layerType: 'bone',
    isAnterior: false,
  ),
  SkeletonHotspot(
    id: 'femur',
    label: 'Femur (Posterior)',
    anatomicalName: 'Os Femoris Posterior',
    relativePosition: Offset(0.42, 0.60),
    color: BioColors.bone,
    layerType: 'bone',
    isAnterior: false,
  ),
  SkeletonHotspot(
    id: 'tibia_fibula',
    label: 'Tibia/Fibula (Back)',
    anatomicalName: 'Tibia & Fibula',
    relativePosition: Offset(0.43, 0.79),
    color: BioColors.bone,
    layerType: 'bone',
    isAnterior: false,
  ),

  // Muscles (Posterior)
  SkeletonHotspot(
    id: 'trapezius',
    label: 'Trapezius',
    anatomicalName: 'M. trapezius',
    relativePosition: Offset(0.50, 0.17),
    color: BioColors.muscle,
    layerType: 'muscle',
    isAnterior: false,
  ),
  SkeletonHotspot(
    id: 'latissimus_dorsi',
    label: 'Latissimus Dorsi',
    anatomicalName: 'M. latissimus dorsi',
    relativePosition: Offset(0.60, 0.33),
    color: BioColors.muscle,
    layerType: 'muscle',
    isAnterior: false,
  ),
  SkeletonHotspot(
    id: 'gluteus_maximus',
    label: 'Gluteus Maximus',
    anatomicalName: 'M. gluteus maximus',
    relativePosition: Offset(0.58, 0.51),
    color: BioColors.muscle,
    layerType: 'muscle',
    isAnterior: false,
  ),
  SkeletonHotspot(
    id: 'hamstrings',
    label: 'Hamstrings',
    anatomicalName: 'Mm. ischiocrurales',
    relativePosition: Offset(0.58, 0.65),
    color: BioColors.muscle,
    layerType: 'muscle',
    isAnterior: false,
  ),
  SkeletonHotspot(
    id: 'calves',
    label: 'Gastrocnemius',
    anatomicalName: 'M. gastrocnemius',
    relativePosition: Offset(0.58, 0.81),
    color: BioColors.muscle,
    layerType: 'muscle',
    isAnterior: false,
  ),
  SkeletonHotspot(
    id: 'triceps',
    label: 'Triceps Brachii',
    anatomicalName: 'M. triceps brachii',
    relativePosition: Offset(0.77, 0.31),
    color: BioColors.muscle,
    layerType: 'muscle',
    isAnterior: false,
  ),

  // Nerves (Posterior)
  SkeletonHotspot(
    id: 'sciatic',
    label: 'Sciatic Nerve',
    anatomicalName: 'N. ischiadicus',
    relativePosition: Offset(0.48, 0.54),
    color: BioColors.nerve,
    layerType: 'nerve',
    isAnterior: false,
  ),
];

const List<SkeletonHotspot> homeBodyMapHotspots = [
  SkeletonHotspot(
    id: 'Cervical spine',
    label: 'Cervical Spine',
    anatomicalName: 'Columna Vertebralis Cervicalis',
    relativePosition: Offset(0.50, 0.145),
    color: BioColors.bone,
    layerType: 'bone',
    isAnterior: true,
  ),
  SkeletonHotspot(
    id: 'Shoulder',
    label: 'Shoulder',
    anatomicalName: 'Articulatio humeri',
    relativePosition: Offset(0.70, 0.195),
    color: BioColors.muscle,
    layerType: 'muscle',
    isAnterior: true,
  ),
  SkeletonHotspot(
    id: 'Elbow',
    label: 'Elbow',
    anatomicalName: 'Articulatio cubiti',
    relativePosition: Offset(0.80, 0.355),
    color: BioColors.bone,
    layerType: 'bone',
    isAnterior: true,
  ),
  SkeletonHotspot(
    id: 'Wrist and hand',
    label: 'Wrist & Hand',
    anatomicalName: 'Articulatio radiocarpea',
    relativePosition: Offset(0.86, 0.50),
    color: BioColors.bone,
    layerType: 'bone',
    isAnterior: true,
  ),
  SkeletonHotspot(
    id: 'Pelvis',
    label: 'Pelvis & SIJ',
    anatomicalName: 'Cingulum pelvicum',
    relativePosition: Offset(0.50, 0.49),
    color: BioColors.bone,
    layerType: 'bone',
    isAnterior: true,
  ),
  SkeletonHotspot(
    id: 'Hip',
    label: 'Hip',
    anatomicalName: 'Articulatio coxae',
    relativePosition: Offset(0.38, 0.52),
    color: BioColors.muscle,
    layerType: 'muscle',
    isAnterior: true,
  ),
  SkeletonHotspot(
    id: 'Knee',
    label: 'Knee',
    anatomicalName: 'Articulatio genus',
    relativePosition: Offset(0.38, 0.70),
    color: BioColors.bone,
    layerType: 'bone',
    isAnterior: true,
  ),
  SkeletonHotspot(
    id: 'Ankle and foot',
    label: 'Ankle & Foot',
    anatomicalName: 'Articulatio talocruralis',
    relativePosition: Offset(0.39, 0.90),
    color: BioColors.bone,
    layerType: 'bone',
    isAnterior: true,
  ),
];
