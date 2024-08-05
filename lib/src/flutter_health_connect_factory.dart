part of flutter_health_connect;

extension _PlatformExceptionExtension on PlatformException {
  ErrorCode get errorCode {
    if (code == 'UNABLE_TO_OPEN_HEALTH_CONNECT_APP') {
      return ErrorCode.unableToOpenHealthConnectApp;
    } else if (code == 'NOT_AVAILABLE') {
      return ErrorCode.notAvailable;
    } else if (code == 'MISSING_PERMISSIONS') {
      return ErrorCode.missingPermissions;
    } else if (code == 'UNKNOWN') {
      return ErrorCode.unknown;
    } else {
      return ErrorCode.unknown;
    }
  }
}

class HealthConnectFactory {
  static const MethodChannel _channel = MethodChannel('flutter_health_connect');

  static Future<bool> checkIfSupported() async {
    return await _channel.invokeMethod('checkIfSupported') as bool;
  }

  static Future<bool> checkIfHealthConnectAppInstalled() async {
    return await _channel.invokeMethod('checkIfHealthConnectAppInstalled') as bool;
  }

  static Future<void> installHealthConnect() async {
    await _channel.invokeMethod('installHealthConnect');
  }

  static Future<bool> openHealthConnectSettings() async {
    final bool isHealthConnectAppInstalled = await checkIfHealthConnectAppInstalled();
    if (!isHealthConnectAppInstalled) {
      throw const FlutterHealthConnectException(
        code: ErrorCode.unableToOpenHealthConnectApp,
        message: 'The Health Connect app is not installed, please install it first.',
      );
    }
    try {
      return await _channel.invokeMethod('openHealthConnectSettings') as bool;
    } on PlatformException catch (e, stackTrace) {
      final String errorMessage = e.errorCode == ErrorCode.unableToOpenHealthConnectApp
          ? 'The Health Connect app is not installed, please install it first.\n$e'
          : e.toString();
      throw FlutterHealthConnectException(
        code: e.errorCode,
        message: errorMessage,
        details: e.details,
        stackTrace: stackTrace,
      );
    }
  }

  static Future<bool> checkPermissions(
    List<HealthConnectDataType> types, {
    bool readOnly = false,
  }) async {
    try {
      return await _channel.invokeMethod(
        'checkPermissions',
        {
          'types': types.map((e) => e.name).toList(),
          'readOnly': readOnly,
        },
      ) as bool;
    } on PlatformException catch (e, stackTrace) {
      throw FlutterHealthConnectException(
        code: e.errorCode,
        message: e.toString(),
        details: e.details,
        stackTrace: stackTrace,
      );
    }
  }

  static Future<bool> requestPermissions(
    List<HealthConnectDataType> types, {
    bool readOnly = false,
  }) async {
    try {
      return await _channel.invokeMethod(
        'requestPermissions',
        {
          'types': types.map((e) => e.name).toList(),
          'readOnly': readOnly,
        },
      ) as bool;
    } on PlatformException catch (e, stackTrace) {
      throw FlutterHealthConnectException(
        code: e.errorCode,
        message: e.toString(),
        details: e.details,
        stackTrace: stackTrace,
      );
    }
  }

  static Future<String> getChangesToken(List<HealthConnectDataType> types) async {
    try {
      return await _channel.invokeMethod(
        'getChangesToken',
        {
          'types': types.map((e) => e.name).toList(),
        },
      ) as String;
    } on PlatformException catch (e, stackTrace) {
      throw FlutterHealthConnectException(
        code: e.errorCode,
        message: e.toString(),
        details: e.details,
        stackTrace: stackTrace,
      );
    }
  }

  static Future<Map<String, dynamic>> getChanges(String token) async {
    try {
      return await _channel.invokeMethod(
        'getChanges',
        {
          'token': token,
        },
      ).then(
        (value) => Map<String, Object>.from(value),
      );
    } on PlatformException catch (e, stackTrace) {
      throw FlutterHealthConnectException(
        code: e.errorCode,
        message: e.toString(),
        details: e.details,
        stackTrace: stackTrace,
      );
    }
  }

  static Future<List<dynamic>> getRecords({
    required DateTime startTime,
    required DateTime endTime,
    required HealthConnectDataType type,
    int? pageSize,
    String? pageToken,
    bool ascendingOrder = true,
  }) async {
    final start = startTime.toUtc().toIso8601String();
    final end = endTime.toUtc().toIso8601String();
    final args = <String, dynamic>{
      'type': type.name,
      'startTime': start,
      'endTime': end,
      'pageSize': pageSize,
      'pageToken': pageToken,
      'ascendingOrder': ascendingOrder,
    };
    try {
      final List<dynamic>? data = await _channel.invokeMethod('getRecords', args);
      if (data != null && data.isNotEmpty) {
        final List<dynamic> records = data.map((e) => mapToRecord(type, Map<String, dynamic>.from(e))).toList();
        return records;
      } else {
        return [];
      }
    } on PlatformException catch (e, stackTrace) {
      throw FlutterHealthConnectException(
        code: e.errorCode,
        message: e.toString(),
        details: e.details,
        stackTrace: stackTrace,
      );
    }
  }

