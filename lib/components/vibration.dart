import 'dart:io';

import 'package:flutter/services.dart';
import 'package:vibration/vibration.dart';

Future<void> handleVibration() async {
  if (Platform.isAndroid) {
    if (await Vibration.hasVibrator() ?? false) {
      Vibration.vibrate(duration: 100);
    }
  } else if (Platform.isIOS) {
    HapticFeedback.mediumImpact();
  }
}
