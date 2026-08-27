// main.dart — Measures Converter
//
// A Flutter application that converts between metric and imperial units
// (distance, weight, volume). Written as a single-file StatefulWidget app for
// clarity — appropriate for the scale of this assignment. Follows Effective
// Dart naming and formatting conventions:
//   https://dart.dev/effective-dart/style
//
// Widget tree overview:
//   MeasuresConverterApp        (StatelessWidget — app-wide config/theme)
//    └─ MaterialApp
//        └─ ConverterHomePage   (StatefulWidget — owns the screen)
//            └─ _ConverterHomePageState.build()
//                └─ Scaffold
//                    ├─ AppBar
//                    └─ Column: Value, From, To, Convert button, result text

import 'package:flutter/material.dart';

// Entry point. Every Dart program starts here.
// runApp() inflates the given widget and attaches it to the screen.
void main() {
  runApp(const MeasuresConverterApp());
}

/// Root widget. Stateless because the app-level configuration (theme, title,
/// home screen) never changes at runtime.
class MeasuresConverterApp extends StatelessWidget {
  // `const` constructor lets Flutter cache and reuse this widget instance —
  // a small but idiomatic performance win recommended by Effective Dart.
  const MeasuresConverterApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Measures Converter',
      // Hide the "DEBUG" ribbon in the top-right corner for a cleaner screenshot.
      debugShowCheckedModeBanner: false,
      // Blue Material theme — matches the AppBar color in the reference image.
      theme: ThemeData(
        primarySwatch: Colors.blue,
        // Use the classic Material look so widgets match the reference exactly.
        useMaterial3: false,
      ),
      home: const ConverterHomePage(),
    );
  }
}

/// The one and only screen. Stateful because the value the user types, the
/// dropdown selections, and the computed result all change over time and must
/// trigger a rebuild whenever they do.
class ConverterHomePage extends StatefulWidget {
  const ConverterHomePage({super.key});

  @override
  State<ConverterHomePage> createState() => _ConverterHomePageState();
}

class _ConverterHomePageState extends State<ConverterHomePage> {
  // ---------------------------------------------------------------------------
  // Static data — declared as `static const` so it lives once, not per-instance.
  // ---------------------------------------------------------------------------

  // The list of units offered in both dropdowns. Order shown to the user =
  // order in this list. Adding a new unit here also requires adding a row and
  // column to _conversionTable below.
  static const List<String> _units = <String>[
    // Distance
    'meters',
    'feet',
    'miles',
    'kilometers',
    // Weight
    'kilograms',
    'pounds',
    // Volume
    'liters',
    'US gallons',
  ];

  // Conversion factors: multiply an amount in the outer key by the inner value
  // to get the amount in the inner key. Nested-map layout is O(1) to look up
  // and cheaper to read than a switch statement with N² branches.
  //
  // Sources for the multipliers (published NIST / SI values):
  //   1 meter    = 3.28084   feet
  //   1 mile     = 1.60934   km
  //   1 kilogram = 2.20462   lb
  //   1 US gallon= 3.78541   L
  //
  // Any (from, to) pair not present in the map is treated as "not supported"
  // (e.g. meters → kilograms is physically meaningless).
  static const Map<String, Map<String, double>> _conversionTable =
      <String, Map<String, double>>{
    // -------- Distance --------
    'meters': <String, double>{
      'meters': 1.0,
      'feet': 3.28084,
      'miles': 0.000621371,
      'kilometers': 0.001,
    },
    'feet': <String, double>{
      'meters': 0.3048,
      'feet': 1.0,
      'miles': 0.000189394,
      'kilometers': 0.0003048,
    },
    'miles': <String, double>{
      'meters': 1609.34,
      'feet': 5280.0,
      'miles': 1.0,
      'kilometers': 1.60934,
    },
    'kilometers': <String, double>{
      'meters': 1000.0,
      'feet': 3280.84,
      'miles': 0.621371,
      'kilometers': 1.0,
    },
    // -------- Weight --------
    'kilograms': <String, double>{
      'kilograms': 1.0,
      'pounds': 2.20462,
    },
    'pounds': <String, double>{
      'kilograms': 0.453592,
      'pounds': 1.0,
    },
    // -------- Volume --------
    'liters': <String, double>{
      'liters': 1.0,
      'US gallons': 0.264172,
    },
    'US gallons': <String, double>{
      'liters': 3.78541,
      'US gallons': 1.0,
    },
  };

  // ---------------------------------------------------------------------------
  // Mutable state — the fields that setState() triggers a rebuild of.
  // ---------------------------------------------------------------------------

  // Controls the text field. Owning the controller (rather than using
  // onChanged) lets us read the current text lazily inside _convert().
  final TextEditingController _valueController = TextEditingController();

  // Selected units, initialized to values that match the reference screenshot.
  String _fromUnit = 'meters';
  String _toUnit = 'feet';

  // The result string shown under the Convert button. Empty until the user
  // taps Convert at least once.
  String _resultMessage = '';

