import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/colors.dart';
import '../widgets/skeleton_overlay_painter.dart' hide BioColors;
import '../widgets/three_d_anatomy_painter.dart';
import 'test_library_screen.dart';

class AnatomyPlaceholderScreen extends StatefulWidget {
  const AnatomyPlaceholderScreen({super.key});

  @override
  State<AnatomyPlaceholderScreen> createState() =>
      _AnatomyPlaceholderScreenState();
}

class _AnatomyPlaceholderScreenState extends State<AnatomyPlaceholderScreen>
    with SingleTickerProviderStateMixin {
  // 3D rotation angles & zoom
  double _rotationY = 0.0;
  double _rotationX = 0.0;
  double _zoom = 1.0;

  // Manual view selection
  bool _isAnterior = true;

  // Active layers configuration
  bool _showBones = true;
  bool _showMuscles = true;
  bool _showNerves = true;
  bool _showLigaments = true;

  // Selected anatomical element details
  String _selectedElementId = 'femur';

  late AnimationController _pulseController;

  Set<String> get _visibleLayers {
    final set = <String>{};
    if (_showBones) set.add('bone');
    if (_showMuscles) set.add('muscle');
    if (_showNerves) set.add('nerve');
    if (_showLigaments) set.add('ligament');
    return set;
  }

  void _handleTap(TapUpDetails details, BoxConstraints constraints) {
    final tapPos = details.localPosition;
    final centerX = constraints.maxWidth / 2;
    final centerY = constraints.maxHeight / 2 - 20;

    String? closestId;
    double minDistance = double.infinity;

    ThreeDAnatomyModel.hotSpotCenters.forEach((id, rawPt) {
      final layerType = _getHotspotLayer(id);
      if (!_visibleLayers.contains(layerType)) return;

      final rotated = rawPt.rotateY(_rotationY).rotateX(_rotationX);
      final isFront = rotated.z > -0.05;
      if (!isFront && id != _selectedElementId) return;

      final projected = rotated.project(constraints.maxWidth, constraints.maxHeight, _zoom, centerX, centerY);
      final dist = (tapPos - projected).distance;

      if (dist < 45.0 && dist < minDistance) {
        minDistance = dist;
        closestId = id;
      }
    });

    if (closestId != null) {
      setState(() {
        _selectedElementId = closestId!;
      });
    }
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

  // Comprehensive Anatomical Database
  final Map<String, _AnatomyElement> _anatomyDb = {
    // === BONES ===
    'skull': _AnatomyElement(
      id: 'skull',
      name: 'Skull (Cranium)',
      latinName: 'Cranium & Mandible',
      layer: _AnatomyLayer.bone,
      description:
          'The protective bony cavity for the brain and sensory organs. Highly relevant in clinical biomechanics for Temporomandibular Joint (TMJ) translation, occlusion, cranial nerve pathways, and cervicogenic headaches.',
      clinicalPearl:
          'Palpate the condylar head of the mandible just anterior to the tragus of the ear during jaw opening to assess translation and deviation.',
      statLabel: 'Clinical Tests: TMJ Mobility Assessment, Jaw Jerk Reflex.',
      region: 'Cervical spine',
    ),
    'spine': _AnatomyElement(
      id: 'spine',
      name: 'Vertebral Column',
      latinName: 'Columna Vertebralis C1-L5',
      layer: _AnatomyLayer.bone,
      description:
          'The central axial skeleton containing 24 articulating vertebrae. Functions as the primary column for weight bearing, spinal cord protection, and trunk multi-planar mobility.',
      clinicalPearl:
          'Always clear the transverse and alar ligaments of the upper cervical spine before executing manual therapy rotations.',
      statLabel:
          'Clinical Tests: Spurling\'s Compress Test, Distraction, Springing Test.',
      region: 'Cervical spine',
    ),
    'ribs': _AnatomyElement(
      id: 'ribs',
      name: 'Rib Cage & Sternum',
      latinName: 'Cavea Thoracis',
      layer: _AnatomyLayer.bone,
      description:
          'Bony-cartilaginous cage formed by 12 pairs of ribs. Articulates with thoracic vertebrae posteriorly and sternum anteriorly. Crucial for respiration kinetics and thoracic spine stabilization.',
      clinicalPearl:
          'Rib hypomobility can mimic thoracic disc herniation or intercostal neuralgia. Check rib excursion during full inhalation.',
      statLabel: 'Clinical Tests: Rib Springing, Costoclavicular Test.',
      region: 'Cervical spine',
    ),
    'pelvis': _AnatomyElement(
      id: 'pelvis',
      name: 'Pelvis',
      latinName: 'Cingulum Pelvicum',
      layer: _AnatomyLayer.bone,
      description:
          'Formed by the sacrum, ilium, ischium, and pubis. Distributes weight from the trunk to the lower limbs. Key structure in lower-quarter biomechanics and pelvic floor stabilization.',
      clinicalPearl:
          'Sacroiliac joint pain is local; pain radiating above L5 is rarely SIJ-related. Use the Laslett test battery.',
      statLabel:
          'Clinical Tests: SIJ Compression, Distraction, Gaenslen\'s Test.',
      region: 'Pelvis',
    ),
    'humerus': _AnatomyElement(
      id: 'humerus',
      name: 'Humerus',
      latinName: 'Os humeri',
      layer: _AnatomyLayer.bone,
      description:
          'The major long bone of the upper limb. Articulates with the scapular glenoid fossa to form the multi-axial glenohumeral joint, and with the radius/ulna distally.',
      clinicalPearl:
          'Repetitive humeral anterior translation indicates micro-instability of the anterior capsule or subscapularis insufficiency.',
      statLabel:
          'Clinical Tests: Apprehension-Relocation, Sulcus Sign, Load and Shift.',
      region: 'Shoulder',
    ),
    'radius_ulna': _AnatomyElement(
      id: 'radius_ulna',
      name: 'Radius & Ulna',
      latinName: 'Radius et ulna',
      layer: _AnatomyLayer.bone,
      description:
          'The twin forearm bones supporting pronation and supination. The radius rotates over the stationary ulna at the proximal and distal radioulnar joints.',
      clinicalPearl:
          'Always check for distal radioulnar joint (DRUJ) laxity after a FOOSH (Fall On Outstretched Hand) injury.',
      statLabel:
          'Clinical Tests: Varus/Valgus Stress, Tinel\'s at Elbow.',
      region: 'Elbow',
    ),
    'femur': _AnatomyElement(
      id: 'femur',
      name: 'Femur',
      latinName: 'Os femoris',
      layer: _AnatomyLayer.bone,
      description:
          'The largest, heaviest, and strongest long bone in the human skeleton. Transmits ground reaction forces from the tibia to the pelvic acetabulum during locomotion.',
      clinicalPearl:
          'Femoral neck fractures in elderly patients often present with external rotation and shortening of the affected limb.',
      statLabel:
          'Clinical Tests: Craig\'s (Femoral Torsion) Test, FABER Test.',
      region: 'Hip',
    ),
    'tibia_fibula': _AnatomyElement(
      id: 'tibia_fibula',
      name: 'Tibia & Fibula',
      latinName: 'Tibia et fibula',
      layer: _AnatomyLayer.bone,
      description:
          'The lower leg skeleton. The tibia bears 90% of the axial load, while the lateral fibula serves as an anchor for ankle/foot stabilizing muscles.',
      clinicalPearl:
          'High ankle sprains involve the distal tibiofibular syndesmosis. Test with the squeeze test and passive external rotation.',
      statLabel:
          'Clinical Tests: Squeeze Test, Cotton Test, Kleiger\'s Test.',
      region: 'Ankle and foot',
    ),

    // === MUSCLES ===
    'deltoid': _AnatomyElement(
      id: 'deltoid',
      name: 'Deltoid Muscle',
      latinName: 'M. deltoideus',
      layer: _AnatomyLayer.muscle,
      description:
          'Multipennate muscle wrapping around the glenohumeral joint. Divided into anterior (flexion), middle (abduction), and posterior (extension/lateral rotation) fibers.',
      clinicalPearl:
          'Weakness or atrophy of the deltoid is a hallmark indicator of axillary nerve compression or C5 nerve root pathology.',
      statLabel:
          'Origin: Lateral Clavicle & Acromion  |  Insertion: Deltoid Tuberosity',
      region: 'Shoulder',
    ),
    'pectoralis': _AnatomyElement(
      id: 'pectoralis',
      name: 'Pectoralis Major',
      latinName: 'M. pectoralis major',
      layer: _AnatomyLayer.muscle,
      description:
          'Large clavicular and sternocostal muscle. Major adductor and medial rotator of the humerus. Often hypertonic in patients with forward-head postural syndrome.',
      clinicalPearl:
          'Shortening of the pectoralis major pulls the scapula into anterior tilt and protraction, narrowing the subacromial space.',
      statLabel:
          'Origin: Clavicle & Sternum  |  Insertion: Lateral Lip of Intertubercular Sulcus',
      region: 'Shoulder',
    ),
    'biceps': _AnatomyElement(
      id: 'biceps',
      name: 'Biceps Brachii',
      latinName: 'M. biceps brachii',
      layer: _AnatomyLayer.muscle,
      description:
          'Two-headed fusiform muscle. Flexes and supinates the forearm at the elbow, and contributes to shoulder flexion. Long head tendon acts as a passive humeral head depressor.',
      clinicalPearl:
          'Speed\'s test is highly sensitive for superior labral (SLAP) lesions and biceps tendinopathy in the bicipital groove.',
      statLabel:
          'Origin: Coracoid & Supraglenoid  |  Insertion: Radial Tuberosity',
      region: 'Shoulder',
    ),
    'abdominals': _AnatomyElement(
      id: 'abdominals',
      name: 'Rectus Abdominis',
      latinName: 'M. rectus abdominis',
      layer: _AnatomyLayer.muscle,
      description:
          'Paired long vertical muscle of the anterior trunk. Flexes the lumbar column and tilts the pelvis posteriorly. Crucial for maintaining intra-abdominal pressure.',
      clinicalPearl:
          'Assess for diastasis recti (separation of the rectus abdominis bellies) postpartum before introducing heavy core loaded flexion.',
      statLabel:
          'Origin: Pubic Crest  |  Insertion: Xiphoid Process & Ribs 5-7',
      region: 'Pelvis',
    ),
    'quadriceps': _AnatomyElement(
      id: 'quadriceps',
      name: 'Quadriceps Femoris',
      latinName: 'M. quadriceps femoris',
      layer: _AnatomyLayer.muscle,
      description:
          'The primary extensor of the knee, consisting of Rectus Femoris, Vastus Lateralis, Vastus Medialis, and Vastus Intermedius. Key stabilizer of the patella.',
      clinicalPearl:
          'In patellofemoral pain syndrome, focus on strengthening the Vastus Medialis Oblique (VMO) to correct lateral patellar tracking.',
      statLabel:
          'Origin: Femur & Anterior Iliac Spine  |  Insertion: Patella & Tibial Tuberosity',
      region: 'Knee',
    ),
    'calves': _AnatomyElement(
      id: 'calves',
      name: 'Gastrocnemius & Soleus',
      latinName: 'M. triceps surae',
      layer: _AnatomyLayer.muscle,
      description:
          'The plantarflexors of the foot. The gastrocnemius crosses both knee and ankle joints, while the deep soleus crosses only the ankle.',
      clinicalPearl:
          'Achilles tendinopathy rehabilitation requires heavy slow resistance training (HSR) or eccentric loading protocols.',
      statLabel:
          'Origin: Femoral Condyles & Tibia  |  Insertion: Calcaneal Tuberosity',
      region: 'Ankle and foot',
    ),
    'trapezius': _AnatomyElement(
      id: 'trapezius',
      name: 'Trapezius',
      latinName: 'M. trapezius',
      layer: _AnatomyLayer.muscle,
      description:
          'Large flat triangular muscle of the upper back. Divided into upper (elevation), middle (retraction), and lower (depression/upward rotation) fibers.',
      clinicalPearl:
          'Upper trapezius dominance combined with lower trapezius weakness is a classic pattern in scapular dyskinesia.',
      statLabel:
          'Origin: Occipital bone & Spinous processes  |  Insertion: Clavicle & Acromion',
      region: 'Cervical spine',
    ),
    'latissimus_dorsi': _AnatomyElement(
      id: 'latissimus_dorsi',
      name: 'Latissimus Dorsi',
      latinName: 'M. latissimus dorsi',
      layer: _AnatomyLayer.muscle,
      description:
          'The widest muscle of the body, wrapping from the spine to the humerus. Powerful adductor, extensor, and internal rotator of the arm.',
      clinicalPearl:
          'A tight latissimus dorsi restricts shoulder flexion and induces compensatory lumbar hyperlordosis during overhead reaching.',
      statLabel:
          'Origin: Thoracolumbar fascia & Iliac crest  |  Insertion: Intertubercular groove',
      region: 'Shoulder',
    ),
    'gluteus_maximus': _AnatomyElement(
      id: 'gluteus_maximus',
      name: 'Gluteus Maximus',
      latinName: 'M. gluteus maximus',
      layer: _AnatomyLayer.muscle,
      description:
          'The primary hip extensor and external rotator. Essential for upright posture, running, climbing stairs, and preventing lumbar overload.',
      clinicalPearl:
          'Inhibited or weak glutes force the hamstrings and erector spinae to work harder, leading to hamstring strains and low back pain.',
      statLabel:
          'Origin: Posterior Ilium & Sacrum  |  Insertion: Gluteal tuberosity & IT Band',
      region: 'Hip',
    ),
    'hamstrings': _AnatomyElement(
      id: 'hamstrings',
      name: 'Hamstrings Group',
      latinName: 'Mm. ischiocrurales',
      layer: _AnatomyLayer.muscle,
      description:
          'Consists of Biceps Femoris, Semitendinosus, and Semimembranosus. Extends the hip and flexes the knee. Acts as a dynamic decelerator during running.',
      clinicalPearl:
          'Eccentric strengthening (e.g., Nordic Hamstring Curls) is highly effective at reducing hamstring tear recurrence.',
      statLabel:
          'Origin: Ischial Tuberosity  |  Insertion: Proximal Tibia & Fibula Head',
      region: 'Hip',
    ),
    'triceps': _AnatomyElement(
      id: 'triceps',
      name: 'Triceps Brachii',
      latinName: 'M. triceps brachii',
      layer: _AnatomyLayer.muscle,
      description:
          'Three-headed muscle of the posterior arm. The primary elbow extensor, with the long head also contributing to shoulder extension and stability.',
      clinicalPearl:
          'Triceps tendonitis presents as localized pain at the olecranon insertion, aggravated by resisted elbow extension.',
      statLabel:
          'Origin: Infraglenoid tubercle & Humeral shaft  |  Insertion: Olecranon of Ulna',
      region: 'Elbow',
    ),

    // === LIGAMENTS ===
    'acl_pcl': _AnatomyElement(
      id: 'acl_pcl',
      name: 'Cruciate Ligaments (ACL & PCL)',
      latinName: 'Lig. cruciatum anterius & posterius',
      layer: _AnatomyLayer.ligament,
      description:
          'Intra-articular knee stabilizers. The ACL limits anterior translation of the tibia; the PCL restricts posterior translation.',
      clinicalPearl:
          'Assess the ACL using Lachman\'s test at 20-30° of knee flexion rather than the anterior drawer test, as spasm can mask a tear.',
      statLabel:
          'Clinical Tests: Lachman\'s Test, Anterior Drawer, Pivot Shift.',
      region: 'Knee',
    ),
    'mcl_lcl': _AnatomyElement(
      id: 'mcl_lcl',
      name: 'Collateral Ligaments (MCL & LCL)',
      latinName: 'Lig. collaterale mediale & laterale',
      layer: _AnatomyLayer.ligament,
      description:
          'Extra-articular stabilizers. The MCL resists valgus stress (inward bowing); the LCL resists varus stress (outward bowing).',
      clinicalPearl:
          'Perform stress testing at both 0° and 30° flexion. Laxity at 0° indicates a multi-ligamentous injury or joint capsule tear.',
      statLabel: 'Clinical Tests: Valgus Stress Test, Varus Stress Test.',
      region: 'Knee',
    ),
    'glenohumeral': _AnatomyElement(
      id: 'glenohumeral',
      name: 'Glenohumeral Ligaments',
      latinName: 'Ligg. glenohumeralia',
      layer: _AnatomyLayer.ligament,
      description:
          'Three bands of fibrous tissue reinforcing the anterior shoulder capsule. Essential for restricting humeral subluxation.',
      clinicalPearl:
          'The inferior glenohumeral ligament (IGHL) is the primary static stabilizer against anterior dislocation during abduction and external rotation.',
      statLabel:
          'Clinical Tests: Apprehension-Relocation, Anterior Release.',
      region: 'Shoulder',
    ),

    // === NERVES ===
    'c6_nerve': _AnatomyElement(
      id: 'c6_nerve',
      name: 'C6 Nerve Root',
      latinName: 'Radix C6 plexus brachialis',
      layer: _AnatomyLayer.nerve,
      description:
          'Exits the spine between C5 and C6. Supplies wrist extensors and provides sensation to the radial arm, thumb, and index finger.',
      clinicalPearl:
          'C6 radiculopathy typically presents with sensory deficits along the lateral forearm and thumb, along with a diminished brachioradialis reflex.',
      statLabel:
          'Sensory: Thumb/Index  |  Myotome: Wrist extension  |  Reflex: Brachioradialis',
      region: 'Cervical spine',
    ),
    'sciatic': _AnatomyElement(
      id: 'sciatic',
      name: 'Sciatic Nerve',
      latinName: 'N. ischiadicus',
      layer: _AnatomyLayer.nerve,
      description:
          'The largest single nerve in the body, originating from L4-S3. Descends through the gluteal region into the posterior thigh, divisioning into tibial and common fibular nerves.',
      clinicalPearl:
          'Perform the Straight Leg Raise (SLR) test. Pain occurring between 30° and 70° indicates dural irritation and nerve root tension.',
      statLabel:
          'Clinical Tests: Straight Leg Raise (SLR), Slump Test, Bragard\'s.',
      region: 'Neurology',
    ),
  };

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


  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final selectedElement =
        _anatomyDb[_selectedElementId] ?? _anatomyDb['femur']!;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Interactive Anatomical Atlas',
          style: TextStyle(fontWeight: FontWeight.w700, letterSpacing: 0.2),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                      'Drag left/right to rotate. Tap any highlighted structure to view medical annotations and clinical orthopedic tests.'),
                  backgroundColor: AppColors.primaryPurple,
                ),
              );
            },
          )
        ],
      ),
      body: Stack(
        children: [
          // 1. BIOLOGICAL RADIANCE BACKGROUND GLOWS
          Positioned(
            left: -80,
            top: 100,
            child: Container(
              width: 260,
              height: 260,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: BioColors.muscle.withOpacity(isDark ? 0.12 : 0.06),
                boxShadow: [
                  BoxShadow(
                    color: BioColors.muscle.withOpacity(isDark ? 0.20 : 0.08),
                    blurRadius: 100,
                  )
                ],
              ),
            ),
          ),
          Positioned(
            right: -60,
            bottom: 240,
            child: Container(
              width: 280,
              height: 280,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: BioColors.ligament.withOpacity(isDark ? 0.12 : 0.06),
                boxShadow: [
                  BoxShadow(
                    color: BioColors.ligament.withOpacity(isDark ? 0.20 : 0.08),
                    blurRadius: 110,
                  )
                ],
              ),
            ),
          ),

          // 2. MAIN ANATOMICAL RENDERER (fills full Stack)
          Positioned.fill(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return GestureDetector(
                  onPanUpdate: (details) {
                    setState(() {
                      _rotationY += details.delta.dx * 0.007;
                      _rotationX -= details.delta.dy * 0.007;
                      _rotationX = _rotationX.clamp(-0.6, 0.6);

                      // Determine view based on rotation angle (spin effect)
                      final double normalizedAngle = (_rotationY % (2 * math.pi) + 2 * math.pi) % (2 * math.pi);
                      if (normalizedAngle > math.pi / 2 &&
                          normalizedAngle < 3 * math.pi / 2) {
                        _isAnterior = false; // Show back view
                      } else {
                        _isAnterior = true; // Show front view
                      }
                    });
                  },
                  onTapUp: (details) => _handleTap(details, constraints),
                  behavior: HitTestBehavior.opaque,
                  child: RepaintBoundary(
                    child: AnimatedBuilder(
                      animation: _pulseController,
                      builder: (context, _) {
                        return CustomPaint(
                          size: Size(constraints.maxWidth, constraints.maxHeight),
                          painter: ThreeDAnatomyPainter(
                            rotationY: _rotationY,
                            rotationX: _rotationX,
                            zoom: _zoom,
                            visibleLayers: _visibleLayers,
                            selectedId: _selectedElementId,
                            pulse: _pulseController.value,
                          ),
                        );
                      },
                    ),
                  ),
                );
              },
            ),
          ),


          // 3. LAYER TOGGLE TOOLBAR
          Positioned(
            left: 16,
            top: 20,
            right: 80,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: isDark ? AppColors.glassBgDark : AppColors.glassBgLight,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isDark
                      ? AppColors.glassBorderDark
                      : AppColors.glassBorderLight,
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10),
                ],
              ),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildFilterChip(
                      label: 'Osteology',
                      icon: Icons.accessibility_new,
                      activeColor: BioColors.bone,
                      value: _showBones,
                      onChanged: (val) => setState(() => _showBones = val),
                    ),
                    const SizedBox(width: 8),
                    _buildFilterChip(
                      label: 'Myology',
                      icon: Icons.fitness_center,
                      activeColor: BioColors.muscle,
                      value: _showMuscles,
                      onChanged: (val) => setState(() => _showMuscles = val),
                    ),
                    const SizedBox(width: 8),
                    _buildFilterChip(
                      label: 'Arthrology',
                      icon: Icons.join_full,
                      activeColor: BioColors.ligament,
                      value: _showLigaments,
                      onChanged: (val) => setState(() => _showLigaments = val),
                    ),
                    const SizedBox(width: 8),
                    _buildFilterChip(
                      label: 'Neurology',
                      icon: Icons.flash_on,
                      activeColor: BioColors.nerve,
                      value: _showNerves,
                      onChanged: (val) => setState(() => _showNerves = val),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // 4. ZOOM & VIEW CONTROL TOOLBAR
          Positioned(
            right: 16,
            top: 20,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
              decoration: BoxDecoration(
                color: isDark ? AppColors.glassBgDark : AppColors.glassBgLight,
                borderRadius: BorderRadius.circular(30),
                border: Border.all(
                  color: isDark
                      ? AppColors.glassBorderDark
                      : AppColors.glassBorderLight,
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10),
                ],
              ),
              child: Column(
                children: [
                  IconButton(
                    icon: Icon(
                      _isAnterior ? Icons.flip_camera_android : Icons.sync,
                      color: AppColors.primaryPink,
                      size: 20,
                    ),
                    tooltip: 'Flip Anterior/Posterior',
                    onPressed: () {
                      setState(() {
                        _isAnterior = !_isAnterior;
                        _rotationY = _isAnterior ? 0.0 : math.pi;
                      });
                    },
                  ),
                  const Divider(color: Colors.white24, height: 10),
                  IconButton(
                    icon: const Icon(Icons.add, color: AppColors.primaryPink, size: 20),
                    onPressed: () {
                      setState(() {
                        _zoom = (_zoom + 0.15).clamp(0.6, 1.8);
                      });
                    },
                  ),
                  const Text(
                    'ZOOM',
                    style: TextStyle(
                      fontSize: 8,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryPurple,
                      letterSpacing: 0.5,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.remove, color: AppColors.primaryPurple, size: 20),
                    onPressed: () {
                      setState(() {
                        _zoom = (_zoom - 0.15).clamp(0.6, 1.8);
                      });
                    },
                  ),
                ],
              ),
            ),
          ),

          // 5. ANATOMICAL DIRECTORY (SCROLLABLE LABELS)
          Positioned(
            left: 12,
            top: 85,
            bottom: 280,
            child: SizedBox(
              width: 130,
              child: AnimatedBuilder(
                animation: _pulseController,
                builder: (context, _) {
                  final visibleHotspots = anatomyScreenHotspots
                      .where((h) =>
                          h.isAnterior == _isAnterior &&
                          _visibleLayers.contains(h.layerType))
                      .toList();
                  return ListView.builder(
                    padding: EdgeInsets.zero,
                    itemCount: visibleHotspots.length,
                    itemBuilder: (context, index) {
                      final hotspot = visibleHotspots[index];
                      final isSelected = hotspot.id == _selectedElementId;
                      // Get the region for this hotspot from anatomy database
                      final elementData = _anatomyDb[hotspot.id];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () {
                              setState(() {
                                _selectedElementId = hotspot.id;
                              });
                            },
                            onDoubleTap: () {
                              // Double-tap navigates directly to tests
                              if (elementData != null) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => TestLibraryScreen(
                                      region: elementData.region,
                                    ),
                                  ),
                                );
                              }
                            },
                            borderRadius: BorderRadius.circular(10),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 5),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? hotspot.color.withOpacity(0.2)
                                    : (isDark
                                        ? AppColors.glassBgDark
                                        : Colors.white.withOpacity(0.6)),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: isSelected
                                      ? hotspot.color.withOpacity(0.5)
                                      : Colors.transparent,
                                  width: 1.0,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 6,
                                    height: 6,
                                    decoration: BoxDecoration(
                                      color: hotspot.color,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 5),
                                  Expanded(
                                    child: Text(
                                      hotspot.label,
                                      style: TextStyle(
                                        fontSize: 9,
                                        fontWeight: isSelected
                                            ? FontWeight.bold
                                            : FontWeight.w500,
                                        color: isDark
                                            ? Colors.white70
                                            : AppColors.lightTextPrimary,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  // Navigation arrow to tests
                                  if (elementData != null)
                                    GestureDetector(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => TestLibraryScreen(
                                              region: elementData.region,
                                            ),
                                          ),
                                        );
                                      },
                                      child: Padding(
                                        padding: const EdgeInsets.only(left: 2),
                                        child: Icon(
                                          Icons.arrow_forward_ios_rounded,
                                          size: 10,
                                          color: isSelected
                                              ? hotspot.color
                                              : (isDark
                                                  ? Colors.white38
                                                  : AppColors.lightTextSecondary),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ),

          // 6. CLINICAL SPECIFICATION DRAWER
          Positioned(
            left: 16,
            right: 16,
            bottom: 16,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.glassBgDark : AppColors.glassBgLight,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: _getLayerColor(selectedElement.layer).withOpacity(0.35),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: _getLayerColor(selectedElement.layer).withOpacity(0.12),
                      blurRadius: 25,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Anatomical Title
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: _getLayerColor(selectedElement.layer)
                                      .withOpacity(0.15),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  _getLayerIcon(selectedElement.layer),
                                  color: _getLayerColor(selectedElement.layer),
                                  size: 18,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      selectedElement.name,
                                      style: theme.textTheme.titleMedium?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15,
                                        color: isDark
                                            ? Colors.white
                                            : AppColors.lightTextPrimary,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    Text(
                                      selectedElement.latinName,
                                      style: TextStyle(
                                        fontStyle: FontStyle.italic,
                                        fontSize: 10,
                                        color: isDark
                                            ? Colors.white54
                                            : AppColors.lightTextSecondary,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: _getLayerColor(selectedElement.layer)
                                .withOpacity(0.15),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            selectedElement.layer.name.toUpperCase(),
                            style: TextStyle(
                              color: _getLayerColor(selectedElement.layer),
                              fontWeight: FontWeight.bold,
                              fontSize: 9,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),

                    // Description text
                    Text(
                      selectedElement.description,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        height: 1.35,
                        fontSize: 12,
                        color: isDark
                            ? Colors.white70
                            : AppColors.lightTextSecondary,
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 10),

                    // Medical Attachment Details (Origin/Insertion or Tests)
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: isDark
                            ? Colors.black.withOpacity(0.18)
                            : Colors.white.withOpacity(0.4),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isDark
                              ? AppColors.glassBorderDark
                              : AppColors.glassBorderLight,
                        ),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: _getLayerColor(selectedElement.layer),
                            size: 13,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              selectedElement.statLabel,
                              style: TextStyle(
                                fontSize: 10.5,
                                fontWeight: FontWeight.w600,
                                color: isDark
                                    ? Colors.white60
                                    : AppColors.lightTextPrimary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Clinical note pearl
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.lightbulb_outline,
                            color: AppColors.primaryPink, size: 14),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Clinical Pearl: ${selectedElement.clinicalPearl}',
                            style: TextStyle(
                              fontSize: 10.5,
                              fontStyle: FontStyle.italic,
                              color: isDark
                                  ? Colors.pinkAccent.shade100
                                  : Colors.pink.shade700,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Direct Orthopedic Test Library Navigation
                    SizedBox(
                      width: double.infinity,
                      height: 44,
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.menu_book, size: 16),
                        label: Text(
                          'Test ${selectedElement.region} orthopedic system',
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _getLayerColor(selectedElement.layer),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => TestLibraryScreen(
                                region: selectedElement.region,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ).animate().fadeIn(duration: 350.ms).slideY(begin: 0.15, end: 0.0),
        ],
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required IconData icon,
    required Color activeColor,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return FilterChip(
      avatar: Icon(icon, size: 15, color: value ? Colors.white : activeColor),
      label: Text(
        label,
        style: TextStyle(
          color: value
              ? Colors.white
              : (isDark ? Colors.white70 : AppColors.lightTextPrimary),
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
      selected: value,
      selectedColor: activeColor,
      backgroundColor: Colors.transparent,
      checkmarkColor: Colors.white,
      showCheckmark: false,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
            color: value ? Colors.transparent : activeColor.withOpacity(0.4)),
      ),
      onSelected: onChanged,
    );
  }

  Color _getLayerColor(_AnatomyLayer layer) {
    switch (layer) {
      case _AnatomyLayer.bone:
        return BioColors.bone;
      case _AnatomyLayer.muscle:
        return BioColors.muscle;
      case _AnatomyLayer.ligament:
        return BioColors.ligament;
      case _AnatomyLayer.nerve:
        return BioColors.nerve;
    }
  }

  IconData _getLayerIcon(_AnatomyLayer layer) {
    switch (layer) {
      case _AnatomyLayer.bone:
        return Icons.accessibility;
      case _AnatomyLayer.muscle:
        return Icons.fitness_center;
      case _AnatomyLayer.ligament:
        return Icons.join_full;
      case _AnatomyLayer.nerve:
        return Icons.flash_on;
    }
  }
}

// Anatomy Element Model
enum _AnatomyLayer { bone, muscle, ligament, nerve }

class _AnatomyElement {
  final String id;
  final String name;
  final String latinName;
  final _AnatomyLayer layer;
  final String description;
  final String clinicalPearl;
  final String statLabel;
  final String region;

  _AnatomyElement({
    required this.id,
    required this.name,
    required this.latinName,
    required this.layer,
    required this.description,
    required this.clinicalPearl,
    required this.statLabel,
    required this.region,
  });
}
