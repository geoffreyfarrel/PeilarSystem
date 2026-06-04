import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../widgets/bottom_nav_bar.dart';

class SecondhandMarketplacePage extends StatefulWidget {
  const SecondhandMarketplacePage({super.key});

  @override
  State<SecondhandMarketplacePage> createState() =>
      _SecondhandMarketplacePageState();
}

enum _MarketLanguage { en, zh }

enum _MarketTab { browse, search, sell, inbox, profile }

const Set<String> _allMarketCategories = <String>{
  'books',
  'men',
  'women',
  'fashion',
  'footwear',
  'electronics',
  'clothing',
  'sports',
  'jewelry',
  'gaming',
  'car',
  'tools',
  'furniture',
  'hobby',
};

class _SecondhandMarketplacePageState extends State<SecondhandMarketplacePage> {
  _MarketLanguage _language = _MarketLanguage.en;
  _MarketTab _tab = _MarketTab.browse;
  bool _showFilter = false;
  MarketProduct? _selectedProduct;
  final Set<int> _favorites = <int>{};
  Set<String> _appliedCategories = <String>{};

  String get _langKey => _language == _MarketLanguage.zh ? 'zh' : 'en';

  String t(String key) => _marketText[_langKey]?[key] ?? key;

  void _openFilterSheet() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.45),
      builder: (context) {
        return _FilterSheet(
          text: t,
          onApply: (categories) {
            setState(() {
              _tab = _MarketTab.search;
              _appliedCategories = categories.isEmpty
                  ? _allMarketCategories
                  : categories;
              _selectedProduct = null;
            });
            Navigator.of(context).pop();
          },
        );
      },
    );
  }

  void _toggleLanguage() {
    setState(() {
      _language = _language == _MarketLanguage.en
          ? _MarketLanguage.zh
          : _MarketLanguage.en;
    });
  }

  void _handleTabPress(_MarketTab tab) {
    setState(() {
      _tab = tab;
      _showFilter = false;
      _selectedProduct = null;
    });
  }

  void _toggleFavorite(int id) {
    setState(() {
      if (_favorites.contains(id)) {
        _favorites.remove(id);
      } else {
        _favorites.add(id);
      }
    });
  }

  void _openPaymentSheet() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.5),
      builder: (context) {
        return _PaymentSheet(text: t, languageKey: _langKey);
      },
    );
  }

  Widget _renderScreen() {
    if (_selectedProduct != null) {
      return _ProductScreen(
        text: t,
        languageKey: _langKey,
        product: _selectedProduct!,
        onBack: () => setState(() => _selectedProduct = null),
        onPay: _openPaymentSheet,
      );
    }

    if (_showFilter) {
      return _FilterScreen(
        text: t,
        onBack: () => setState(() => _showFilter = false),
      );
    }

    switch (_tab) {
      case _MarketTab.browse:
        return _BrowseScreen(
          text: t,
          languageKey: _langKey,
          favorites: _favorites,
          onFavoriteTap: _toggleFavorite,
          onProductTap: (product) => setState(() => _selectedProduct = product),
          onSearchTap: () => _handleTabPress(_MarketTab.search),
          onFilterTap: _openFilterSheet,
        );
      case _MarketTab.search:
        return _SearchScreen(
          text: t,
          languageKey: _langKey,
          appliedCategories: _appliedCategories,
          onFilterTap: _openFilterSheet,
          onProductTap: (product) => setState(() => _selectedProduct = product),
          onClearFilters: () => setState(() => _appliedCategories = <String>{}),
        );
      case _MarketTab.sell:
        return _SellScreen(
          text: t,
          onClose: () => _handleTabPress(_MarketTab.browse),
        );
      case _MarketTab.inbox:
        return _InboxScreen(text: t);
      case _MarketTab.profile:
        return _ProfileScreen(
          text: t,
          onLanguageTap: _toggleLanguage,
          onPaymentTap: _openPaymentSheet,
          onMenuTap: (label) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(label)));
          },
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _MarketColors.white,
      bottomNavigationBar: const BottomNavBar(),
      body: SafeArea(
        child: Column(
          children: [
            _MarketHeader(
              title: t('appName'),
              currentTab: _tab,
              text: t,
              language: _language,
              onTabSelected: _handleTabPress,
              onLanguageSelected: (language) =>
                  setState(() => _language = language),
            ),
            Expanded(child: ClipRect(child: _renderScreen())),
          ],
        ),
      ),
    );
  }
}

class _MarketColors {
  static const Color primary = Color(0xFF0079BF);
  static const Color danger = Color(0xFFC6006E);
  static const Color warning = Color(0xFFEDA944);
  static const Color success = Color(0xFF0E9A33);
  static const Color bg = Color(0xFFF7F7F7);
  static const Color white = Color(0xFFFFFFFF);
  static const Color text = Color(0xFF1A1A1A);
  static const Color textMuted = Color(0xFF6B7280);
  static const Color border = Color(0xFFE5E7EB);
}

class _MarketHeader extends StatelessWidget {
  final String title;
  final _MarketTab currentTab;
  final String Function(String key) text;
  final _MarketLanguage language;
  final ValueChanged<_MarketTab> onTabSelected;
  final ValueChanged<_MarketLanguage> onLanguageSelected;

  const _MarketHeader({
    required this.title,
    required this.currentTab,
    required this.text,
    required this.language,
    required this.onTabSelected,
    required this.onLanguageSelected,
  });

