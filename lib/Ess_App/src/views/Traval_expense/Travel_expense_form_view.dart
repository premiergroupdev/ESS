// lib/Ess_App/src/views/travel_expense/travel_expense_form_view.dart
//
// Adjust the import paths below to match your actual project structure —
// they're written to line up with the api_service.dart you shared
// (…/src/services/remote/api_service.dart, …/src/models/api_response_models/…).
//
// Requires the `intl` and `file_picker` packages, plus the
// google_places_service.dart file (Places Autocomplete + Distance Matrix).

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../../models/api_form_data_models/Travel_expense_form_model.dart';
import '../../services/remote/api_service.dart';
import '../../services/remote/google_places_services.dart';

// ---- Design tokens -------------------------------------------------------
const Color _kPrimary = Color(0xFF1B4F8C);
const Color _kPrimaryLight = Color(0xFFEAF1FA);
const Color _kBg = Color(0xFFF4F6F9);
const Color _kBorder = Color(0xFFE1E5EA);
const double _kGap = 14;
const double _kCardRadius = 10;
// ---------------------------------------------------------------------------

class TravelExpenseFormView extends StatefulWidget {
  const TravelExpenseFormView({Key? key}) : super(key: key);

  @override
  State<TravelExpenseFormView> createState() => _TravelExpenseFormViewState();
}

class _TravelExpenseFormViewState extends State<TravelExpenseFormView> {
  final ApiService _apiService = ApiService();
  final GooglePlacesService _placesService = GooglePlacesService();

  bool _loading = true;
  String? _errorMessage;
  TravelFormData? _entitlements;

  final TextEditingController _reasonController = TextEditingController();
  String? _selectedMonth;

  bool _submitting = false;

  // --- Travel type lock -----------------------------------------------
  // Once a value is picked, _travelTypeLocked flips true and stays true.
  // The dropdown's onChanged becomes null while locked, so it can't be
  // reopened/changed until this screen is rebuilt from scratch (i.e. the
  // form is reloaded / re-navigated to).
  String? _travelType;
  bool _travelTypeLocked = false;
  // ----------------------------------------------------------------------

  final List<_TravelEntry> _entries = [];

  final TextEditingController _totalKmController = TextEditingController();
  final TextEditingController _totalRsController = TextEditingController();
  final TextEditingController _totalLitersController = TextEditingController();
  final TextEditingController _totalDaController = TextEditingController();
  final TextEditingController _commentsController = TextEditingController();

  PlatformFile? _attachedFile;

  static const List<String> _months = [
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December',
  ];

  final DateFormat _dateTimeFmt = DateFormat('dd MMM yyyy, hh:mm a');

  @override
  void initState() {
    super.initState();
    _fetchEntitlements();
    _addEntry(); // start with one entry row like the web form
  }

  Future<void> _fetchEntitlements() async {
    setState(() {
      _loading = true;
      _errorMessage = null;
    });

    final result = await _apiService.getTravelForm(context);

    result.when(
      success: (model) {
        setState(() {
          _entitlements = model.data;
          _loading = false;
        });
        _recalculateTotals();
      },
      failure: (error) {
        setState(() {
          _errorMessage = error.toString();
          _loading = false;
        });
      },
    );
  }

  void _addEntry() => setState(() => _entries.add(_TravelEntry()));

  void _removeEntry(int index) {
    setState(() {
      _entries.removeAt(index).dispose();
    });
    _recalculateTotals();
  }

  void _selectTravelType(String? value) {
    if (_travelTypeLocked || value == null) return;
    setState(() {
      _travelType = value;
      _travelTypeLocked = true;
    });
  }

  // --- Location autocomplete + distance ---------------------------------

  void _onFromChanged(_TravelEntry entry, String value) {
    entry.fromLatLng = null;
    entry.distanceKm = null;
    entry.debounce?.cancel();
    entry.debounce = Timer(const Duration(milliseconds: 400), () async {
      final results = await _placesService.autocomplete(value, sessionToken: entry.sessionToken);
      if (!mounted) return;
      setState(() => entry.fromSuggestions = results);
    });
  }