  // Framework hook: release the controller when the widget is removed to
  // avoid a memory leak. Required whenever you create a TextEditingController
  // as a field.
  @override
  void dispose() {
    _valueController.dispose();
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // Business logic
  // ---------------------------------------------------------------------------

  /// Called when the Convert button is tapped. Parses the input, looks up the
  /// conversion factor, and writes the result into _resultMessage inside a
  /// setState() call so the UI rebuilds.
  void _convert() {
    // Read the current text and try to parse it as a double. Using
    // double.tryParse (not parse) means we handle invalid input without
    // throwing — a friendlier user experience.
    final String rawInput = _valueController.text.trim();
    final double? input = double.tryParse(rawInput);

    // Every branch below ends with setState() so the result line updates
    // atomically no matter which path we take.
    setState(() {
      if (input == null) {
        _resultMessage = 'Please enter a valid number.';
        return;
      }

      // Look up the row for the "from" unit, then the specific "to" factor.
      // Both lookups can return null if the pair isn't in _conversionTable,
      // which is how we detect unsupported conversions like meters → kilograms.
      final double? factor = _conversionTable[_fromUnit]?[_toUnit];
      if (factor == null) {
        _resultMessage =
            'This conversion is not supported ($_fromUnit → $_toUnit).';
        return;
      }

      // Do the math.
      final double output = input * factor;

      // Format the result: fixed 3 decimals, then strip trailing zeros so
      // "328.084" renders as-is but "5.000" becomes "5". Matches the format
      // shown in the reference screenshot.
      final String formatted = _stripTrailingZeros(output.toStringAsFixed(3));

      _resultMessage = '$input $_fromUnit are $formatted $_toUnit';
    });
  }

  /// Removes trailing zeros (and a trailing decimal point, if any) from a
  /// number formatted with toStringAsFixed. Kept as a private helper so
  /// _convert() reads top-to-bottom without inline formatting noise.
  static String _stripTrailingZeros(String s) {
    if (!s.contains('.')) return s;
    // Regex: remove trailing zeros, then remove a trailing dot if left over.
    return s.replaceAll(RegExp(r'0+$'), '').replaceAll(RegExp(r'\.$'), '');
  }

  // ---------------------------------------------------------------------------
  // UI
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    // Reusable text style for the three section labels ("Value", "From", "To").
    // Declared once here so any tweak (font size, color) propagates to all
    // three labels — a small application of DRY.
    const TextStyle labelStyle = TextStyle(fontSize: 20.0, color: Colors.grey);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Measures Converter'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        // Scrolls if the on-screen keyboard covers the fields on smaller
        // devices. On the iOS Simulator with a hardware keyboard this is
        // invisible, but it's a defensive-UX habit.
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            // -------- Value section --------
            const SizedBox(height: 8.0),
            const Center(child: Text('Value', style: labelStyle)),
            const SizedBox(height: 8.0),
            TextField(
              controller: _valueController,
              // A numeric keyboard on iOS/Android. Signed + decimal so users
              // can also enter fractional and negative values (e.g. -40°-like
              // scenarios). The Convert action still validates.
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
                signed: true,
              ),
              style: const TextStyle(fontSize: 22.0, color: Colors.blue),
              decoration: const InputDecoration(hintText: '0'),
            ),

            // -------- From section --------
            const SizedBox(height: 24.0),
            const Center(child: Text('From', style: labelStyle)),
            const SizedBox(height: 8.0),
            _buildUnitDropdown(
              currentValue: _fromUnit,
              onChanged: (String? next) {
                if (next == null) return;
                setState(() => _fromUnit = next);
              },
            ),

            // -------- To section --------
            const SizedBox(height: 24.0),
            const Center(child: Text('To', style: labelStyle)),
            const SizedBox(height: 8.0),
            _buildUnitDropdown(
              currentValue: _toUnit,
              onChanged: (String? next) {
                if (next == null) return;
                setState(() => _toUnit = next);
              },
            ),

            // -------- Convert button --------
            const SizedBox(height: 32.0),
            Center(
              child: ElevatedButton(
                onPressed: _convert,
                child: const Text('Convert'),
              ),
            ),

            // -------- Result --------
            const SizedBox(height: 24.0),
            Center(
              child: Text(
                _resultMessage,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 20.0, color: Colors.black87),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Extracted to keep build() readable — the From and To dropdowns are
  /// structurally identical, so building them via one helper avoids duplication.
  Widget _buildUnitDropdown({
    required String currentValue,
    required ValueChanged<String?> onChanged,
  }) {
    return DropdownButton<String>(
      value: currentValue,
      isExpanded: true, // stretches to the column width, matching the mockup
      style: const TextStyle(fontSize: 18.0, color: Colors.blue),
      // Convert the plain string list into a list of DropdownMenuItem widgets.
      items: _units
          .map(
            (String unit) => DropdownMenuItem<String>(
              value: unit,
              child: Text(unit),
            ),
          )
          .toList(),
      onChanged: onChanged,
    );
  }
}
