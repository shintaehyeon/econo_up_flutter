import '../../../core/constants/api_endpoints.dart';
import '../../../core/network/api_client.dart';

class CurriculumApi {
  CurriculumApi(this._client);

  final ApiClient _client;

  Future<CategoriesResult> categories() async {
    final data = await _client.get<Map<String, dynamic>>(ApiEndpoints.categories);
    return CategoriesResult.fromJson(data);
  }

  Future<RoadmapResult> roadmap(String categoryCode) async {
    final data = await _client.get<Map<String, dynamic>>(ApiEndpoints.categoryRoadmap(categoryCode));
    return RoadmapResult.fromJson(data);
  }

  Future<StageMapResult> stageMap({required int unitId, required int stageId}) async {
    final data = await _client.get<Map<String, dynamic>>(ApiEndpoints.stageMap(unitId, stageId));
    return StageMapResult.fromJson(data);
  }
}

class CategoriesResult {
  const CategoriesResult({required this.categories});

  final List<CurriculumCategory> categories;

  factory CategoriesResult.fromJson(Map<String, dynamic> json) {
    return CategoriesResult(
      categories: _asList(json['categories']).map(CurriculumCategory.fromJson).toList(),
    );
  }
}

class CurriculumCategory {
  const CurriculumCategory({
    required this.code,
    required this.name,
    required this.description,
    required this.accessType,
    required this.progressPercent,
  });

  final String code;
  final String name;
  final String description;
  final String accessType;
  final int progressPercent;

  factory CurriculumCategory.fromJson(Object? value) {
    final json = _asMap(value);
    return CurriculumCategory(
      code: '${json['code'] ?? ''}',
      name: '${json['name'] ?? ''}',
      description: '${json['description'] ?? ''}',
      accessType: '${json['accessType'] ?? 'FREE'}',
      progressPercent: _asInt(json['progressPercent']),
    );
  }
}

class RoadmapResult {
  const RoadmapResult({
    required this.category,
    required this.summary,
    required this.units,
  });

  final CurriculumCategorySummary category;
  final RoadmapSummary summary;
  final List<CurriculumUnit> units;

  factory RoadmapResult.fromJson(Map<String, dynamic> json) {
    return RoadmapResult(
      category: CurriculumCategorySummary.fromJson(json['category']),
      summary: RoadmapSummary.fromJson(json['roadmap']),
      units: _asList(json['units']).map(CurriculumUnit.fromJson).toList(),
    );
  }
}

class CurriculumCategorySummary {
  const CurriculumCategorySummary({
    required this.code,
    required this.name,
    required this.subtitle,
    required this.accessType,
  });

  final String code;
  final String name;
  final String subtitle;
  final String accessType;

  factory CurriculumCategorySummary.fromJson(Object? value) {
    final json = _asMap(value);
    return CurriculumCategorySummary(
      code: '${json['code'] ?? ''}',
      name: '${json['name'] ?? ''}',
      subtitle: '${json['subtitle'] ?? ''}',
      accessType: '${json['accessType'] ?? 'FREE'}',
    );
  }
}

class RoadmapSummary {
  const RoadmapSummary({
    required this.completedUnitCount,
    required this.totalUnitCount,
    required this.progressPercent,
  });

  final int completedUnitCount;
  final int totalUnitCount;
  final int progressPercent;

  factory RoadmapSummary.fromJson(Object? value) {
    final json = _asMap(value);
    return RoadmapSummary(
      completedUnitCount: _asInt(json['completedUnitCount']),
      totalUnitCount: _asInt(json['totalUnitCount']),
      progressPercent: _asInt(json['progressPercent']),
    );
  }
}

class CurriculumUnit {
  const CurriculumUnit({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.status,
    required this.progressPercent,
    required this.stages,
  });

  final int id;
  final String title;
  final String subtitle;
  final String status;
  final int progressPercent;
  final List<CurriculumStage> stages;

  factory CurriculumUnit.fromJson(Object? value) {
    final json = _asMap(value);
    final stages = _asList(json['stages']).map(CurriculumStage.fromJson).toList();
    final stagePreview = _asList(json['stagePreview']);
    return CurriculumUnit(
      id: _asInt(json['id']),
      title: '${json['title'] ?? ''}',
      subtitle: '${json['subtitle'] ?? ''}',
      status: '${json['status'] ?? 'AVAILABLE'}',
      progressPercent: _asInt(json['progressPercent']),
      stages: stages.isNotEmpty
          ? stages
          : List.generate(stagePreview.length, (index) {
              return CurriculumStage(
                id: index + 1,
                title: '${stagePreview[index]}',
                status: 'AVAILABLE',
                progressPercent: 0,
              );
            }),
    );
  }
}

class CurriculumStage {
  const CurriculumStage({
    required this.id,
    required this.title,
    required this.status,
    required this.progressPercent,
  });

  final int id;
  final String title;
  final String status;
  final int progressPercent;

  bool get isCompleted => status == 'COMPLETED';
  bool get isLocked => status == 'LOCKED';

  factory CurriculumStage.fromJson(Object? value) {
    final json = _asMap(value);
    return CurriculumStage(
      id: _asInt(json['id']),
      title: '${json['title'] ?? ''}',
      status: '${json['status'] ?? 'AVAILABLE'}',
      progressPercent: _asInt(json['progressPercent']),
    );
  }
}

class StageMapResult {
  const StageMapResult({
    required this.unit,
    required this.stage,
    required this.sessions,
    required this.simulationCta,
  });

  final Map<String, dynamic> unit;
  final Map<String, dynamic> stage;
  final List<CurriculumSession> sessions;
  final Map<String, dynamic> simulationCta;

  factory StageMapResult.fromJson(Map<String, dynamic> json) {
    return StageMapResult(
      unit: _asMap(json['unit']),
      stage: _asMap(json['stage']),
      sessions: _asList(json['sessions']).map(CurriculumSession.fromJson).toList(),
      simulationCta: _asMap(json['simulationCta']),
    );
  }
}

class CurriculumSession {
  const CurriculumSession({
    required this.id,
    required this.code,
    required this.type,
    required this.title,
    required this.status,
  });

  final int id;
  final String code;
  final String type;
  final String title;
  final String status;

  factory CurriculumSession.fromJson(Object? value) {
    final json = _asMap(value);
    return CurriculumSession(
      id: _asInt(json['id']),
      code: '${json['code'] ?? ''}',
      type: '${json['type'] ?? 'QUIZ'}',
      title: '${json['title'] ?? ''}',
      status: '${json['status'] ?? 'AVAILABLE'}',
    );
  }
}

int _asInt(Object? value, {int fallback = 0}) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse('$value') ?? fallback;
}

Map<String, dynamic> _asMap(Object? value) {
  if (value is Map<String, dynamic>) return value;
  if (value is Map) return Map<String, dynamic>.from(value);
  return <String, dynamic>{};
}

List<Object?> _asList(Object? value) {
  if (value is List) return value;
  return const [];
}