  void _onToChanged(_TravelEntry entry, String value) {
    entry.toLatLng = null;
    entry.distanceKm = null;
    entry.debounce?.cancel();
    entry.debounce = Timer(const Duration(milliseconds: 400), () async {
      final results = await _placesService.autocomplete(value, sessionToken: entry.sessionToken);
      if (!mounted) return;
      setState(() => entry.toSuggestions = results);
    });
  }

  Future<void> _selectFromSuggestion(_TravelEntry entry, PlaceSuggestion s) async {
    entry.fromController.text = s.description;
    setState(() => entry.fromSuggestions = []);
    final latLng = await _placesService.getPlaceLatLng(s.placeId, sessionToken: entry.sessionToken);
    entry.fromLatLng = latLng;
    await _maybeCalculateDistance(entry);
  }

  Future<void> _selectToSuggestion(_TravelEntry entry, PlaceSuggestion s) async {
    entry.toController.text = s.description;
    setState(() => entry.toSuggestions = []);
    final latLng = await _placesService.getPlaceLatLng(s.placeId, sessionToken: entry.sessionToken);
    entry.toLatLng = latLng;
    await _maybeCalculateDistance(entry);
  }

  Future<void> _maybeCalculateDistance(_TravelEntry entry) async {
    if (entry.fromLatLng == null || entry.toLatLng == null) return;

    setState(() => entry.calculatingDistance = true);
    final km = await _placesService.drivingDistanceKm(entry.fromLatLng!, entry.toLatLng!);
    if (!mounted) return;
    setState(() {
      entry.distanceKm = km;
      entry.calculatingDistance = false;
    });
    _recalculateTotals();
  }

  /// Sums every entry's distance and fills Total KM / Total Rs / Total
  /// Liters from the entitlements (km_rate, km_ltr). Entries without a
  /// resolved distance yet just contribute 0.
  void _recalculateTotals() {
    // Round Trip entries count double — distanceKm from the API is always
    // one-way, so effectiveDistanceKm doubles it when tripType is 'Round Trip'.
    final totalKm = _entries.fold<double>(0, (sum, e) => sum + (e.effectiveDistanceKm ?? 0));
    // Round FIRST, then use that rounded figure for every downstream
    // calculation — Total Rs and Total Liters must be based on the same
    // whole-number km shown in Total KM, not the raw decimal sum.
    final roundedTotalKm = totalKm.roundToDouble();
    final kmRate = _entitlements?.kmRate ?? 0;
    final kmLtr = _entitlements?.kmLtr ?? 0;
    // Sum each entry's DA/night-stay cost (see _tripCost) into Total DA.
    final totalDa = _entries.fold<double>(0, (sum, e) => sum + (_tripCost(e) ?? 0));

    setState(() {
      _totalKmController.text = roundedTotalKm.toStringAsFixed(0);
      _totalRsController.text = (roundedTotalKm * kmRate).toStringAsFixed(0);
      _totalLitersController.text = kmLtr > 0 ? (roundedTotalKm / kmLtr).toStringAsFixed(0) : '0';
      _totalDaController.text = totalDa.toStringAsFixed(0);
    });
  }

  // --- Departure / Arrival date+time & auto-computed duration ------------

  Future<void> _pickTripDateTime(_TravelEntry entry, {required bool isDeparture}) async {
    final initial = (isDeparture ? entry.departureDateTime : entry.arrivalDateTime) ?? DateTime.now();

    final pickedDate = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (pickedDate == null) return;

    final pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(initial),
    );
    if (pickedTime == null) return;

    final combined = DateTime(pickedDate.year, pickedDate.month, pickedDate.day, pickedTime.hour, pickedTime.minute);

