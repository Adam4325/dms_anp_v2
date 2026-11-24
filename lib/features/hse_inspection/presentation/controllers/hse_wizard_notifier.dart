import 'dart:convert';
import 'dart:io';

import 'package:dms_anp/features/hse_inspection/data/datasources/hse_remote_datasource.dart';
import 'package:dms_anp/features/hse_inspection/data/models/hse_models.dart';
import 'package:dms_anp/features/hse_inspection/domain/repositories/hse_repository.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

class HseWizardNotifier extends ChangeNotifier {
  final HseRepository _repository;
  final ImagePicker _picker = ImagePicker();
  final String username;

  HseWizardNotifier({
    required this.username,
    HseRepository? repository,
  }) : _repository = repository ?? HseRemoteDataSource();

  int _currentStep = 0; // 0: Search, 1: Preview, 2: Form, 3: Success
  String _selectedEntityType = HseEntityType.driver;
  String _searchQuery = '';
  List<EntityPreviewModel> _suggestions = [];
  bool _isSearching = false;
  bool _isLookingUp = false;
  String? _lookupError;

  EntityPreviewModel? _previewEntity;

  List<ViolationTypeModel> _violationTypes = [];
  bool _isLoadingCategories = false;
  String? _selectedCategory;
  String? _selectedSanction;
  DateTime _incidentDate = DateTime.now();
  DateTime _dueDate = DateTime.now().add(const Duration(days: 3));
  String _description = '';
  File? _evidenceBeforeFile;
  String _evidenceBeforeBase64 = '';

  bool _disposed = false;
  bool _isSubmitting = false;
  int _searchSeq = 0;
  String? _submitError;
  Map<String, dynamic>? _submittedTicket;

