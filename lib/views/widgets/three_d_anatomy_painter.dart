import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Representation of a 3D coordinate vector
class Vector3 {
  final double x;
  final double y;
  final double z;

  const Vector3(this.x, this.y, this.z);

  Vector3 rotateY(double angle) {
    final cosA = math.cos(angle);
    final sinA = math.sin(angle);
    return Vector3(
      x * cosA - z * sinA,
      y,
      x * sinA + z * cosA,
    );
  }

  Vector3 rotateX(double angle) {
    final cosA = math.cos(angle);
    final sinA = math.sin(angle);
    return Vector3(
      x,
      y * cosA - z * sinA,
      y * sinA + z * cosA,
    );
  }

  Offset project(double width, double height, double zoom, double centerX, double centerY) {
    const d = 0.5; // Perspective factor
    final scale = zoom * math.min(width, height) * 0.44;
    final denom = (1.0 - z * d).clamp(0.1, 3.0);
    return Offset(
      centerX + (x * scale) / denom,
      centerY + (y * scale) / denom,
    );
  }

  double dot(Vector3 other) {
    return x * other.x + y * other.y + z * other.z;
  }

  Vector3 normalize() {
    final len = math.sqrt(x * x + y * y + z * z);
    if (len == 0) return const Vector3(0, 0, 0);
    return Vector3(x / len, y / len, z / len);
  }

  Vector3 operator -(Vector3 other) => Vector3(x - other.x, y - other.y, z - other.z);
  Vector3 operator +(Vector3 other) => Vector3(x + other.x, y + other.y, z + other.z);
  Vector3 operator *(double scalar) => Vector3(x * scalar, y * scalar, z * scalar);

  double distanceTo(Vector3 other) {
    final dx = x - other.x;
    final dy = y - other.y;
    final dz = z - other.z;
    return math.sqrt(dx * dx + dy * dy + dz * dz);
  }
}

/// A pre-computed drawing instruction sorted by depth
class DrawPrimitive {
  final double depth; // Sorted from back to front
  final void Function(Canvas canvas) draw;

  DrawPrimitive({required this.depth, required this.draw});
}

/// Pre-cached structures to avoid allocating lists and objects inside paint loop
class CachedMuscle {
  final String id;
  final List<List<Vector3>> fibers;
  const CachedMuscle({required this.id, required this.fibers});
}

class CachedNerve {
  final String id;
  final List<List<Vector3>> paths;
  const CachedNerve({required this.id, required this.paths});
}

class CachedLigament {
  final String id;
  final List<List<Vector3>> lines;
  const CachedLigament({required this.id, required this.lines});
}

/// Color codes for different biological systems
class BioColors {
  static const Color bone = Color(0xFFE5D3B3);      // Soft Warm Ivory Bone
  static const Color boneSelected = Color(0xFFFFFFFF);
  static const Color muscle = Color(0xFFFF5252);    // Glowing Red Myology
  static const Color muscleSelected = Color(0xFFFF8A80);
  static const Color nerve = Color(0xFFFFD740);     // Neurology Amber
  static const Color nerveSelected = Color(0xFFFFF176);
  static const Color ligament = Color(0xFF1DE9B6);  // Arthrology Collagen Mint
  static const Color ligamentSelected = Color(0xFF64FFDA);
}

/// Static 3D Human Anatomy Database & Cached Geometries
class ThreeDAnatomyModel {
  // Joint Nodes
  static const Map<String, Vector3> joints = {
    'skull_center': Vector3(0, -0.75, 0),
    'neck': Vector3(0, -0.62, 0),
    'thoracic_top': Vector3(0, -0.5, -0.02),
    'thoracic_mid': Vector3(0, -0.32, -0.04),
    'lumbar_mid': Vector3(0, -0.15, -0.03),
    'sacrum_top': Vector3(0, 0.02, -0.02),
    'sacrum_bottom': Vector3(0, 0.12, -0.03),
    'sternum_top': Vector3(0, -0.5, 0.05),
    'sternum_bottom': Vector3(0, -0.23, 0.05),

    'shoulder_l': Vector3(-0.18, -0.5, -0.02),
    'shoulder_r': Vector3(0.18, -0.5, -0.02),
    'elbow_l': Vector3(-0.25, -0.22, 0.0),
    'elbow_r': Vector3(0.25, -0.22, 0.0),
    'wrist_l': Vector3(-0.28, 0.05, 0.02),
    'wrist_r': Vector3(0.28, 0.05, 0.02),

    'hip_l': Vector3(-0.11, 0.08, 0.0),
    'hip_r': Vector3(0.11, 0.08, 0.0),
    'knee_l': Vector3(-0.12, 0.44, 0.02),
    'knee_r': Vector3(0.12, 0.44, 0.02),
    'ankle_l': Vector3(-0.13, 0.78, -0.02),
    'ankle_r': Vector3(0.13, 0.78, -0.02),
  };

  // Hotspots Centers
  static final Map<String, Vector3> hotSpotCenters = {
    'skull': const Vector3(0, -0.75, 0.05),
    'spine': const Vector3(0, -0.32, -0.04),
    'ribs': const Vector3(0.10, -0.35, 0.06),
    'pelvis': const Vector3(0, 0.06, 0.0),
    'humerus': const Vector3(0.20, -0.36, -0.01),
    'radius_ulna': const Vector3(0.26, -0.08, 0.01),
    'femur': const Vector3(0.11, 0.26, 0.01),
    'tibia_fibula': const Vector3(0.12, 0.61, 0.0),
    'deltoid': const Vector3(0.20, -0.46, 0.03),
    'pectoralis': const Vector3(0.09, -0.38, 0.06),
    'biceps': const Vector3(0.23, -0.34, 0.03),
    'abdominals': const Vector3(0, -0.12, 0.05),
    'quadriceps': const Vector3(0.12, 0.26, 0.06),
    'calves': const Vector3(0.12, 0.61, -0.05),
    'trapezius': const Vector3(0.0, -0.42, -0.06),
    'latissimus_dorsi': const Vector3(0.10, -0.22, -0.05),
    'gluteus_maximus': const Vector3(0.11, 0.12, -0.05),
    'hamstrings': const Vector3(0.12, 0.26, -0.05),
    'triceps': const Vector3(0.23, -0.34, -0.03),
    'acl_pcl': const Vector3(0.12, 0.44, 0.02),
    'mcl_lcl': const Vector3(0.15, 0.44, 0.0),
    'glenohumeral': const Vector3(0.19, -0.5, 0.02),
    'c6_nerve': const Vector3(0.06, -0.58, 0.01),
    'sciatic': const Vector3(0.08, 0.18, -0.04),
  };

  // Pre-compiled cached lists generated exactly ONCE on load to ensure optimal speed
  static final List<List<Vector3>> cachedSkull = _generateSkull();
  static final List<List<Vector3>> cachedSkullMesh = _generateSkullMesh();
  static final List<List<Vector3>> cachedRibs = _generateRibs();
  static final List<List<Vector3>> cachedPelvis = _generatePelvis();
  static final List<List<Vector3>> cachedLimbMeshes = _generateLimbMeshes();
  static final List<CachedMuscle> cachedMuscles = _generateMuscles();
  static final List<CachedNerve> cachedNerves = _generateNerves();
  static final List<CachedLigament> cachedLigaments = _generateLigaments();