    setState(() {
      if (isDeparture) {
        entry.departureDateTime = combined;
      } else {
        entry.arrivalDateTime = combined;
      }
    });
    // Duration (and therefore the DA/night-stay cost) just changed.
    _recalculateTotals();
  }

  /// Days/nights derived purely from departure & arrival date+time.
  /// Returns null if dates aren't set yet or arrival isn't after departure
  /// (that invalid case is surfaced separately in the UI).
  _DurationInfo? _durationInfo(_TravelEntry entry) {
    final dep = entry.departureDateTime;
    final arr = entry.arrivalDateTime;
    if (dep == null || arr == null || !arr.isAfter(dep)) return null;

    final depDateOnly = DateTime(dep.year, dep.month, dep.day);
    final arrDateOnly = DateTime(arr.year, arr.month, arr.day);
    final nights = arrDateOnly.difference(depDateOnly).inDays;
    final days = nights + 1;
    return _DurationInfo(days: days, nights: nights);
  }

  /// Returns a human-readable "X Days, Y Nights" string. Returns null if
  /// either date isn't set yet, and 'invalid' if arrival isn't after
  /// departure.
  String? _durationLabel(_TravelEntry entry) {
    final dep = entry.departureDateTime;
    final arr = entry.arrivalDateTime;
    if (dep == null || arr == null) return null;
    if (!arr.isAfter(dep)) return 'invalid';

    final info = _durationInfo(entry)!;
    return '${info.days} Day${info.days == 1 ? '' : 's'}, ${info.nights} Night${info.nights == 1 ? '' : 's'}';
  }

  /// Per-trip cost: one day's DA plus the night-stay rate for every
  /// night away.
  ///   cost = DA + (nights x night_stay_rate)
  /// e.g. DA=750, night_stay=1000:
  ///   0 nights (same-day trip) -> 750
  ///   2 Days, 1 Night          -> 750 + (1 x 1000) = 1750
  ///   3 Days, 2 Nights         -> 750 + (2 x 1000) = 2750
  double? _tripCost(_TravelEntry entry) {
    final info = _durationInfo(entry);
    if (info == null) return null;

    final da = _entitlements?.da ?? 0;
    final nightStay = _entitlements?.nightstay ?? 0;

    return da + (info.nights * nightStay);
  }

  // ------------------------------------------------------------------------

  Future<void> _pickAttachment() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['xls', 'xlsx', 'csv', 'pdf'],
    );
    if (result != null && result.files.isNotEmpty) {
      setState(() => _attachedFile = result.files.first);
    }
  }

  Future<void> _onProceed() async {
    if (_travelType == null) return _showSnack('Please select a Travel Type first.');
    if (_selectedMonth == null) return _showSnack('Please select the Expense Month.');
    if (_entries.isEmpty) return _showSnack('Please add at least one trip record.');

    for (final e in _entries) {
      if (_durationLabel(e) == 'invalid') {
        return _showSnack('One of your trip entries has an arrival date/time before its departure.');
      }
      if (e.departureDateTime == null || e.arrivalDateTime == null) {
        return _showSnack('Every trip entry needs a departure and arrival date/time.');
      }
      if (e.distanceKm == null) {
        return _showSnack('Every trip entry needs a resolved From/To distance.');
      }
    }

    setState(() => _submitting = true);

    final apiTravelType = _travelType == 'Own Vehicle' ? 'self_vehicle' : 'public_transport';
    final maxKm = _entitlements?.maxKm ?? 0;

    int successCount = 0;
    final List<String> failures = [];

    for (int i = 0; i < _entries.length; i++) {
      final e = _entries[i];
      final info = _durationInfo(e)!;
      final cost = _tripCost(e) ?? 0;
      final apiTripType = e.tripType == 'Round Trip' ? 'round' : 'single';
      final exceedsMax = maxKm > 0 && (e.effectiveDistanceKm ?? 0) > maxKm;

      final result = await _apiService.submitTravelExpense(
        empName: _entitlements?.name ?? '',
        designation: _entitlements?.designation ?? '',
        department: _entitlements?.department ?? '',
        reasonOfTravel: _reasonController.text,
        travelType: apiTravelType,
        tripType: apiTripType,
        origin: e.fromController.text,
        destination: e.toController.text,
        distanceKm: e.distanceKm!,
        isKmExceed: exceedsMax,
        departureDateTime: e.departureDateTime!,
        arrivalDateTime: e.arrivalDateTime!,
        durationDays: info.days,
        durationNights: info.nights,
        daCharges: cost,
        kmRate: _entitlements?.kmRate ?? 0,
        totalLiters: double.tryParse(_totalLitersController.text) ?? 0,
        kmLtr: _entitlements?.kmLtr ?? 0,
        attachmentPath: _attachedFile?.path,
      );

      result.when(
        success: (_) => successCount++,
        failure: (err) => failures.add('Entry ${i + 1}: $err'),
      );
    }

    setState(() => _submitting = false);

    if (failures.isEmpty) {
      _showSnack('All $successCount trip record(s) submitted successfully.');
    } else {
      _showSnack('$successCount submitted, ${failures.length} failed. Check console for details.');
      debugPrint(failures.join('\n'));
    }
  }
  void _showSnack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  void dispose() {
    _reasonController.dispose();
    _totalKmController.dispose();
    _totalRsController.dispose();
    _totalLitersController.dispose();
    _totalDaController.dispose();
    _commentsController.dispose();
    for (final e in _entries) {
      e.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kBg,
      appBar: AppBar(
        backgroundColor: _kPrimary,
        elevation: 0,
        title: const Text('Travel Expense Form',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white)
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarBrightness: Brightness.light,
          statusBarIconBrightness: Brightness.light,
        ),
      ),
      body: SafeArea(
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : _errorMessage != null
            ? Center(child: _buildError())
            : _buildForm(),
      ),
    );
  }

  Widget _buildError() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline, color: Colors.redAccent, size: 40),
          const SizedBox(height: 12),
          Text(_errorMessage ?? 'Something went wrong', textAlign: TextAlign.center),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _fetchEntitlements,
            style: ElevatedButton.styleFrom(backgroundColor: _kPrimary),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildEntitlementsCard(),
          const SizedBox(height: _kGap),
          _buildEmployeeCard(),
          const SizedBox(height: _kGap),
          _buildTravelTypeCard(),
          if (_travelType != null) ...[
            const SizedBox(height: _kGap + 4),
            _sectionHeading('Trip Records', icon: Icons.map_outlined),
            const SizedBox(height: 10),
            for (int i = 0; i < _entries.length; i++) ...[
              _buildEntryCard(i, _entries[i]),
              const SizedBox(height: 10),
            ],
            _buildAddRecordButton(),
            const SizedBox(height: _kGap + 4),
            _sectionHeading('Totals', icon: Icons.summarize_outlined),
            const SizedBox(height: 10),
            _buildTotalsCard(),
            const SizedBox(height: _kGap),
            _buildAttachmentCard(),
            const SizedBox(height: _kGap + 6),
            _buildProceedButton(),
          ],
        ],
      ),
    );
  }

  Widget _sectionHeading(String text, {IconData? icon}) {
    return Row(
      children: [
        if (icon != null) ...[
          Icon(icon, size: 17, color: _kPrimary),
          const SizedBox(width: 6),
        ],
        Text(
          text,
          style: const TextStyle(color: _kPrimary, fontWeight: FontWeight.bold, fontSize: 14),
        ),
      ],
    );
  }

  // --- Entitlements -------------------------------------------------------

  Widget _buildEntitlementsCard() {
    final e = _entitlements;
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionHeading('Your Entitlements', icon: Icons.card_giftcard_outlined),
          const SizedBox(height: 10),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              // Rate/KM keeps its exact API value — the rest are whole
              // numbers already so they're shown rounded.
              _entitlementChip('Rate / KM', e?.kmRate, preserveDecimals: true),
              _entitlementChip('DA / Outstation', e?.da),
              _entitlementChip('Night Stay', e?.nightstay),
              _entitlementChip('KM / Litre', e?.kmLtr),
            ],
          ),
        ],
      ),
    );
  }

  /// Formats an entitlement value. When [preserveDecimals] is false
  /// (default) it's rounded to a whole number, matching the original
  /// design. When true, the API value is shown exactly as returned —
  /// no rounding — with trailing zeros trimmed (7.50 -> 7.5, 8.00 -> 8).
  String _formatNumber(double? value, {bool preserveDecimals = false}) {
    if (value == null) return '-';
    if (!preserveDecimals) return value.toStringAsFixed(0);
    if (value == value.roundToDouble()) return value.toStringAsFixed(0);
    var s = value.toStringAsFixed(2);
    s = s.replaceFirst(RegExp(r'0+$'), '');
    s = s.replaceFirst(RegExp(r'\.$'), '');
    return s;
  }

  Widget _entitlementChip(String label, double? value, {bool preserveDecimals = false}) {
    return Container(
      constraints: const BoxConstraints(minWidth: 96),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: _kPrimaryLight,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label, style: const TextStyle(fontSize: 10.5, color: Colors.black54)),
          const SizedBox(height: 3),
          Text(
            _formatNumber(value, preserveDecimals: preserveDecimals),
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: _kPrimary),
          ),
        ],
      ),
    );
  }

  // --- Employee info --------------------------------------------------------

  Widget _buildEmployeeCard() {
    final e = _entitlements;
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionHeading('Employee Details', icon: Icons.badge_outlined),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _readonlyField('Employee Code', e?.code ?? '')),
              const SizedBox(width: 10),
              Expanded(child: _readonlyField('Grade', e?.grades ?? '')),
            ],
          ),
          const SizedBox(height: 10),
          _readonlyField('Name', e?.name ?? ''),
          const SizedBox(height: 10),
          _readonlyField('Dept / Branch', e?.department ?? ''),
          const SizedBox(height: 10),
          _labeledField(
            'Reason of Travel',
            TextField(controller: _reasonController, decoration: _inputDecoration(hint: 'Enter reason')),
          ),
          const SizedBox(height: 10),
          _labeledField(
            'Expense Month',
            DropdownButtonFormField<String>(
              value: _selectedMonth,
              isExpanded: true,
              decoration: _inputDecoration(hint: 'Select month'),
              items: _months.map((m) => DropdownMenuItem(value: m, child: Text(m))).toList(),
              onChanged: (val) => setState(() => _selectedMonth = val),
            ),
          ),
        ],
      ),
    );
  }

  // --- Travel type ---------------------------------------------------------

  Widget _buildTravelTypeCard() {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionHeading('Travel Type', icon: Icons.directions_car_filled_outlined),
          const SizedBox(height: 4),
          if (_travelTypeLocked)
            const Padding(
              padding: EdgeInsets.only(bottom: 8),
              child: Text(
                'Locked for this form — reload the screen to change it.',
                style: TextStyle(fontSize: 11, color: Colors.black45, fontStyle: FontStyle.italic),
              ),
            ),
          DropdownButtonFormField<String>(
            value: _travelType,
            isExpanded: true,
            decoration: _inputDecoration(hint: 'Select Conveyance First').copyWith(
              filled: _travelTypeLocked,
              fillColor: _travelTypeLocked ? Colors.grey.shade200 : null,
              suffixIcon: _travelTypeLocked ? const Icon(Icons.lock_outline, size: 18, color: Colors.black38) : null,
            ),
            items: const [
              DropdownMenuItem(value: 'Own Vehicle', child: Text('Own Vehicle')),
              DropdownMenuItem(value: 'Public Transport', child: Text('Public Transport')),
            ],
            onChanged: _travelTypeLocked ? null : _selectTravelType,
          ),
        ],
      ),
    );
  }

  // --- Trip entries (card layout) ------------------------------------------

  Widget _buildEntryCard(int index, _TravelEntry entry) {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 12,
                backgroundColor: _kPrimary,
                child: Text('${index + 1}', style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(width: 8),
              Text('Trip Entry ${index + 1}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              const Spacer(),
              if (_entries.length > 1)
                InkWell(
                  onTap: () => _removeEntry(index),
                  borderRadius: BorderRadius.circular(16),
                  child: const Padding(
                    padding: EdgeInsets.all(4),
                    child: Icon(Icons.close, size: 18, color: Colors.redAccent),
                  ),
                ),
            ],
          ),
          const Divider(height: 20, color: _kBorder),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _labeledField(
                  'Trip Type',
                  DropdownButtonFormField<String>(
                    value: entry.tripType,
                    isExpanded: true,
                    isDense: true,
                    decoration: _inputDecoration(),
                    items: const [
                      DropdownMenuItem(value: 'One Way', child: Text('One Way')),
                      DropdownMenuItem(value: 'Round Trip', child: Text('Round Trip')),
                    ],
                    onChanged: (val) {
                      setState(() => entry.tripType = val ?? entry.tripType);
                      // Switching One Way <-> Round Trip changes the
                      // effective (possibly doubled) distance, so totals
                      // need to be redone immediately.
                      _recalculateTotals();
                    },
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _labeledField(
                  'Destination',
                  DropdownButtonFormField<String>(
                    value: entry.destinationType,
                    isExpanded: true,
                    isDense: true,
                    decoration: _inputDecoration(),
                    items: const [
                      DropdownMenuItem(value: 'In City', child: Text('In City')),
                      DropdownMenuItem(value: 'Out City', child: Text('Out City')),
                    ],
                    onChanged: (val) => setState(() => entry.destinationType = val ?? entry.destinationType),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _labeledField(
            'From',
            _locationField(
              controller: entry.fromController,
              hint: 'e.g. Karachi',
              suggestions: entry.fromSuggestions,
              onChanged: (v) => _onFromChanged(entry, v),
              onSelect: (s) => _selectFromSuggestion(entry, s),
            ),
          ),
          const SizedBox(height: 12),
          _labeledField(
            'To',
            _locationField(
              controller: entry.toController,
              hint: 'e.g. Lahore',
              suggestions: entry.toSuggestions,
              onChanged: (v) => _onToChanged(entry, v),
              onSelect: (s) => _selectToSuggestion(entry, s),
            ),
          ),
          if (entry.calculatingDistance) ...[
            const SizedBox(height: 10),
            const Row(
              children: [
                SizedBox(height: 14, width: 14, child: CircularProgressIndicator(strokeWidth: 2)),
                SizedBox(width: 8),
                Text('Calculating distance…', style: TextStyle(fontSize: 11, color: Colors.black54)),
              ],
            ),
          ] else if (entry.distanceKm != null) ...[
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: [
                _infoChip(
                  icon: Icons.route_outlined,
                  text: entry.tripType == 'Round Trip'
                      ? '${entry.effectiveDistanceKm!.toStringAsFixed(0)} km round trip'
                      : '${entry.distanceKm!.toStringAsFixed(0)} km',
                ),
                _infoChip(
                  icon: Icons.payments_outlined,
                  text: 'Rs ${(_distanceCost(entry) ?? 0).toStringAsFixed(0)}',
                ),
              ],
            ),
            if (entry.tripType == 'Round Trip')
              Padding(
                padding: const EdgeInsets.only(top: 4, left: 2),
                child: Text(
                  'One-way: ${entry.distanceKm!.toStringAsFixed(0)} km × 2',
                  style: const TextStyle(fontSize: 10.5, color: Colors.black45),
                ),
              ),
          ],
          const SizedBox(height: 14),
          // Departure / Arrival now each capture date + time directly —
          // this is what Duration is computed from below, so there's no
          // separate duration input anymore.
          Row(
            children: [
              Expanded(
                child: _labeledField(
                  'Departure Date & Time',
                  _dateTapField(
                    label: entry.departureDateTime == null ? 'Select date & time' : _dateTimeFmt.format(entry.departureDateTime!),
                    onTap: () => _pickTripDateTime(entry, isDeparture: true),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _labeledField(
                  'Arrival Date & Time',
                  _dateTapField(
                    label: entry.arrivalDateTime == null ? 'Select date & time' : _dateTimeFmt.format(entry.arrivalDateTime!),
                    onTap: () => _pickTripDateTime(entry, isDeparture: false),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildDurationIndicator(entry),
        ],
      ),
    );
  }

  /// Read-only, auto-computed from departure/arrival — never entered by
  /// hand. Shows both the Days/Nights breakdown and the DA/night-stay
  /// cost it produces (see _tripCost) side by side.
  Widget _buildDurationIndicator(_TravelEntry entry) {
    final label = _durationLabel(entry);
    if (label == null) return const SizedBox.shrink();

    final isInvalid = label == 'invalid';
    final cost = _tripCost(entry);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: isInvalid ? const Color(0xFFFDECEC) : _kPrimaryLight,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        children: [
          Icon(isInvalid ? Icons.error_outline : Icons.hourglass_bottom, size: 15, color: isInvalid ? Colors.redAccent : _kPrimary),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              isInvalid ? 'Arrival must be after departure' : 'Duration: $label',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: isInvalid ? Colors.redAccent : _kPrimary),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (!isInvalid && cost != null) ...[
            const SizedBox(width: 6),
            Text(
              'Rs ${cost.toStringAsFixed(0)}',
              style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: _kPrimary),
            ),
          ],
        ],
      ),
    );
  }

  /// Rupees for an entry's distance: km_rate × the ROUNDED effective
  /// (round-trip-aware) kilometers — round first, then multiply, so this
  /// always matches the whole-number km shown next to it.
  double? _distanceCost(_TravelEntry entry) {
    final km = entry.effectiveDistanceKm;
    if (km == null) return null;
    final roundedKm = km.roundToDouble();
    final kmRate = _entitlements?.kmRate ?? 0;
    return roundedKm * kmRate;
  }

  Widget _infoChip({required IconData icon, required String text}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(color: _kPrimaryLight, borderRadius: BorderRadius.circular(6)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: _kPrimary),
          const SizedBox(width: 6),
          Text(text, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: _kPrimary)),
        ],
      ),
    );
  }

  /// Text field + inline suggestion dropdown for a From/To location.
  Widget _locationField({
    required TextEditingController controller,
    required String hint,
    required List<PlaceSuggestion> suggestions,
    required ValueChanged<String> onChanged,
    required ValueChanged<PlaceSuggestion> onSelect,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: controller,
          decoration: _inputDecoration(hint: hint).copyWith(prefixIcon: const Icon(Icons.place_outlined, size: 18)),
          onChanged: onChanged,
        ),
        if (suggestions.isNotEmpty)
          Container(
            margin: const EdgeInsets.only(top: 4),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: _kBorder),
              borderRadius: BorderRadius.circular(6),
              boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 2))],
            ),
            constraints: const BoxConstraints(maxHeight: 160),
            child: ListView.separated(
              shrinkWrap: true,
              padding: EdgeInsets.zero,
              itemCount: suggestions.length,
              separatorBuilder: (_, __) => Divider(height: 1, color: Colors.grey.shade200),
              itemBuilder: (context, i) {
                final s = suggestions[i];
                return InkWell(
                  onTap: () => onSelect(s),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                    child: Text(s.description, style: const TextStyle(fontSize: 12.5), overflow: TextOverflow.ellipsis),
                  ),
                );
              },
            ),
          ),
      ],
    );
  }

  Widget _dateTapField({required String label, required VoidCallback onTap, IconData icon = Icons.event_outlined}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: InputDecorator(
        decoration: _inputDecoration().copyWith(prefixIcon: Icon(icon, size: 16)),
        child: Text(
          label,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontSize: 12.5),
        ),
      ),
    );
  }

  Widget _buildAddRecordButton() {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: _addEntry,
        style: OutlinedButton.styleFrom(
          foregroundColor: _kPrimary,
          side: const BorderSide(color: _kPrimary),
          padding: const EdgeInsets.symmetric(vertical: 13),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        icon: const Icon(Icons.add, size: 18),
        label: const Text('Add New Record', style: TextStyle(fontWeight: FontWeight.w600)),
      ),
    );
  }

  // --- Totals ----------------------------------------------------------------

  Widget _buildTotalsCard() {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Distance & DA are auto-calculated from the trips above — adjust manually if needed.',
            style: TextStyle(fontSize: 11, color: Colors.black45),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _labeledField('KiloMeters', TextField(controller: _totalKmController, keyboardType: TextInputType.number, decoration: _inputDecoration()))),
              const SizedBox(width: 10),
              Expanded(child: _labeledField('Rupees', TextField(controller: _totalRsController, keyboardType: TextInputType.number, decoration: _inputDecoration()))),
            ],
          ),
          const SizedBox(height: 10),
          _labeledField('Liters (approx.)', TextField(controller: _totalLitersController, keyboardType: TextInputType.number, decoration: _inputDecoration())),
          const SizedBox(height: 10),
          _labeledField('Total DA (Rupees)', TextField(controller: _totalDaController, keyboardType: TextInputType.number, decoration: _inputDecoration())),
        ],
      ),
    );
  }

  Widget _buildAttachmentCard() {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionHeading('Attachments & Comments', icon: Icons.attach_file),
          const SizedBox(height: 10),
          const Text('Additional expenses / itinerary plans / visit report', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
          const Text('Formats allowed: xls, csv, xlsx, pdf', style: TextStyle(fontSize: 11, color: Colors.redAccent)),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _pickAttachment,
              style: OutlinedButton.styleFrom(
                foregroundColor: _kPrimary,
                side: BorderSide(color: Colors.grey.shade400),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              icon: const Icon(Icons.upload_file, size: 17),
              label: Text(
                _attachedFile?.name ?? 'Choose File',
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
          const SizedBox(height: 12),
          _labeledField('Comments', TextField(controller: _commentsController, decoration: _inputDecoration(), maxLines: 3)),
        ],
      ),
    );
  }

  Widget _buildProceedButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: _onProceed,
        style: ElevatedButton.styleFrom(
          backgroundColor: _kPrimary,
          padding: const EdgeInsets.symmetric(vertical: 15),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          elevation: 1,
        ),
        icon: const Icon(Icons.arrow_forward, color: Colors.white, size: 18),
        label: const Text('PROCEED', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
      ),
    );
  }

  // --- Shared helpers -----------------------------------------------------

  Widget _readonlyField(String label, String value) {
    return _labeledField(
      label,
      TextField(
        readOnly: true,
        controller: TextEditingController(text: value),
        style: const TextStyle(color: Colors.black87),
        decoration: _inputDecoration().copyWith(filled: true, fillColor: Colors.grey.shade100),
      ),
    );
  }

  Widget _labeledField(String label, Widget field) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label, style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: _kPrimary)),
        const SizedBox(height: 5),
        field,
      ],
    );
  }

  InputDecoration _inputDecoration({String? hint}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(fontSize: 12.5, color: Colors.black38),
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: _kBorder)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: _kBorder)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: _kPrimary, width: 1.4)),
    );
  }

  Widget _card({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(_kCardRadius),
        border: Border.all(color: _kBorder),
        boxShadow: const [BoxShadow(color: Color(0x08000000), blurRadius: 6, offset: Offset(0, 2))],
      ),
      child: child,
    );
  }
}

