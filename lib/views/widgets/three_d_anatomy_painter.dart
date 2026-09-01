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
  static const Color bone = Color(0xFFF3E7D3);      // Soft Warm Ivory Bone
  static const Color boneSelected = Color(0xFFFFFFFF);
  static const Color muscle = Color(0xFFDC2626);    // Rich Anatomical Crimson Red Muscle
  static const Color muscleSelected = Color(0xFFFF2A55); // Glowing Muscle Ruby Accent
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
  static final List<List<Vector3>> cachedBodySilhouette = _generateBodySilhouette();
  static final List<List<Vector3>> cachedSkull = _generateSkull();
  static final List<List<Vector3>> cachedSkullMesh = _generateSkullMesh();
  static final List<List<Vector3>> cachedMandibleMesh = _generateMandibleMesh();
  static final List<List<Vector3>> cachedZygomaticPatches = _generateZygomaticPatches();
  static final List<List<Vector3>> cachedSutureLines = _generateSutureLines();
  static final List<List<Vector3>> cachedToothRow = _generateToothRow();
  static final List<List<Vector3>> cachedMaxillaRidge = _generateMaxillaRidge();
  static final List<List<Vector3>> cachedRibs = _generateRibs();
  static final List<List<Vector3>> cachedPelvis = _generatePelvis();
  static final List<List<Vector3>> cachedLimbMeshes = _generateLimbMeshes();
  static final List<CachedMuscle> cachedMuscles = _generateMuscles();
  static final List<CachedNerve> cachedNerves = _generateNerves();
  static final List<CachedLigament> cachedLigaments = _generateLigaments();

  /// Generates a volumetric 3D human body silhouette outline mesh
  static List<List<Vector3>> _generateBodySilhouette() {
    final list = <List<Vector3>>[];

    // Torso & pelvis cross-section definitions [Y, Rx (width), Rz (depth)]
    final torsoRings = [
      const Vector3(0.0, -0.54, 0.16), // Neck/Shoulders top (rx=0.16, rz=0.07)
      const Vector3(0.0, -0.42, 0.20), // Upper Chest
      const Vector3(0.0, -0.28, 0.17), // Lower Ribs
      const Vector3(0.0, -0.14, 0.14), // Waist
      const Vector3(0.0, 0.04, 0.16),  // Hips top
      const Vector3(0.0, 0.14, 0.15),  // Pelvis bottom
    ];
    final torsoDepths = [0.07, 0.09, 0.08, 0.07, 0.08, 0.075];

    const ringSteps = 14;
    for (int i = 0; i < torsoRings.length - 1; i++) {
      final y1 = torsoRings[i].y;
      final rx1 = torsoRings[i].z;
      final rz1 = torsoDepths[i];

      final y2 = torsoRings[i + 1].y;
      final rx2 = torsoRings[i + 1].z;
      final rz2 = torsoDepths[i + 1];

      for (int j = 0; j < ringSteps; j++) {
        final a1 = 2 * math.pi * j / ringSteps;
        final a2 = 2 * math.pi * (j + 1) / ringSteps;

        final p1 = Vector3(rx1 * math.cos(a1), y1, rz1 * math.sin(a1));
        final p2 = Vector3(rx1 * math.cos(a2), y1, rz1 * math.sin(a2));
        final p3 = Vector3(rx2 * math.cos(a2), y2, rz2 * math.sin(a2));
        final p4 = Vector3(rx2 * math.cos(a1), y2, rz2 * math.sin(a1));

        list.add([p1, p2, p3, p4]);
      }
    }
    return list;
  }

  /// Applies anatomical displacement to a cranium vertex for realistic skull shape.
  /// lat: latitude angle, lon: longitude angle
  static Vector3 _displaceSkullVertex(double cx, double cy, double cz,
      double baseRx, double baseRy, double baseRz, double lat, double lon) {
    // Normalized direction components
    final cosLat = math.cos(lat);
    final sinLat = math.sin(lat);
    final cosLon = math.cos(lon);
    final sinLon = math.sin(lon);

    double rx = baseRx;
    double ry = baseRy;
    double rz = baseRz;

    // --- Occipital bulge: enlarge back of skull (lon near π, cosLon ~ -1) ---
    final backFactor = math.max(0.0, -cosLon); // 1.0 at back, 0.0 at front
    rz += 0.018 * backFactor * backFactor; // Subtle posterior elongation

    // --- Temporal flattening: narrow sides (sinLon near ±1) ---
    final sideFactor = sinLon.abs();
    rx -= 0.008 * sideFactor * sideFactor * math.max(0.0, cosLat); // Flatten mid-laterally

    // --- Brow ridge / Supraorbital prominence (front-upper region) ---
    final frontFactor = math.max(0.0, cosLon); // 1.0 at front
    final upperFactor = math.max(0.0, -sinLat); // 1.0 at top
    final browLat = (lat + 0.15).abs(); // near lat ~ -0.15 (slightly above equator)
    final browStrength = math.exp(-browLat * browLat / 0.08) * frontFactor;
    rz += 0.012 * browStrength; // Push brow forward
    ry -= 0.005 * browStrength; // Slight vertical flattening at brow

    // --- Cranial vault: slightly taller at crown ---
    final crownFactor = math.max(0.0, upperFactor - 0.3);
    ry += 0.010 * crownFactor;

    // --- Frontal bone slight flattening (forehead) ---
    final foreheadRegion = math.max(0.0, frontFactor - 0.5) * math.max(0.0, upperFactor - 0.2);
    rz -= 0.006 * foreheadRegion;

    // --- Lower face narrowing (below equator, front) ---
    final lowerFace = math.max(0.0, sinLat) * frontFactor; // bottom + front
    rx -= 0.015 * lowerFace * lowerFace;

    return Vector3(
      cx + rx * cosLat * sinLon,
      cy + ry * sinLat,
      cz + rz * cosLat * cosLon,
    );
  }

  static List<List<Vector3>> _generateSkullMesh() {
    final mesh = <List<Vector3>>[];
    const cx = 0.0;
    const cy = -0.76;
    const cz = 0.0;
    const rx = 0.088;  // Slightly wider base
    const ry = 0.098;  // Slightly taller
    const rz = 0.092;  // Slightly deeper

    // High resolution mesh for smooth, realistic surface
    const latSteps = 14;
    const lonSteps = 22;

    for (int i = 0; i < latSteps; i++) {
      final lat1 = -math.pi / 2 + (math.pi * i / latSteps);
      final lat2 = -math.pi / 2 + (math.pi * (i + 1) / latSteps);

      for (int j = 0; j < lonSteps; j++) {
        final lon1 = 2 * math.pi * j / lonSteps;
        final lon2 = 2 * math.pi * (j + 1) / lonSteps;

        final p1 = _displaceSkullVertex(cx, cy, cz, rx, ry, rz, lat1, lon1);
        final p2 = _displaceSkullVertex(cx, cy, cz, rx, ry, rz, lat1, lon2);
        final p3 = _displaceSkullVertex(cx, cy, cz, rx, ry, rz, lat2, lon2);
        final p4 = _displaceSkullVertex(cx, cy, cz, rx, ry, rz, lat2, lon1);

        mesh.add([p1, p2, p3, p4]);
      }
    }
    return mesh;
  }

  /// 3D mandible (jawbone) as a volumetric U-shaped mesh
  static List<List<Vector3>> _generateMandibleMesh() {
    final mesh = <List<Vector3>>[];
    const cx = 0.0;
    const cy = -0.76;
    const cz = 0.0;

    // Generate U-shaped mandible cross-sections along its curve
    const segments = 16; // Steps along the U-curve
    const radialSteps = 6; // Cross-section resolution
    const mandibleRadius = 0.012; // Thickness of jawbone

    // Define mandible path: U-shape from left ramus down around chin to right ramus
    final mandiblePath = <Vector3>[];
    for (int s = 0; s <= segments; s++) {
      final t = s / segments; // 0 = left ramus top, 0.5 = chin, 1.0 = right ramus top
      final angle = math.pi * t; // 0 to π for U-shape

      // Horizontal sweep
      final px = cx + 0.058 * math.cos(angle); // Left to right
      // Vertical: ramus goes up on sides, chin at bottom
      final py = cy + 0.030 + 0.065 * math.sin(angle);
      // Depth: chin is forward, rami are back
      final pz = cz + 0.020 + 0.062 * math.sin(angle);

      mandiblePath.add(Vector3(px, py, pz));
    }

    // Generate cross-section quads along path
    for (int s = 0; s < segments; s++) {
      final c1 = mandiblePath[s];
      final c2 = mandiblePath[s + 1];

      // Direction along mandible
      final dir = (c2 - c1).normalize();
      Vector3 perp1 = (dir.x.abs() < 0.9)
          ? cross(dir, const Vector3(1, 0, 0)).normalize()
          : cross(dir, const Vector3(0, 1, 0)).normalize();
      final perp2 = cross(dir, perp1).normalize();

      // Varying thickness: thicker at chin (s~segments/2), thinner at rami
      final chinFactor = math.sin(s / segments * math.pi);
      final radius = mandibleRadius * (0.7 + 0.5 * chinFactor);

      for (int r = 0; r < radialSteps; r++) {
        final a1 = 2 * math.pi * r / radialSteps;
        final a2 = 2 * math.pi * (r + 1) / radialSteps;

        final off1a = perp1 * (math.cos(a1) * radius) + perp2 * (math.sin(a1) * radius);
        final off1b = perp1 * (math.cos(a2) * radius) + perp2 * (math.sin(a2) * radius);

        // Recompute for next segment center
        Vector3 dir2;
        Vector3 perp1b, perp2b;
        if (s + 1 < segments) {
          final c3 = mandiblePath[s + 2];
          dir2 = (c3 - c2).normalize();
        } else {
          dir2 = dir;
        }
        perp1b = (dir2.x.abs() < 0.9)
            ? cross(dir2, const Vector3(1, 0, 0)).normalize()
            : cross(dir2, const Vector3(0, 1, 0)).normalize();
        perp2b = cross(dir2, perp1b).normalize();

        final chinFactor2 = math.sin((s + 1) / segments * math.pi);
        final radius2 = mandibleRadius * (0.7 + 0.5 * chinFactor2);

        final off2a = perp1b * (math.cos(a1) * radius2) + perp2b * (math.sin(a1) * radius2);
        final off2b = perp1b * (math.cos(a2) * radius2) + perp2b * (math.sin(a2) * radius2);

        mesh.add([
          c1 + off1a,
          c1 + off1b,
          c2 + off2b,
          c2 + off2a,
        ]);
      }
    }
    return mesh;
  }

  /// 3D zygomatic (cheekbone) patches as small convex surface quads
  static List<List<Vector3>> _generateZygomaticPatches() {
    final mesh = <List<Vector3>>[];
    const cx = 0.0;
    const cy = -0.76;
    const cz = 0.0;

    // Generate cheekbone as a curved surface patch on each side
    for (final side in [-1.0, 1.0]) {
      const patchStepsU = 4;
      const patchStepsV = 3;

      for (int u = 0; u < patchStepsU; u++) {
        for (int v = 0; v < patchStepsV; v++) {
          final t1u = u / patchStepsU;
          final t2u = (u + 1) / patchStepsU;
          final t1v = v / patchStepsV;
          final t2v = (v + 1) / patchStepsV;

          // Cheekbone sweeps from temporal region to near orbit
          Vector3 zygPt(double tu, double tv) {
            final x = cx + side * (0.075 - 0.030 * tu); // Narrowing toward front
            final y = cy + 0.005 + 0.025 * tv; // Slight vertical extent
            final z = cz + 0.010 + 0.065 * tu; // Sweeping forward
            // Add convex bulge
            final bulge = 0.008 * math.sin(tu * math.pi) * math.sin(tv * math.pi);
            return Vector3(x, y, z + bulge);
          }

          mesh.add([
            zygPt(t1u, t1v),
            zygPt(t2u, t1v),
            zygPt(t2u, t2v),
            zygPt(t1u, t2v),
          ]);
        }
      }
    }
    return mesh;
  }

  /// Cranial suture lines (coronal, sagittal, lambdoid)
  static List<List<Vector3>> _generateSutureLines() {
    final lines = <List<Vector3>>[];
    const cx = 0.0;
    const cy = -0.76;
    const cz = 0.0;
    const r = 0.097; // Just above cranium surface

    // Coronal suture: lateral arc across top, from ear to ear, slightly behind crown
    final coronal = <Vector3>[];
    for (double t = -0.85; t <= 0.85; t += 0.08) {
      final angle = t; // lateral sweep
      coronal.add(Vector3(
        cx + r * math.sin(angle),
        cy - r * 0.85 + 0.008 * (angle * angle), // Slight droop at sides
        cz + r * 0.25, // Positioned anterior to midline
      ));
    }
    lines.add(coronal);

    // Sagittal suture: midline from front to back along top of skull
    final sagittal = <Vector3>[];
    for (double t = 0.2; t <= 3.0; t += 0.12) {
      final lon = t; // Front to back
      sagittal.add(Vector3(
        cx,
        cy - r * 0.92 + 0.005 * math.sin(lon), // Slight undulation
        cz + r * math.cos(lon) * 0.5,
      ));
    }
    lines.add(sagittal);

    // Lambdoid suture: V-shape at back of skull
    final lambdoidL = <Vector3>[];
    final lambdoidR = <Vector3>[];
    for (double t = 0; t <= 1.0; t += 0.1) {
      lambdoidL.add(Vector3(
        cx - r * 0.6 * t,
        cy - r * 0.7 + r * 0.35 * t,
        cz - r * 0.65 + 0.01 * t,
      ));
      lambdoidR.add(Vector3(
        cx + r * 0.6 * t,
        cy - r * 0.7 + r * 0.35 * t,
        cz - r * 0.65 + 0.01 * t,
      ));
    }
    lines.add(lambdoidL);
    lines.add(lambdoidR);

    return lines;
  }

  /// Tooth row along mandible (small rectangular blocks)
  static List<List<Vector3>> _generateToothRow() {
    final teeth = <List<Vector3>>[];
    const cx = 0.0;
    const cy = -0.76;
    const cz = 0.0;
    const numTeeth = 12;

    for (int i = 0; i < numTeeth; i++) {
      final t = (i + 0.5) / numTeeth; // 0 to 1
      final angle = math.pi * 0.12 + (math.pi * 0.76) * t; // Subset of U-curve

      final px = cx + 0.048 * math.cos(angle);
      final py = cy + 0.055 + 0.042 * math.sin(angle); // Sits on mandible inner edge
      final pz = cz + 0.040 + 0.048 * math.sin(angle);

      // Small tooth block
      const tw = 0.004; // tooth width
      const th = 0.008; // tooth height
      // Direction tangent along jaw arc
      final tangent = Vector3(-math.sin(angle), 0, math.cos(angle)).normalize();

      // Four corners of tooth front face
      teeth.add([
        Vector3(px - tangent.x * tw, py - th, pz - tangent.z * tw),
        Vector3(px + tangent.x * tw, py - th, pz + tangent.z * tw),
        Vector3(px + tangent.x * tw, py, pz + tangent.z * tw),
        Vector3(px - tangent.x * tw, py, pz - tangent.z * tw),
      ]);
    }
    return teeth;
  }

  /// Maxilla ridge (upper jaw bone ridge below nasal aperture)
  static List<List<Vector3>> _generateMaxillaRidge() {
    final mesh = <List<Vector3>>[];
    const cx = 0.0;
    const cy = -0.76;
    const cz = 0.0;

    // Curved ridge below nose, connecting to zygomatic arches
    const steps = 8;
    for (int i = 0; i < steps; i++) {
      final t1 = i / steps;
      final t2 = (i + 1) / steps;
      final angle1 = -math.pi * 0.4 + math.pi * 0.8 * t1;
      final angle2 = -math.pi * 0.4 + math.pi * 0.8 * t2;

      final x1 = cx + 0.042 * math.sin(angle1);
      final x2 = cx + 0.042 * math.sin(angle2);
      final z1 = cz + 0.078 + 0.005 * math.cos(angle1);
      final z2 = cz + 0.078 + 0.005 * math.cos(angle2);
      final y1 = cy + 0.042;
      final y2 = cy + 0.050;

      mesh.add([
        Vector3(x1, y1, z1),
        Vector3(x2, y1, z2),
        Vector3(x2, y2, z2),
        Vector3(x1, y2, z1),
      ]);
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
    list.addAll(_generateCylinderMesh(joints['shoulder_l']!, joints['elbow_l']!, 0.012));
    list.addAll(_generateCylinderMesh(joints['shoulder_r']!, joints['elbow_r']!, 0.012));
    // Femur L/R
    list.addAll(_generateCylinderMesh(joints['hip_l']!, joints['knee_l']!, 0.016));
    list.addAll(_generateCylinderMesh(joints['hip_r']!, joints['knee_r']!, 0.016));
    // Tibia L/R
    list.addAll(_generateCylinderMesh(joints['knee_l']!, joints['ankle_l']!, 0.011));
    list.addAll(_generateCylinderMesh(joints['knee_r']!, joints['ankle_r']!, 0.011));
    // Radius / Ulna L/R
    list.addAll(_generateCylinderMesh(joints['elbow_l']!, joints['wrist_l']!, 0.009));
    list.addAll(_generateCylinderMesh(joints['elbow_r']!, joints['wrist_r']!, 0.009));
    // Sternum & Clavicles
    list.addAll(_generateCylinderMesh(joints['sternum_top']!, joints['sternum_bottom']!, 0.014));
    list.addAll(_generateCylinderMesh(joints['shoulder_l']!, joints['sternum_top']!, 0.007));
    list.addAll(_generateCylinderMesh(joints['shoulder_r']!, joints['sternum_top']!, 0.007));

    return list;
  }

  static List<List<Vector3>> _generateSkull() {
    final paths = <List<Vector3>>[];
    const double cx = 0.0;
    const double cy = -0.76;
    const double cz = 0.0;

    // --- Left & Right Orbital (Eye Socket) Rings --- (thicker, more defined)
    final eyeL = <Vector3>[];
    final eyeR = <Vector3>[];
    for (double a = 0; a <= 2 * math.pi + 0.01; a += math.pi / 10) {
      // Slightly larger, more oval sockets
      final horizScale = 0.022;
      final vertScale = 0.018;
      eyeL.add(Vector3(
        cx - 0.032 + horizScale * math.cos(a),
        cy - 0.008 + vertScale * math.sin(a),
        cz + 0.082,
      ));
      eyeR.add(Vector3(
        cx + 0.032 + horizScale * math.cos(a),
        cy - 0.008 + vertScale * math.sin(a),
        cz + 0.082,
      ));
    }
    paths.add(eyeL);
    paths.add(eyeR);

    // --- Inner orbital detail (pupil area shadow ring) ---
    final innerEyeL = <Vector3>[];
    final innerEyeR = <Vector3>[];
    for (double a = 0; a <= 2 * math.pi + 0.01; a += math.pi / 8) {
      innerEyeL.add(Vector3(
        cx - 0.032 + 0.012 * math.cos(a),
        cy - 0.008 + 0.010 * math.sin(a),
        cz + 0.084,
      ));
      innerEyeR.add(Vector3(
        cx + 0.032 + 0.012 * math.cos(a),
        cy - 0.008 + 0.010 * math.sin(a),
        cz + 0.084,
      ));
    }
    paths.add(innerEyeL);
    paths.add(innerEyeR);

    // --- Supraorbital ridge (brow bone line) ---
    paths.add([
      Vector3(cx - 0.055, cy - 0.018, cz + 0.072),
      Vector3(cx - 0.042, cy - 0.026, cz + 0.080),
      Vector3(cx - 0.020, cy - 0.028, cz + 0.086),
      Vector3(cx, cy - 0.028, cz + 0.088),
      Vector3(cx + 0.020, cy - 0.028, cz + 0.086),
      Vector3(cx + 0.042, cy - 0.026, cz + 0.080),
      Vector3(cx + 0.055, cy - 0.018, cz + 0.072),
    ]);

    // --- Nasal Aperture (Piriform cavity) --- deeper, more defined
    paths.add([
      Vector3(cx, cy + 0.008, cz + 0.092),
      Vector3(cx - 0.015, cy + 0.022, cz + 0.090),
      Vector3(cx - 0.014, cy + 0.035, cz + 0.086),
      Vector3(cx - 0.008, cy + 0.043, cz + 0.084),
      Vector3(cx, cy + 0.045, cz + 0.083),
      Vector3(cx + 0.008, cy + 0.043, cz + 0.084),
      Vector3(cx + 0.014, cy + 0.035, cz + 0.086),
      Vector3(cx + 0.015, cy + 0.022, cz + 0.090),
      Vector3(cx, cy + 0.008, cz + 0.092),
    ]);

    // --- Nasal bone (bridge of nose) ---
    paths.add([
      Vector3(cx - 0.006, cy - 0.015, cz + 0.088),
      Vector3(cx - 0.008, cy + 0.005, cz + 0.092),
      Vector3(cx, cy + 0.010, cz + 0.093),
      Vector3(cx + 0.008, cy + 0.005, cz + 0.092),
      Vector3(cx + 0.006, cy - 0.015, cz + 0.088),
    ]);

    // --- Zygomatic Arches (Cheekbones) --- more defined sweep
    paths.add([
      Vector3(cx - 0.088, cy + 0.002, cz - 0.005),
      Vector3(cx - 0.082, cy + 0.005, cz + 0.020),
      Vector3(cx - 0.075, cy + 0.008, cz + 0.042),
      Vector3(cx - 0.062, cy + 0.014, cz + 0.062),
      Vector3(cx - 0.048, cy + 0.018, cz + 0.075),
      Vector3(cx - 0.038, cy + 0.020, cz + 0.082),
    ]);
    paths.add([
      Vector3(cx + 0.088, cy + 0.002, cz - 0.005),
      Vector3(cx + 0.082, cy + 0.005, cz + 0.020),
      Vector3(cx + 0.075, cy + 0.008, cz + 0.042),
      Vector3(cx + 0.062, cy + 0.014, cz + 0.062),
      Vector3(cx + 0.048, cy + 0.018, cz + 0.075),
      Vector3(cx + 0.038, cy + 0.020, cz + 0.082),
    ]);

    // --- Mandible (Jawbone) outer contour ---
    paths.add([
      Vector3(cx - 0.062, cy + 0.022, cz + 0.015),
      Vector3(cx - 0.060, cy + 0.040, cz + 0.035),
      Vector3(cx - 0.055, cy + 0.058, cz + 0.052),
      Vector3(cx - 0.042, cy + 0.076, cz + 0.068),
      Vector3(cx - 0.025, cy + 0.088, cz + 0.078),
      Vector3(cx - 0.012, cy + 0.094, cz + 0.083),
      Vector3(cx, cy + 0.098, cz + 0.085),
      Vector3(cx + 0.012, cy + 0.094, cz + 0.083),
      Vector3(cx + 0.025, cy + 0.088, cz + 0.078),
      Vector3(cx + 0.042, cy + 0.076, cz + 0.068),
      Vector3(cx + 0.055, cy + 0.058, cz + 0.052),
      Vector3(cx + 0.060, cy + 0.040, cz + 0.035),
      Vector3(cx + 0.062, cy + 0.022, cz + 0.015),
    ]);

    // --- Mandible chin detail (mentum protrusion) ---
    paths.add([
      Vector3(cx - 0.018, cy + 0.090, cz + 0.082),
      Vector3(cx - 0.010, cy + 0.098, cz + 0.088),
      Vector3(cx, cy + 0.100, cz + 0.090),
      Vector3(cx + 0.010, cy + 0.098, cz + 0.088),
      Vector3(cx + 0.018, cy + 0.090, cz + 0.082),
    ]);

    // --- Temporal lines (side arches over cranium) ---
    final tempL = <Vector3>[];
    final tempR = <Vector3>[];
    for (double t = 0; t <= 1.0; t += 0.08) {
      final angle = math.pi * t;
      tempL.add(Vector3(
        cx - 0.065 * math.sin(angle),
        cy - 0.098 + 0.022 * t,
        cz + 0.065 * math.cos(angle),
      ));
      tempR.add(Vector3(
        cx + 0.065 * math.sin(angle),
        cy - 0.098 + 0.022 * t,
        cz + 0.065 * math.cos(angle),
      ));
    }
    paths.add(tempL);
    paths.add(tempR);

    // --- Mastoid process (behind ear bumps) ---
    paths.add([
      Vector3(cx - 0.078, cy + 0.015, cz - 0.030),
      Vector3(cx - 0.082, cy + 0.030, cz - 0.025),
      Vector3(cx - 0.078, cy + 0.040, cz - 0.020),
    ]);
    paths.add([
      Vector3(cx + 0.078, cy + 0.015, cz - 0.030),
      Vector3(cx + 0.082, cy + 0.030, cz - 0.025),
      Vector3(cx + 0.078, cy + 0.040, cz - 0.020),
    ]);

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

      // Cache a rich density of 12 fibers per muscle belly for dense 3D muscular volume
      const numFibers = 12;
      for (int i = 0; i < numFibers; i++) {
        final fiber = <Vector3>[];
        final radialOffsetAngle = (2 * math.pi * i) / numFibers;
        const spacingRadius = 0.022;

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
  final bool drawWireframe;

  ThreeDAnatomyPainter({
    required this.rotationY,
    required this.rotationX,
    required this.zoom,
    required this.visibleLayers,
    this.selectedId,
    required this.pulse,
    this.drawWireframe = true,
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

    if (drawWireframe) {
      // ==========================================
      // 0. ANATOMICAL HUMAN BODY SILHOUETTE OUTLINE
      // ==========================================
    final silhouetteLightDir = Vector3(0.2, -0.8, 0.6).normalize();
    for (final quad in ThreeDAnatomyModel.cachedBodySilhouette) {
      final rQuad = quad.map((pt) => pt.rotateY(rotationY).rotateX(rotationX)).toList();
      final depth = (rQuad[0].z + rQuad[1].z + rQuad[2].z + rQuad[3].z) / 4;

      final v10 = rQuad[1] - rQuad[0];
      final v20 = rQuad[2] - rQuad[0];
      final normal = ThreeDAnatomyModel.cross(v10, v20).normalize();
      final light = (normal.dot(silhouetteLightDir)).clamp(0.2, 1.0);

      primitives.add(DrawPrimitive(
        depth: depth - 0.15, // Always behind bones & muscles
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
              (139 * light).round(),
              (92 * light).round(),
              (246 * light).round(),
              0.05,
            )
            ..style = PaintingStyle.fill);

          c.drawPath(path, Paint()
            ..color = const Color(0xFFEC4899).withValues(alpha: 0.08)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 0.5);
        },
      ));
    }

    // ==========================================
    // 1. OSTEOLOGY (BONES) - 3D Shaded Mesh Projection
    // ==========================================
    if (visibleLayers.contains('bone')) {
      final isBoneSelected = selectedId == 'skull';
      final boneColor = isBoneSelected ? BioColors.boneSelected : BioColors.bone;
      final lightDir = Vector3(0.35, -0.65, 0.75).normalize();
      // Secondary fill light from the left for more depth
      final fillLightDir = Vector3(-0.5, -0.3, 0.4).normalize();
      // View direction for specular & rim lighting
      final viewDir = const Vector3(0, 0, 1).normalize();

      // 3D Skull Polyhedral Shaded Mesh with enhanced lighting
      for (final quad in ThreeDAnatomyModel.cachedSkullMesh) {
        final rQuad = quad.map((pt) => pt.rotateY(rotationY).rotateX(rotationX)).toList();
        final depth = (rQuad[0].z + rQuad[1].z + rQuad[2].z + rQuad[3].z) / 4;

        final v10 = rQuad[1] - rQuad[0];
        final v20 = rQuad[2] - rQuad[0];
        final normal = ThreeDAnatomyModel.cross(v10, v20).normalize();

        // Diffuse lighting (key + fill)
        final diffuseKey = (normal.dot(lightDir)).clamp(0.0, 1.0);
        final diffuseFill = (normal.dot(fillLightDir)).clamp(0.0, 1.0) * 0.3;
        final ambient = 0.22;
        final diffuse = (ambient + diffuseKey * 0.65 + diffuseFill).clamp(0.0, 1.0);

        // Specular highlight (Blinn-Phong approximation)
        final halfVec = (lightDir + viewDir).normalize();
        final specAngle = (normal.dot(halfVec)).clamp(0.0, 1.0);
        final specular = math.pow(specAngle, 32.0) * 0.4;

        // Rim lighting effect (edges glow when selected)
        final rimDot = 1.0 - (normal.dot(viewDir)).abs().clamp(0.0, 1.0);
        final rimLight = isBoneSelected ? rimDot * rimDot * 0.35 : rimDot * rimDot * 0.08;

        // Warm bone subsurface scattering tint (edges get warmer/pinkish)
        final warmEdge = rimDot * 0.15;

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

            // Base warm bone color with diffuse + specular + rim
            final r = ((229 * diffuse + 255 * specular + 255 * warmEdge + (isBoneSelected ? 180 * rimLight : 0)).clamp(0, 255)).round();
            final g = ((211 * diffuse + 245 * specular + 190 * warmEdge + (isBoneSelected ? 120 * rimLight : 0)).clamp(0, 255)).round();
            final b = ((179 * diffuse + 220 * specular + 160 * warmEdge + (isBoneSelected ? 255 * rimLight : 0)).clamp(0, 255)).round();

            c.drawPath(path, Paint()
              ..color = Color.fromRGBO(r, g, b, isBoneSelected ? 0.95 : 0.75)
              ..style = PaintingStyle.fill);

            // Subtle edge wireframe
            c.drawPath(path, Paint()
              ..color = boneColor.withValues(alpha: isBoneSelected ? 0.6 : 0.18)
              ..style = PaintingStyle.stroke
              ..strokeWidth = 0.4);
          },
        ));
      }

      // 3D Mandible Mesh (volumetric jawbone)
      for (final quad in ThreeDAnatomyModel.cachedMandibleMesh) {
        final rQuad = quad.map((pt) => pt.rotateY(rotationY).rotateX(rotationX)).toList();
        final depth = (rQuad[0].z + rQuad[1].z + rQuad[2].z + rQuad[3].z) / 4;

        final v10 = rQuad[1] - rQuad[0];
        final v20 = rQuad[2] - rQuad[0];
        final normal = ThreeDAnatomyModel.cross(v10, v20).normalize();
        final light = (normal.dot(lightDir)).clamp(0.2, 1.0);
        final spec = math.pow((normal.dot((lightDir + viewDir).normalize())).clamp(0.0, 1.0), 24.0) * 0.3;

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
                ((225 * light + 255 * spec).clamp(0, 255)).round(),
                ((205 * light + 245 * spec).clamp(0, 255)).round(),
                ((170 * light + 220 * spec).clamp(0, 255)).round(),
                isBoneSelected ? 0.92 : 0.7,
              )
              ..style = PaintingStyle.fill);

            c.drawPath(path, Paint()
              ..color = boneColor.withValues(alpha: isBoneSelected ? 0.5 : 0.15)
              ..style = PaintingStyle.stroke
              ..strokeWidth = 0.3);
          },
        ));
      }

      // Zygomatic cheekbone patches (3D surface)
      for (final quad in ThreeDAnatomyModel.cachedZygomaticPatches) {
        final rQuad = quad.map((pt) => pt.rotateY(rotationY).rotateX(rotationX)).toList();
        final depth = (rQuad[0].z + rQuad[1].z + rQuad[2].z + rQuad[3].z) / 4;

        final v10 = rQuad[1] - rQuad[0];
        final v20 = rQuad[2] - rQuad[0];
        final normal = ThreeDAnatomyModel.cross(v10, v20).normalize();
        final light = (normal.dot(lightDir)).clamp(0.25, 1.0);

        primitives.add(DrawPrimitive(
          depth: depth + 0.02,
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
                (232 * light).round(),
                (215 * light).round(),
                (185 * light).round(),
                isBoneSelected ? 0.88 : 0.55,
              )
              ..style = PaintingStyle.fill);
          },
        ));
      }

      // Maxilla ridge (upper jaw)
      for (final quad in ThreeDAnatomyModel.cachedMaxillaRidge) {
        final rQuad = quad.map((pt) => pt.rotateY(rotationY).rotateX(rotationX)).toList();
        final depth = (rQuad[0].z + rQuad[1].z + rQuad[2].z + rQuad[3].z) / 4;

        final v10 = rQuad[1] - rQuad[0];
        final v20 = rQuad[2] - rQuad[0];
        final normal = ThreeDAnatomyModel.cross(v10, v20).normalize();
        final light = (normal.dot(lightDir)).clamp(0.3, 1.0);

        primitives.add(DrawPrimitive(
          depth: depth + 0.03,
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
                (228 * light).round(),
                (210 * light).round(),
                (178 * light).round(),
                isBoneSelected ? 0.85 : 0.5,
              )
              ..style = PaintingStyle.fill);
          },
        ));
      }

      // Tooth row (small tooth blocks along mandible)
      for (final quad in ThreeDAnatomyModel.cachedToothRow) {
        final rQuad = quad.map((pt) => pt.rotateY(rotationY).rotateX(rotationX)).toList();
        final depth = (rQuad[0].z + rQuad[1].z + rQuad[2].z + rQuad[3].z) / 4;

        primitives.add(DrawPrimitive(
          depth: depth + 0.04,
          draw: (c) {
            final path = Path();
            final start = rQuad.first.project(size.width, size.height, zoom, centerX, centerY);
            path.moveTo(start.dx, start.dy);
            for (int i = 1; i < rQuad.length; i++) {
              final pt = rQuad[i].project(size.width, size.height, zoom, centerX, centerY);
              path.lineTo(pt.dx, pt.dy);
            }
            path.close();

            // White/cream tooth color
            c.drawPath(path, Paint()
              ..color = Color.fromRGBO(248, 245, 235, isBoneSelected ? 0.9 : 0.5)
              ..style = PaintingStyle.fill);
            c.drawPath(path, Paint()
              ..color = Color.fromRGBO(200, 190, 170, isBoneSelected ? 0.7 : 0.3)
              ..style = PaintingStyle.stroke
              ..strokeWidth = 0.5);
          },
        ));
      }

      // Cranial suture lines
      for (final rawPath in ThreeDAnatomyModel.cachedSutureLines) {
        final rotatedPath = rawPath.map((pt) => pt.rotateY(rotationY).rotateX(rotationX)).toList();
        final depth = rotatedPath.map((pt) => pt.z).reduce((a, b) => a + b) / rotatedPath.length;

        primitives.add(DrawPrimitive(
          depth: depth + 0.06,
          draw: (c) {
            final path = Path();
            final start = rotatedPath.first.project(size.width, size.height, zoom, centerX, centerY);
            path.moveTo(start.dx, start.dy);
            for (int i = 1; i < rotatedPath.length; i++) {
              final pt = rotatedPath[i].project(size.width, size.height, zoom, centerX, centerY);
              path.lineTo(pt.dx, pt.dy);
            }

            // Subtle dark suture lines with a jagged/dashed appearance
            c.drawPath(path, Paint()
              ..color = Color.fromRGBO(160, 140, 110, isBoneSelected ? 0.55 : 0.22)
              ..style = PaintingStyle.stroke
              ..strokeWidth = isBoneSelected ? 1.2 : 0.6);
          },
        ));
      }

      // Skull Facial Features (Eye Sockets, Nasal Cavity, Brow Ridge, Zygomatic Arch, Mandible outline)
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

            // Darker feature lines for anatomical definition
            c.drawPath(path, Paint()
              ..color = isBoneSelected
                  ? const Color.fromRGBO(255, 255, 255, 1.0)
                  : const Color.fromRGBO(180, 160, 130, 0.9)
              ..style = PaintingStyle.stroke
              ..strokeWidth = isBoneSelected ? 2.2 : 1.4);
          },
        ));
      }

      // Rim glow effect when skull is selected
      if (isBoneSelected) {
        final skullCenter = const Vector3(0, -0.76, 0.05).rotateY(rotationY).rotateX(rotationX);
        primitives.add(DrawPrimitive(
          depth: skullCenter.z + 0.07,
          draw: (c) {
            final pos = skullCenter.project(size.width, size.height, zoom, centerX, centerY);
            final glowRadius = 48.0 + 4.0 * math.sin(pulse * 2 * math.pi);
            c.drawCircle(
              pos,
              glowRadius * zoom,
              Paint()
                ..color = const Color.fromRGBO(229, 211, 179, 0.12)
                ..style = PaintingStyle.fill
                ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 18),
            );
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
                (243 * light).round(),
                (231 * light).round(),
                (211 * light).round(),
                0.45,
              )
              ..style = PaintingStyle.fill);

            c.drawPath(path, Paint()
              ..color = const Color(0xFFD4C3A3).withValues(alpha: 0.18)
              ..style = PaintingStyle.stroke
              ..strokeWidth = 0.3);
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
              ..color = ribColor.withValues(alpha: isRibsSelected ? 0.55 : 0.22)
              ..style = PaintingStyle.stroke
              ..strokeWidth = isRibsSelected ? 3.5 : 1.8);

            c.drawPath(path, Paint()
              ..color = ribColor.withValues(alpha: isRibsSelected ? 1.0 : 0.65)
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
              ..color = pelvisColor.withValues(alpha: isPelvisSelected ? 0.55 : 0.22)
              ..style = PaintingStyle.stroke
              ..strokeWidth = isPelvisSelected ? 4.0 : 2.0);

            c.drawPath(path, Paint()
              ..color = pelvisColor.withValues(alpha: isPelvisSelected ? 1.0 : 0.7)
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
              ..color = spineColor.withValues(alpha: isSpineSelected ? 0.45 : 0.05)
              ..strokeWidth = isSpineSelected ? 8.0 : 3.0
              ..strokeCap = StrokeCap.round);
            c.drawLine(p1, p2, Paint()
              ..color = spineColor.withValues(alpha: isSpineSelected ? 1.0 : 0.25)
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
                  ..color = spineColor.withValues(alpha: isSpineSelected ? 1.0 : 0.25)
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
                ..color = color.withValues(alpha: isSel ? 0.45 : 0.03)
                ..strokeWidth = bone.thickness * (isSel ? 3.5 : 1.8)
                ..strokeCap = StrokeCap.round);
              c.drawLine(p1, p2, Paint()
                ..color = color.withValues(alpha: isSel ? 1.0 : 0.2)
                ..strokeWidth = bone.thickness * (isSel ? 1.5 : 0.8)
                ..strokeCap = StrokeCap.round);
            } else {
              final axis = Offset(p2.dy - p1.dy, p1.dx - p2.dx);
              final len = math.sqrt(axis.dx * axis.dx + axis.dy * axis.dy);
              if (len > 0) {
                final norm = Offset(axis.dx / len, axis.dy / len);
                final offsetVec = norm * (bone.offsetScale * math.min(size.width, size.height) * zoom);

                c.drawLine(p1 - offsetVec, p2 - offsetVec, Paint()
                  ..color = color.withValues(alpha: isSel ? 1.0 : 0.2)
                  ..strokeWidth = bone.thickness * (isSel ? 1.4 : 0.7));
                c.drawLine(p1 + offsetVec, p2 + offsetVec, Paint()
                  ..color = color.withValues(alpha: isSel ? 1.0 : 0.2)
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

        for (final rawFiber in muscle.fibers) {
          // Perform lightweight Y/X matrix rotation of cached vertices
          final rotatedFiber = rawFiber.map((pt) => pt.rotateY(rotationY).rotateX(rotationX)).toList();
          final depth = rotatedFiber.map((pt) => pt.z).reduce((a, b) => a + b) / rotatedFiber.length;

          primitives.add(DrawPrimitive(
            depth: depth + (isSel ? 0.05 : 0.0),
            draw: (c) {
              final path = Path();
              final start = rotatedFiber.first.project(size.width, size.height, zoom, centerX, centerY);
              path.moveTo(start.dx, start.dy);

              for (int i = 1; i < rotatedFiber.length; i++) {
                final pt = rotatedFiber[i].project(size.width, size.height, zoom, centerX, centerY);
                path.lineTo(pt.dx, pt.dy);
              }

              final baseAlpha = isSel ? 0.95 + 0.05 * math.sin(pulse * 2 * math.pi) : 0.78;

              // Layer 1: Muscle Belly Base Bulk (Deep Crimson Organic Volume Mass)
              c.drawPath(path, Paint()
                ..color = (isSel ? const Color(0xFFFF1744) : const Color(0xFFB91C1C)).withValues(alpha: baseAlpha * 0.45)
                ..style = PaintingStyle.stroke
                ..strokeWidth = isSel ? 2.5 : 1.2
                ..strokeCap = StrokeCap.round);

              // Layer 2: Muscular Fiber Striation (Rich Fleshy Red Highlight)
              c.drawPath(path, Paint()
                ..color = (isSel ? const Color(0xFFFF8A9E) : const Color(0xFFEF4444)).withValues(alpha: baseAlpha * 0.6)
                ..style = PaintingStyle.stroke
                ..strokeWidth = isSel ? 1.0 : 0.5
                ..strokeCap = StrokeCap.round);
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
                ..color = color.withValues(alpha: isSel ? 0.25 : 0.08)
                ..style = PaintingStyle.stroke
                ..strokeWidth = isSel ? 1.8 : 1.0);

              c.drawPath(path, Paint()
                ..color = color.withValues(alpha: isSel ? 0.95 : 0.45)
                ..style = PaintingStyle.stroke
                ..strokeWidth = isSel ? 0.8 : 0.4);
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
                ..color = color.withValues(alpha: isSel ? 0.35 : 0.15)
                ..strokeWidth = isSel ? 3.0 : 1.5
                ..strokeCap = StrokeCap.square);
              c.drawLine(p1, p2, Paint()
                ..color = color.withValues(alpha: isSel ? 0.85 : 0.45)
                ..strokeWidth = isSel ? 1.2 : 0.6
                ..strokeCap = StrokeCap.square);
            },
          ));
        }
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
              ..color = color.withValues(alpha: isSel ? 0.35 : 0.14)
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
              ..color = color.withValues(alpha: 0.85)
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
