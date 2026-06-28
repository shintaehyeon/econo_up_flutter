import '../../../core/constants/api_endpoints.dart';
import '../../../core/network/api_client.dart';

class SimulationApi {
  const SimulationApi(this._client);

  final ApiClient _client;

  Future<List<SimulationSummary>> list() async {
    final data = await _client.get<Map<String, dynamic>>(ApiEndpoints.simulations);
    return _asList(data['simulations']).map(SimulationSummary.fromJson).toList();
  }

  Future<SimulationAttempt> start(String simulationId, {bool resume = true}) async {
    final data = await _client.post<Map<String, dynamic>>(
      ApiEndpoints.startSimulation(simulationId),
      body: {'resume': resume},
    );
    return SimulationAttempt.fromJson(data);
  }

  Future<Map<String, dynamic>> submitAnswer({
    required int attemptId,
    required int stepNo,
    required Map<String, dynamic> answer,
  }) {
    return _client.post<Map<String, dynamic>>(
      ApiEndpoints.submitSimulationAnswer(attemptId, stepNo),
      body: {'answer': answer},
    );
  }

  Future<Map<String, dynamic>> complete(int attemptId) {
    return _client.post<Map<String, dynamic>>(ApiEndpoints.completeSimulation(attemptId));
  }

  Future<SimulationStepData> step({
    required int attemptId,
    required int stepNo,
  }) async {
    final data = await _client.get<Map<String, dynamic>>(ApiEndpoints.simulationStep(attemptId, stepNo));
    return SimulationStepData.fromJson(data);
  }
}

class SimulationSummary {
  const SimulationSummary({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.unlocked,
    required this.status,
    required this.unlockStageId,
    required this.totalSteps,
    required this.rewardXp,
    required this.badge,
  });

  factory SimulationSummary.fromJson(Object? value) {
    final json = _asMap(value);
    return SimulationSummary(
      id: _asString(json['simulationId']),
      title: _asString(json['title']),
      description: _asString(json['description']),
      icon: _asString(json['icon'], fallback: '🏠'),
      unlocked: json['unlocked'] == true,
      status: _asString(json['status']),
      unlockStageId: _asInt(json['unlockStageId']),
      totalSteps: _asInt(json['totalSteps']),
      rewardXp: _asInt(json['rewardXp']),
      badge: _asString(json['badge']),
    );
  }

  final String id;
  final String title;
  final String description;
  final String icon;
  final bool unlocked;
  final String status;
  final int unlockStageId;
  final int totalSteps;
  final int rewardXp;
  final String badge;
}

class SimulationAttempt {
  const SimulationAttempt({
    required this.attemptId,
    required this.currentStep,
    required this.totalSteps,
  });

  factory SimulationAttempt.fromJson(Map<String, dynamic> json) {
    final progress = _asMap(json['progress']);
    return SimulationAttempt(
      attemptId: _asInt(json['attemptId']),
      currentStep: _asInt(progress['current'], fallback: 1),
      totalSteps: _asInt(progress['total'], fallback: 5),
    );
  }

  final int attemptId;
  final int currentStep;
  final int totalSteps;
}

class SimulationStepData {
  const SimulationStepData({
    required this.stepNo,
    required this.type,
    required this.title,
    required this.prompt,
    required this.choices,
  });

  factory SimulationStepData.fromJson(Map<String, dynamic> json) {
    final step = _asMap(json['step']);
    final payload = _asMap(step['payload']);
    return SimulationStepData(
      stepNo: _asInt(step['stepNo']),
      type: _asString(step['type']),
      title: _asString(step['title']),
      prompt: _asString(step['prompt']),
      choices: _asList(payload['choices']).map(SimulationChoice.fromJson).where((choice) => choice.id.isNotEmpty).toList(),
    );
  }

  final int stepNo;
  final String type;
  final String title;
  final String prompt;
  final List<SimulationChoice> choices;

  List<String> choiceIdsWhere(bool Function(SimulationChoice choice) test) {
    return choices.where(test).map((choice) => choice.id).toList();
  }
}

class SimulationChoice {
  const SimulationChoice({
    required this.id,
    required this.text,
  });

  factory SimulationChoice.fromJson(Object? value) {
    final json = _asMap(value);
    return SimulationChoice(
      id: _asString(json['id']),
      text: _asString(json['text']),
    );
  }

  final String id;
  final String text;
}

Map<String, dynamic> _asMap(Object? value) {
  if (value is Map<String, dynamic>) return value;
  if (value is Map) return value.map((key, item) => MapEntry('$key', item));
  return <String, dynamic>{};
}

List<dynamic> _asList(Object? value) {
  if (value is List) return value;
  return const [];
}

int _asInt(Object? value, {int fallback = 0}) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse('$value') ?? fallback;
}

String _asString(Object? value, {String fallback = ''}) {
  if (value == null) return fallback;
  final text = '$value';
  return text.isEmpty ? fallback : text;
}