  static List<List<Vector3>> _generateSkullMesh() {
    final mesh = <List<Vector3>>[];
    // Cranium center - head sits at top of body
    // Y axis: negative = up, positive = down
    // Z axis: positive = forward (toward viewer)
    const cx = 0.0;
    const cy = -0.76;
    const cz = 0.0;
    const rx = 0.085; // width
    const ry = 0.095; // height
    const rz = 0.090; // depth

    const latSteps = 8;
    const lonSteps = 14;

    for (int i = 0; i < latSteps; i++) {
      final lat1 = -math.pi / 2 + (math.pi * i / latSteps);
      final lat2 = -math.pi / 2 + (math.pi * (i + 1) / latSteps);

      for (int j = 0; j < lonSteps; j++) {
        // lon=0 => cos=1, sin=0 => front of skull faces +Z
        final lon1 = 2 * math.pi * j / lonSteps;
        final lon2 = 2 * math.pi * (j + 1) / lonSteps;

        // X = lateral, Y = vertical, Z = anterior-posterior
        final p1 = Vector3(
          cx + rx * math.cos(lat1) * math.sin(lon1),
          cy + ry * math.sin(lat1),
          cz + rz * math.cos(lat1) * math.cos(lon1),
        );
        final p2 = Vector3(
          cx + rx * math.cos(lat1) * math.sin(lon2),
          cy + ry * math.sin(lat1),
          cz + rz * math.cos(lat1) * math.cos(lon2),
        );
        final p3 = Vector3(
          cx + rx * math.cos(lat2) * math.sin(lon2),
          cy + ry * math.sin(lat2),
          cz + rz * math.cos(lat2) * math.cos(lon2),
        );
        final p4 = Vector3(
          cx + rx * math.cos(lat2) * math.sin(lon1),
          cy + ry * math.sin(lat2),
          cz + rz * math.cos(lat2) * math.cos(lon1),
        );

        mesh.add([p1, p2, p3, p4]);
      }
    }
    return mesh;
  }

  static List<List<Vector3>> _generateCylinderMesh(Vector3 start, Vector3 end, double radius, {int sides = 6}) {
    final mesh = <List<Vector3>>[];
    final axis = end - start;
    final len = math.sqrt(axis.x * axis.x + axis.y * axis.y + axis.z * axis.z);
    if (len == 0) return mesh;

    final dir = axis.normalize();
    Vector3 perp1 = (dir.x.abs() < 0.9) ? ThreeDAnatomyModel.cross(dir, const Vector3(1, 0, 0)) : ThreeDAnatomyModel.cross(dir, const Vector3(0, 1, 0));
    perp1 = perp1.normalize();
    final perp2 = ThreeDAnatomyModel.cross(dir, perp1);

    for (int i = 0; i < sides; i++) {
      final a1 = (2 * math.pi * i) / sides;
      final a2 = (2 * math.pi * (i + 1)) / sides;

      final off1 = perp1 * (math.cos(a1) * radius) + perp2 * (math.sin(a1) * radius);
      final off2 = perp1 * (math.cos(a2) * radius) + perp2 * (math.sin(a2) * radius);

      final p1 = start + off1;
      final p2 = start + off2;
      final p3 = end + off2;
      final p4 = end + off1;

      mesh.add([p1, p2, p3, p4]);
    }
    return mesh;
  }

  static List<List<Vector3>> _generateLimbMeshes() {
    final list = <List<Vector3>>[];
    // Humerus L/R
    list.addAll(_generateCylinderMesh(joints['shoulder_l']!, joints['elbow_l']!, 0.022));
    list.addAll(_generateCylinderMesh(joints['shoulder_r']!, joints['elbow_r']!, 0.022));
    // Femur L/R
    list.addAll(_generateCylinderMesh(joints['hip_l']!, joints['knee_l']!, 0.028));
    list.addAll(_generateCylinderMesh(joints['hip_r']!, joints['knee_r']!, 0.028));
    // Tibia L/R
    list.addAll(_generateCylinderMesh(joints['knee_l']!, joints['ankle_l']!, 0.020));
    list.addAll(_generateCylinderMesh(joints['knee_r']!, joints['ankle_r']!, 0.020));
    // Radius / Ulna L/R
    list.addAll(_generateCylinderMesh(joints['elbow_l']!, joints['wrist_l']!, 0.016));
    list.addAll(_generateCylinderMesh(joints['elbow_r']!, joints['wrist_r']!, 0.016));
    // Sternum & Clavicles
    list.addAll(_generateCylinderMesh(joints['sternum_top']!, joints['sternum_bottom']!, 0.025));
    list.addAll(_generateCylinderMesh(joints['shoulder_l']!, joints['sternum_top']!, 0.012));
    list.addAll(_generateCylinderMesh(joints['shoulder_r']!, joints['sternum_top']!, 0.012));

    return list;
  }