/// Simple days/nights pair returned by _durationInfo.
class _DurationInfo {
  final int days;
  final int nights;
  _DurationInfo({required this.days, required this.nights});
}

/// Local (unsaved) state for a single trip row. Not the API model —
/// this only exists to drive the form until a submit endpoint is wired up.
class _TravelEntry {
  String tripType = 'One Way';
  String destinationType = 'In City';
  final TextEditingController fromController = TextEditingController();
  final TextEditingController toController = TextEditingController();

  // Departure/Arrival now carry both date AND time — Duration is derived
  // from these two, there is no separate duration input.
  DateTime? departureDateTime;
  DateTime? arrivalDateTime;

  // Places autocomplete + distance state
  final String sessionToken = DateTime.now().millisecondsSinceEpoch.toString();
  List<PlaceSuggestion> fromSuggestions = [];
  List<PlaceSuggestion> toSuggestions = [];
  LatLng? fromLatLng;
  LatLng? toLatLng;
  double? distanceKm; // always one-way, as returned by the Distance Matrix API
  bool calculatingDistance = false;
  Timer? debounce;

  /// distanceKm doubled when this is a Round Trip — this is the value
  /// that should actually feed Total KM / Rs / Liters, not distanceKm
  /// directly.
  double? get effectiveDistanceKm {
    if (distanceKm == null) return null;
    return tripType == 'Round Trip' ? distanceKm! * 2 : distanceKm;
  }

  Map<String, dynamic> toJson() {
    return {
      'trip_type': tripType,
      'destination_type': destinationType,
      'from': fromController.text,
      'to': toController.text,
      'one_way_distance_km': distanceKm,
      'distance_km': effectiveDistanceKm,
      'departure_datetime': departureDateTime?.toIso8601String(),
      'arrival_datetime': arrivalDateTime?.toIso8601String(),
    };
  }

  void dispose() {
    debounce?.cancel();
    fromController.dispose();
    toController.dispose();
  }
}