  static const List<_MarketMenuSpec> _items = [
    _MarketMenuSpec(_MarketTab.browse, Icons.apps_rounded, 'browse'),
    _MarketMenuSpec(_MarketTab.search, Icons.search_rounded, 'search'),
    _MarketMenuSpec(_MarketTab.sell, Icons.add_rounded, 'sell'),
    _MarketMenuSpec(_MarketTab.inbox, Icons.mail_outline_rounded, 'inbox'),
    _MarketMenuSpec(
      _MarketTab.profile,
      Icons.person_outline_rounded,
      'profile',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 12, 10, 10),
      decoration: const BoxDecoration(
        color: _MarketColors.text,
        border: Border(bottom: BorderSide(color: _MarketColors.text)),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: _MarketColors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.menu_book_rounded,
              color: _MarketColors.primary,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: _MarketColors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  text(
                    _items
                        .firstWhere((item) => item.tab == currentTab)
                        .labelKey,
                  ),
                  style: const TextStyle(
                    color: _MarketColors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          _MarketLanguageToggle(
            language: language,
            onSelected: onLanguageSelected,
          ),
          const SizedBox(width: 4),
          PopupMenuButton<_MarketTab>(
            tooltip: 'Secondhand menu',
            icon: const Icon(
              Icons.menu_rounded,
              color: _MarketColors.white,
              size: 28,
            ),
            onSelected: onTabSelected,
            itemBuilder: (context) {
              return _items.map((item) {
                final active = item.tab == currentTab;
                return PopupMenuItem<_MarketTab>(
                  value: item.tab,
                  child: Row(
                    children: [
                      Icon(
                        item.icon,
                        color: active
                            ? _MarketColors.primary
                            : _MarketColors.textMuted,
                        size: 20,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          text(item.labelKey),
                          style: TextStyle(
                            color: active
                                ? _MarketColors.primary
                                : _MarketColors.text,
                            fontWeight: active
                                ? FontWeight.w700
                                : FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList();
            },
          ),
        ],
      ),
    );
  }
}

class _MarketLanguageToggle extends StatelessWidget {
  final _MarketLanguage language;
  final ValueChanged<_MarketLanguage> onSelected;

  const _MarketLanguageToggle({
    required this.language,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _MarketLanguageOption(
            label: '繁中',
            selected: language == _MarketLanguage.zh,
            onTap: () => onSelected(_MarketLanguage.zh),
          ),
          _MarketLanguageOption(
            label: 'EN',
            selected: language == _MarketLanguage.en,
            onTap: () => onSelected(_MarketLanguage.en),
          ),
        ],
      ),
    );
  }
}

class _MarketLanguageOption extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _MarketLanguageOption({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: selected ? _MarketColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: selected ? FontWeight.w800 : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

class _MarketMenuSpec {
  final _MarketTab tab;
  final IconData icon;
  final String labelKey;

  const _MarketMenuSpec(this.tab, this.icon, this.labelKey);
}

const Map<String, Map<String, String>> _marketText = {
  'en': {
    'appName': 'EasyMarket',
    'browse': 'Browse',
    'search': 'Search',
    'sell': 'Sell',
    'inbox': 'Inbox',
    'profile': 'Profile',
    'recommended': 'Recommended for you',
    'all': 'All',
    'books': 'Books',
    'men': 'Men',
    'women': 'Women',
    'footwear': 'Footwear',
    'findWhat': 'Find what you need...',
    'filter': 'Filter',
    'clearAll': 'Clear all',
    'category': 'Category',
    'sortBy': 'Sort by',
    'newestFirst': 'Newest First',
    'priceRange': 'Price Range',
    'condition': 'Condition',
    'deliveryOptions': 'Delivery Options',
    'availableShipping': 'Available for Shipping',
    'localPickup': 'Local Pickups Only',
    'applyFilters': 'Apply Filters',
    'sellAnItem': 'Sell an item',
    'title': 'Title',
    'description': 'Description',
    'details': 'Details',
    'brand': 'Brand',
    'author': 'Author',
    'size': 'Size',
    'price': 'Price',
    'postItem': 'Post Item',
    'favorites': 'Favorites',
    'balance': 'Balance',
    'notifications': 'Notifications',
    'shippingPreferences': 'Shipping preferences',
    'myOrders': 'My orders',
    'settings': 'Settings',
    'helpCenter': 'Help center',
    'aboutUs': 'About us',
    'noReviewsYet': 'No reviews yet',
    'pay': 'Pay',
    'receive': 'Receive',
    'scanQR': 'Scan QR Code',
    'showQR': 'Show My QR Code',
    'paymentTitle': 'Payment',
    'scanToPay': 'Scan to Pay',
    'myQRCode': 'My QR Code',
    'amount': 'Amount (TWD)',
    'confirm': 'Confirm Payment',
    'cancel': 'Cancel',
    'close': 'Close',
    'enterAmount': 'Enter amount',
    'paymentSuccess': 'Payment Successful!',
    'back': 'Back',
    'likeNew': 'Like new',
    'veryGood': 'Very good',
    'good': 'Good',
    'new': 'New',
    'language': '繁中',
    'electronics': 'Electronics',
    'fashion': 'Fashion',
    'sports': 'Sports',
    'tools': 'Tools',
    'gaming': 'Gaming',
    'furniture': 'Furniture',
    'clothing': 'Clothing',
    'jewelry': 'Jewelry',
    'car': 'Car',
    'hobby': 'Hobby',
    'sneakers': 'Sneakers',
    'nike': 'Nike',
    'eu42': 'EU 42',
    'messages': 'Messages',
    'noMessages': 'No messages yet',
    'itemPosted': 'Item posted successfully!',
    'cameraPreview': 'Camera Preview',
    'marketId': 'EasyMarket ID: #38291',
    'addPhoto': 'Upload photos',
    'postedBack': 'Returning to marketplace...',
  },
  'zh': {
    'appName': '易市場',
    'browse': '瀏覽',
    'search': '搜尋',
    'sell': '賣出',
    'inbox': '收件匣',
    'profile': '個人',
    'recommended': '為您推薦',
    'all': '全部',
    'books': '二手書',
    'men': '男裝',
    'women': '女裝',
    'footwear': '鞋類',
    'findWhat': '找找您需要的...',
    'filter': '篩選',
    'clearAll': '清除全部',
    'category': '類別',
    'sortBy': '排序',
    'newestFirst': '最新優先',
    'priceRange': '價格範圍',
    'condition': '狀態',
    'deliveryOptions': '配送選項',
    'availableShipping': '可郵寄',
    'localPickup': '僅限自取',
    'applyFilters': '套用篩選',
    'sellAnItem': '刊登物品',
    'title': '標題',
    'description': '描述',
    'details': '詳細資料',
    'brand': '品牌',
    'size': '尺寸',
    'price': '價格',
    'postItem': '刊登物品',
    'favorites': '我的收藏',
    'balance': '餘額',
    'notifications': '通知',
    'shippingPreferences': '配送設定',
    'myOrders': '我的訂單',
    'settings': '設定',
    'helpCenter': '幫助中心',
    'aboutUs': '關於我們',
    'noReviewsYet': '尚無評價',
    'pay': '付款',
    'receive': '收款',
    'scanQR': '掃描 QR 碼',
    'showQR': '顯示我的 QR 碼',
    'paymentTitle': '付款',
    'scanToPay': '掃碼付款',
    'myQRCode': '我的 QR 碼',
    'amount': '金額 (新台幣)',
    'confirm': '確認付款',
    'cancel': '取消',
    'close': '關閉',
    'enterAmount': '輸入金額',
    'paymentSuccess': '付款成功！',
    'back': '返回',
    'likeNew': '近全新',
    'veryGood': '非常好',
    'good': '良好',
    'new': '全新',
    'language': 'EN',
    'electronics': '電子產品',
    'fashion': '時尚',
    'sports': '運動',
    'tools': '工具',
    'gaming': '遊戲',
    'furniture': '家具',
    'clothing': '服飾',
    'jewelry': '飾品',
    'car': '汽車用品',
    'hobby': '興趣',
    'sneakers': '運動鞋',
    'nike': 'Nike',
    'eu42': 'EU 42',
    'messages': '訊息',
    'noMessages': '目前沒有訊息',
    'itemPosted': '物品刊登成功！',
    'cameraPreview': '相機預覽',
    'marketId': 'EasyMarket ID: #38291',
    'addPhoto': '上傳照片',
    'postedBack': '正在返回市集...',
  },
};

class MarketProduct {
  final int id;
  final String name;
  final String nameZh;
  final String brand;
  final String size;
  final String conditionKey;
  final int price;
  final IconData icon;
  final String category;
  final String imageUrl;

  const MarketProduct({
    required this.id,
    required this.name,
    required this.nameZh,
    required this.brand,
    required this.size,
    required this.conditionKey,
    required this.price,
    required this.icon,
    required this.category,
    required this.imageUrl,
  });
}

const List<MarketProduct> _products = [
  MarketProduct(
    id: 101,
    name: 'Calculus: Early Transcendentals',
    nameZh: 'Calculus: Early Transcendentals',
    brand: 'James Stewart / Cengage',
    size: '9th ed.',
    conditionKey: 'veryGood',
    price: 42,
    icon: Icons.menu_book_rounded,
    category: 'books',
    imageUrl:
        'https://m.media-amazon.com/images/I/81ziq+bBzdL._AC_UF1000,1000_QL80_.jpg',
  ),
  MarketProduct(
    id: 102,
    name: 'Principles of Economics',
    nameZh: 'Principles of Economics',
    brand: 'N. Gregory Mankiw / Cengage',
    size: '10th ed.',
    conditionKey: 'good',
    price: 35,
    icon: Icons.library_books_rounded,
    category: 'books',
    imageUrl:
        'https://m.media-amazon.com/images/I/71K+PErGErL._AC_UF1000,1000_QL80_.jpg',
  ),
  MarketProduct(
    id: 103,
    name: 'Campbell Biology',
    nameZh: 'Campbell Biology',
    brand: 'Urry, Cain, Wasserman',
    size: '12th ed.',
    conditionKey: 'likeNew',
    price: 48,
    icon: Icons.auto_stories_rounded,
    category: 'books',
    imageUrl:
        'https://down-tw.img.susercontent.com/file/tw-11134207-7r991-loqm1ysiu0l82c',
  ),
  MarketProduct(
    id: 104,
    name: 'Introduction to Algorithms',
    nameZh: 'Introduction to Algorithms',
    brand: 'CLRS / MIT Press',
    size: '4th ed.',
    conditionKey: 'veryGood',
    price: 52,
    icon: Icons.code_rounded,
    category: 'books',
    imageUrl: 'https://pictures.abebooks.com/isbn/9780262533058-us.jpg',
  ),
  MarketProduct(
    id: 1,
    name: 'Nike Tracksuit',
    nameZh: '海軍棒球帽',
    brand: 'Nike',
    size: 'M',
    conditionKey: 'likeNew',
    price: 12,
    icon: Icons.checkroom_rounded,
    category: 'clothing',
    imageUrl:
        'https://images.unsplash.com/photo-1523398002811-999ca8dec234?auto=format&fit=crop&w=600&q=80',
  ),
  MarketProduct(
    id: 2,
    name: 'Adidas Sneakers',
    nameZh: '博世電鑽',
    brand: 'Adidas',
    size: 'US 9',
    conditionKey: 'veryGood',
    price: 22,
    icon: Icons.directions_run_rounded,
    category: 'footwear',
    imageUrl:
        'https://images.unsplash.com/photo-1542291026-7eec264c27ff?auto=format&fit=crop&w=600&q=80',
  ),
  MarketProduct(
    id: 3,
    name: 'Casio Watch',
    nameZh: '深藍西裝',
    brand: 'Casio',
    size: '37 mm',
    conditionKey: 'good',
    price: 34,
    icon: Icons.watch_rounded,
    category: 'jewelry',
    imageUrl:
        'https://images.unsplash.com/photo-1523275335684-37898b6baf30?auto=format&fit=crop&w=600&q=80',
  ),
  MarketProduct(
    id: 4,
    name: 'Puma T-shirt',
    nameZh: '黑色手錶',
    brand: 'Puma',
    size: 'L',
    conditionKey: 'veryGood',
    price: 10,
    icon: Icons.checkroom_outlined,
    category: 'clothing',
    imageUrl:
        'https://images.unsplash.com/photo-1521572163474-6864f9cf17ab?auto=format&fit=crop&w=600&q=80',
  ),
  MarketProduct(
    id: 5,
    name: 'Armani Sunglasses',
    nameZh: 'Nike 運動鞋',
    brand: 'Armani',
    size: '57 mm',
    conditionKey: 'good',
    price: 88,
    icon: Icons.diamond_outlined,
    category: 'fashion',
    imageUrl:
        'https://images.unsplash.com/photo-1511499767150-a48a237f0083?auto=format&fit=crop&w=600&q=80',
  ),
  MarketProduct(
    id: 6,
    name: 'Vans Sneakers',
    nameZh: '夏日洋裝',
    brand: 'Vans',
    size: 'US 10',
    conditionKey: 'veryGood',
    price: 14,
    icon: Icons.directions_run_rounded,
    category: 'footwear',
    imageUrl:
        'https://images.unsplash.com/photo-1525966222134-fcfa99b8ae77?auto=format&fit=crop&w=600&q=80',
  ),
  MarketProduct(
    id: 7,
    name: 'Zara Hoodie',
    nameZh: 'Zara Hoodie',
    brand: 'Zara',
    size: 'S',
    conditionKey: 'good',
    price: 19,
    icon: Icons.checkroom_rounded,
    category: 'men',
    imageUrl:
        'https://images.unsplash.com/photo-1578587018452-892bacefd3f2?auto=format&fit=crop&w=600&q=80',
  ),
  MarketProduct(
    id: 8,
    name: 'Wireless Earbuds',
    nameZh: 'Wireless Earbuds',
    brand: 'Sony',
    size: '2.5 x 1.5 cm',
    conditionKey: 'likeNew',
    price: 28,
    icon: Icons.headphones_rounded,
    category: 'electronics',
    imageUrl:
        'https://images.unsplash.com/photo-1606220945770-b5b6c2c55bf1?auto=format&fit=crop&w=600&q=80',
  ),
  MarketProduct(
    id: 9,
    name: 'Pink Wallet',
    nameZh: 'Pink Wallet',
    brand: 'Coach',
    size: 'S',
    conditionKey: 'good',
    price: 9,
    icon: Icons.account_balance_wallet_outlined,
    category: 'women',
    imageUrl:
        'https://images.unsplash.com/photo-1627123424574-724758594e93?auto=format&fit=crop&w=600&q=80',
  ),
  MarketProduct(
    id: 10,
    name: 'Logitech Mouse',
    nameZh: 'Logitech Mouse',
    brand: 'Logitech',
    size: 'M',
    conditionKey: 'veryGood',
    price: 16,
    icon: Icons.mouse_outlined,
    category: 'gaming',
    imageUrl:
        'https://images.unsplash.com/photo-1615663245857-ac93bb7c39e7?auto=format&fit=crop&w=600&q=80',
  ),
];

class _BrowseScreen extends StatefulWidget {
  final String Function(String key) text;
  final String languageKey;
  final Set<int> favorites;
  final ValueChanged<int> onFavoriteTap;
  final ValueChanged<MarketProduct> onProductTap;
  final VoidCallback onSearchTap;
  final VoidCallback onFilterTap;

  const _BrowseScreen({
    required this.text,
    required this.languageKey,
    required this.favorites,
    required this.onFavoriteTap,
    required this.onProductTap,
    required this.onSearchTap,
    required this.onFilterTap,
  });

  @override
  State<_BrowseScreen> createState() => _BrowseScreenState();
}

class _BrowseScreenState extends State<_BrowseScreen> {
  String _activeTab = 'all';
  static const List<String> _tabs = [
    'all',
    'books',
    'men',
    'women',
    'footwear',
    'electronics',
    'clothing',
    'sports',
    'fashion',
    'jewelry',
    'gaming',
    'tools',
    'furniture',
    'hobby',
  ];

  @override
  Widget build(BuildContext context) {
    final filtered = _activeTab == 'all'
        ? _products
        : _products.where((p) => p.category == _activeTab).toList();

    return Container(
      color: _MarketColors.bg,
      child: Column(
        children: [
          Container(
            color: _MarketColors.white,
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _SearchBoxPlaceholder(
                        text: widget.text('findWhat'),
                        onTap: widget.onSearchTap,
                      ),
                    ),
                    const SizedBox(width: 10),
                    IconButton(
                      onPressed: widget.onFilterTap,
                      icon: const Icon(Icons.tune_rounded),
                      color: _MarketColors.primary,
                      tooltip: widget.text('filter'),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 34,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: _tabs.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(width: 8),
                    itemBuilder: (context, index) {
                      final tab = _tabs[index];
                      final active = _activeTab == tab;
                      return _CategoryChip(
                        label: widget.text(tab),
                        active: active,
                        onTap: () => setState(() => _activeTab = tab),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Text(
                  widget.text('recommended'),
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 17,
                    color: _MarketColors.text,
                  ),
                ),
                const SizedBox(height: 14),
                _ProductGrid(
                  products: filtered,
                  languageKey: widget.languageKey,
                  text: widget.text,
                  favorites: widget.favorites,
                  onFavoriteTap: widget.onFavoriteTap,
                  onProductTap: widget.onProductTap,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SearchBoxPlaceholder extends StatelessWidget {
  final String text;
  final VoidCallback? onTap;

  const _SearchBoxPlaceholder({required this.text, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: _MarketColors.white,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          decoration: BoxDecoration(
            color: _MarketColors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: _MarketColors.border, width: 1.5),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.search_rounded,
                color: _MarketColors.textMuted,
                size: 19,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  text,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: _MarketColors.textMuted,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback onTap;

  const _CategoryChip({
    required this.label,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: active ? _MarketColors.success : _MarketColors.bg,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          child: Text(
            label,
            style: TextStyle(
              color: active ? Colors.white : _MarketColors.text,
              fontWeight: active ? FontWeight.w600 : FontWeight.w400,
              fontSize: 13,
            ),
          ),
        ),
      ),
    );
  }
}

class _ProductGrid extends StatelessWidget {
  final List<MarketProduct> products;
  final String languageKey;
  final String Function(String key) text;
  final Set<int> favorites;
  final ValueChanged<int> onFavoriteTap;
  final ValueChanged<MarketProduct> onProductTap;

  const _ProductGrid({
    required this.products,
    required this.languageKey,
    required this.text,
    required this.favorites,
    required this.onFavoriteTap,
    required this.onProductTap,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 0.58,
      ),
      itemCount: products.length,
      itemBuilder: (context, index) {
        final product = products[index];
        final favorite = favorites.contains(product.id);
        return _ProductCard(
          product: product,
          languageKey: languageKey,
          text: text,
          favorite: favorite,
          onFavoriteTap: () => onFavoriteTap(product.id),
          onTap: () => onProductTap(product),
        );
      },
    );
  }
}

class _ProductCard extends StatelessWidget {
  final MarketProduct product;
  final String languageKey;
  final String Function(String key) text;
  final bool favorite;
  final VoidCallback onFavoriteTap;
  final VoidCallback onTap;

  const _ProductCard({
    required this.product,
    required this.languageKey,
    required this.text,
    required this.favorite,
    required this.onFavoriteTap,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final detailLabel = product.category == 'books'
        ? text('details')
        : text('size');

    return Material(
      color: _MarketColors.white,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: _MarketColors.border),
          ),
          clipBehavior: Clip.hardEdge,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _ProductImageArea(
                  icon: product.icon,
                  imageUrl: product.imageUrl,
                  favorite: favorite,
                  onFavoriteTap: onFavoriteTap,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      languageKey == 'zh' ? product.nameZh : product.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: _MarketColors.text,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '$detailLabel ${product.size} · ${text(product.conditionKey)}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: _MarketColors.textMuted,
                        fontSize: 11,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '\$${product.price}.00',
                      style: const TextStyle(
                        color: _MarketColors.success,
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProductImageArea extends StatelessWidget {
  final IconData icon;
  final String imageUrl;
  final bool favorite;
  final VoidCallback onFavoriteTap;

  const _ProductImageArea({
    required this.icon,
    required this.imageUrl,
    required this.favorite,
    required this.onFavoriteTap,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          width: double.infinity,
          color: _MarketColors.bg,
          child: Image.network(
            imageUrl,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => Icon(
              icon,
              size: 52,
              color: _MarketColors.text.withValues(alpha: 0.72),
            ),
          ),
        ),
        Positioned(
          top: 8,
          right: 8,
          child: Material(
            color: favorite ? _MarketColors.danger : _MarketColors.white,
            shape: const CircleBorder(),
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: onFavoriteTap,
              child: SizedBox(
                width: 28,
                height: 28,
                child: Icon(
                  favorite
                      ? Icons.favorite_rounded
                      : Icons.favorite_border_rounded,
                  color: favorite
                      ? _MarketColors.white
                      : _MarketColors.textMuted,
                  size: 16,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _SearchScreen extends StatefulWidget {
  final String Function(String key) text;
  final String languageKey;
  final Set<String> appliedCategories;
  final VoidCallback onFilterTap;
  final ValueChanged<MarketProduct> onProductTap;
  final VoidCallback onClearFilters;

  const _SearchScreen({
    required this.text,
    required this.languageKey,
    required this.appliedCategories,
    required this.onFilterTap,
    required this.onProductTap,
    required this.onClearFilters,
  });

  static const List<_SearchCategorySpec> _categories = [
    _SearchCategorySpec(
      'books',
      Icons.menu_book_rounded,
      _MarketColors.primary,
    ),
    _SearchCategorySpec('men', Icons.checkroom_rounded, _MarketColors.primary),
    _SearchCategorySpec(
      'women',
      Icons.checkroom_outlined,
      _MarketColors.danger,
    ),
    _SearchCategorySpec(
      'footwear',
      Icons.directions_run_rounded,
      _MarketColors.warning,
    ),
    _SearchCategorySpec(
      'electronics',
      Icons.phone_iphone_rounded,
      _MarketColors.success,
    ),
    _SearchCategorySpec(
      'clothing',
      Icons.dry_cleaning_rounded,
      _MarketColors.primary,
    ),
    _SearchCategorySpec(
      'sports',
      Icons.sports_tennis_rounded,
      _MarketColors.danger,
    ),
    _SearchCategorySpec('fashion', Icons.style_rounded, _MarketColors.warning),
    _SearchCategorySpec(
      'jewelry',
      Icons.diamond_outlined,
      _MarketColors.success,
    ),
    _SearchCategorySpec(
      'gaming',
      Icons.sports_esports_rounded,
      _MarketColors.primary,
    ),
    _SearchCategorySpec(
      'car',
      Icons.directions_car_filled_outlined,
      _MarketColors.danger,
    ),
    _SearchCategorySpec('tools', Icons.handyman_rounded, _MarketColors.warning),
    _SearchCategorySpec(
      'furniture',
      Icons.chair_outlined,
      _MarketColors.success,
    ),
    _SearchCategorySpec(
      'hobby',
      Icons.menu_book_rounded,
      _MarketColors.primary,
    ),
  ];

  @override
  State<_SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<_SearchScreen> {
  late final TextEditingController _controller;
  String _query = '';

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _setQuery(String value) {
    _controller.text = value;
    _controller.selection = TextSelection.collapsed(offset: value.length);
    setState(() => _query = value);
  }

  List<MarketProduct> get _results {
    final normalized = _query.trim().toLowerCase();
    if (widget.appliedCategories.isNotEmpty && normalized.isEmpty) {
      return _products
          .where(
            (product) => widget.appliedCategories.contains(product.category),
          )
          .toList();
    }
    if (normalized.isEmpty) return const [];
    return _products.where((product) {
      return product.name.toLowerCase().contains(normalized) ||
          product.category.toLowerCase().contains(normalized) ||
          widget.text(product.category).toLowerCase().contains(normalized) ||
          product.size.toLowerCase().contains(normalized);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final results = _results;
    return Container(
      color: _MarketColors.white,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 20),
            child: _SearchHeader(
              controller: _controller,
              hintText: widget.text('findWhat'),
              onChanged: (value) => setState(() => _query = value),
              onClear: _query.isEmpty ? null : () => _setQuery(''),
              onFilterTap: widget.onFilterTap,
            ),
          ),
          Expanded(
            child: _query.trim().isEmpty && widget.appliedCategories.isEmpty
                ? GridView.count(
                    padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                    crossAxisCount: 3,
                    mainAxisSpacing: 34,
                    crossAxisSpacing: 24,
                    childAspectRatio: 0.86,
                    children: _SearchScreen._categories.map((category) {
                      return _SearchCategoryTile(
                        label: widget.text(category.key),
                        icon: category.icon,
                        color: category.color,
                        onTap: () => _setQuery(category.key),
                      );
                    }).toList(),
                  )
                : _SearchProductResults(
                    products: results,
                    languageKey: widget.languageKey,
                    text: widget.text,
                    onProductTap: widget.onProductTap,
                    onClearFilters: widget.appliedCategories.isEmpty
                        ? null
                        : widget.onClearFilters,
                  ),
          ),
        ],
      ),
    );
  }
}

class _SearchProductResults extends StatelessWidget {
  final List<MarketProduct> products;
  final String languageKey;
  final String Function(String key) text;
  final ValueChanged<MarketProduct> onProductTap;
  final VoidCallback? onClearFilters;

  const _SearchProductResults({
    required this.products,
    required this.languageKey,
    required this.text,
    required this.onProductTap,
    required this.onClearFilters,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      children: [
        if (onClearFilters != null)
          Align(
            alignment: Alignment.centerRight,
            child: _ClearAllButton(
              label: text('clearAll'),
              onPressed: onClearFilters!,
            ),
          ),
        const SizedBox(height: 8),
        if (products.isEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.only(top: 32),
              child: Text(
                text('findWhat'),
                style: const TextStyle(
                  color: _MarketColors.textMuted,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          )
        else
          _ProductGrid(
            products: products,
            languageKey: languageKey,
            text: text,
            favorites: const <int>{},
            onFavoriteTap: (_) {},
            onProductTap: onProductTap,
          ),
      ],
    );
  }
}

class _ClearAllButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;

  const _ClearAllButton({required this.label, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: const Icon(Icons.refresh_rounded, size: 16),
      label: Text(label),
      style: OutlinedButton.styleFrom(
        foregroundColor: _MarketColors.danger,
        side: const BorderSide(color: _MarketColors.danger),
        visualDensity: VisualDensity.compact,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
      ),
    );
  }
}

class _SearchHeader extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final ValueChanged<String> onChanged;
  final VoidCallback? onClear;
  final VoidCallback onFilterTap;

  const _SearchHeader({
    required this.controller,
    required this.hintText,
    required this.onChanged,
    required this.onClear,
    required this.onFilterTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: controller,
            onChanged: onChanged,
            textInputAction: TextInputAction.search,
            decoration: InputDecoration(
              hintText: hintText,
              prefixIcon: const Icon(Icons.search_rounded),
              suffixIcon: onClear == null
                  ? null
                  : IconButton(
                      onPressed: onClear,
                      icon: const Icon(Icons.close_rounded),
                    ),
              filled: true,
              fillColor: _MarketColors.white,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 13,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: _MarketColors.border),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(
                  color: _MarketColors.primary,
                  width: 1.5,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        IconButton(
          onPressed: onFilterTap,
          icon: const Icon(Icons.tune_rounded),
          color: _MarketColors.textMuted,
          tooltip: 'Filter',
        ),
      ],
    );
  }
}

class _SearchCategorySpec {
  final String key;
  final IconData icon;
  final Color color;

  const _SearchCategorySpec(this.key, this.icon, this.color);
}

class _SearchCategoryTile extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _SearchCategoryTile({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            child: Icon(icon, color: _MarketColors.white, size: 28),
          ),
          const SizedBox(height: 10),
          Text(
            label,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: _MarketColors.text,
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterSheet extends StatefulWidget {
  final String Function(String key) text;
  final ValueChanged<Set<String>> onApply;

  const _FilterSheet({required this.text, required this.onApply});

  @override
  State<_FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends State<_FilterSheet> {
  double _priceMax = 800;
  String _condition = 'new';
  bool _shipping = false;
  bool _pickup = false;
  final Set<String> _selectedCategories = <String>{};

  static const List<String> _categories = [
    'books',
    'men',
    'women',
    'fashion',
    'footwear',
    'electronics',
    'clothing',
    'sports',
    'jewelry',
    'gaming',
    'car',
    'tools',
    'furniture',
    'hobby',
  ];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Container(
          width: double.infinity,
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.86,
          ),
          decoration: const BoxDecoration(
            color: _MarketColors.bg,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(
            children: [
              const SizedBox(height: 10),
              Container(
                width: 48,
                height: 4,
                decoration: BoxDecoration(
                  color: _MarketColors.border,
                  borderRadius: BorderRadius.circular(99),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 12),
                child: Row(
                  children: [
                    const SizedBox(width: 116),
                    Expanded(
                      child: Center(
                        child: Text(
                          widget.text('filter'),
                          style: const TextStyle(
                            color: _MarketColors.text,
                            fontSize: 24,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 116,
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: _ClearAllButton(
                          label: widget.text('clearAll'),
                          onPressed: () {
                            setState(() {
                              _selectedCategories.clear();
                              _priceMax = 1000;
                              _condition = 'new';
                              _shipping = false;
                              _pickup = false;
                            });
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1, color: _MarketColors.border),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(24, 22, 24, 24),
                  children: [
                    _FilterSection(
                      title: widget.text('category'),
                      child: Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: _categories.map((category) {
                          final selected = _selectedCategories.contains(
                            category,
                          );
                          return _FilterChipButton(
                            label: widget.text(category),
                            selected: selected,
                            onTap: () {
                              setState(() {
                                if (selected) {
                                  _selectedCategories.remove(category);
                                } else {
                                  _selectedCategories.add(category);
                                }
                              });
                            },
                          );
                        }).toList(),
                      ),
                    ),
                    _FilterSection(
                      title: widget.text('sortBy'),
                      child: _MarketDropdown(
                        value: 'newestFirst',
                        items: ['newestFirst'],
                        text: widget.text,
                        onChanged: (_) {},
                      ),
                    ),
                    _FilterSection(
                      title: widget.text('priceRange'),
                      child: Column(
                        children: [
                          Slider(
                            value: _priceMax,
                            min: 0,
                            max: 1000,
                            divisions: 100,
                            activeColor: _MarketColors.success,
                            inactiveColor: _MarketColors.border,
                            onChanged: (value) =>
                                setState(() => _priceMax = value),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                '\$0',
                                style: TextStyle(
                                  color: _MarketColors.textMuted,
                                  fontSize: 12,
                                ),
                              ),
                              Text(
                                '\$${_priceMax.round()}',
                                style: const TextStyle(
                                  color: _MarketColors.textMuted,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    _FilterSection(
                      title: widget.text('condition'),
                      child: _MarketDropdown(
                        value: _condition,
                        items: const ['new', 'likeNew', 'veryGood', 'good'],
                        text: widget.text,
                        onChanged: (value) =>
                            setState(() => _condition = value ?? 'new'),
                      ),
                    ),
                    _FilterSection(
                      title: widget.text('deliveryOptions'),
                      child: Column(
                        children: [
                          _MarketCheckbox(
                            label: widget.text('availableShipping'),
                            value: _shipping,
                            onChanged: (value) =>
                                setState(() => _shipping = value ?? false),
                          ),
                          _MarketCheckbox(
                            label: widget.text('localPickup'),
                            value: _pickup,
                            onChanged: (value) =>
                                setState(() => _pickup = value ?? false),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 4),
                    SizedBox(
                      height: 48,
                      child: ElevatedButton(
                        onPressed: () => widget.onApply(
                          Set<String>.from(_selectedCategories),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _MarketColors.success,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          widget.text('applyFilters'),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FilterScreen extends StatefulWidget {
  final String Function(String key) text;
  final VoidCallback onBack;

  const _FilterScreen({required this.text, required this.onBack});

  @override
  State<_FilterScreen> createState() => _FilterScreenState();
}

class _FilterScreenState extends State<_FilterScreen> {
  double _priceMax = 800;
  String _condition = 'new';
  bool _shipping = false;
  bool _pickup = false;
  final Set<String> _selectedCategories = <String>{};

  static const List<String> _categories = [
    'books',
    'men',
    'women',
    'fashion',
    'footwear',
    'electronics',
    'clothing',
    'sports',
    'jewelry',
    'gaming',
    'car',
    'tools',
    'furniture',
    'hobby',
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      color: _MarketColors.bg,
      child: Column(
        children: [
          Container(
            color: _MarketColors.white,
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: _SearchBoxPlaceholder(text: widget.text('findWhat')),
                ),
                const SizedBox(width: 10),
                IconButton(
                  onPressed: widget.onBack,
                  icon: const Icon(Icons.close_rounded),
                  color: _MarketColors.danger,
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      widget.text('filter'),
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 18,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _selectedCategories.clear();
                          _priceMax = 1000;
                        });
                      },
                      child: Text(
                        widget.text('clearAll'),
                        style: const TextStyle(color: _MarketColors.danger),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                _FilterSection(
                  title: widget.text('category'),
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _categories.map((category) {
                      final selected = _selectedCategories.contains(category);
                      return _FilterChipButton(
                        label: widget.text(category),
                        selected: selected,
                        onTap: () {
                          setState(() {
                            if (selected) {
                              _selectedCategories.remove(category);
                            } else {
                              _selectedCategories.add(category);
                            }
                          });
                        },
                      );
                    }).toList(),
                  ),
                ),
                _FilterSection(
                  title: widget.text('sortBy'),
                  child: _MarketDropdown(
                    value: 'newestFirst',
                    items: ['newestFirst'],
                    text: widget.text,
                    onChanged: (_) {},
                  ),
                ),
                _FilterSection(
                  title: widget.text('priceRange'),
                  child: Column(
                    children: [
                      Slider(
                        value: _priceMax,
                        min: 0,
                        max: 1000,
                        divisions: 100,
                        activeColor: _MarketColors.success,
                        inactiveColor: _MarketColors.border,
                        onChanged: (value) => setState(() => _priceMax = value),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            '\$0',
                            style: TextStyle(
                              color: _MarketColors.textMuted,
                              fontSize: 12,
                            ),
                          ),
                          Text(
                            '\$${_priceMax.round()}',
                            style: const TextStyle(
                              color: _MarketColors.textMuted,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                _FilterSection(
                  title: widget.text('condition'),
                  child: _MarketDropdown(
                    value: _condition,
                    items: const ['new', 'likeNew', 'veryGood', 'good'],
                    text: widget.text,
                    onChanged: (value) =>
                        setState(() => _condition = value ?? 'new'),
                  ),
                ),
                _FilterSection(
                  title: widget.text('deliveryOptions'),
                  child: Column(
                    children: [
                      _MarketCheckbox(
                        label: widget.text('availableShipping'),
                        value: _shipping,
                        onChanged: (value) =>
                            setState(() => _shipping = value ?? false),
                      ),
                      _MarketCheckbox(
                        label: widget.text('localPickup'),
                        value: _pickup,
                        onChanged: (value) =>
                            setState(() => _pickup = value ?? false),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 4),
                SizedBox(
                  height: 48,
                  child: ElevatedButton(
                    onPressed: widget.onBack,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _MarketColors.success,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      widget.text('applyFilters'),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
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

class _FilterSection extends StatelessWidget {
  final String title;
  final Widget child;

  const _FilterSection({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }
}

class _FilterChipButton extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _FilterChipButton({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? _MarketColors.success : _MarketColors.white,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: selected ? _MarketColors.success : _MarketColors.border,
              width: 1.5,
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: selected ? _MarketColors.white : _MarketColors.text,
              fontSize: 13,
              fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
        ),
      ),
    );
  }
}

class _MarketDropdown extends StatelessWidget {
  final String value;
  final List<String> items;
  final String Function(String key) text;
  final ValueChanged<String?> onChanged;

  const _MarketDropdown({
    required this.value,
    required this.items,
    required this.text,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      initialValue: value,
      items: items.map((item) {
        return DropdownMenuItem<String>(value: item, child: Text(text(item)));
      }).toList(),
      onChanged: onChanged,
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 10,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: _MarketColors.border, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(
            color: _MarketColors.primary,
            width: 1.5,
          ),
        ),
      ),
    );
  }
}

class _MarketCheckbox extends StatelessWidget {
  final String label;
  final bool value;
  final ValueChanged<bool?> onChanged;

  const _MarketCheckbox({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return CheckboxListTile(
      contentPadding: EdgeInsets.zero,
      dense: true,
      controlAffinity: ListTileControlAffinity.leading,
      activeColor: _MarketColors.success,
      title: Text(label, style: const TextStyle(fontSize: 14)),
      value: value,
      onChanged: onChanged,
    );
  }
}

class _SellScreen extends StatefulWidget {
  final String Function(String key) text;
  final VoidCallback onClose;

  const _SellScreen({required this.text, required this.onClose});

  @override
  State<_SellScreen> createState() => _SellScreenState();
}

class _SellScreenState extends State<_SellScreen> {
  final TextEditingController _titleController = TextEditingController(
    text: 'Calculus: Early Transcendentals',
  );
  final TextEditingController _descriptionController = TextEditingController(
    text: 'Used for Calculus I. Clean pages, a few pencil notes.',
  );
  final TextEditingController _brandController = TextEditingController(
    text: 'Stewart',
  );
  final TextEditingController _sizeController = TextEditingController(
    text: '9th edition, hardcover, clean pages',
  );
  final TextEditingController _priceController = TextEditingController(
    text: '42',
  );
  String _category = 'books';
  String _condition = 'veryGood';
  final ImagePicker _imagePicker = ImagePicker();
  final List<Uint8List> _photoBytes = <Uint8List>[];
  bool _posted = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _brandController.dispose();
    _sizeController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  void _handlePost() {
    setState(() => _posted = true);
    Future.delayed(const Duration(milliseconds: 1800), () {
      if (!mounted) return;
      setState(() => _posted = false);
      widget.onClose();
    });
  }

  Future<void> _pickPhoto() async {
    final remainingSlots = 3 - _photoBytes.length;
    if (remainingSlots <= 0) return;

    try {
      final picked = await _imagePicker.pickMultiImage(
        imageQuality: 85,
        limit: remainingSlots,
      );
      if (picked.isEmpty) return;

      final nextPhotos = <Uint8List>[];
      for (final image in picked.take(remainingSlots)) {
        nextPhotos.add(await image.readAsBytes());
      }

      if (!mounted) return;
      setState(() => _photoBytes.addAll(nextPhotos));
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not open image upload. Please try again.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_posted) {
      return Container(
        color: _MarketColors.bg,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.check_circle_rounded,
                size: 64,
                color: _MarketColors.success,
              ),
              const SizedBox(height: 16),
              Text(
                widget.text('itemPosted'),
                style: const TextStyle(
                  color: _MarketColors.success,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                widget.text('postedBack'),
                style: const TextStyle(
                  color: _MarketColors.textMuted,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Container(
      color: _MarketColors.bg,
      child: Column(
        children: [
          Container(
            color: _MarketColors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.text('sellAnItem'),
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 17,
                  ),
                ),
                IconButton(
                  onPressed: widget.onClose,
                  icon: const Icon(Icons.close_rounded),
                  color: _MarketColors.textMuted,
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Row(
                  children: [
                    for (int i = 0; i < _photoBytes.length; i++) ...[
                      _PhotoBox(
                        index: i,
                        bytes: _photoBytes[i],
                        onRemove: () => setState(() => _photoBytes.removeAt(i)),
                      ),
                      const SizedBox(width: 10),
                    ],
                    if (_photoBytes.length < 3)
                      _AddPhotoBox(
                        label: widget.text('addPhoto'),
                        onTap: _pickPhoto,
                      ),
                  ],
                ),
                const SizedBox(height: 16),
                _LabeledTextField(
                  label: widget.text('title'),
                  controller: _titleController,
                  hintText: 'Calculus: Early Transcendentals',
                ),
                const SizedBox(height: 14),
                _LabeledTextField(
                  label: widget.text('description'),
                  controller: _descriptionController,
                  hintText: 'Condition notes, class used for, pickup place...',
                  minLines: 3,
                  maxLines: 4,
                ),
                const SizedBox(height: 14),
                _MarketDropdown(
                  value: _category,
                  items: const [
                    'books',
                    'electronics',
                    'clothing',
                    'footwear',
                    'furniture',
                    'tools',
                    'hobby',
                  ],
                  text: widget.text,
                  onChanged: (value) =>
                      setState(() => _category = value ?? 'books'),
                ),
                const SizedBox(height: 14),
                _LabeledTextField(
                  label: widget.text('brand'),
                  controller: _brandController,
                  hintText: 'Author / publisher / brand',
                ),
                const SizedBox(height: 14),
                _LabeledTextField(
                  label: widget.text('details'),
                  controller: _sizeController,
                  hintText: 'Edition, ISBN, course, pickup place',
                ),
                const SizedBox(height: 14),
                _MarketDropdown(
                  value: _condition,
                  items: const ['new', 'likeNew', 'veryGood', 'good'],
                  text: widget.text,
                  onChanged: (value) =>
                      setState(() => _condition = value ?? 'veryGood'),
                ),
                const SizedBox(height: 14),
                _LabeledTextField(
                  label: widget.text('price'),
                  controller: _priceController,
                  hintText: '42',
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 2),
                const SizedBox(height: 20),
                SizedBox(
                  height: 48,
                  child: ElevatedButton(
                    onPressed: _handlePost,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _MarketColors.success,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      widget.text('postItem'),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
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

class _PhotoBox extends StatelessWidget {
  final int index;
  final Uint8List bytes;
  final VoidCallback onRemove;

  const _PhotoBox({
    required this.index,
    required this.bytes,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: 90,
          height: 90,
          decoration: BoxDecoration(
            color: _MarketColors.bg,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: _MarketColors.border),
          ),
          clipBehavior: Clip.hardEdge,
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.memory(bytes, fit: BoxFit.cover),
              Align(
                alignment: Alignment.bottomLeft,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 3,
                  ),
                  color: Colors.black.withValues(alpha: 0.45),
                  child: Text(
                    'Photo ${index + 1}',
                    style: const TextStyle(
                      color: _MarketColors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        Positioned(
          top: -6,
          right: -6,
          child: InkWell(
            onTap: onRemove,
            customBorder: const CircleBorder(),
            child: Container(
              width: 22,
              height: 22,
              decoration: const BoxDecoration(
                color: _MarketColors.danger,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.close_rounded,
                color: Colors.white,
                size: 12,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _AddPhotoBox extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _AddPhotoBox({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: label,
      child: Material(
        color: _MarketColors.warning,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: SizedBox(
            width: 90,
            height: 90,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.add_photo_alternate_rounded,
                  size: 28,
                  color: _MarketColors.white,
                ),
                const SizedBox(height: 6),
                Text(
                  label,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: _MarketColors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
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

class _LabeledTextField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final String hintText;
  final int minLines;
  final int maxLines;
  final TextInputType? keyboardType;

  const _LabeledTextField({
    required this.label,
    required this.controller,
    required this.hintText,
    this.minLines = 1,
    this.maxLines = 1,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          minLines: minLines,
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: hintText,
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 10,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(
                color: _MarketColors.border,
                width: 1.5,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(
                color: _MarketColors.primary,
                width: 1.5,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _InboxScreen extends StatelessWidget {
  final String Function(String key) text;

  const _InboxScreen({required this.text});

  static const List<_InboxThread> _threads = [
    _InboxThread(
      name: 'Ming Chen',
      item: 'Calculus: Early Transcendentals',
      message: 'Can we meet near the library at 3 PM?',
      time: '12:48',
      color: _MarketColors.primary,
      unread: true,
    ),
    _InboxThread(
      name: 'Yu Ting',
      item: 'Campbell Biology',
      message: 'Is the access code already used?',
      time: '11:20',
      color: _MarketColors.success,
      unread: true,
    ),
    _InboxThread(
      name: 'Alex Wang',
      item: 'Introduction to Algorithms',
      message: 'I can pick it up after data structures class.',
      time: 'Yesterday',
      color: _MarketColors.warning,
      unread: false,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      color: _MarketColors.bg,
      child: Column(
        children: [
          Container(
            width: double.infinity,
            color: _MarketColors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Text(
              text('messages'),
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 17),
            ),
          ),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: _threads.length,
              separatorBuilder: (context, index) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final thread = _threads[index];
                return _InboxThreadTile(thread: thread);
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _InboxThread {
  final String name;
  final String item;
  final String message;
  final String time;
  final Color color;
  final bool unread;

  const _InboxThread({
    required this.name,
    required this.item,
    required this.message,
    required this.time,
    required this.color,
    required this.unread,
  });
}

class _InboxThreadTile extends StatelessWidget {
  final _InboxThread thread;

  const _InboxThreadTile({required this.thread});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: _MarketColors.white,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: () {},
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: thread.color,
                child: Text(
                  thread.name.substring(0, 1),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            thread.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 15,
                            ),
                          ),
                        ),
                        Text(
                          thread.time,
                          style: const TextStyle(
                            color: _MarketColors.textMuted,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      thread.item,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: _MarketColors.primary,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      thread.message,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: _MarketColors.textMuted,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              if (thread.unread) ...[
                const SizedBox(width: 10),
                Container(
                  width: 9,
                  height: 9,
                  decoration: const BoxDecoration(
                    color: _MarketColors.danger,
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _ProfileScreen extends StatelessWidget {
  final String Function(String key) text;
  final VoidCallback onLanguageTap;
  final VoidCallback onPaymentTap;
  final ValueChanged<String> onMenuTap;

  const _ProfileScreen({
    required this.text,
    required this.onLanguageTap,
    required this.onPaymentTap,
    required this.onMenuTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: _MarketColors.bg,
      child: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF515F49), Color(0xFF79926C)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(28),
            ),
            child: Column(
              children: [
                Container(
                  width: 76,
                  height: 76,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.school_rounded,
                    color: Color(0xFF515F49),
                    size: 42,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Verified Student',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'NTPU Student ID bound',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: _MarketColors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: _MarketColors.border),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.verified, color: _MarketColors.primary),
                    SizedBox(width: 8),
                    Text(
                      'Student Account',
                      style: TextStyle(
                        color: Color(0xFF515F49),
                        fontSize: 17,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 14),
                _StudentProfileRow(label: 'Student ID', value: '411000000'),
                _StudentProfileRow(label: 'Name', value: 'Daniel Kuo'),
                _StudentProfileRow(
                  label: 'Email',
                  value: 'daniel@gm.ntpu.edu.tw',
                ),
                _StudentProfileRow(label: 'Major', value: 'Computer Science'),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _StudentMarketStat(
            icon: Icons.menu_book_rounded,
            title: 'Academic book seller',
            subtitle: '4 listed textbooks · 98% response rate',
            color: _MarketColors.primary,
          ),
          const SizedBox(height: 10),
          _StudentMarketStat(
            icon: Icons.lock_rounded,
            title: 'Verified campus trading',
            subtitle: 'Only bound students can contact and buy',
            color: _MarketColors.success,
          ),
        ],
      ),
    );
  }
}

class _StudentProfileRow extends StatelessWidget {
  final String label;
  final String value;

  const _StudentProfileRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 7),
      child: Row(
        children: [
          SizedBox(
            width: 88,
            child: Text(
              label,
              style: TextStyle(
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: Color(0xFF2F2929),
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StudentMarketStat extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;

  const _StudentMarketStat({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _MarketColors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _MarketColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: _MarketColors.text,
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: _MarketColors.textMuted,
                    fontSize: 13,
                    height: 1.3,
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

class _ProductScreen extends StatelessWidget {
  final String Function(String key) text;
  final String languageKey;
  final MarketProduct product;
  final VoidCallback onBack;
  final VoidCallback onPay;

  const _ProductScreen({
    required this.text,
    required this.languageKey,
    required this.product,
    required this.onBack,
    required this.onPay,
  });

  @override
  Widget build(BuildContext context) {
    final productName = languageKey == 'zh' ? product.nameZh : product.name;
    final isBook = product.category == 'books';
    final labels = [
      text('category'),
      isBook ? text('author') : text('brand'),
      isBook ? text('details') : text('size'),
      text('condition'),
      text('price'),
    ];
    final values = [
      text(product.category),
      product.brand,
      product.size,
      text(product.conditionKey),
      '\$${product.price}.00',
    ];

    return Container(
      color: _MarketColors.bg,
      child: ListView(
        children: [
          Container(
            color: _MarketColors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                IconButton(
                  onPressed: onBack,
                  icon: const Icon(Icons.arrow_back_rounded),
                  color: _MarketColors.text,
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    productName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 17,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            height: 240,
            color: _MarketColors.bg,
            child: Image.network(
              product.imageUrl,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Icon(
                product.icon,
                size: 90,
                color: _MarketColors.text.withValues(alpha: 0.72),
              ),
            ),
          ),
          Container(
            color: Colors.white,
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  productName,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '\$${product.price}.00',
                  style: const TextStyle(
                    color: _MarketColors.success,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${text('size')} ${product.size} · ${text(product.conditionKey)}',
                  style: const TextStyle(
                    color: _MarketColors.textMuted,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                for (int i = 0; i < labels.length; i++)
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    decoration: const BoxDecoration(
                      border: Border(
                        bottom: BorderSide(color: _MarketColors.border),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          labels[i],
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                        Text(
                          values[i],
                          style: const TextStyle(color: _MarketColors.primary),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              height: 48,
              child: ElevatedButton.icon(
                onPressed: onPay,
                icon: const Icon(
                  Icons.credit_card_rounded,
                  color: Colors.white,
                ),
                label: Text(text('pay')),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _MarketColors.primary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  textStyle: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PaymentSheet extends StatefulWidget {
  final String Function(String key) text;
  final String languageKey;

  const _PaymentSheet({required this.text, required this.languageKey});

  @override
  State<_PaymentSheet> createState() => _PaymentSheetState();
}

enum _PaymentMode { menu, scan, showQr }

class _PaymentSheetState extends State<_PaymentSheet> {
  final TextEditingController _amountController = TextEditingController();
  final MobileScannerController _scannerController = MobileScannerController(
    detectionSpeed: DetectionSpeed.noDuplicates,
  );
  _PaymentMode _mode = _PaymentMode.menu;
  bool _success = false;
  bool _scanned = false;

  @override
  void dispose() {
    _amountController.dispose();
    _scannerController.dispose();
    super.dispose();
  }

  void _handleDetect(BarcodeCapture capture) {
    if (_scanned || capture.barcodes.isEmpty) return;
    final raw = capture.barcodes.first.rawValue;
    if (raw == null || raw.isEmpty) return;
    final extracted = _extractAmountFromQr(raw);
    if (extracted == null) return;
    _scanned = true;
    _amountController.text = extracted;
    setState(() {});
  }

  String? _extractAmountFromQr(String raw) {
    final payMatch = RegExp(
      r'pay:[^:]+:([0-9]+(?:\.[0-9]+)?):TWD',
    ).firstMatch(raw);
    if (payMatch != null) return payMatch.group(1);

    final peilarParts = raw.split(':');
    if (raw.startsWith('PEILAR:') && peilarParts.length >= 3) {
      final parsed = double.tryParse(peilarParts[2]);
      if (parsed != null && parsed > 0) {
        return parsed % 1 == 0
            ? parsed.toInt().toString()
            : parsed.toStringAsFixed(2);
      }
    }
    return null;
  }

  void _confirm() {
    final amount = double.tryParse(_amountController.text.trim());
    if (amount == null || amount <= 0) return;
    setState(() => _success = true);
    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;
      setState(() {
        _success = false;
        _mode = _PaymentMode.menu;
        _scanned = false;
        _amountController.clear();
      });
    });
  }

  void _setMode(_PaymentMode mode) {
    setState(() {
      _mode = mode;
      _success = false;
      _scanned = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Container(
          width: double.infinity,
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.82,
          ),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          padding: EdgeInsets.fromLTRB(
            20,
            24,
            20,
            32 + MediaQuery.of(context).viewInsets.bottom,
          ),
          child: SingleChildScrollView(
            child: _success
                ? _PaymentSuccess(text: widget.text('paymentSuccess'))
                : switch (_mode) {
                    _PaymentMode.menu => _paymentMenu(),
                    _PaymentMode.scan => _scanToPay(),
                    _PaymentMode.showQr => _showQrCode(),
                  },
          ),
        ),
      ),
    );
  }

  Widget _paymentMenu() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              widget.text('paymentTitle'),
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
            IconButton(
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.close_rounded),
              color: _MarketColors.textMuted,
            ),
          ],
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              child: _PaymentModeCard(
                icon: Icons.photo_camera_outlined,
                label: widget.text('scanQR'),
                color: _MarketColors.primary,
                background: _MarketColors.bg,
                onTap: () => _setMode(_PaymentMode.scan),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _PaymentModeCard(
                icon: Icons.qr_code_2_rounded,
                label: widget.text('showQR'),
                color: _MarketColors.success,
                background: _MarketColors.bg,
                onTap: () => _setMode(_PaymentMode.showQr),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _scanToPay() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _PaymentBackHeader(
          title: widget.text('scanToPay'),
          onBack: () => _setMode(_PaymentMode.menu),
        ),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: _MarketColors.bg,
            borderRadius: BorderRadius.circular(16),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: SizedBox(
              height: 200,
              width: double.infinity,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  MobileScanner(
                    controller: _scannerController,
                    onDetect: _handleDetect,
                  ),
                  Container(color: Colors.black.withValues(alpha: 0.25)),
                  const _ScannerFrame(),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.55),
                          borderRadius: BorderRadius.circular(99),
                        ),
                        child: Text(
                          widget.text('cameraPreview'),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        _PaymentAmountInput(
          controller: _amountController,
          label: widget.text('amount'),
          hint: widget.text('enterAmount'),
          onChanged: () => setState(() {}),
        ),
        const SizedBox(height: 16),
        _ConfirmPaymentButton(
          enabled: _amountController.text.trim().isNotEmpty,
          label: widget.text('confirm'),
          onPressed: _confirm,
        ),
      ],
    );
  }

  Widget _showQrCode() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _PaymentBackHeader(
          title: widget.text('myQRCode'),
          onBack: () => _setMode(_PaymentMode.menu),
        ),
        const SizedBox(height: 20),
        Center(
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: _MarketColors.border, width: 2),
                ),
                child: QrImageView(
                  data: 'danielk87-easymarket-uid-38291',
                  size: 160,
                  backgroundColor: Colors.white,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'danielk87',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
              ),
              const SizedBox(height: 3),
              Text(
                widget.text('marketId'),
                style: const TextStyle(
                  color: _MarketColors.textMuted,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        _PaymentAmountInput(
          controller: _amountController,
          label: widget.text('amount'),
          hint: widget.text('enterAmount'),
          onChanged: () => setState(() {}),
        ),
        if (_amountController.text.trim().isNotEmpty) ...[
          const SizedBox(height: 16),
          Center(
            child: Column(
              children: [
                QrImageView(
                  data: 'pay:danielk87:${_amountController.text.trim()}:TWD',
                  size: 100,
                  backgroundColor: Colors.white,
                ),
                const SizedBox(height: 6),
                Text(
                  'TWD ${_amountController.text.trim()}',
                  style: const TextStyle(
                    color: _MarketColors.textMuted,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            style: ElevatedButton.styleFrom(
              backgroundColor: _MarketColors.danger,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              widget.text('close'),
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
        ),
      ],
    );
  }
}

class _PaymentSuccess extends StatelessWidget {
  final String text;

  const _PaymentSuccess({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 32),
      child: Column(
        children: [
          const Icon(
            Icons.check_circle_rounded,
            size: 56,
            color: _MarketColors.success,
          ),
          const SizedBox(height: 12),
          Text(
            text,
            style: const TextStyle(
              color: _MarketColors.success,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _PaymentModeCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final Color background;
  final VoidCallback onTap;

  const _PaymentModeCard({
    required this.icon,
    required this.label,
    required this.color,
    required this.background,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: background,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: color, width: 2),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 32, color: color),
              const SizedBox(height: 8),
              Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PaymentBackHeader extends StatelessWidget {
  final String title;
  final VoidCallback onBack;

  const _PaymentBackHeader({required this.title, required this.onBack});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
          onPressed: onBack,
          icon: const Icon(Icons.arrow_back_rounded),
          color: _MarketColors.text,
        ),
        const SizedBox(width: 2),
        Text(
          title,
          style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
        ),
      ],
    );
  }
}

class _ScannerFrame extends StatelessWidget {
  const _ScannerFrame();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _ScannerFramePainter(),
      child: const SizedBox.expand(),
    );
  }
}

class _ScannerFramePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = _MarketColors.primary
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final frameWidth = size.width * 0.78;
    final frameHeight = size.height * 0.62;
    final left = (size.width - frameWidth) / 2;
    final top = (size.height - frameHeight) / 2;
    final right = left + frameWidth;
    final bottom = top + frameHeight;
    const len = 26.0;

    canvas.drawLine(Offset(left, top), Offset(left + len, top), paint);
    canvas.drawLine(Offset(left, top), Offset(left, top + len), paint);
    canvas.drawLine(Offset(right, top), Offset(right - len, top), paint);
    canvas.drawLine(Offset(right, top), Offset(right, top + len), paint);
    canvas.drawLine(Offset(left, bottom), Offset(left + len, bottom), paint);
    canvas.drawLine(Offset(left, bottom), Offset(left, bottom - len), paint);
    canvas.drawLine(Offset(right, bottom), Offset(right - len, bottom), paint);
    canvas.drawLine(Offset(right, bottom), Offset(right, bottom - len), paint);

    final scanPaint = Paint()
      ..color = _MarketColors.primary
      ..strokeWidth = 2.0;
    canvas.drawLine(
      Offset(left + 18, size.height / 2),
      Offset(right - 18, size.height / 2),
      scanPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _PaymentAmountInput extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final VoidCallback onChanged;

  const _PaymentAmountInput({
    required this.controller,
    required this.label,
    required this.hint,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(color: _MarketColors.textMuted, fontSize: 13),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          onChanged: (_) => onChanged(),
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 12,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(
                color: _MarketColors.border,
                width: 1.5,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(
                color: _MarketColors.primary,
                width: 1.5,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _ConfirmPaymentButton extends StatelessWidget {
  final bool enabled;
  final String label;
  final VoidCallback onPressed;

  const _ConfirmPaymentButton({
    required this.enabled,
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton(
        onPressed: enabled ? onPressed : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: _MarketColors.success,
          disabledBackgroundColor: _MarketColors.bg,
          foregroundColor: Colors.white,
          disabledForegroundColor: _MarketColors.textMuted,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(
          label,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}