  static List<List<Vector3>> _generateSkull() {
    final paths = <List<Vector3>>[];
    // Skull center: top of body. Y-up = negative, Z-forward = positive.
    const double cx = 0.0;
    const double cy = -0.76;
    const double cz = 0.0;

    // --- Left & Right Orbital (Eye Socket) Rings ---
    // Placed on the FRONT face of skull (z ~ +0.075-0.085)
    // Left eye: x=-0.030, Right eye: x=+0.030
    // Eye socket sits at mid-upper face: y = cy - 0.005
    final eyeL = <Vector3>[];
    final eyeR = <Vector3>[];
    for (double a = 0; a <= 2 * math.pi + 0.01; a += math.pi / 7) {
      eyeL.add(Vector3(
        cx - 0.030 + 0.019 * math.cos(a),
        cy - 0.010 + 0.016 * math.sin(a),
        cz + 0.079,
      ));
      eyeR.add(Vector3(
        cx + 0.030 + 0.019 * math.cos(a),
        cy - 0.010 + 0.016 * math.sin(a),
        cz + 0.079,
      ));
    }
    paths.add(eyeL);
    paths.add(eyeR);

    // --- Nasal Aperture (Piriform cavity) ---
    // Between and below the eye sockets
    paths.add([
      Vector3(cx,        cy + 0.012, cz + 0.088),
      Vector3(cx - 0.013, cy + 0.025, cz + 0.086),
      Vector3(cx - 0.010, cy + 0.038, cz + 0.082),
      Vector3(cx,        cy + 0.040, cz + 0.081),
      Vector3(cx + 0.010, cy + 0.038, cz + 0.082),
      Vector3(cx + 0.013, cy + 0.025, cz + 0.086),
      Vector3(cx,        cy + 0.012, cz + 0.088),
    ]);

    // --- Zygomatic Arches (Cheekbones) ---
    // Sweep from lateral skull to front face
    paths.add([
      Vector3(cx - 0.082, cy + 0.005, cz + 0.000),
      Vector3(cx - 0.075, cy + 0.008, cz + 0.038),
      Vector3(cx - 0.058, cy + 0.015, cz + 0.065),
      Vector3(cx - 0.040, cy + 0.020, cz + 0.080),
    ]);
    paths.add([
      Vector3(cx + 0.082, cy + 0.005, cz + 0.000),
      Vector3(cx + 0.075, cy + 0.008, cz + 0.038),
      Vector3(cx + 0.058, cy + 0.015, cz + 0.065),
      Vector3(cx + 0.040, cy + 0.020, cz + 0.080),
    ]);

    // --- Mandible (Jawbone) ---
    // U-shaped jaw below the nasal aperture
    paths.add([
      Vector3(cx - 0.060, cy + 0.025, cz + 0.018),
      Vector3(cx - 0.055, cy + 0.055, cz + 0.050),
      Vector3(cx - 0.038, cy + 0.080, cz + 0.072),
      Vector3(cx - 0.018, cy + 0.092, cz + 0.083),
      Vector3(cx,         cy + 0.096, cz + 0.085),
      Vector3(cx + 0.018, cy + 0.092, cz + 0.083),
      Vector3(cx + 0.038, cy + 0.080, cz + 0.072),
      Vector3(cx + 0.055, cy + 0.055, cz + 0.050),
      Vector3(cx + 0.060, cy + 0.025, cz + 0.018),
    ]);

    // --- Temporal lines (side arches over cranium) ---
    final tempL = <Vector3>[];
    final tempR = <Vector3>[];
    for (double t = 0; t <= 1.0; t += 0.1) {
      final angle = math.pi * t;  // 0..pi sweep over left side
      tempL.add(Vector3(
        cx - 0.060 * math.sin(angle),
        cy - 0.095 + 0.020 * t,
        cz + 0.060 * math.cos(angle),
      ));
      tempR.add(Vector3(
        cx + 0.060 * math.sin(angle),
        cy - 0.095 + 0.020 * t,
        cz + 0.060 * math.cos(angle),
      ));
    }
    paths.add(tempL);
    paths.add(tempR);

    return paths;
  }

  static List<List<Vector3>> _generateRibs() {
    final paths = <List<Vector3>>[];
    final ribHeights = [-0.47, -0.42, -0.37, -0.32, -0.27, -0.22];

    for (int i = 0; i < ribHeights.length; i++) {
      final y = ribHeights[i];
      final leftRib = <Vector3>[];
      final rightRib = <Vector3>[];
      final width = 0.13 + (0.02 * math.sin((i / ribHeights.length) * math.pi));
      const depthBulge = 0.06;

      for (int step = 0; step <= 8; step++) {
        final t = step / 8;
        final angle = math.pi / 2 + (math.pi / 2) * t;

        leftRib.add(Vector3(
          -width * math.sin(angle),
          y + 0.03 * t,
          -0.03 + depthBulge * (1 - math.cos(angle)),
        ));

        rightRib.add(Vector3(
          width * math.sin(angle),
          y + 0.03 * t,
          -0.03 + depthBulge * (1 - math.cos(angle)),
        ));
      }
      paths.add(leftRib);
      paths.add(rightRib);
    }
    return paths;
  }

  static List<List<Vector3>> _generatePelvis() {
    return [
      [
        const Vector3(0.0, 0.02, -0.02),
        const Vector3(-0.07, 0.0, -0.03),
        const Vector3(-0.125, 0.03, -0.02),
        const Vector3(-0.13, 0.08, 0.01),
        const Vector3(-0.09, 0.12, 0.03),
        const Vector3(-0.04, 0.12, 0.04),
        const Vector3(0.0, 0.08, 0.03),
        const Vector3(-0.03, 0.13, 0.02),
        const Vector3(-0.06, 0.12, 0.0),
        const Vector3(-0.11, 0.08, 0.0),
      ],
      [
        const Vector3(0.0, 0.02, -0.02),
        const Vector3(0.07, 0.0, -0.03),
        const Vector3(0.125, 0.03, -0.02),
        const Vector3(0.13, 0.08, 0.01),
        const Vector3(0.09, 0.12, 0.03),
        const Vector3(0.04, 0.12, 0.04),
        const Vector3(0.0, 0.08, 0.03),
        const Vector3(0.03, 0.13, 0.02),
        const Vector3(0.06, 0.12, 0.0),
        const Vector3(0.11, 0.08, 0.0),
      ],
      [
        const Vector3(0, 0.02, -0.02),
        const Vector3(-0.035, 0.05, -0.03),
        const Vector3(-0.02, 0.10, -0.035),
        const Vector3(0, 0.12, -0.035),
        const Vector3(0.02, 0.10, -0.035),
        const Vector3(0.035, 0.05, -0.03),
        const Vector3(0, 0.02, -0.02),
      ]
    ];
  }

  static Vector3 cross(Vector3 a, Vector3 b) {
    return Vector3(
      a.y * b.z - a.z * b.y,
      a.z * b.x - a.x * b.z,
      a.x * b.y - a.y * b.x,
    );
  }

