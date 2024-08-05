import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_health_connect/flutter_health_connect.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  /// NOTE: [_checkIfShouldShowPrivacyPolicyChannel] needs to match the CHANNEL name defined in android/app/src/main/kotlin/dev/duynp/flutter_health_connect_example/MainActivity.kt
  static const String _checkIfShouldShowPrivacyPolicyChannel = 'app.channel.flutter.health.connect.show.privacy.policy';

  /// NOTE: [_checkIfShouldShowPrivacyPolicyFunction] needs to match the FUNCTION name defined in android/app/src/main/kotlin/dev/duynp/flutter_health_connect_example/MainActivity.kt
  static const String _checkIfShouldShowPrivacyPolicyFunction = 'checkIfShouldShowPrivacyPolicy';
  static const MethodChannel platform = MethodChannel(_checkIfShouldShowPrivacyPolicyChannel);

  static const String _privacyPolicy = 'You asked to see our privacy policy.\n\n'
      'I would show it to you, but we both know these are always written in such a way that only lawyers can both read and understand them fully (at the cost of their sanity).\n\n'
      'Just accept it, and pray we somewhat have your best interest at heart.';

  // List<HealthConnectDataType> types = [
  //   HealthConnectDataType.ActiveCaloriesBurned,
  //   HealthConnectDataType.BasalBodyTemperature,
  //   HealthConnectDataType.BasalMetabolicRate,
  //   HealthConnectDataType.BloodGlucose,
  //   HealthConnectDataType.BloodPressure,
  //   HealthConnectDataType.BodyFat,
  //   HealthConnectDataType.BodyTemperature,
  //   HealthConnectDataType.BodyWaterMass,
  //   HealthConnectDataType.BoneMass,
  //   HealthConnectDataType.CervicalMucus,
  //   HealthConnectDataType.CyclingPedalingCadence,
  //   HealthConnectDataType.Distance,
  //   HealthConnectDataType.ElevationGained,
  //   HealthConnectDataType.ExerciseSession,
  //   HealthConnectDataType.FloorsClimbed,
  //   HealthConnectDataType.HeartRate,
  //   HealthConnectDataType.HeartRateVariabilityRmssd,
  //   HealthConnectDataType.Height,
  //   HealthConnectDataType.Hydration,
  //   HealthConnectDataType.IntermenstrualBleeding,
  //   HealthConnectDataType.LeanBodyMass,
  //   HealthConnectDataType.MenstruationFlow,
  //   HealthConnectDataType.Nutrition,
  //   HealthConnectDataType.OvulationTest,
  //   HealthConnectDataType.OxygenSaturation,
  //   HealthConnectDataType.Power,
  //   HealthConnectDataType.RespiratoryRate,
  //   HealthConnectDataType.RestingHeartRate,
  //   HealthConnectDataType.SexualActivity,
  //   HealthConnectDataType.SleepSession,
  //   HealthConnectDataType.Speed,
  //   HealthConnectDataType.StepsCadence,
  //   HealthConnectDataType.Steps,
  //   HealthConnectDataType.TotalCaloriesBurned,
  //   HealthConnectDataType.Vo2Max,
  //   HealthConnectDataType.Weight,
  //   HealthConnectDataType.WheelchairPushes,
  // ];

  final List<HealthConnectDataType> _types = [
    HealthConnectDataType.Steps,
    HealthConnectDataType.ExerciseSession,
    // HealthConnectDataType.HeartRate,
    // HealthConnectDataType.SleepSession,
    // HealthConnectDataType.OxygenSaturation,
    // HealthConnectDataType.RespiratoryRate,
  ];

  final bool _isReadOnly = true;

  String _resultText = '';
  String _token = '';

  @override
  void initState() {
    super.initState();

    /// If your application's android:launchMode is set to "standard" or "singleTop" in your AndroidManifest then initState
    /// will be called when the user taps the "privacy policy" in Google Health's permission dialog.
    /// If it is instead set to "singleTask" or "singleInstance" or "singleInstancePerTask" then initState will NOT be called.
    /// See [_onRequestPermissionsButtonTap] for more info.
    _checkIfShouldShowPrivacyPolicy().then(
      (shouldShowPrivacyPolicy) {
        if (shouldShowPrivacyPolicy) {
          _updateResultText(_privacyPolicy);
        }
      },
    );
  }

  Future<bool> _checkIfShouldShowPrivacyPolicy() async =>
      await platform.invokeMethod(_checkIfShouldShowPrivacyPolicyFunction) as bool;

  void _updateResultText(String newText) {
    if (context.mounted) {
      setState(() => _resultText = newText);
    }
  }

  void _onCheckIfSupportedButtonTap() async {
    try {
      final bool checkIfSupported = await HealthConnectFactory.checkIfSupported();
      _updateResultText('checkIfSupported: $checkIfSupported');
    } catch (e, stackTrace) {
      final String errorMessage = '$e,\n$stackTrace';
      debugPrint(errorMessage);
      _updateResultText(errorMessage);
    }
  }

  void _onCheckIfHealthConnectAppInstalledButtonTap() async {
    try {
      final bool checkIfHealthConnectAppInstalled = await HealthConnectFactory.checkIfHealthConnectAppInstalled();
      _updateResultText('checkIfHealthConnectAppInstalled: $checkIfHealthConnectAppInstalled');
    } catch (e, stackTrace) {
      final String errorMessage = '$e,\n$stackTrace';
      debugPrint(errorMessage);
      _updateResultText(errorMessage);
    }
  }

  void _onInstallHealthConnectButtonTap() async {
    try {
      await HealthConnectFactory.installHealthConnect();
      _updateResultText('Install activity started');
    } catch (e, stackTrace) {
      final String errorMessage = '$e,\n$stackTrace';
      debugPrint(errorMessage);
      _updateResultText(errorMessage);
    }
  }

  void _onOpenHealthConnectSettingsButtonTap() async {
    try {
      await HealthConnectFactory.openHealthConnectSettings();
      _updateResultText('Settings activity started');
    } catch (e, stackTrace) {
      final String errorMessage = '$e,\n$stackTrace';
      debugPrint(errorMessage);
      _updateResultText(errorMessage);
    }
  }

  void _onCheckPermissionsButtonTap() async {
    try {
      final bool hasPermissions = await HealthConnectFactory.checkPermissions(
        _types,
        readOnly: _isReadOnly,
      );
      _updateResultText('hasPermissions: $hasPermissions');
    } catch (e, stackTrace) {
      final String errorMessage = '$e,\n$stackTrace';
      debugPrint(errorMessage);
      _updateResultText(errorMessage);
    }
  }

  void _onGetChangesTokenButtonTap() async {
    try {
      _token = await HealthConnectFactory.getChangesToken(_types);
      _updateResultText('Changes token: $_token');
    } catch (e, stackTrace) {
      final String errorMessage = '$e,\n$stackTrace';
      debugPrint(errorMessage);
      _updateResultText(errorMessage);
    }
  }

  void _onGetChangesButtonTap() async {
    try {
      if (_token.isEmpty) {
        _updateResultText('Changes: Before getting the changes you need to generate the changes token.');
        return;
      }

      final Map<String, dynamic> changes = await HealthConnectFactory.getChanges(_token);
      _updateResultText('Changes: $changes');
    } catch (e, stackTrace) {
      final String errorMessage = '$e,\n$stackTrace';
      debugPrint(errorMessage);
      _updateResultText(errorMessage);
    }
  }

  void _onRequestPermissionsButtonTap() async {
    try {
      final bool hasPermissions = await HealthConnectFactory.requestPermissions(
        _types,
        readOnly: _isReadOnly,
      );

      /// If your application's android:launchMode is set to "singleTask" or "singleInstance" or
      /// "singleInstancePerTask" in your AndroidManifest then the app will continue executing the code
      /// from here when the user taps the "privacy policy" button in Google Health's permission dialog.
      /// If it is instead set to "standard" or "singleTop" then the code under will NOT be called, and initState
      /// will be called instead.
      final bool shouldShowPrivacyPolicy = await _checkIfShouldShowPrivacyPolicy();
      if (shouldShowPrivacyPolicy) {
        _updateResultText(_privacyPolicy);
      } else {
        _updateResultText('Has permissions: $hasPermissions');
      }
    } catch (e, stackTrace) {
      final String errorMessage = '$e,\n$stackTrace';
      debugPrint(errorMessage);
      _updateResultText(errorMessage);
    }
  }

  void _onGetRecordsButtonTap() async {
    try {
      final DateTime startTime = DateTime.now().subtract(const Duration(days: 4));
      final DateTime endTime = DateTime.now();
      final List<Future<dynamic>> requests = [];
      final Map<String, dynamic> typePoints = {};
      for (final HealthConnectDataType type in _types) {
        requests.add(
          HealthConnectFactory.getRecords(
            type: type,
            startTime: startTime,
            endTime: endTime,
          ).then(
            (value) => typePoints.addAll({type.name: value}),
          ),
        );
      }
      await Future.wait(requests);
      _updateResultText('$typePoints');
    } catch (e, stackTrace) {
      final String errorMessage = '$e,\n$stackTrace';
      debugPrint(errorMessage);
      _updateResultText(errorMessage);
    }
  }

  void _onSendRecordsButtonTap() async {
    try {
      final DateTime startTime = DateTime.now().subtract(const Duration(seconds: 5));
      final DateTime endTime = DateTime.now();
      final StepsRecord stepsRecord = StepsRecord(
        startTime: startTime,
        endTime: endTime,
        count: 5,
      );
      final ExerciseSessionRecord exerciseSessionRecord = ExerciseSessionRecord(
        startTime: startTime,
        endTime: endTime,
        exerciseType: ExerciseType.walking,
      );
      final List<Future<dynamic>> requests = [];
      final Map<String, dynamic> typePoints = {};

      requests.add(HealthConnectFactory.writeData(
        type: HealthConnectDataType.Steps,
        data: [stepsRecord],
      ).then((value) => typePoints.addAll({HealthConnectDataType.Steps.name: stepsRecord})));

      requests.add(HealthConnectFactory.writeData(
        type: HealthConnectDataType.ExerciseSession,
        data: [exerciseSessionRecord],
      ).then((value) => typePoints.addAll({HealthConnectDataType.ExerciseSession.name: exerciseSessionRecord})));

      await Future.wait(requests);

      _updateResultText('$typePoints');
    } catch (e, stackTrace) {
      final String errorMessage = '$e,\n$stackTrace';
      debugPrint(errorMessage);
      _updateResultText(errorMessage);
    }
  }

  void _onGetAggregatedDataButtonTap() async {
    try {
      final DateTime startTime = DateTime.now().subtract(const Duration(days: 1));
      final DateTime endTime = DateTime.now();
      final Map<String, double> result = await HealthConnectFactory.aggregate(
        aggregationKeys: [
          StepsRecord.aggregationKeyCountTotal,
          ExerciseSessionRecord.aggregationKeyExerciseDurationTotal,
        ],
        startTime: startTime,
        endTime: endTime,
      );
      _updateResultText('$result');
    } catch (e, stackTrace) {
      final String errorMessage = '$e,\n$stackTrace';
      debugPrint(errorMessage);
      _updateResultText(errorMessage);
    }
  }

  @override
  Widget build(BuildContext context) => MaterialApp(
        home: Scaffold(
          appBar: AppBar(
            title: const Text('Health Connect'),
          ),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              ElevatedButton(
                onPressed: () => _onCheckIfSupportedButtonTap(),
                child: const Text('Check if Api is supported'),
              ),
              ElevatedButton(
                onPressed: () => _onCheckIfHealthConnectAppInstalledButtonTap(),
                child: const Text('Check if Google Health Connect app is installed'),
              ),
              ElevatedButton(
                onPressed: () => _onInstallHealthConnectButtonTap(),
                child: const Text('Install Health Connect'),
              ),
              ElevatedButton(
                onPressed: () => _onOpenHealthConnectSettingsButtonTap(),
                child: const Text('Open Health Connect Settings'),
              ),
              ElevatedButton(
                onPressed: () async => _onCheckPermissionsButtonTap(),
                child: const Text('Check if permissions are granted'),
              ),
              ElevatedButton(
                onPressed: () => _onGetChangesTokenButtonTap(),
                child: const Text('Get Changes Token'),
              ),
              ElevatedButton(
                onPressed: () => _onGetChangesButtonTap(),
                child: const Text('Get Changes'),
              ),
              ElevatedButton(
                onPressed: () => _onRequestPermissionsButtonTap(),
                child: const Text('Request Permissions'),
              ),
              ElevatedButton(
                onPressed: () => _onGetRecordsButtonTap(),
                child: const Text('Get Records'),
              ),
              ElevatedButton(
                onPressed: () => _onSendRecordsButtonTap(),
                child: const Text('Send Records'),
              ),
              ElevatedButton(
                onPressed: () => _onGetAggregatedDataButtonTap(),
                child: const Text('Get aggregated data'),
              ),
              Text(_resultText),
            ],
          ),
        ),
      );
}
