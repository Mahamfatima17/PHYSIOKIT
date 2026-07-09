class SpecialTest {
  final int id;
  final String name;
  final String category;
  final String region;
  final String purpose;
  final String procedure;
  final String positiveSign;
  final String patientPosition;
  final String therapistPosition;
  final String interpretation;
  final String clinicalNotes;
  final String sensitivity;
  final String specificity;
  final String importantNotes;
  final String illustration;
  final String reference;

  SpecialTest({
    required this.id,
    required this.name,
    required this.category,
    required this.region,
    required this.purpose,
    required this.procedure,
    required this.positiveSign,
    required this.patientPosition,
    required this.therapistPosition,
    required this.interpretation,
    required this.clinicalNotes,
    required this.sensitivity,
    required this.specificity,
    required this.importantNotes,
    required this.illustration,
    required this.reference,
  });

  factory SpecialTest.fromMap(Map<String, dynamic> map) {
    return SpecialTest(
      id: map['id'] ?? 0,
      name: map['name'] ?? '',
      category: map['category'] ?? '',
      region: map['region'] ?? '',
      purpose: map['purpose'] ?? '',
      procedure: map['procedure'] ?? '',
      positiveSign: map['positive_sign'] ?? '',
      patientPosition: map['patient_position'] ?? 'Refer to procedure',
      therapistPosition: map['therapist_position'] ?? 'Refer to procedure',
      interpretation: map['interpretation'] ?? '',
      clinicalNotes: map['clinical_notes'] ?? '',
      sensitivity: map['sensitivity'] ?? 'N/A',
      specificity: map['specificity'] ?? 'N/A',
      importantNotes: map['important_notes'] ?? '',
      illustration: map['illustration'] ?? '',
      reference: map['reference'] ?? 'The Physiotherapist\'s Pocket Book',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'region': region,
      'purpose': purpose,
      'procedure': procedure,
      'positive_sign': positiveSign,
      'patient_position': patientPosition,
      'therapist_position': therapistPosition,
      'interpretation': interpretation,
      'clinical_notes': clinicalNotes,
      'sensitivity': sensitivity,
      'specificity': specificity,
      'important_notes': importantNotes,
      'illustration': illustration,
      'reference': reference,
    };
  }
}