  static List<CachedMuscle> _generateMuscles() {
    final list = <CachedMuscle>[];

    // Define all muscle structures with static endpoints & bulge amounts
    final definitions = [
      // Deltoids
      _RawMuscleDef('deltoid', const Vector3(-0.16, -0.5, 0.01), const Vector3(-0.21, -0.36, 0.0), 0.04, const Vector3(-0.8, 0, 0.5)),
      _RawMuscleDef('deltoid', const Vector3(0.16, -0.5, 0.01), const Vector3(0.21, -0.36, 0.0), 0.04, const Vector3(0.8, 0, 0.5)),

      // Pectorals
      _RawMuscleDef('pectoralis', const Vector3(-0.01, -0.47, 0.05), const Vector3(-0.19, -0.42, 0.01), 0.025, const Vector3(-0.1, 0, 0.9)),
      _RawMuscleDef('pectoralis', const Vector3(-0.01, -0.40, 0.05), const Vector3(-0.19, -0.42, 0.01), 0.025, const Vector3(-0.1, 0, 0.9)),
      _RawMuscleDef('pectoralis', const Vector3(-0.01, -0.32, 0.05), const Vector3(-0.19, -0.42, 0.01), 0.025, const Vector3(-0.1, 0, 0.9)),
      _RawMuscleDef('pectoralis', const Vector3(0.01, -0.47, 0.05), const Vector3(0.19, -0.42, 0.01), 0.025, const Vector3(0.1, 0, 0.9)),
      _RawMuscleDef('pectoralis', const Vector3(0.01, -0.40, 0.05), const Vector3(0.19, -0.42, 0.01), 0.025, const Vector3(0.1, 0, 0.9)),
      _RawMuscleDef('pectoralis', const Vector3(0.01, -0.32, 0.05), const Vector3(0.19, -0.42, 0.01), 0.025, const Vector3(0.1, 0, 0.9)),

      // Biceps
      _RawMuscleDef('biceps', const Vector3(-0.18, -0.49, 0.01), const Vector3(-0.25, -0.21, 0.01), 0.038, const Vector3(-0.3, 0.1, 0.95)),
      _RawMuscleDef('biceps', const Vector3(0.18, -0.49, 0.01), const Vector3(0.25, -0.21, 0.01), 0.038, const Vector3(0.3, 0.1, 0.95)),

      // Triceps
      _RawMuscleDef('triceps', const Vector3(-0.18, -0.49, -0.03), const Vector3(-0.25, -0.23, -0.02), 0.035, const Vector3(-0.2, -0.1, -0.95)),
      _RawMuscleDef('triceps', const Vector3(0.18, -0.49, -0.03), const Vector3(0.25, -0.23, -0.02), 0.035, const Vector3(0.2, -0.1, -0.95)),

      // Rectus Abdominis
      _RawMuscleDef('abdominals', const Vector3(-0.04, -0.23, 0.05), const Vector3(-0.04, 0.08, 0.03), 0.018, const Vector3(0, 0, 1)),
      _RawMuscleDef('abdominals', const Vector3(0.04, -0.23, 0.05), const Vector3(0.04, 0.08, 0.03), 0.018, const Vector3(0, 0, 1)),

      // Quadriceps
      _RawMuscleDef('quadriceps', const Vector3(-0.11, 0.11, 0.02), const Vector3(-0.12, 0.42, 0.03), 0.045, const Vector3(-0.1, 0.1, 0.95)),
      _RawMuscleDef('quadriceps', const Vector3(-0.14, 0.18, 0.03), const Vector3(-0.12, 0.42, 0.03), 0.045, const Vector3(-0.1, 0.1, 0.95)),
      _RawMuscleDef('quadriceps', const Vector3(0.11, 0.11, 0.02), const Vector3(0.12, 0.42, 0.03), 0.045, const Vector3(0.1, 0.1, 0.95)),
      _RawMuscleDef('quadriceps', const Vector3(0.14, 0.18, 0.03), const Vector3(0.12, 0.42, 0.03), 0.045, const Vector3(0.1, 0.1, 0.95)),

      // Hamstrings
      _RawMuscleDef('hamstrings', const Vector3(-0.10, 0.10, -0.02), const Vector3(-0.12, 0.44, -0.01), 0.038, const Vector3(0, -0.1, -0.95)),
      _RawMuscleDef('hamstrings', const Vector3(-0.08, 0.13, -0.03), const Vector3(-0.12, 0.44, -0.01), 0.038, const Vector3(0, -0.1, -0.95)),
      _RawMuscleDef('hamstrings', const Vector3(0.10, 0.10, -0.02), const Vector3(0.12, 0.44, -0.01), 0.038, const Vector3(0, -0.1, -0.95)),
      _RawMuscleDef('hamstrings', const Vector3(0.08, 0.13, -0.03), const Vector3(0.12, 0.44, -0.01), 0.038, const Vector3(0, -0.1, -0.95)),

      // Calves
      _RawMuscleDef('calves', const Vector3(-0.12, 0.44, -0.01), const Vector3(-0.13, 0.74, -0.03), 0.04, const Vector3(-0.1, -0.15, -0.95)),
      _RawMuscleDef('calves', const Vector3(0.12, 0.44, -0.01), const Vector3(0.13, 0.74, -0.03), 0.04, const Vector3(0.1, -0.15, -0.95)),

      // Trapezius
      _RawMuscleDef('trapezius', const Vector3(0.0, -0.65, -0.03), const Vector3(-0.18, -0.5, -0.02), 0.015, const Vector3(0, 0, -1)),
      _RawMuscleDef('trapezius', const Vector3(0.0, -0.58, -0.04), const Vector3(0.18, -0.5, -0.02), 0.015, const Vector3(0, 0, -1)),
      _RawMuscleDef('trapezius', const Vector3(0.0, -0.45, -0.05), const Vector3(0.0, -0.32, -0.04), 0.015, const Vector3(0, 0, -1)),

      // Latissimus Dorsi
      _RawMuscleDef('latissimus_dorsi', const Vector3(0.0, -0.32, -0.04), const Vector3(-0.19, -0.41, -0.01), 0.02, const Vector3(-0.3, 0, -0.9)),
      _RawMuscleDef('latissimus_dorsi', const Vector3(0.0, -0.12, -0.04), const Vector3(-0.19, -0.41, -0.01), 0.02, const Vector3(-0.3, 0, -0.9)),
      _RawMuscleDef('latissimus_dorsi', const Vector3(0.0, -0.32, -0.04), const Vector3(0.19, -0.41, -0.01), 0.02, const Vector3(0.3, 0, -0.9)),
      _RawMuscleDef('latissimus_dorsi', const Vector3(0.0, -0.12, -0.04), const Vector3(0.19, -0.41, -0.01), 0.02, const Vector3(0.3, 0, -0.9)),

      // Glutes
      _RawMuscleDef('gluteus_maximus', const Vector3(-0.01, 0.03, -0.02), const Vector3(-0.12, 0.18, -0.02), 0.045, const Vector3(-0.4, -0.1, -0.95)),
      _RawMuscleDef('gluteus_maximus', const Vector3(-0.06, 0.08, -0.03), const Vector3(-0.12, 0.18, -0.02), 0.045, const Vector3(-0.4, -0.1, -0.95)),
      _RawMuscleDef('gluteus_maximus', const Vector3(0.01, 0.03, -0.02), const Vector3(0.12, 0.18, -0.02), 0.045, const Vector3(0.4, -0.1, -0.95)),
      _RawMuscleDef('gluteus_maximus', const Vector3(0.06, 0.08, -0.03), const Vector3(0.12, 0.18, -0.02), 0.045, const Vector3(0.4, -0.1, -0.95)),
    ];

    for (final def in definitions) {
      final fibers = <List<Vector3>>[];
      final axis = Vector3(def.ins.x - def.orig.x, def.ins.y - def.orig.y, def.ins.z - def.orig.z);
      final axisLength = math.sqrt(axis.x * axis.x + axis.y * axis.y + axis.z * axis.z);
      if (axisLength == 0) continue;

      final dir = Vector3(axis.x / axisLength, axis.y / axisLength, axis.z / axisLength);

      Vector3 perp1;
      if (dir.x.abs() < 0.9) {
        perp1 = cross(dir, const Vector3(1, 0, 0));
      } else {
        perp1 = cross(dir, const Vector3(0, 1, 0));
      }
      final lenP1 = math.sqrt(perp1.x * perp1.x + perp1.y * perp1.y + perp1.z * perp1.z);
      perp1 = Vector3(perp1.x / lenP1, perp1.y / lenP1, perp1.z / lenP1);
      final perp2 = cross(dir, perp1);

      // Cache a static density of 6 fibers (highly detailed, zero dynamic lag)
      const numFibers = 6;
      for (int i = 0; i < numFibers; i++) {
        final fiber = <Vector3>[];
        final radialOffsetAngle = (2 * math.pi * i) / numFibers;
        const spacingRadius = 0.015;

        final offX = perp1.x * math.cos(radialOffsetAngle) * spacingRadius + perp2.x * math.sin(radialOffsetAngle) * spacingRadius;
        final offY = perp1.y * math.cos(radialOffsetAngle) * spacingRadius + perp2.y * math.sin(radialOffsetAngle) * spacingRadius;
        final offZ = perp1.z * math.cos(radialOffsetAngle) * spacingRadius + perp2.z * math.sin(radialOffsetAngle) * spacingRadius;

        const steps = 6;
        for (int s = 0; s <= steps; s++) {
          final t = s / steps;
          final base = Vector3(
            def.orig.x + axis.x * t,
            def.orig.y + axis.y * t,
            def.orig.z + axis.z * t,
          );

          final bulge = math.sin(t * math.pi) * def.bulge;

          fiber.add(Vector3(
            base.x + offX * (1 - math.sin(t * math.pi) * 0.3) + def.bulgeDir.x * bulge,
            base.y + offY * (1 - math.sin(t * math.pi) * 0.3) + def.bulgeDir.y * bulge,
            base.z + offZ * (1 - math.sin(t * math.pi) * 0.3) + def.bulgeDir.z * bulge,
          ));
        }
        fibers.add(fiber);
      }
      list.add(CachedMuscle(id: def.id, fibers: fibers));
    }

    return list;
  }

