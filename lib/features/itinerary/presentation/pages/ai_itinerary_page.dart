import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart' hide Path;

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
  static const Color _blue = Color(0xFF0079BF);
  static const Color _green = Color(0xFF0E9A33);
  static const Color _pink = Color(0xFFC6006E);
  static const Color _yellow = Color(0xFFEDA944);
  static const Color _ink = Color(0xFF181A20);
  static const Color _softPink = Color(0xFFFFEEF5);
  static const Color _softBlue = Color(0xFFE3F2FB);
  static const Color _softGreen = Color(0xFFE5F5EB);
  static const Color _softYellow = Color(0xFFFFF9C9);
  static const Color _border = Color(0xFFDDE7D7);
  static const LatLng _defaultLatLng = LatLng(24.9421, 121.3702);

  final TextEditingController _locationCtrl = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final Set<String> _interests = {'historic', 'food'};
  final Set<String> _planning = {'discounts', 'transit', 'student'};

  final MapController _mapController = MapController();
  String? _selectedPlace;
  LatLng? _selectedLatLng;
  List<Map<String, dynamic>> _suggestions = [];
  bool _showSuggestions = false;
  Timer? _debounce;
  bool _loadingGps = false;

  DateTime _date = DateTime(2026, 6, 20);
  String _travelWith = 'friends';
  String _budget = '1k3k';
  int _step = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_selectedLatLng == null) _useGps();
    });
  }

  @override
  void dispose() {
    _locationCtrl.dispose();
    _scrollController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _goToStep(int step) {
    setState(() => _step = step);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(0);
      }
    });
  }

  Future<void> _useGps() async {
    setState(() => _loadingGps = true);
    try {
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.deniedForever) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Location permission denied')),
          );
        }
        return;
      }
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.medium,
      );
      if (!mounted) return;
      final latlng = LatLng(position.latitude, position.longitude);
      setState(() => _selectedLatLng = latlng);
      _mapController.move(latlng, 14.0);
      await _reverseGeocode(latlng);
    } catch (_) {
      if (!mounted) return;
      setState(() => _selectedLatLng = _defaultLatLng);
    } finally {
      if (mounted) setState(() => _loadingGps = false);
    }
  }

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
        '&format=json&limit=3&addressdetails=1'
        '&accept-language=$lang&countrycodes=tw',
      );
      final response = await http.get(
        uri,
        headers: {'User-Agent': 'PeilarSuperapp/1.0 (contact@example.com)'},
      );
      if (response.statusCode == 200 && mounted) {
        final list = jsonDecode(response.body) as List<dynamic>;
        setState(() {
          _suggestions = list.cast<Map<String, dynamic>>().take(5).toList();
          _showSuggestions = _suggestions.isNotEmpty;
        });
      }
    } catch (_) {}
  }

  Future<void> _pickSuggestion(Map<String, dynamic> suggestion) async {
    final display = suggestion['display_name'] as String? ?? '';
    final name =
        suggestion['name'] as String? ?? display.split(',').first.trim();
    final lat = double.tryParse(suggestion['lat'] as String? ?? '');
    final lon = double.tryParse(suggestion['lon'] as String? ?? '');

    setState(() {
      _locationCtrl.text = display.split(',').take(2).join(',').trim();
      _selectedPlace = name;
      _suggestions = [];
      _showSuggestions = false;
    });

    if (lat != null && lon != null) {
      final geo = LatLng(lat, lon);
      setState(() => _selectedLatLng = geo);
      _mapController.move(geo, 14.0);
    }
  }

  Future<void> _reverseGeocode(LatLng geo) async {
    try {
      final lang = ref.read(languageProvider) == AppLanguage.zh
          ? 'zh-TW'
          : 'en';
      final uri = Uri.parse(
        'https://nominatim.openstreetmap.org/reverse'
        '?lat=${geo.latitude}&lon=${geo.longitude}'
        '&format=json&accept-language=$lang',
      );
      final response = await http.get(
        uri,
        headers: {'User-Agent': 'PeilarSuperapp/1.0 (contact@example.com)'},
      );
      if (response.statusCode == 200 && mounted) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final display = data['display_name'] as String?;
        if (display != null) {
          setState(() {
            _locationCtrl.text = display.split(',').take(2).join(',').trim();
            _selectedPlace = display.split(',').first.trim();
          });
        }
      }
    } catch (_) {}
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime.now(),
      lastDate: DateTime(2028, 12, 31),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(
            primary: _pink,
            onPrimary: Colors.white,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _date = picked);
  }

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
        .set(_selectedLatLng ?? _defaultLatLng);
    await ref.read(itineraryProvider.notifier).generate(request, lang);
    if (!mounted) return;

    ref
        .read(itineraryProvider)
        .when(
          data: (result) {
            if (result != null) context.go('/itinerary-result');
          },
          loading: () {},
          error: (error, stackTrace) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  text['generationError'] ??
                      'Failed to generate itinerary. Please try again.',
                ),
                backgroundColor: const Color(0xFFC6006E),
              ),
            );
          },
        );
  }

  @override
  Widget build(BuildContext context) {
    final text = ref.watch(appTextProvider);
    final isGenerating = ref.watch(itineraryProvider) is AsyncLoading;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          _ItineraryHeader(
            title: text['aiTitle'] ?? 'AI Itinerary',
            onBack: _step == 0 ? () => context.go('/') : () => _goToStep(0),
          ),
          Expanded(
            child: SingleChildScrollView(
              controller: _scrollController,
              padding: const EdgeInsets.fromLTRB(22, 24, 22, 28),
              child: _step == 0
                  ? _buildTripBasics(text)
                  : _buildPreferences(text, isGenerating),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTripBasics(Map<String, String> text) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _StepProgress(current: 1),
        const SizedBox(height: 22),
        _SectionLabel(
          icon: Icons.place_outlined,
          title: text['whereGo'] ?? 'Where do you want to go?',
          color: _pink,
          background: _softPink,
        ),
        const SizedBox(height: 14),
        _buildLocationRow(text),
        if (_showSuggestions && _suggestions.isNotEmpty) ...[
          const SizedBox(height: 8),
          _buildSuggestionsCard(),
        ],
        const SizedBox(height: 16),
        _buildMapCard(text),
        const SizedBox(height: 28),
        _SectionLabel(
          icon: Icons.calendar_month_outlined,
          title: text['whenGo'] ?? 'When do you plan to go?',
          color: _blue,
          background: _softBlue,
        ),
        const SizedBox(height: 14),
        _buildDateRow(),
        const SizedBox(height: 28),
        _SectionLabel(
          icon: Icons.group_outlined,
          title: text['whoGo'] ?? 'Who is going with you?',
          color: _green,
          background: _softGreen,
        ),
        const SizedBox(height: 14),
        _buildCompanionRow(text),
        const SizedBox(height: 28),
        _BenefitBanner(
          title: text['maximizeBenefits'] ?? 'Maximize Your Benefits',
          body:
              text['maximizeBenefitsBody'] ??
              "We'll use your Student EasyCard benefits including student discounts and EasyCard transit offers to build the best itinerary for you.",
        ),
        const SizedBox(height: 24),
        _PinkActionButton(
          label: text['preferences'] ?? 'Preferences',
          icon: Icons.chevron_right,
          onPressed: () => _goToStep(1),
        ),
      ],
    );
  }

  Widget _buildPreferences(Map<String, String> text, bool isGenerating) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _StepProgress(current: 2),
        const SizedBox(height: 22),
        _SectionLabel(
          icon: Icons.favorite_outline,
          title: text['interests'] ?? 'What are you interested in?',
          subtitle: text['chooseAll'] ?? 'Choose all that apply',
          color: _pink,
          background: _softPink,
        ),
        const SizedBox(height: 14),
        _buildInterestsGrid(text),
        const SizedBox(height: 30),
        _SectionLabel(
          icon: Icons.tune,
          title: text['planTripQuestion'] ?? 'How should we plan your trip?',
          color: _green,
          background: _softGreen,
        ),
        const SizedBox(height: 14),
        _buildPlanningOptions(text),
        const SizedBox(height: 28),
        _SectionLabel(
          icon: Icons.account_balance_wallet_outlined,
          title: text['budget'] ?? 'What is your estimated budget?',
          color: _yellow,
          background: _softYellow,
        ),
        const SizedBox(height: 14),
        _buildBudgetDropdown(text),
        const SizedBox(height: 24),
        _BenefitBanner(
          title: text['bestMatchBoundCard'] ?? 'Best match for your bound card',
          body:
              text['bestMatchBoundCardBody'] ??
              'Estimated total savings up to NT\$165 using student admission offers and EasyCard transit discounts.',
        ),
        const SizedBox(height: 24),
        _PinkActionButton(
          label: isGenerating
              ? (text['generating'] ?? 'Generating...')
              : (text['generateItinerary'] ?? 'Generate Itinerary'),
          icon: isGenerating ? null : Icons.auto_awesome,
          busy: isGenerating,
          onPressed: isGenerating ? null : _generate,
        ),
      ],
    );
  }

  Widget _buildLocationRow(Map<String, String> text) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _locationCtrl,
            onChanged: _onLocationChanged,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
            decoration: InputDecoration(
              hintText:
                  text['wherePlaceholder'] ??
                  'e.g. Sanxia Old Street, Zushi Temple',
              prefixIcon: const Icon(Icons.search, color: _green, size: 20),
              hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 18,
                vertical: 18,
              ),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(22),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: const BorderSide(color: _pink, width: 1.4),
                borderRadius: BorderRadius.circular(22),
              ),
            ),
          ),
        ),
        const SizedBox(width: 14),
        SizedBox(
          width: 54,
          height: 54,
          child: IconButton.filled(
            tooltip: text['useMyLocation'] ?? 'Use my location',
            onPressed: _loadingGps ? null : _useGps,
            icon: _loadingGps
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.my_location, size: 24),
            style: IconButton.styleFrom(
              backgroundColor: const Color(0xFFF1F1F1),
              foregroundColor: Colors.grey.shade800,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSuggestionsCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.07),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: _suggestions.map((suggestion) {
          final display = suggestion['display_name'] as String? ?? '';
          final name = (suggestion['name'] as String? ?? '').isNotEmpty
              ? suggestion['name'] as String
              : display.split(',').first.trim();
          final secondary = display.split(',').skip(1).take(2).join(',').trim();
          return InkWell(
            onTap: () => _pickSuggestion(suggestion),
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  const Icon(Icons.place_outlined, color: _pink, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          style: const TextStyle(
                            color: _ink,
                            fontWeight: FontWeight.w800,
                            fontSize: 14,
                          ),
                        ),
                        if (secondary.isNotEmpty)
                          Text(
                            secondary,
                            style: TextStyle(
                              color: Colors.grey.shade500,
                              fontSize: 12,
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

  Widget _buildMapCard(Map<String, String> text) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: SizedBox(
        height: 190,
        width: double.infinity,
        child: Stack(
          children: [
            FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: _selectedLatLng ?? _defaultLatLng,
                initialZoom: 13.0,
                onPositionChanged: (camera, hasGesture) {
                  if (hasGesture && mounted) {
                    setState(() => _selectedLatLng = camera.center);
                  }
                },
              ),
              children: [
                TileLayer(
                  urlTemplate:
                      'https://{s}.basemaps.cartocdn.com/rastertiles/voyager/{z}/{x}/{y}.png',
                  subdomains: const ['a', 'b', 'c', 'd'],
                  userAgentPackageName: 'com.peilar.superapp',
                ),
              ],
            ),
            const Center(
              child: Padding(
                padding: EdgeInsets.only(bottom: 34),
                child: Icon(
                  Icons.location_pin,
                  color: Color(0xFF0E9A33),
                  size: 54,
                  shadows: [
                    Shadow(
                      color: Colors.black26,
                      blurRadius: 8,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              right: 18,
              bottom: 18,
              child: FilledButton.icon(
                onPressed: _loadingGps ? null : _useGps,
                icon: const Icon(Icons.map_outlined, size: 18),
                label: Text(text['useMyLocation'] ?? 'Use my location'),
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: _ink,
                  elevation: 8,
                  shadowColor: Colors.black.withValues(alpha: 0.18),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateRow() {
    final weekday = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return InkWell(
      onTap: _pickDate,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        height: 54,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Row(
          children: [
            const Icon(Icons.calendar_month, color: _pink, size: 21),
            const SizedBox(width: 12),
            Text(
              '${_date.year} / ${_date.month.toString().padLeft(2, '0')} / ${_date.day.toString().padLeft(2, '0')} (${weekday[_date.weekday - 1]})',
              style: const TextStyle(
                color: _ink,
                fontSize: 15,
                fontWeight: FontWeight.w900,
              ),
            ),
            const Spacer(),
            const Icon(Icons.keyboard_arrow_down, color: _pink, size: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildCompanionRow(Map<String, String> text) {
    final options = [
      ('solo', text['solo'] ?? 'Solo', Icons.person_outline),
      ('friends', text['friends'] ?? 'Friends', Icons.groups),
      ('family', text['family'] ?? 'Family', Icons.family_restroom),
    ];

    return Row(
      children: options.asMap().entries.map((entry) {
        final option = entry.value;
        final selected = _travelWith == option.$1;
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(
              right: entry.key < options.length - 1 ? 12 : 0,
            ),
            child: InkWell(
              onTap: () => setState(() => _travelWith = option.$1),
              borderRadius: BorderRadius.circular(18),
              child: Container(
                height: 72,
                decoration: BoxDecoration(
                  color: selected ? _softPink : Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: selected ? _pink : Colors.grey.shade300,
                    width: selected ? 1.3 : 1,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      option.$3,
                      color: selected ? _pink : Colors.grey.shade700,
                      size: 28,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      option.$2,
                      style: TextStyle(
                        color: selected ? _pink : Colors.grey.shade800,
                        fontSize: 13,
                        fontWeight: FontWeight.w900,
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

  Widget _buildInterestsGrid(Map<String, String> text) {
    final options = [
      (
        'historic',
        text['historicLandmarks'] ?? 'Historic Landmarks',
        Icons.account_balance_outlined,
      ),
      (
        'food',
        text['deliciousFoods'] ?? 'Delicious Foods',
        Icons.restaurant_outlined,
      ),
      ('art', text['artGalleries'] ?? 'Art Galleries', Icons.palette_outlined),
      ('hiking', text['hiking'] ?? 'Hiking', Icons.hiking),
      ('shopping', text['shopping'] ?? 'Shopping', Icons.shopping_bag_outlined),
      (
        'mustSee',
        text['mustSeeAttractions'] ?? 'Must-see Attractions',
        Icons.star_outline,
      ),
    ];

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 14,
      mainAxisSpacing: 14,
      childAspectRatio: 2.8,
      children: options.map((option) {
        final selected = _interests.contains(option.$1);
        return InkWell(
          onTap: () => setState(() {
            if (selected) {
              _interests.remove(option.$1);
            } else {
              _interests.add(option.$1);
            }
          }),
          borderRadius: BorderRadius.circular(18),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              color: selected ? _softPink : Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: selected ? _pink : Colors.grey.shade300,
                width: selected ? 1.3 : 1,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  selected ? Icons.check_box : Icons.check_box_outline_blank,
                  color: selected ? _pink : Colors.grey.shade700,
                  size: 22,
                ),
                const SizedBox(width: 12),
                Icon(
                  option.$3,
                  color: selected ? _pink : Colors.grey.shade700,
                  size: 26,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    option.$2,
                    style: TextStyle(
                      color: selected ? _pink : Colors.grey.shade800,
                      fontSize: 13,
                      fontWeight: FontWeight.w900,
                      height: 1.15,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildPlanningOptions(Map<String, String> text) {
    final options = [
      (
        'discounts',
        text['prioritizeDiscounts'] ?? 'Prioritize Discounts',
        Icons.local_offer_outlined,
      ),
      (
        'transit',
        text['useEasyCardTransit'] ?? 'Use EasyCard Transit',
        Icons.directions_bus_outlined,
      ),
      (
        'student',
        text['studentOffers'] ?? 'Student Offers',
        Icons.school_outlined,
      ),
    ];

    return Row(
      children: options.asMap().entries.map((entry) {
        final option = entry.value;
        final selected = _planning.contains(option.$1);
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(
              right: entry.key < options.length - 1 ? 10 : 0,
            ),
            child: InkWell(
              onTap: () => setState(() {
                if (selected) {
                  _planning.remove(option.$1);
                } else {
                  _planning.add(option.$1);
                }
              }),
              borderRadius: BorderRadius.circular(16),
              child: Container(
                constraints: const BoxConstraints(minHeight: 80),
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: selected ? _softPink : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: selected ? _pink : Colors.grey.shade300,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          selected
                              ? Icons.check_box
                              : Icons.check_box_outline_blank,
                          color: selected ? _pink : Colors.grey.shade500,
                          size: 18,
                        ),
                        const SizedBox(width: 4),
                        Icon(
                          option.$3,
                          color: selected ? _pink : Colors.grey.shade600,
                          size: 20,
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      option.$2,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: selected ? _pink : Colors.grey.shade800,
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                        height: 1.2,
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

  Widget _buildBudgetDropdown(Map<String, String> text) {
    final options = [
      ('under1k', text['budgetUnder1k'] ?? 'Under NT\$1,000'),
      ('1k3k', text['budget1k3k'] ?? 'NT\$1,000-3,000'),
      ('3k5k', text['budget3k5k'] ?? 'NT\$3,000-5,000'),
      ('over5k', text['budgetOver5k'] ?? 'Over NT\$5,000'),
    ];

    return Container(
      height: 54,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _budget,
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down, color: _ink, size: 24),
          dropdownColor: Colors.white,
          style: const TextStyle(
            color: _ink,
            fontWeight: FontWeight.w900,
            fontSize: 15,
          ),
          items: options
              .map(
                (option) => DropdownMenuItem(
                  value: option.$1,
                  child: Row(
                    children: [
                      const Icon(
                        Icons.payments_outlined,
                        color: _ink,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Text(option.$2),
                    ],
                  ),
                ),
              )
              .toList(),
          onChanged: (value) {
            if (value != null) setState(() => _budget = value);
          },
        ),
      ),
    );
  }
}

class _ItineraryHeader extends StatelessWidget {
  final String title;
  final VoidCallback onBack;

  const _ItineraryHeader({required this.title, required this.onBack});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black,
      padding: EdgeInsets.fromLTRB(
        18,
        MediaQuery.of(context).padding.top + 12,
        18,
        18,
      ),
      child: Column(
        children: [
          Row(
            children: [
              IconButton(
                onPressed: onBack,
                icon: const Icon(
                  Icons.arrow_back,
                  color: Colors.white,
                  size: 28,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              const LanguageToggle(darkMode: true),
            ],
          ),
        ],
      ),
    );
  }
}

class _StepProgress extends StatelessWidget {
  final int current;

  const _StepProgress({required this.current});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (index) {
        final step = index + 1;
        final active = step == current;
        final done = step < current;
        final stepColor = const [
          Color(0xFFC6006E),
          Color(0xFF0079BF),
          Color(0xFF0E9A33),
        ][index];
        return Row(
          children: [
            Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: active || done ? stepColor : Colors.grey.shade200,
                shape: BoxShape.circle,
                border: Border.all(
                  color: active || done ? stepColor : Colors.grey.shade300,
                ),
              ),
              child: Center(
                child: Text(
                  '$step',
                  style: TextStyle(
                    color: active || done ? Colors.white : Colors.grey.shade600,
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ),
            if (step < 3)
              Container(
                width: 36,
                height: 3,
                color: done ? const Color(0xFFEDA944) : Colors.grey.shade300,
              ),
          ],
        );
      }),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Color color;
  final Color background;

  const _SectionLabel({
    required this.icon,
    required this.title,
    this.subtitle,
    this.color = const Color(0xFFC6006E),
    this.background = const Color(0xFFFFEEF5),
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(color: background, shape: BoxShape.circle),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 3),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Color(0xFF181A20),
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    height: 1.1,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 6),
                  Text(
                    subtitle!,
                    style: TextStyle(
                      color: Colors.grey.shade500,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _BenefitBanner extends StatelessWidget {
  final String title;
  final String body;

  const _BenefitBanner({required this.title, required this.body});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F6FF),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFB9D8FF)),
      ),
      child: Row(
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFFD7E7FF)),
            ),
            child: const Icon(
              Icons.local_offer_outlined,
              color: Color(0xFF0079BF),
              size: 30,
            ),
          ),
          const SizedBox(width: 18),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Color(0xFF0079BF),
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  body,
                  style: const TextStyle(
                    color: Color(0xFF2F3338),
                    fontSize: 14,
                    height: 1.35,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PinkActionButton extends StatelessWidget {
  final String label;
  final IconData? icon;
  final bool busy;
  final VoidCallback? onPressed;

  const _PinkActionButton({
    required this.label,
    required this.onPressed,
    this.icon,
    this.busy = false,
  });

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null;
    return Opacity(
      opacity: enabled ? 1 : 0.62,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: enabled ? onPressed : null,
          borderRadius: BorderRadius.circular(22),
          child: Ink(
            width: double.infinity,
            height: 56,
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(22),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (busy)
                  const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2.5,
                    ),
                  )
                else if (icon != null)
                  Icon(icon, size: 22, color: Colors.white),
                if (busy || icon != null) const SizedBox(width: 10),
                Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