  static Future<bool> writeData({
    required HealthConnectDataType type,
    required List<Record> data,
  }) async {
    final args = <String, dynamic>{
      'type': type.name,
      'data': List<Map<String, dynamic>>.from(data.map((Record e) => e.toMap())),
    };
    try {
      return await _channel.invokeMethod('writeData', args);
    } on PlatformException catch (e, stackTrace) {
      throw FlutterHealthConnectException(
        code: e.errorCode,
        message: e.toString(),
        details: e.details,
        stackTrace: stackTrace,
      );
    }
  }

  static Future<bool> deleteRecordsByIds({
    required HealthConnectDataType type,
    List<String> idList = const [],
    List<String> clientRecordIdsList = const [],
  }) async {
    final args = <String, dynamic>{
      'type': type.name,
      'idList': idList,
      'clientRecordIdsList': clientRecordIdsList,
    };
    try {
      return await _channel.invokeMethod('deleteRecordsByIds', args);
    } on PlatformException catch (e, stackTrace) {
      throw FlutterHealthConnectException(
        code: e.errorCode,
        message: e.toString(),
        details: e.details,
        stackTrace: stackTrace,
      );
    }
  }

  static Future<bool> deleteRecordsByTime({
    required HealthConnectDataType type,
    required DateTime startTime,
    required DateTime endTime,
  }) async {
    final start = startTime.toUtc().toIso8601String();
    final end = endTime.toUtc().toIso8601String();
    final args = <String, dynamic>{
      'type': type.name,
      'startTime': start,
      'endTime': end,
    };
    try {
      return await _channel.invokeMethod('deleteRecordsByTime', args);
    } on PlatformException catch (e, stackTrace) {
      throw FlutterHealthConnectException(
        code: e.errorCode,
        message: e.toString(),
        details: e.details,
        stackTrace: stackTrace,
      );
    }
  }

  /// Get statistics by aggregating data.
  /// This can, for example, give you the total steps count over the last 7 days, or the average heart rate over the last month.
  ///
  /// You need the corresponding permission to get statistic for a given type. See [requestPermissions].
  ///
  /// [aggregationKeys] is a list of all the metrics you want to get statistics about. These keys can be found in
  /// their corresponding records, like [StepsRecord.aggregationKeyCountTotal].
  ///
  /// This function returns a map with the [aggregationKeys] as keys and the associated results as values. All values are
  /// doubles, look at the aggregationKey description to read more about the units.
  ///
  /// This function calls the "aggregate" function of the Health Connect SDK on Android. See:
  /// https://developer.android.com/health-and-fitness/guides/health-connect/common-workflows/aggregate-data
  /// NOTE: This does not support Bucket aggregation, only Basic aggregation.
  ///
  /// Example:
  ///  var result = await HealthConnectFactory.aggregate(
  ///     aggregationKeys: [
  ///       StepsRecord.aggregationKeyCountTotal,
  ///       ExerciseSessionRecord.aggregationKeyExerciseDurationTotal,
  ///     ],
  ///     startTime: DateTime.now().subtract(const Duration(days: 1)),
  ///     endTime: DateTime.now(),
  ///   );
  ///
  ///  // Statics over the last 24 hours:
  ///  var stepsCountTotal = result[StepsRecord.aggregationKeyCountTotal];
  ///  var exerciseDurationTotal = result[ExerciseSessionRecord.aggregationKeyExerciseDurationTotal];
  ///
  static Future<Map<String, double>> aggregate({
    required List<String> aggregationKeys,
    required DateTime startTime,
    required DateTime endTime,
  }) async {
    if (aggregationKeys.isEmpty) {
      return {};
    }
    final start = startTime.toUtc().toIso8601String();
    final end = endTime.toUtc().toIso8601String();
    final args = <String, dynamic>{
      'aggregationKeys': aggregationKeys,
      'startTime': start,
      'endTime': end,
    };

    try {
      return await _channel.invokeMethod('aggregate', args).then((value) => Map<String, double>.from(value));
    } on PlatformException catch (e, stackTrace) {
      throw FlutterHealthConnectException(
        code: e.errorCode,
        message: e.toString(),
        details: e.details,
        stackTrace: stackTrace,
      );
    }
  }