  static List<CachedNerve> _generateNerves() {
    return [
      const CachedNerve(
        id: 'c6_nerve',
        paths: [
          [
            Vector3(0, -0.72, 0.01),
            Vector3(0, -0.62, 0),
            Vector3(0, -0.45, -0.02),
            Vector3(0, -0.1, -0.02),
          ],
          [
            Vector3(0, -0.58, 0.0),
            Vector3(-0.08, -0.54, 0.0),
            Vector3(-0.18, -0.5, -0.02),
            Vector3(-0.21, -0.38, 0.01),
            Vector3(-0.25, -0.22, 0.0),
            Vector3(-0.27, -0.05, 0.02),
            Vector3(-0.28, 0.05, 0.02),
          ],
          [
            Vector3(-0.25, -0.22, 0.0),
            Vector3(-0.24, -0.10, 0.01),
            Vector3(-0.25, 0.05, 0.02),
          ],
          [
            Vector3(0, -0.58, 0.0),
            Vector3(0.08, -0.54, 0.0),
            Vector3(0.18, -0.5, -0.02),
            Vector3(0.21, -0.38, 0.01),
            Vector3(0.25, -0.22, 0.0),
            Vector3(0.27, -0.05, 0.02),
            Vector3(0.28, 0.05, 0.02),
          ],
          [
            Vector3(0.25, -0.22, 0.0),
            Vector3(0.24, -0.10, 0.01),
            Vector3(0.25, 0.05, 0.02),
          ]
        ],
      ),
      const CachedNerve(
        id: 'sciatic',
        paths: [
          [
            Vector3(0.0, 0.08, -0.03),
            Vector3(-0.06, 0.14, -0.03),
            Vector3(-0.09, 0.26, -0.03),
            Vector3(-0.12, 0.44, -0.02),
            Vector3(-0.125, 0.60, -0.02),
            Vector3(-0.13, 0.78, -0.03),
          ],
          [
            Vector3(0.0, 0.08, -0.03),
            Vector3(0.06, 0.14, -0.03),
            Vector3(0.09, 0.26, -0.03),
            Vector3(0.12, 0.44, -0.02),
            Vector3(0.125, 0.60, -0.02),
            Vector3(0.13, 0.78, -0.03),
          ]
        ],
      )
    ];
  }

  static List<CachedLigament> _generateLigaments() {
    return [
      const CachedLigament(
        id: 'glenohumeral',
        lines: [
          [Vector3(-0.18, -0.5, -0.02), Vector3(-0.20, -0.45, 0.0)],
          [Vector3(-0.16, -0.49, 0.01), Vector3(-0.21, -0.47, -0.01)],
          [Vector3(0.18, -0.5, -0.02), Vector3(0.20, -0.45, 0.0)],
          [Vector3(0.16, -0.49, 0.01), Vector3(0.21, -0.47, -0.01)]
        ],
      ),
      const CachedLigament(
        id: 'acl_pcl',
        lines: [
          [Vector3(-0.12, 0.435, 0.03), Vector3(-0.115, 0.445, 0.015)],
          [Vector3(-0.12, 0.445, 0.03), Vector3(-0.115, 0.435, 0.015)],
          [Vector3(0.12, 0.435, 0.03), Vector3(0.115, 0.445, 0.015)],
          [Vector3(0.12, 0.445, 0.03), Vector3(0.115, 0.435, 0.015)]
        ],
      ),
      const CachedLigament(
        id: 'mcl_lcl',
        lines: [
          [Vector3(-0.14, 0.42, 0.02), Vector3(-0.14, 0.46, 0.02)],
          [Vector3(-0.10, 0.42, 0.02), Vector3(-0.10, 0.46, 0.02)],
          [Vector3(0.14, 0.42, 0.02), Vector3(0.14, 0.46, 0.02)],
          [Vector3(0.10, 0.42, 0.02), Vector3(0.10, 0.46, 0.02)]
        ],
      )
    ];
  }
}

class _RawMuscleDef {
  final String id;
  final Vector3 orig;
  final Vector3 ins;
  final double bulge;
  final Vector3 bulgeDir;
  const _RawMuscleDef(this.id, this.orig, this.ins, this.bulge, this.bulgeDir);
}

class _LimbBone {
  final String id;
  final String start;
  final String end;
  final double thickness;
  final double offsetScale;
  const _LimbBone(this.id, this.start, this.end, this.thickness, {this.offsetScale = 0.0});
}


/// Highly optimized 3D CustomPainter
class ThreeDAnatomyPainter extends CustomPainter {
  final double rotationY;
  final double rotationX;
  final double zoom;
  final Set<String> visibleLayers;
  final String? selectedId;
  final double pulse;

