import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:maplibre_gl/maplibre_gl.dart';
import 'package:http/http.dart' as http;
import '../../../landing/presentation/providers/language_provider.dart';
import '../../../landing/presentation/widgets/language_toggle.dart';
import '../../domain/entities/itinerary_request.dart';
import '../providers/itinerary_provider.dart';

class AiItineraryPage extends ConsumerStatefulWidget {
  const AiItineraryPage({super.key});

  @override
  ConsumerState<AiItineraryPage> createState() => _AiItineraryPageState();
}

class _AiItineraryPageState extends ConsumerState<AiItineraryPage> {
  static const Color _darkGreen = Color(0xFF515F49);
  static const Color _green = Color(0xFF79926C);
  static const Color _lightGreen = Color(0xFFF2F6EF);
  static const Color _border = Color(0xFFDDE7D7);

  // Default: Sanxia, New Taipei City
  static const LatLng _defaultLatLng = LatLng(24.9421, 121.3702);

  // Free MapLibre tile style (Carto Voyager, no API key required)
  static const String _mapStyle =
      'https://basemaps.cartocdn.com/gl/voyager-gl-style/style.json';

  final TextEditingController _locationCtrl = TextEditingController();
  String? _selectedPlace;
  LatLng? _selectedLatLng;
  List<Map<String, dynamic>> _suggestions = [];
  bool _showSuggestions = false;
  Timer? _debounce;
  bool _loadingGps = false;
  MapLibreMapController? _mapController;

  DateTime _date = DateTime(2026, 6, 20);
  String _travelWith = 'friends';
  final Set<String> _interests = {'historic', 'food'};
  String _budget = '1k3k';

  @override
  void dispose() {
    _locationCtrl.dispose();
    _debounce?.cancel();
    // _mapController?.dispose();
    super.dispose();
  }

  // ── GPS ────────────────────────────────────────────────────────────────