  static Future<dynamic> getRecordById({
    required String id,
    required HealthConnectDataType type,
  }) async {
    final args = <String, dynamic>{
      'type': type.name,
      'id': id,
    };
    final Map<dynamic, dynamic>? data =
        await _channel.invokeMethod('getRecordById', args);
    if (data != null && data.isNotEmpty) {
      return mapToRecord(type, Map<String, dynamic>.from(data));
    } else {
      return null;
    }
  }

  static dynamic mapToRecord(HealthConnectDataType type, Map<String, dynamic> map) {
    switch (type) {
      case HealthConnectDataType.ActiveCaloriesBurned:
        return ActiveCaloriesBurnedRecord.fromMap(map);
      case HealthConnectDataType.BasalBodyTemperature:
        return BasalBodyTemperatureRecord.fromMap(map);
      case HealthConnectDataType.BasalMetabolicRate:
        return BasalMetabolicRateRecord.fromMap(map);
      case HealthConnectDataType.BloodGlucose:
        return BloodGlucoseRecord.fromMap(map);
      case HealthConnectDataType.BloodPressure:
        return BloodPressureRecord.fromMap(map);
      case HealthConnectDataType.BodyFat:
        return BodyFatRecord.fromMap(map);
      case HealthConnectDataType.BodyTemperature:
        return BodyTemperatureRecord.fromMap(map);
      case HealthConnectDataType.BodyWaterMass:
        return BodyWaterMassRecord.fromMap(map);
      case HealthConnectDataType.BoneMass:
        return BoneMassRecord.fromMap(map);
      case HealthConnectDataType.CervicalMucus:
        return CervicalMucusRecord.fromMap(map);
      case HealthConnectDataType.CyclingPedalingCadence:
        return CyclingPedalingCadenceRecord.fromMap(map);
      case HealthConnectDataType.Distance:
        return DistanceRecord.fromMap(map);
      case HealthConnectDataType.ElevationGained:
        return ElevationGainedRecord.fromMap(map);
      case HealthConnectDataType.ExerciseSession:
        return ExerciseSessionRecord.fromMap(map);
      case HealthConnectDataType.FloorsClimbed:
        return FloorsClimbedRecord.fromMap(map);
      case HealthConnectDataType.HeartRate:
        return HeartRateRecord.fromMap(map);
      case HealthConnectDataType.HeartRateVariabilityRmssd:
        return HeartRateVariabilityRmssdRecord.fromMap(map);
      case HealthConnectDataType.Height:
        return HeightRecord.fromMap(map);
      case HealthConnectDataType.Hydration:
        return HydrationRecord.fromMap(map);
      case HealthConnectDataType.IntermenstrualBleeding:
        return IntermenstrualBleedingRecord.fromMap(map);
      case HealthConnectDataType.LeanBodyMass:
        return LeanBodyMassRecord.fromMap(map);
      case HealthConnectDataType.MenstruationFlow:
        return MenstruationFlowRecord.fromMap(map);
      case HealthConnectDataType.MenstruationPeriod:
        return MenstruationPeriodRecord.fromMap(map);
      case HealthConnectDataType.Nutrition:
        return NutritionRecord.fromMap(map);
      case HealthConnectDataType.OvulationTest:
        return OvulationTestRecord.fromMap(map);
      case HealthConnectDataType.OxygenSaturation:
        return OxygenSaturationRecord.fromMap(map);
      case HealthConnectDataType.Power:
        return PowerRecord.fromMap(map);
      case HealthConnectDataType.RespiratoryRate:
        return RespiratoryRateRecord.fromMap(map);
      case HealthConnectDataType.RestingHeartRate:
        return RestingHeartRateRecord.fromMap(map);
      case HealthConnectDataType.SexualActivity:
        return SexualActivityRecord.fromMap(map);
      case HealthConnectDataType.SleepSession:
        return SleepSessionRecord.fromMap(map);
      case HealthConnectDataType.Speed:
        return SpeedRecord.fromMap(map);
      case HealthConnectDataType.StepsCadence:
        return StepsCadenceRecord.fromMap(map);
      case HealthConnectDataType.Steps:
        return StepsRecord.fromMap(map);
      case HealthConnectDataType.TotalCaloriesBurned:
        return TotalCaloriesBurnedRecord.fromMap(map);
      case HealthConnectDataType.Vo2Max:
        return Vo2MaxRecord.fromMap(map);
      case HealthConnectDataType.Weight:
        return WeightRecord.fromMap(map);
      case HealthConnectDataType.WheelchairPushes:
        return WheelchairPushesRecord.fromMap(map);
    }
  }
}