  ThreeDAnatomyPainter({
    required this.rotationY,
    required this.rotationX,
    required this.zoom,
    required this.visibleLayers,
    this.selectedId,
    required this.pulse,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final centerX = size.width / 2;
    final centerY = size.height / 2 - 20;

    final primitives = <DrawPrimitive>[];

    // Rotated joint coordinates
    final rotatedJoints = <String, Vector3>{};
    ThreeDAnatomyModel.joints.forEach((key, pt) {
      rotatedJoints[key] = pt.rotateY(rotationY).rotateX(rotationX);
    });

    // ==========================================
    // 1. OSTEOLOGY (BONES) - 3D Shaded Mesh Projection
    // ==========================================
    if (visibleLayers.contains('bone')) {
      final isBoneSelected = selectedId == 'skull';
      final boneColor = isBoneSelected ? BioColors.boneSelected : BioColors.bone;
      final lightDir = Vector3(0.35, -0.65, 0.75).normalize();

      // 3D Skull Polyhedral Shaded Mesh
      for (final quad in ThreeDAnatomyModel.cachedSkullMesh) {
        final rQuad = quad.map((pt) => pt.rotateY(rotationY).rotateX(rotationX)).toList();
        final depth = (rQuad[0].z + rQuad[1].z + rQuad[2].z + rQuad[3].z) / 4;

        final v10 = rQuad[1] - rQuad[0];
        final v20 = rQuad[2] - rQuad[0];
        final normal = ThreeDAnatomyModel.cross(v10, v20).normalize();
        final light = (normal.dot(lightDir)).clamp(0.25, 1.0);

        primitives.add(DrawPrimitive(
          depth: depth,
          draw: (c) {
            final path = Path();
            final start = rQuad.first.project(size.width, size.height, zoom, centerX, centerY);
            path.moveTo(start.dx, start.dy);
            for (int i = 1; i < rQuad.length; i++) {
              final pt = rQuad[i].project(size.width, size.height, zoom, centerX, centerY);
              path.lineTo(pt.dx, pt.dy);
            }
            path.close();

            c.drawPath(path, Paint()
              ..color = Color.fromRGBO(
                (229 * light).round(),
                (211 * light).round(),
                (179 * light).round(),
                isBoneSelected ? 0.95 : 0.7,
              )
              ..style = PaintingStyle.fill);

            c.drawPath(path, Paint()
              ..color = boneColor.withOpacity(isBoneSelected ? 1.0 : 0.4)
              ..style = PaintingStyle.stroke
              ..strokeWidth = 0.8);
          },
        ));
      }

      // Skull Facial Features (Eye Sockets, Nasal Cavity, Zygomatic Arch, Mandible Jaw)
      for (final rawPath in ThreeDAnatomyModel.cachedSkull) {
        final rotatedPath = rawPath.map((pt) => pt.rotateY(rotationY).rotateX(rotationX)).toList();
        final depth = rotatedPath.map((pt) => pt.z).reduce((a, b) => a + b) / rotatedPath.length;

        primitives.add(DrawPrimitive(
          depth: depth + 0.05,
          draw: (c) {
            final path = Path();
            final start = rotatedPath.first.project(size.width, size.height, zoom, centerX, centerY);
            path.moveTo(start.dx, start.dy);
            for (int i = 1; i < rotatedPath.length; i++) {
              final pt = rotatedPath[i].project(size.width, size.height, zoom, centerX, centerY);
              path.lineTo(pt.dx, pt.dy);
            }

            c.drawPath(path, Paint()
              ..color = boneColor.withOpacity(isBoneSelected ? 1.0 : 0.85)
              ..style = PaintingStyle.stroke
              ..strokeWidth = isBoneSelected ? 2.5 : 1.5);
          },
        ));
      }

      // 3D Volumetric Limb Bone Meshes (Humerus, Femur, Tibia, Radius, Ulna, Sternum)
      for (final quad in ThreeDAnatomyModel.cachedLimbMeshes) {
        final rQuad = quad.map((pt) => pt.rotateY(rotationY).rotateX(rotationX)).toList();
        final depth = (rQuad[0].z + rQuad[1].z + rQuad[2].z + rQuad[3].z) / 4;

        final v10 = rQuad[1] - rQuad[0];
        final v20 = rQuad[2] - rQuad[0];
        final normal = ThreeDAnatomyModel.cross(v10, v20).normalize();
        final light = (normal.dot(lightDir)).clamp(0.25, 1.0);

        primitives.add(DrawPrimitive(
          depth: depth,
          draw: (c) {
            final path = Path();
            final start = rQuad.first.project(size.width, size.height, zoom, centerX, centerY);
            path.moveTo(start.dx, start.dy);
            for (int i = 1; i < rQuad.length; i++) {
              final pt = rQuad[i].project(size.width, size.height, zoom, centerX, centerY);
              path.lineTo(pt.dx, pt.dy);
            }
            path.close();

            c.drawPath(path, Paint()
              ..color = Color.fromRGBO(
                (229 * light).round(),
                (211 * light).round(),
                (179 * light).round(),
                0.8,
              )
              ..style = PaintingStyle.fill);

            c.drawPath(path, Paint()
              ..color = BioColors.bone.withOpacity(0.4)
              ..style = PaintingStyle.stroke
              ..strokeWidth = 0.7);
          },
        ));
      }

      // Rib Cage
      final isRibsSelected = selectedId == 'ribs';
      final ribColor = isRibsSelected ? BioColors.boneSelected : BioColors.bone;
      for (final rawPath in ThreeDAnatomyModel.cachedRibs) {
        final rotatedPath = rawPath.map((pt) => pt.rotateY(rotationY).rotateX(rotationX)).toList();
        final depth = rotatedPath.map((pt) => pt.z).reduce((a, b) => a + b) / rotatedPath.length;

        primitives.add(DrawPrimitive(
          depth: depth,
          draw: (c) {
            final path = Path();
            final start = rotatedPath.first.project(size.width, size.height, zoom, centerX, centerY);
            path.moveTo(start.dx, start.dy);
            for (int i = 1; i < rotatedPath.length; i++) {
              final pt = rotatedPath[i].project(size.width, size.height, zoom, centerX, centerY);
              path.lineTo(pt.dx, pt.dy);
            }

            c.drawPath(path, Paint()
              ..color = ribColor.withOpacity(isRibsSelected ? 0.55 : 0.22)
              ..style = PaintingStyle.stroke
              ..strokeWidth = isRibsSelected ? 3.5 : 1.8);

            c.drawPath(path, Paint()
              ..color = ribColor.withOpacity(isRibsSelected ? 1.0 : 0.65)
              ..style = PaintingStyle.stroke
              ..strokeWidth = isRibsSelected ? 1.8 : 1.0);
          },
        ));
      }

      // Pelvis
      final isPelvisSelected = selectedId == 'pelvis';
      final pelvisColor = isPelvisSelected ? BioColors.boneSelected : BioColors.bone;
      for (final rawPath in ThreeDAnatomyModel.cachedPelvis) {
        final rotatedPath = rawPath.map((pt) => pt.rotateY(rotationY).rotateX(rotationX)).toList();
        final depth = rotatedPath.map((pt) => pt.z).reduce((a, b) => a + b) / rotatedPath.length;

        primitives.add(DrawPrimitive(
          depth: depth,
          draw: (c) {
            final path = Path();
            final start = rotatedPath.first.project(size.width, size.height, zoom, centerX, centerY);
            path.moveTo(start.dx, start.dy);
            for (int i = 1; i < rotatedPath.length; i++) {
              final pt = rotatedPath[i].project(size.width, size.height, zoom, centerX, centerY);
              path.lineTo(pt.dx, pt.dy);
            }

            c.drawPath(path, Paint()
              ..color = pelvisColor.withOpacity(isPelvisSelected ? 0.55 : 0.22)
              ..style = PaintingStyle.stroke
              ..strokeWidth = isPelvisSelected ? 4.0 : 2.0);

            c.drawPath(path, Paint()
              ..color = pelvisColor.withOpacity(isPelvisSelected ? 1.0 : 0.7)
              ..style = PaintingStyle.stroke
              ..strokeWidth = isPelvisSelected ? 2.0 : 1.0);
          },
        ));
      }

      // Spine
      final isSpineSelected = selectedId == 'spine';
      final spineColor = isSpineSelected ? BioColors.boneSelected : BioColors.bone;
      final spineBones = [
        ['neck', 'thoracic_top'],
        ['thoracic_top', 'thoracic_mid'],
        ['thoracic_mid', 'lumbar_mid'],
        ['lumbar_mid', 'sacrum_top'],
        ['sacrum_top', 'sacrum_bottom']
      ];
      for (final pair in spineBones) {
        final rStart = rotatedJoints[pair[0]]!;
        final rEnd = rotatedJoints[pair[1]]!;
        final depth = (rStart.z + rEnd.z) / 2;

        primitives.add(DrawPrimitive(
          depth: depth,
          draw: (c) {
            final p1 = rStart.project(size.width, size.height, zoom, centerX, centerY);
            final p2 = rEnd.project(size.width, size.height, zoom, centerX, centerY);

            c.drawLine(p1, p2, Paint()
              ..color = spineColor.withOpacity(isSpineSelected ? 0.45 : 0.05)
              ..strokeWidth = isSpineSelected ? 8.0 : 3.0
              ..strokeCap = StrokeCap.round);
            c.drawLine(p1, p2, Paint()
              ..color = spineColor.withOpacity(isSpineSelected ? 1.0 : 0.25)
              ..strokeWidth = isSpineSelected ? 3.0 : 1.2
              ..strokeCap = StrokeCap.round);

            final steps = 4;
            for (int s = 1; s < steps; s++) {
              final t = s / steps;
              final rMid = Vector3(
                rStart.x + (rEnd.x - rStart.x) * t,
                rStart.y + (rEnd.y - rStart.y) * t,
                rStart.z + (rEnd.z - rStart.z) * t,
              );
              final midP = rMid.project(size.width, size.height, zoom, centerX, centerY);
              final axis = Offset(p2.dy - p1.dy, p1.dx - p2.dx);
              final len = math.sqrt(axis.dx * axis.dx + axis.dy * axis.dy);
              if (len > 0) {
                final norm = Offset(axis.dx / len, axis.dy / len);
                final barHalf = norm * (isSpineSelected ? 12.0 : 5.0);
                c.drawLine(midP - barHalf, midP + barHalf, Paint()
                  ..color = spineColor.withOpacity(isSpineSelected ? 1.0 : 0.25)
                  ..strokeWidth = isSpineSelected ? 2.0 : 0.8);
              }
            }
          },
        ));
      }

      // Limbs
      final limbConnections = [
        _LimbBone('humerus', 'shoulder_l', 'elbow_l', 2.2),
        _LimbBone('humerus', 'shoulder_r', 'elbow_r', 2.2),
        _LimbBone('radius_ulna', 'elbow_l', 'wrist_l', 1.5, offsetScale: 0.015),
        _LimbBone('radius_ulna', 'elbow_r', 'wrist_r', 1.5, offsetScale: 0.015),
        _LimbBone('femur', 'hip_l', 'knee_l', 3.0),
        _LimbBone('femur', 'hip_r', 'knee_r', 3.0),
        _LimbBone('tibia_fibula', 'knee_l', 'ankle_l', 1.8, offsetScale: 0.012),
        _LimbBone('tibia_fibula', 'knee_r', 'ankle_r', 1.8, offsetScale: 0.012),
        _LimbBone('ribs', 'sternum_top', 'sternum_bottom', 2.5),
        _LimbBone('spine', 'sternum_top', 'shoulder_l', 1.2),
        _LimbBone('spine', 'sternum_top', 'shoulder_r', 1.2),
      ];

      for (final bone in limbConnections) {
        final isSel = selectedId == bone.id;
        final color = isSel ? BioColors.boneSelected : BioColors.bone;
        final rStart = rotatedJoints[bone.start]!;
        final rEnd = rotatedJoints[bone.end]!;
        final depth = (rStart.z + rEnd.z) / 2;

        primitives.add(DrawPrimitive(
          depth: depth,
          draw: (c) {
            final p1 = rStart.project(size.width, size.height, zoom, centerX, centerY);
            final p2 = rEnd.project(size.width, size.height, zoom, centerX, centerY);

            if (bone.offsetScale == 0.0) {
              c.drawLine(p1, p2, Paint()
                ..color = color.withOpacity(isSel ? 0.45 : 0.03)
                ..strokeWidth = bone.thickness * (isSel ? 3.5 : 1.8)
                ..strokeCap = StrokeCap.round);
              c.drawLine(p1, p2, Paint()
                ..color = color.withOpacity(isSel ? 1.0 : 0.2)
                ..strokeWidth = bone.thickness * (isSel ? 1.5 : 0.8)
                ..strokeCap = StrokeCap.round);
            } else {
              final axis = Offset(p2.dy - p1.dy, p1.dx - p2.dx);
              final len = math.sqrt(axis.dx * axis.dx + axis.dy * axis.dy);
              if (len > 0) {
                final norm = Offset(axis.dx / len, axis.dy / len);
                final offsetVec = norm * (bone.offsetScale * math.min(size.width, size.height) * zoom);

                c.drawLine(p1 - offsetVec, p2 - offsetVec, Paint()
                  ..color = color.withOpacity(isSel ? 1.0 : 0.2)
                  ..strokeWidth = bone.thickness * (isSel ? 1.4 : 0.7));
                c.drawLine(p1 + offsetVec, p2 + offsetVec, Paint()
                  ..color = color.withOpacity(isSel ? 1.0 : 0.2)
                  ..strokeWidth = bone.thickness * (isSel ? 1.4 : 0.7));
              }
            }
          },
        ));
      }
    }

    // ==========================================
    // 2. MYOLOGY (MUSCLES) - Pre-cached projection
    // ==========================================
    if (visibleLayers.contains('muscle')) {
      for (final muscle in ThreeDAnatomyModel.cachedMuscles) {
        final isSel = selectedId == muscle.id;
        final color = isSel ? BioColors.muscleSelected : BioColors.muscle;

        for (final rawFiber in muscle.fibers) {
          // Perform lightweight Y/X matrix rotation of cached vertices
          final rotatedFiber = rawFiber.map((pt) => pt.rotateY(rotationY).rotateX(rotationX)).toList();
          final depth = rotatedFiber.map((pt) => pt.z).reduce((a, b) => a + b) / rotatedFiber.length;

          primitives.add(DrawPrimitive(
            depth: depth,
            draw: (c) {
              final path = Path();
              final start = rotatedFiber.first.project(size.width, size.height, zoom, centerX, centerY);
              path.moveTo(start.dx, start.dy);

              for (int i = 1; i < rotatedFiber.length; i++) {
                final pt = rotatedFiber[i].project(size.width, size.height, zoom, centerX, centerY);
                path.lineTo(pt.dx, pt.dy);
              }

              final alpha = isSel ? 0.85 + 0.15 * math.sin(pulse * 2 * math.pi) : 0.08;
              c.drawPath(path, Paint()
                ..color = color.withOpacity(alpha)
                ..style = PaintingStyle.stroke
                ..strokeWidth = isSel ? 1.8 : 0.6);
            },
          ));
        }
      }
    }

    // ==========================================
    // 3. NEUROLOGY (NERVES) - Pre-cached projection
    // ==========================================
    if (visibleLayers.contains('nerve')) {
      for (final nerve in ThreeDAnatomyModel.cachedNerves) {
        final isSel = selectedId == nerve.id;
        final color = isSel ? BioColors.nerveSelected : BioColors.nerve;

        for (final rawPath in nerve.paths) {
          final rotatedPath = rawPath.map((pt) => pt.rotateY(rotationY).rotateX(rotationX)).toList();
          final depth = rotatedPath.map((pt) => pt.z).reduce((a, b) => a + b) / rotatedPath.length;

          primitives.add(DrawPrimitive(
            depth: depth,
            draw: (c) {
              final path = Path();
              final start = rotatedPath.first.project(size.width, size.height, zoom, centerX, centerY);
              path.moveTo(start.dx, start.dy);
              for (int i = 1; i < rotatedPath.length; i++) {
                final pt = rotatedPath[i].project(size.width, size.height, zoom, centerX, centerY);
                path.lineTo(pt.dx, pt.dy);
              }

              c.drawPath(path, Paint()
                ..color = color.withOpacity(isSel ? 0.35 : 0.1)
                ..style = PaintingStyle.stroke
                ..strokeWidth = isSel ? 3.5 : 2.0);

              c.drawPath(path, Paint()
                ..color = color.withOpacity(isSel ? 1.0 : 0.6)
                ..style = PaintingStyle.stroke
                ..strokeWidth = isSel ? 1.2 : 0.7);
            },
          ));
        }
      }
    }

    // ==========================================
    // 4. ARTHROLOGY (LIGAMENTS) - Pre-cached projection
    // ==========================================
    if (visibleLayers.contains('ligament')) {
      for (final lig in ThreeDAnatomyModel.cachedLigaments) {
        final isSel = selectedId == lig.id;
        final color = isSel ? BioColors.ligamentSelected : BioColors.ligament;

        for (final pair in lig.lines) {
          final rStart = pair[0].rotateY(rotationY).rotateX(rotationX);
          final rEnd = pair[1].rotateY(rotationY).rotateX(rotationX);
          final depth = (rStart.z + rEnd.z) / 2;

          primitives.add(DrawPrimitive(
            depth: depth,
            draw: (c) {
              final p1 = rStart.project(size.width, size.height, zoom, centerX, centerY);
              final p2 = rEnd.project(size.width, size.height, zoom, centerX, centerY);

              c.drawLine(p1, p2, Paint()
                ..color = color.withOpacity(isSel ? 0.45 : 0.22)
                ..strokeWidth = isSel ? 6.0 : 4.0
                ..strokeCap = StrokeCap.square);
              c.drawLine(p1, p2, Paint()
                ..color = color.withOpacity(isSel ? 1.0 : 0.75)
                ..strokeWidth = isSel ? 2.5 : 1.5
                ..strokeCap = StrokeCap.square);
            },
          ));
        }
      }
    }

    // ==========================================
    // DRAW INTERACTIVE HOTSPOT ANCHOR DOTS
    // ==========================================
    ThreeDAnatomyModel.hotSpotCenters.forEach((id, rawPt) {
      final layerType = _getHotspotLayer(id);
      if (!visibleLayers.contains(layerType)) return;

      final isSel = selectedId == id;
      final rotated = rawPt.rotateY(rotationY).rotateX(rotationX);

      final isFront = rotated.z > -0.05;
      if (!isFront && !isSel) return;

      final color = _getLayerColor(layerType);

      primitives.add(DrawPrimitive(
        depth: rotated.z + 0.05,
        draw: (c) {
          final pos = rotated.project(size.width, size.height, zoom, centerX, centerY);

          final radiusGlow = isSel
              ? 18.0 + 4.0 * math.sin(pulse * 2 * math.pi)
              : 8.0 + 2.0 * math.sin(pulse * 2 * math.pi);
          c.drawCircle(
            pos,
            radiusGlow,
            Paint()
              ..color = color.withOpacity(isSel ? 0.35 : 0.14)
              ..style = PaintingStyle.fill
              ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
          );

          c.drawCircle(
            pos,
            isSel ? 7.0 : 4.5,
            Paint()
              ..color = isSel ? Colors.white : color
              ..style = PaintingStyle.fill,
          );

          if (isSel) {
            c.drawCircle(
              pos,
              12.0,
              Paint()
                ..color = color
                ..style = PaintingStyle.stroke
                ..strokeWidth = 1.5,
            );

            final isLeftPart = rawPt.x < 0;
            final lineEnd = Offset(
              isLeftPart ? pos.dx - 55 : pos.dx + 55,
              pos.dy - 25,
            );
            final lineExt = Offset(
              isLeftPart ? lineEnd.dx - 20 : lineEnd.dx + 20,
              lineEnd.dy,
            );

            final linePaint = Paint()
              ..color = color.withOpacity(0.85)
              ..style = PaintingStyle.stroke
              ..strokeWidth = 1.3;

            c.drawLine(pos, lineEnd, linePaint);
            c.drawLine(lineEnd, lineExt, linePaint);
            c.drawCircle(lineExt, 2.5, Paint()..color = color);
          }
        },
      ));
    });

    // Sort from back to front (ascending Z)
    primitives.sort((a, b) => a.depth.compareTo(b.depth));

    for (final primitive in primitives) {
      primitive.draw(canvas);
    }
  }

  @override
  bool shouldRepaint(covariant ThreeDAnatomyPainter oldDelegate) {
    return oldDelegate.rotationY != rotationY ||
        oldDelegate.rotationX != rotationX ||
        oldDelegate.zoom != zoom ||
        oldDelegate.visibleLayers != visibleLayers ||
        oldDelegate.selectedId != selectedId ||
        oldDelegate.pulse != pulse;
  }

  String _getHotspotLayer(String id) {
    if (id == 'skull' || id == 'spine' || id == 'ribs' || id == 'pelvis' || id == 'humerus' || id == 'radius_ulna' || id == 'femur' || id == 'tibia_fibula') {
      return 'bone';
    }
    if (id == 'acl_pcl' || id == 'mcl_lcl' || id == 'glenohumeral') {
      return 'ligament';
    }
    if (id == 'c6_nerve' || id == 'sciatic') {
      return 'nerve';
    }
    return 'muscle';
  }

  Color _getLayerColor(String layer) {
    switch (layer) {
      case 'bone': return BioColors.bone;
      case 'muscle': return BioColors.muscle;
      case 'nerve': return BioColors.nerve;
      case 'ligament': return BioColors.ligament;
      default: return Colors.white;
    }
  }
}