  @override
  void notifyListeners() {
    if (!_disposed) {
      super.notifyListeners();
    }
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  // Getters
  int get currentStep => _currentStep;
  String get selectedEntityType => _selectedEntityType;
  String get searchQuery => _searchQuery;
  List<EntityPreviewModel> get suggestions => _suggestions;
  bool get isSearching => _isSearching;
  bool get isLookingUp => _isLookingUp;
  String? get lookupError => _lookupError;
  EntityPreviewModel? get previewEntity => _previewEntity;
  List<ViolationTypeModel> get violationTypes => _violationTypes;
  bool get isLoadingCategories => _isLoadingCategories;
  String? get selectedCategory => _selectedCategory;
  String? get selectedSanction => _selectedSanction;
  DateTime get incidentDate => _incidentDate;
  DateTime get dueDate => _dueDate;
  String get description => _description;
  File? get evidenceBeforeFile => _evidenceBeforeFile;
  bool get hasEvidencePhoto => _evidenceBeforeBase64.isNotEmpty;
  bool get isSubmitting => _isSubmitting;
  String? get submitError => _submitError;
  Map<String, dynamic>? get submittedTicket => _submittedTicket;

  List<String> _sanctionOptions = [];
  List<String> get sanctionOptions => _sanctionOptions.isNotEmpty
      ? _sanctionOptions
      : HseEntityType.sanctionOptions(_selectedEntityType);

  Future<void> init() async {
    await Future.wait([
      searchEntities(''),
      loadViolationTypes(),
    ]);
  }

  Future<void> setEntityType(String type) async {
    if (_selectedEntityType == type) return;
    _searchSeq++;
    _selectedEntityType = type;
    _previewEntity = null;
    _lookupError = null;
    _suggestions = [];
    _selectedCategory = null;
    _selectedSanction = null;
    notifyListeners();
    await Future.wait([
      searchEntities(_searchQuery),
      loadViolationTypes(),
    ]);
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
  }

  Future<void> searchEntities(String query) async {
    final seq = ++_searchSeq;
    final reqType = _selectedEntityType;
    _searchQuery = query.trim();
    _isSearching = true;
    _lookupError = null;
    notifyListeners();
    try {
      final results = await _repository.searchEntities(
        reqType,
        _searchQuery,
      );
      if (seq != _searchSeq || reqType != _selectedEntityType) return;
      _suggestions = results;
    } catch (e) {
      if (seq != _searchSeq || reqType != _selectedEntityType) return;
      _suggestions = [];
      _lookupError = e.toString();
    } finally {
      if (seq == _searchSeq && reqType == _selectedEntityType) {
        _isSearching = false;
        notifyListeners();
      }
    }
  }

  Future<void> loadViolationTypes() async {
    _isLoadingCategories = true;
    notifyListeners();
    try {
      final results = await Future.wait([
        _repository.fetchViolationTypes(_selectedEntityType),
        _repository.fetchSanctionTypes(_selectedEntityType),
      ]);
      _violationTypes = results[0] as List<ViolationTypeModel>;
      _sanctionOptions = results[1] as List<String>;
      if (_violationTypes.isNotEmpty) {
        _selectedCategory = _violationTypes.first.categoryName;
      } else {
        _selectedCategory = null;
      }
      final sanctions = sanctionOptions;
      _selectedSanction = sanctions.isNotEmpty ? sanctions.first : null;
    } catch (_) {
      _violationTypes = [];
      _sanctionOptions = [];
    } finally {
      _isLoadingCategories = false;
      notifyListeners();
    }
  }

  Future<bool> lookupAndAdvance(String idOrScanCode) async {
    final targetId = idOrScanCode.trim();
    if (targetId.isEmpty) {
      _lookupError = 'Masukkan ID atau lakukan Scan Barcode terlebih dahulu.';
      notifyListeners();
      return false;
    }

    _isLookingUp = true;
    _lookupError = null;
    notifyListeners();
    try {
      final result =
          await _repository.lookupEntity(_selectedEntityType, targetId);
      _previewEntity = result;
      _currentStep = 1;
      return true;
    } catch (e) {
      _lookupError = e.toString();
      return false;
    } finally {
      _isLookingUp = false;
      notifyListeners();
    }
  }

  void goToStep(int step) {
    if (step < 0 || step > 3) return;
    _currentStep = step;
    _submitError = null;
    notifyListeners();
  }

  void setCategory(String? val) {
    _selectedCategory = val;
    notifyListeners();
  }

  void setSanction(String? val) {
    _selectedSanction = val;
    notifyListeners();
  }

  void setIncidentDate(DateTime dt) {
    _incidentDate = dt;
    notifyListeners();
  }

  void setDueDate(DateTime dt) {
    _dueDate = dt;
    notifyListeners();
  }

  void setDescription(String val) {
    _description = val;
  }

  Future<String?> pickEvidenceBefore(ImageSource source) async {
    try {
      final picked = await _picker.pickImage(
        source: source,
        imageQuality: 75,
        maxWidth: 1280,
      );
      if (picked == null) return null;
      final file = File(picked.path);
      final bytes = await file.readAsBytes();
      _evidenceBeforeFile = file;
      _evidenceBeforeBase64 = base64Encode(bytes);
      _submitError = null;
      notifyListeners();
      return null;
    } catch (e) {
      return 'Gagal mengambil foto: $e';
    }
  }

  void clearEvidencePhoto() {
    _evidenceBeforeFile = null;
    _evidenceBeforeBase64 = '';
    notifyListeners();
  }

  Future<bool> submitFinding() async {
    final target = _previewEntity;
    if (target == null) {
      _submitError = 'Target entitas belum dipilih.';
      notifyListeners();
      return false;
    }
    if ((_selectedCategory ?? '').isEmpty) {
      _submitError = 'Pilih kategori pelanggaran.';
      notifyListeners();
      return false;
    }
    if ((_selectedSanction ?? '').isEmpty) {
      _submitError = 'Pilih tingkat sanksi / tindakan.';
      notifyListeners();
      return false;
    }
    if (_description.trim().isEmpty) {
      _submitError = 'Deskripsi detail pelanggaran wajib diisi.';
      notifyListeners();
      return false;
    }
    if (_evidenceBeforeBase64.isEmpty) {
      _submitError = 'Foto bukti temuan (Evidence Before) wajib dilampirkan.';
      notifyListeners();
      return false;
    }

    _isSubmitting = true;
    _submitError = null;
    notifyListeners();

    try {
      final dfDate = DateFormat('yyyy-MM-dd');
      final dueFormatted = '${dfDate.format(_dueDate)} 17:00:00';
      final payload = FindingSubmissionModel(
        entityType: target.entityType,
        entityId: target.id,
        incidentDate: dfDate.format(_incidentDate),
        violationCategory: _selectedCategory!,
        sanctionLevel: _selectedSanction!,
        description: _description.trim(),
        evidenceBeforeBase64: _evidenceBeforeBase64,
        dueDate: dueFormatted,
        createdBy: username,
      );

      final result = await _repository.createFinding(payload);
      _submittedTicket = result;
      _currentStep = 3;
      return true;
    } catch (e) {
      _submitError = e.toString();
      return false;
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }

  void resetWizard() {
    _currentStep = 0;
    _previewEntity = null;
    _lookupError = null;
    _submitError = null;
    _submittedTicket = null;
    _description = '';
    _evidenceBeforeFile = null;
    _evidenceBeforeBase64 = '';
    _incidentDate = DateTime.now();
    _dueDate = DateTime.now().add(const Duration(days: 3));
    if (_violationTypes.isNotEmpty) {
      _selectedCategory = _violationTypes.first.categoryName;
    }
    final sanctions = sanctionOptions;
    _selectedSanction = sanctions.isNotEmpty ? sanctions.first : null;
    notifyListeners();
    searchEntities(_searchQuery);
  }
}

