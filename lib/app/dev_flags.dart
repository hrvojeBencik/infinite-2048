import 'package:flutter/foundation.dart';

/// Debug-only flags for dev tools. Null in release builds.
final ValueNotifier<bool>? perfOverlayNotifier =
    kDebugMode ? ValueNotifier<bool>(false) : null;