  Future<void> _useGps() async {
    setState(() => _loadingGps = true);
    try {
      var perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) {
        perm = await Geolocator.requestPermission();
      }
      if (perm == LocationPermission.deniedForever) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Location permission denied')),
          );
        }
        return;
      }
      final pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.medium,
      );
      if (!mounted) return;
      final latlng = LatLng(pos.latitude, pos.longitude);
      setState(() => _selectedLatLng = latlng);
      await _mapController?.animateCamera(
        CameraUpdate.newLatLngZoom(latlng, 14),
      );
      await _reverseGeocode(latlng);
    } catch (_) {
      // GPS unavailable (emulator etc.) — stay on default
      if (!mounted) return;
      setState(() => _selectedLatLng = _defaultLatLng);
    } finally {
      if (mounted) setState(() => _loadingGps = false);
    }
  }

  // ── Nominatim geocoding (free, no API key) ────────────────────────────

  void _onLocationChanged(String value) {
    _debounce?.cancel();
    if (value.trim().isEmpty) {
      setState(() {
        _suggestions = [];
        _showSuggestions = false;
      });
      return;
    }
    _debounce = Timer(const Duration(milliseconds: 400), () {
      _fetchSuggestions(value.trim());
    });
  }

  Future<void> _fetchSuggestions(String input) async {
    try {
      final lang = ref.read(languageProvider) == AppLanguage.zh
          ? 'zh-TW'
          : 'en';
      final uri = Uri.parse(
        'https://nominatim.openstreetmap.org/search'
        '?q=${Uri.encodeComponent(input)}'
        '&format=json&limit=5&addressdetails=1'
        '&accept-language=$lang&countrycodes=tw',
      );
      final res = await http.get(
        uri,
        headers: {'User-Agent': 'PeilarSuperapp/1.0 (contact@example.com)'},
      );
      if (res.statusCode == 200 && mounted) {
        final list = jsonDecode(res.body) as List<dynamic>;
        final results = list.cast<Map<String, dynamic>>().take(5).toList();
        setState(() {
          _suggestions = results;
          _showSuggestions = results.isNotEmpty;
        });
      }
    } catch (_) {}
  }

  Future<void> _pickSuggestion(Map<String, dynamic> s) async {
    final display = s['display_name'] as String? ?? '';
    final name = s['name'] as String? ?? display.split(',').first.trim();
    final lat = double.tryParse(s['lat'] as String? ?? '');
    final lon = double.tryParse(s['lon'] as String? ?? '');

    setState(() {
      _locationCtrl.text = display.split(',').take(2).join(',').trim();
      _selectedPlace = name;
      _suggestions = [];
      _showSuggestions = false;
    });

    if (lat != null && lon != null) {
      final latlng = LatLng(lat, lon);
      setState(() => _selectedLatLng = latlng);
      await _mapController?.animateCamera(
        CameraUpdate.newLatLngZoom(latlng, 14),
      );
    }
  }

  Future<void> _reverseGeocode(LatLng latlng) async {
    try {
      final lang = ref.read(languageProvider) == AppLanguage.zh
          ? 'zh-TW'
          : 'en';
      final uri = Uri.parse(
        'https://nominatim.openstreetmap.org/reverse'
        '?lat=${latlng.latitude}&lon=${latlng.longitude}'
        '&format=json&accept-language=$lang',
      );
      final res = await http.get(
        uri,
        headers: {'User-Agent': 'PeilarSuperapp/1.0 (contact@example.com)'},
      );
      if (res.statusCode == 200 && mounted) {
        final data = jsonDecode(res.body) as Map<String, dynamic>;
        final display = data['display_name'] as String?;
        if (display != null) {
          final shortName = display.split(',').take(2).join(',').trim();
          setState(() {
            _locationCtrl.text = shortName;
            _selectedPlace = display.split(',').first.trim();
          });
        }
      }
    } catch (_) {}
  }

  // ── Date ────────────────────────────────────────────────────────────────

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime.now(),
      lastDate: DateTime(2028, 12, 31),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(
            primary: _darkGreen,
            onPrimary: Colors.white,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _date = picked);
  }

  // ── Generate ───────────────────────────────────────────────────────────

  Future<void> _generate() async {
    final text = ref.read(appTextProvider);
    final location = _locationCtrl.text.trim();
    if (location.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            text['locationRequired'] ?? 'Please enter a destination',
          ),
        ),
      );
      return;
    }

    final lang = ref.read(languageProvider) == AppLanguage.zh ? 'zh' : 'en';
    final request = ItineraryRequest(
      location: _selectedPlace ?? location,
      latitude: _selectedLatLng?.latitude,
      longitude: _selectedLatLng?.longitude,
      date: _date,
      travelWith: _travelWith,
      interests: _interests.toList(),
      budget: _budget,
    );

    ref
        .read(itineraryDestinationProvider.notifier)
        .set((_selectedLatLng != null) ? _selectedLatLng : _defaultLatLng);
    await ref.read(itineraryProvider.notifier).generate(request, lang);
    if (!mounted) return;

    ref
        .read(itineraryProvider)
        .when(
          data: (result) {
            if (result != null) context.go('/itinerary-result');
          },
          loading: () {},
          error: (e, st) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  text['generationError'] ??
                      'Failed to generate itinerary. Please try again.',
                ),
                backgroundColor: Colors.red.shade700,
              ),
            );
          },
        );
  }

  // ── Build ─────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final text = ref.watch(appTextProvider);
    final isGenerating = ref.watch(itineraryProvider) is AsyncLoading;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              _buildAppBar(text),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 110),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    // Where
                    _SectionLabel(
                      icon: Icons.place_outlined,
                      title: text['whereGo'] ?? 'Where do you want to go?',
                    ),
                    const SizedBox(height: 12),
                    _buildLocationRow(text),
                    if (_showSuggestions && _suggestions.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      _buildSuggestionsCard(),
                    ],
                    const SizedBox(height: 12),
                    _buildMapCard(),
                    const SizedBox(height: 28),

                    // When
                    _SectionLabel(
                      icon: Icons.calendar_month_outlined,
                      title: text['whenGo'] ?? 'When do you plan to go?',
                    ),
                    const SizedBox(height: 12),
                    _buildDateRow(),
                    const SizedBox(height: 28),

                    // Who
                    _SectionLabel(
                      icon: Icons.group_outlined,
                      title: text['whoGo'] ?? 'Who is going with you?',
                    ),
                    const SizedBox(height: 12),
                    _buildCompanionRow(text),
                    const SizedBox(height: 28),

                    // Interests
                    _SectionLabel(
                      icon: Icons.favorite_outline,
                      title: text['interests'] ?? 'What are you interested in?',
                      subtitle: text['chooseAll'] ?? '*Choose all that apply',
                    ),
                    const SizedBox(height: 12),
                    _buildInterestsGrid(text),
                    const SizedBox(height: 28),

                    // Budget
                    _SectionLabel(
                      icon: Icons.payments_outlined,
                      title: text['budget'] ?? 'What is your estimated budget?',
                    ),
                    const SizedBox(height: 12),
                    _buildBudgetDropdown(text),
                  ]),
                ),
              ),
            ],
          ),

          // Fixed Generate button
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 30),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 16,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: SizedBox(
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: isGenerating ? null : _generate,
                  icon: isGenerating
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2.5,
                          ),
                        )
                      : const Icon(Icons.auto_awesome, size: 20),
                  label: Text(
                    isGenerating
                        ? (text['generating'] ?? 'Generating...')
                        : (text['generateItinerary'] ?? 'Generate Itinerary'),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _darkGreen,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: _green,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── AppBar ─────────────────────────────────────────────────────────────

  SliverAppBar _buildAppBar(Map<String, String> text) {
    return SliverAppBar(
      expandedHeight: 155,
      floating: false,
      pinned: true,
      backgroundColor: _darkGreen,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () => context.go('/'),
      ),
      actions: const [
        Padding(
          padding: EdgeInsets.only(right: 14),
          child: LanguageToggle(darkMode: true),
        ),
      ],
      title: Text(
        text['aiTitle'] ?? 'AI Itinerary',
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w900,
          fontSize: 18,
        ),
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF3F4D38), Color(0xFF79926C)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Center(
            child: Padding(
              padding: const EdgeInsets.only(top: 56),
              child: Text(
                text['aiSubtitle'] ?? 'Plan your trip with AI assistance',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 13,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ── Location row ────────────────────────────────────────────────────────

  Widget _buildLocationRow(Map<String, String> text) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _locationCtrl,
            onChanged: _onLocationChanged,
            decoration: InputDecoration(
              hintText: text['wherePlaceholder'] ?? 'e.g. Sanxia Old Street',
              prefixIcon: const Icon(Icons.search, color: _green, size: 20),
              hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
              filled: true,
              fillColor: _lightGreen,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 13,
              ),
              enabledBorder: OutlineInputBorder(
                borderSide: const BorderSide(color: _border),
                borderRadius: BorderRadius.circular(12),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: const BorderSide(color: _darkGreen, width: 1.5),
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        SizedBox(
          width: 48,
          height: 48,
          child: IconButton.filled(
            tooltip: text['useMyLocation'] ?? 'Use my location',
            onPressed: _loadingGps ? null : _useGps,
            icon: _loadingGps
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : const Icon(Icons.my_location, size: 20),
            style: IconButton.styleFrom(
              backgroundColor: _darkGreen,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ── Autocomplete dropdown ───────────────────────────────────────────────

  Widget _buildSuggestionsCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.07),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: _suggestions.map((s) {
          final display = s['display_name'] as String? ?? '';
          final name = (s['name'] as String? ?? '').isNotEmpty
              ? s['name'] as String
              : display.split(',').first.trim();
          final secondary = display.split(',').skip(1).take(2).join(',').trim();
          return InkWell(
            onTap: () => _pickSuggestion(s),
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
              child: Row(
                children: [
                  const Icon(Icons.place_outlined, color: _green, size: 18),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          style: const TextStyle(
                            color: _darkGreen,
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                          ),
                        ),
                        if (secondary.isNotEmpty)
                          Text(
                            secondary,
                            style: TextStyle(
                              color: Colors.grey.shade500,
                              fontSize: 11,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // ── MapLibre map ────────────────────────────────────────────────────────

  Widget _buildMapCard() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: SizedBox(
        height: 220,
        width: double.infinity,
        child: Stack(
          children: [
            MapLibreMap(
              styleString: _mapStyle,
              initialCameraPosition: CameraPosition(
                target: _selectedLatLng ?? _defaultLatLng,
                zoom: 13,
              ),
              onMapCreated: (ctrl) {
                _mapController = ctrl;
                // Auto-GPS on first load if no location selected
                if (_selectedLatLng == null) _useGps();
              },
              onCameraIdle: () {
                final latlng = _mapController?.cameraPosition?.target;
                if (latlng != null && mounted) {
                  setState(() => _selectedLatLng = latlng);
                }
              },
              myLocationEnabled: true,
              myLocationRenderMode: MyLocationRenderMode.normal,
              compassEnabled: false,
              rotateGesturesEnabled: false,
              tiltGesturesEnabled: false,
            ),
            // Center pin overlay
            const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.location_pin,
                    color: Color(0xFF515F49),
                    size: 38,
                    shadows: [
                      Shadow(
                        color: Colors.black26,
                        blurRadius: 6,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  SizedBox(height: 36),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Date ────────────────────────────────────────────────────────────────

  Widget _buildDateRow() {
    return InkWell(
      onTap: _pickDate,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: _lightGreen,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: _border),
        ),
        child: Row(
          children: [
            const Icon(Icons.calendar_month, color: _green, size: 20),
            const SizedBox(width: 12),
            Text(
              '${_date.year} / ${_date.month.toString().padLeft(2, '0')} / ${_date.day.toString().padLeft(2, '0')}',
              style: const TextStyle(
                color: _darkGreen,
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
            const Spacer(),
            const Icon(Icons.edit_calendar_outlined, color: _green, size: 18),
          ],
        ),
      ),
    );
  }

  // ── Companion ──────────────────────────────────────────────────────────

  Widget _buildCompanionRow(Map<String, String> text) {
    const options = [
      ('solo', Icons.person),
      ('friends', Icons.group),
      ('family', Icons.family_restroom),
    ];
    final labels = {
      'solo': text['solo'] ?? 'Solo',
      'friends': text['friends'] ?? 'Friends',
      'family': text['family'] ?? 'Family',
    };

    return Row(
      children: options.asMap().entries.map((e) {
        final key = e.value.$1;
        final icon = e.value.$2;
        final selected = _travelWith == key;
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(right: e.key < options.length - 1 ? 8 : 0),
            child: InkWell(
              onTap: () => setState(() => _travelWith = key),
              borderRadius: BorderRadius.circular(12),
              child: Container(
                height: 60,
                decoration: BoxDecoration(
                  color: selected ? _darkGreen : _lightGreen,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: selected ? _darkGreen : _border),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      icon,
                      color: selected ? Colors.white : _green,
                      size: 22,
                    ),
                    const SizedBox(height: 3),
                    Text(
                      labels[key] ?? key,
                      style: TextStyle(
                        color: selected ? Colors.white : _darkGreen,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  // ── Interests ──────────────────────────────────────────────────────────

  Widget _buildInterestsGrid(Map<String, String> text) {
    final options = [
      (
        'historic',
        text['historic'] ?? 'Historic',
        Icons.account_balance_outlined,
      ),
      ('food', text['food'] ?? 'Food', Icons.restaurant_outlined),
      ('art', text['art'] ?? 'Art', Icons.palette_outlined),
      ('hiking', text['hiking'] ?? 'Hiking', Icons.hiking),
      ('shopping', text['shopping'] ?? 'Shopping', Icons.shopping_bag_outlined),
      ('mustSee', text['mustSee'] ?? 'Must-see', Icons.star_outline),
    ];

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      childAspectRatio: 3.4,
      children: options.map((opt) {
        final selected = _interests.contains(opt.$1);
        return InkWell(
          onTap: () => setState(() {
            if (selected) {
              _interests.remove(opt.$1);
            } else {
              _interests.add(opt.$1);
            }
          }),
          borderRadius: BorderRadius.circular(10),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              color: selected ? const Color(0xFFDDE7D7) : _lightGreen,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: selected ? _darkGreen : _border),
            ),
            child: Row(
              children: [
                Icon(
                  selected ? Icons.check_box : Icons.check_box_outline_blank,
                  color: selected ? _darkGreen : _green,
                  size: 18,
                ),
                const SizedBox(width: 6),
                Icon(opt.$3, color: selected ? _darkGreen : _green, size: 15),
                const SizedBox(width: 5),
                Expanded(
                  child: Text(
                    opt.$2,
                    style: const TextStyle(
                      color: _darkGreen,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  // ── Budget ─────────────────────────────────────────────────────────────

  Widget _buildBudgetDropdown(Map<String, String> text) {
    final options = [
      ('under1k', text['budgetUnder1k'] ?? 'Under NT\$1,000'),
      ('1k3k', text['budget1k3k'] ?? 'NT\$1,000–3,000'),
      ('3k5k', text['budget3k5k'] ?? 'NT\$3,000–5,000'),
      ('over5k', text['budgetOver5k'] ?? 'Over NT\$5,000'),
    ];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
      decoration: BoxDecoration(
        color: _lightGreen,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _border),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _budget,
          isExpanded: true,
          icon: const Icon(Icons.expand_more, color: _green),
          dropdownColor: Colors.white,
          style: const TextStyle(
            color: _darkGreen,
            fontWeight: FontWeight.w700,
            fontSize: 14,
          ),
          items: options
              .map(
                (opt) => DropdownMenuItem(
                  value: opt.$1,
                  child: Row(
                    children: [
                      const Icon(
                        Icons.payments_outlined,
                        color: _green,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Text(opt.$2),
                    ],
                  ),
                ),
              )
              .toList(),
          onChanged: (v) {
            if (v != null) setState(() => _budget = v);
          },
        ),
      ),
    );
  }
}

// ── Section label ─────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;

  const _SectionLabel({required this.icon, required this.title, this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: const Color(0xFF515F49), size: 18),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  color: Color(0xFF515F49),
                  fontSize: 15,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ],
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 3),
          Padding(
            padding: const EdgeInsets.only(left: 26),
            child: Text(
              subtitle!,
              style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
            ),
          ),
        ],
      ],
    );
  }
}
