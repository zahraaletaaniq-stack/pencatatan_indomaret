import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppData.load();
  runApp(const IndomaretApp());
}

class IndomaretApp extends StatelessWidget {
  const IndomaretApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Indomaret',
      theme: ThemeData(
        useMaterial3: false,
        primaryColor: AppColors.blue,
        scaffoldBackgroundColor: AppColors.background,
        fontFamily: 'Roboto',
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.blue),
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.blue,
          foregroundColor: Colors.white,
          elevation: 0,
        ),
      ),
      home: const SplashScreen(),
    );
  }
}

class AppColors {
  static const blue = Color(0xFF08469A);
  static const darkBlue = Color(0xFF063A7D);
  static const red = Color(0xFFE51D24);
  static const yellow = Color(0xFFFFC20E);
  static const background = Color(0xFFF5F7FA);
  static const text = Color(0xFF1D2A3A);
  static const muted = Color(0xFF7A8795);
  static const green = Color(0xFF35A866);
  static const greenSoft = Color(0xFFEAF7EF);
}

class ProductRecord {
  final String name;
  final String code;
  final int quantity;
  final String companyCode;
  final DateTime date;

  const ProductRecord({
    required this.name,
    required this.code,
    required this.quantity,
    required this.companyCode,
    required this.date,
  });

  factory ProductRecord.fromJson(Map<String, dynamic> json) => ProductRecord(
    name: json['name'] as String,
    code: json['code'] as String,
    quantity: json['quantity'] as int,
    companyCode: json['companyCode'] as String,
    date: DateTime.parse(json['date'] as String),
  );

  Map<String, dynamic> toJson() => {
    'name': name,
    'code': code,
    'quantity': quantity,
    'companyCode': companyCode,
    'date': date.toIso8601String(),
  };
}

class ReturnRequest {
  final ProductRecord product;
  final int quantity;
  final String reason;
  final DateTime date;

  const ReturnRequest({
    required this.product,
    required this.quantity,
    required this.reason,
    required this.date,
  });

  factory ReturnRequest.fromJson(Map<String, dynamic> json) => ReturnRequest(
    product: ProductRecord.fromJson(json['product'] as Map<String, dynamic>),
    quantity: json['quantity'] as int,
    reason: json['reason'] as String,
    date: DateTime.parse(json['date'] as String),
  );

  Map<String, dynamic> toJson() => {
    'product': product.toJson(),
    'quantity': quantity,
    'reason': reason,
    'date': date.toIso8601String(),
  };
}

class AppData {
  static final List<ProductRecord> incoming = [];
  static final List<ReturnRequest> returnRequests = [];
  static const companyCode = 'IND-001';

  static Future<void> load() async {
    final preferences = await SharedPreferences.getInstance();
    incoming
      ..clear()
      ..addAll(
        (preferences.getStringList('incoming_records') ?? []).map(
          (json) =>
              ProductRecord.fromJson(jsonDecode(json) as Map<String, dynamic>),
        ),
      );
    returnRequests
      ..clear()
      ..addAll(
        (preferences.getStringList('return_requests') ?? []).map(
          (json) =>
              ReturnRequest.fromJson(jsonDecode(json) as Map<String, dynamic>),
        ),
      );
  }

  static Future<bool> addIncoming(ProductRecord record) async {
    final preferences = await SharedPreferences.getInstance();
    final records = [...incoming, record];
    final saved = await preferences.setStringList(
      'incoming_records',
      records.map((item) => jsonEncode(item.toJson())).toList(),
    );
    if (!saved) return false;
    incoming.add(record);
    return true;
  }

  static Future<bool> addReturnRequest(ReturnRequest request) async {
    final preferences = await SharedPreferences.getInstance();
    final requests = [...returnRequests, request];
    final saved = await preferences.setStringList(
      'return_requests',
      requests.map((item) => jsonEncode(item.toJson())).toList(),
    );
    if (!saved) return false;
    returnRequests.add(request);
    return true;
  }

  static List<ProductRecord> get returnableProducts => [
    ProductRecord(
      name: 'Indomie Goreng',
      code: 'NDM-G01',
      quantity: 12,
      companyCode: companyCode,
      date: _initialProductDate,
    ),
    ProductRecord(
      name: 'Tepung Terigu',
      code: 'TTR-001',
      quantity: 46,
      companyCode: companyCode,
      date: _initialProductDate,
    ),
    ProductRecord(
      name: 'Minyak Goreng',
      code: 'MKG-001',
      quantity: 32,
      companyCode: companyCode,
      date: _initialProductDate,
    ),
    ...incoming,
  ];

  static final DateTime _initialProductDate = DateTime(2026, 11, 18);
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future<void>.delayed(const Duration(milliseconds: 1300), () {
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.blue,
      body: Stack(
        children: [
          Positioned(
            top: 75,
            right: -45,
            child: _circle(AppColors.yellow, 150),
          ),
          Positioned(
            bottom: -55,
            left: -35,
            child: _circle(AppColors.red, 150),
          ),
          Positioned(
            bottom: 35,
            right: -20,
            child: _circle(const Color(0xFF2A63B1), 75),
          ),
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _indomaretLogo(),
                const SizedAlt(height: 28),
                const Text(
                  'Catat Barang Masuk',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedAlt(height: 8),
                const Text(
                  'Pencatatan barang masuk, cepat dan akurat',
                  style: TextStyle(color: Color(0xFFC7D7EF), fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _circle(Color color, double size) => Container(
    width: size,
    height: size,
    decoration: BoxDecoration(color: color, shape: BoxShape.circle),
  );
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedAlt(height: 18),
              _indomaretLogo(),
              const SizedAlt(height: 36),
              const Text(
                'Masuk ke akun',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: AppColors.text,
                ),
              ),
              const SizedAlt(height: 8),
              const Text(
                'Kelola pencatatan barang dengan mudah',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.muted),
              ),
              const SizedAlt(height: 30),
              const _TextField(label: 'ID Karyawan', hint: 'Contoh: EMP-001'),
              const SizedAlt(height: 16),
              const _TextField(
                label: 'Password',
                hint: 'Masukkan password',
                obscure: true,
              ),
              const SizedAlt(height: 20),
              AppButton(text: 'Masuk', onTap: _openHome),
              const SizedAlt(height: 12),
              OutlinedAppButton(
                text: 'Masuk dengan Sidik Jari',
                icon: Icons.fingerprint,
                onTap: _showBiometric,
              ),
              const SizedAlt(height: 24),
              TextButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const ForgotPasswordScreen(),
                  ),
                ),
                child: const Text(
                  'Lupa kata sandi?',
                  style: TextStyle(color: AppColors.blue),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showBiometric() {
    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 18, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 42,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFDDE3EA),
                borderRadius: BorderRadius.circular(5),
              ),
            ),
            const SizedAlt(height: 24),
            Container(
              width: 90,
              height: 90,
              decoration: const BoxDecoration(
                color: Color(0xFFF0F7FF),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.fingerprint,
                size: 58,
                color: AppColors.blue,
              ),
            ),
            const SizedAlt(height: 16),
            const Text(
              'Gunakan sidik jari',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
            ),
            const SizedAlt(height: 6),
            const Text(
              'Sentuh sensor sidik jari',
              style: TextStyle(color: AppColors.muted),
            ),
            const SizedAlt(height: 22),
            AppButton(
              text: 'Gunakan sidik jari',
              onTap: () {
                Navigator.pop(sheetContext);
                _openHome();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _openHome() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const MainShell()),
    );
  }
}

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  int step = 0;

  @override
  Widget build(BuildContext context) {
    final titles = [
      'Lupa Kata Sandi',
      'Verifikasi Kode',
      'Buat Kata Sandi Baru',
    ];
    final descriptions = [
      'Masukkan ID karyawan untuk mendapatkan kode pemulihan.',
      'Masukkan kode verifikasi yang dikirimkan.',
      'Buat kata sandi baru untuk akun Anda.',
    ];
    return Scaffold(
      appBar: AppBar(title: Text(titles[step]), centerTitle: true),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 30),
        children: [
          Text(
            descriptions[step],
            style: const TextStyle(color: AppColors.muted),
          ),
          const SizedAlt(height: 20),
          if (step == 0) ...[
            const _TextField(label: 'ID Karyawan', hint: 'EMP-001'),
            const _InfoBox(
              text: 'Kode pemulihan dikirim ke nomor yang terdaftar pada akun.',
            ),
          ],
          if (step == 1) ...[
            const _TextField(
              label: 'Kode Verifikasi',
              hint: 'Masukkan 6 digit',
            ),
            const _InfoBox(text: 'Kode berlaku selama 10 menit.'),
          ],
          if (step == 2) ...[
            const _TextField(
              label: 'Kata Sandi Baru',
              hint: 'Minimal 8 karakter',
              obscure: true,
            ),
            const SizedAlt(height: 12),
            const _TextField(
              label: 'Ulangi Kata Sandi',
              hint: 'Ulangi kata sandi baru',
              obscure: true,
            ),
          ],
          const SizedAlt(height: 24),
          AppButton(
            text: step == 2 ? 'Simpan Kata Sandi' : 'Lanjutkan',
            onTap: () {
              if (step < 2) {
                setState(() => step++);
              } else {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Kata sandi berhasil diperbarui'),
                  ),
                );
              }
            },
          ),
        ],
      ),
    );
  }
}

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int index = 0;

  @override
  Widget build(BuildContext context) {
    final pages = [
      const HomeScreen(),
      const StockScreen(),
      const ReportScreen(),
      const ProfileScreen(),
    ];
    return Scaffold(
      body: pages[index],
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Color(0x14000000),
              blurRadius: 12,
              offset: Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: SizedBox(
            height: 68,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _navItem(0, Icons.home_rounded, 'Beranda'),
                _navItem(1, Icons.inventory_2_rounded, 'Stok'),
                _navItem(2, Icons.description_rounded, 'Riwayat'),
                _navItem(3, Icons.person_rounded, 'Profil'),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _navItem(int value, IconData icon, String label) {
    final selected = index == value;
    return InkWell(
      onTap: () => setState(() => index = value),
      child: SizedBox(
        width: 72,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: selected ? AppColors.yellow : AppColors.muted,
              size: 24,
            ),
            const SizedAlt(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: selected ? AppColors.blue : AppColors.muted,
                fontWeight: selected ? FontWeight.w800 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF0B63B6),
                    AppColors.blue,
                    AppColors.darkBlue,
                  ],
                ),
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(26),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Image.asset(
                          'assets/indomaret_logo.png',
                          width: 86,
                          height: 28,
                          fit: BoxFit.contain,
                        ),
                      ),
                      const Spacer(),
                      Container(
                        width: 42,
                        height: 42,
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.85),
                            width: 2,
                          ),
                        ),
                        child: const ClipOval(
                          child: Image(
                            image: AssetImage('assets/profile_imes.png'),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedAlt(height: 18),
                  const Text(
                    'Halo, Imes Amalia!',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedAlt(height: 4),
                  const Text(
                    'IND-001  -  Indomaret',
                    style: TextStyle(
                      color: Color(0xFFD8E6F7),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Menu Utama',
                    style: TextStyle(
                      color: AppColors.text,
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedAlt(height: 12),
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 1.42,
                    children: [
                      _actionCard(
                        context,
                        'Barang Masuk',
                        'Catat penerimaan',
                        Icons.qr_code_scanner_rounded,
                        const Color(0xFFE8F1FF),
                        const Color(0xFF2D73C9),
                        () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const IncomingMenuScreen(),
                          ),
                        ),
                      ),
                      _actionCard(
                        context,
                        'Stok',
                        'Lihat persediaan',
                        Icons.inventory_2_outlined,
                        const Color(0xFFEEF0FF),
                        const Color(0xFF5B65C7),
                        () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const StockScreen(),
                          ),
                        ),
                      ),
                      _actionCard(
                        context,
                        'Retur',
                        'Ajukan pengembalian',
                        Icons.assignment_return_rounded,
                        const Color(0xFFFFF2D5),
                        const Color(0xFFD38A09),
                        () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const ReturnScreen(),
                          ),
                        ),
                      ),
                      _actionCard(
                        context,
                        'Riwayat',
                        'Buka laporan',
                        Icons.history_rounded,
                        const Color(0xFFEAF7EF),
                        const Color(0xFF31A864),
                        () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const ReportScreen(),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const IncomingMenuScreen()),
        ),
        backgroundColor: AppColors.red,
        foregroundColor: Colors.white,
        elevation: 8,
        tooltip: 'Tambah barang masuk',
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        child: const Icon(Icons.add_rounded, size: 34),
      ),
    );
  }

  Widget _actionCard(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    Color bg,
    Color fg,
    VoidCallback onTap,
  ) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      elevation: 2,
      shadowColor: const Color(0x1A1D2A3A),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: bg,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(icon, color: fg, size: 27),
                  ),
                  const Spacer(),
                  Container(
                    width: 26,
                    height: 26,
                    decoration: const BoxDecoration(
                      color: Color(0xFFF5F7FA),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.arrow_forward_rounded,
                      size: 15,
                      color: AppColors.muted,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              Text(
                title,
                style: const TextStyle(
                  color: AppColors.text,
                  fontWeight: FontWeight.w800,
                  fontSize: 14,
                ),
              ),
              const SizedAlt(height: 2),
              Text(
                subtitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: AppColors.muted,
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class IncomingMenuScreen extends StatelessWidget {
  const IncomingMenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Barang Masuk')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text(
            'Pilih metode',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
          ),
          const SizedAlt(height: 16),
          _method(
            context,
            Icons.qr_code_scanner_rounded,
            'Scan Barcode',
            'Pindai barcode otomatis',
            const ScannerScreen(),
          ),
          const SizedAlt(height: 12),
          _method(
            context,
            Icons.edit_note_rounded,
            'Input Manual',
            'Isi data barang secara manual',
            const ManualIncomingScreen(),
          ),
        ],
      ),
    );
  }

  Widget _method(
    BuildContext context,
    IconData icon,
    String title,
    String subtitle,
    Widget page,
  ) {
    return InkWell(
      onTap: () =>
          Navigator.push(context, MaterialPageRoute(builder: (_) => page)),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5FA),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: AppColors.blue),
            ),
            const SizedAlt(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                  const SizedAlt(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: AppColors.muted,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: AppColors.muted),
          ],
        ),
      ),
    );
  }
}

class ScannerScreen extends StatefulWidget {
  const ScannerScreen({super.key});

  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen> {
  final List<ProductRecord> _products = AppData.returnableProducts;
  late ProductRecord _selectedProduct = _products.first;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Scan Barcode')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Container(
              height: 270,
              width: double.infinity,
              decoration: BoxDecoration(
                color: const Color(0xFF0B0F14),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.qr_code_scanner,
                    size: 130,
                    color: Colors.white70,
                  ),
                  const SizedAlt(height: 10),
                  const Text(
                    'Arahkan kamera ke barcode',
                    style: TextStyle(color: Colors.white54),
                  ),
                  const SizedAlt(height: 18),
                  TextButton(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ProductDetailScreen(
                          name: _selectedProduct.name,
                          code: _selectedProduct.code,
                          quantity: _selectedProduct.quantity,
                        ),
                      ),
                    ),
                    style: TextButton.styleFrom(foregroundColor: Colors.white),
                    child: const Text('Mulai Scan'),
                  ),
                ],
              ),
            ),
            const SizedAlt(height: 18),
            DropdownButtonFormField<ProductRecord>(
              initialValue: _selectedProduct,
              isExpanded: true,
              decoration: InputDecoration(
                labelText: 'Pilih produk / kode barcode',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              items: _products
                  .map(
                    (product) => DropdownMenuItem(
                      value: product,
                      child: Text('${product.name} · ${product.code}'),
                    ),
                  )
                  .toList(),
              onChanged: (product) {
                if (product != null) {
                  setState(() => _selectedProduct = product);
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}

class ManualIncomingScreen extends StatefulWidget {
  const ManualIncomingScreen({super.key});

  @override
  State<ManualIncomingScreen> createState() => _ManualIncomingScreenState();
}

class _ManualIncomingScreenState extends State<ManualIncomingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _codeController = TextEditingController();
  final _quantityController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _codeController.dispose();
    _quantityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Input Manual')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Form(
            key: _formKey,
            child: Column(
              children: [
                _TextField(
                  label: 'Nama Barang',
                  hint: 'Masukkan nama barang',
                  controller: _nameController,
                  validator: _requiredValidator,
                ),
                const SizedAlt(height: 14),
                _TextField(
                  label: 'Kode Barang',
                  hint: 'Contoh: BRG-001',
                  controller: _codeController,
                  validator: _requiredValidator,
                ),
                const SizedAlt(height: 14),
                _TextField(
                  label: 'Jumlah',
                  hint: '0',
                  controller: _quantityController,
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    final quantity = int.tryParse(value?.trim() ?? '');
                    if (quantity == null || quantity <= 0) {
                      return 'Masukkan jumlah lebih dari 0';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.all(20),
        child: AppButton(text: 'Cek Data', onTap: _continueToDetail),
      ),
    );
  }

  String? _requiredValidator(String? value) =>
      value == null || value.trim().isEmpty ? 'Bagian ini wajib diisi' : null;

  void _continueToDetail() {
    if (!_formKey.currentState!.validate()) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ProductDetailScreen(
          name: _nameController.text.trim(),
          code: _codeController.text.trim(),
          quantity: int.parse(_quantityController.text.trim()),
        ),
      ),
    );
  }
}

class ProductDetailScreen extends StatefulWidget {
  final String name;
  final String code;
  final int quantity;

  const ProductDetailScreen({
    super.key,
    this.name = 'Indomie Goreng',
    this.code = 'NDM-G01',
    this.quantity = 10,
  });

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  late int quantity = widget.quantity;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Detail Barang')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                Container(
                  width: 58,
                  height: 58,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFE0C2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.fastfood_outlined,
                    color: AppColors.red,
                  ),
                ),
                const SizedAlt(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.name,
                        style: const TextStyle(fontWeight: FontWeight.w800),
                      ),
                      SizedAlt(height: 4),
                      Text(
                        widget.code,
                        style: const TextStyle(
                          color: AppColors.muted,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedAlt(height: 18),
          const Text(
            'Jumlah diterima',
            style: TextStyle(fontWeight: FontWeight.w800),
          ),
          const SizedAlt(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _quantityButton(
                  Icons.remove,
                  () => setState(
                    () => quantity = quantity > 1 ? quantity - 1 : 1,
                  ),
                ),
                Text(
                  '$quantity',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                _quantityButton(Icons.add, () => setState(() => quantity++)),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.all(20),
        child: AppButton(
          text: 'Lanjut ke Konfirmasi',
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ConfirmationScreen(
                record: ProductRecord(
                  name: widget.name,
                  code: widget.code,
                  quantity: quantity,
                  companyCode: AppData.companyCode,
                  date: DateTime.now(),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _quantityButton(IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: const Color(0xFFF2F5F8),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, size: 18),
      ),
    );
  }
}

class ConfirmationScreen extends StatelessWidget {
  final ProductRecord record;

  const ConfirmationScreen({super.key, required this.record});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Konfirmasi')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _summaryCard(record.name, '${record.code} · ${record.quantity} pcs'),
          const SizedAlt(height: 12),
          _summaryCard(
            'Kode perusahaan: ${record.companyCode}',
            'Tanggal input: ${_formatDate(record.date)}',
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppButton(
              text: 'Konfirmasi & Simpan',
              onTap: () async {
                final saved = await AppData.addIncoming(record);
                if (!context.mounted) return;
                if (!saved) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Riwayat barang masuk gagal disimpan.'),
                    ),
                  );
                  return;
                }
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SuccessScreen()),
                );
              },
            ),
            const SizedAlt(height: 10),
            const OutlinedAppButton(text: 'Batal'),
          ],
        ),
      ),
    );
  }

  Widget _summaryCard(String title, String subtitle) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
          const SizedAlt(height: 6),
          Text(
            subtitle,
            style: const TextStyle(color: AppColors.muted, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class SuccessScreen extends StatelessWidget {
  const SuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F7F2),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 94,
                height: 94,
                decoration: const BoxDecoration(
                  color: AppColors.green,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check, color: Colors.white, size: 54),
              ),
              const SizedAlt(height: 20),
              const Text(
                'Barang berhasil disimpan',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 21, fontWeight: FontWeight.w800),
              ),
              const SizedAlt(height: 8),
              const Text(
                'Pencatatan barang masuk sudah tersimpan.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.muted),
              ),
              const SizedAlt(height: 28),
              AppButton(
                text: 'Kembali ke Beranda',
                color: AppColors.yellow,
                textColor: AppColors.text,
                onTap: () =>
                    Navigator.of(context).popUntil((route) => route.isFirst),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class StockScreen extends StatelessWidget {
  const StockScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Stok'),
        actions: [
          TextButton(
            onPressed: () {},
            child: const Text('Semua', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Riwayat stok',
            style: TextStyle(fontWeight: FontWeight.w800),
          ),
          const SizedAlt(height: 12),
          _stockCard(
            'Indomie Goreng',
            'Barang populer',
            12,
            10,
            2,
            const Color(0xFFFFE0C2),
          ),
          const SizedAlt(height: 10),
          _stockCard(
            'Tepung Terigu',
            'Kebutuhan dapur',
            46,
            28,
            4,
            const Color(0xFFE6EAF6),
          ),
          const SizedAlt(height: 10),
          _stockCard(
            'Minyak Goreng',
            'Minyak kemasan',
            32,
            18,
            3,
            const Color(0xFFFFE9AE),
          ),
        ],
      ),
    );
  }

  Widget _stockCard(
    String name,
    String subtitle,
    int stock,
    int masuk,
    int retur,
    Color iconBg,
  ) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.inventory_2_outlined,
                  color: AppColors.blue,
                  size: 20,
                ),
              ),
              const SizedAlt(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                    const SizedAlt(height: 3),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: AppColors.muted,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '$stock',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: AppColors.blue,
                ),
              ),
            ],
          ),
          const SizedAlt(height: 12),
          Row(
            children: [
              Expanded(
                child: _stockStat(
                  'Masuk',
                  '$masuk',
                  AppColors.greenSoft,
                  AppColors.green,
                ),
              ),
              const SizedAlt(width: 8),
              Expanded(
                child: _stockStat(
                  'Retur',
                  '$retur',
                  const Color(0xFFFFEAE9),
                  AppColors.red,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _stockStat(String label, String value, Color bg, Color color) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: color, fontSize: 11)),
          Text(
            value,
            style: TextStyle(color: color, fontWeight: FontWeight.w800),
          ),
        ],
      ),
    );
  }
}

class ReturnScreen extends StatelessWidget {
  const ReturnScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final products = AppData.returnableProducts;
    return Scaffold(
      appBar: AppBar(title: const Text('Retur Barang')),
      body: products.isEmpty
          ? const Center(child: Text('Belum ada barang yang dapat diretur.'))
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                const Text(
                  'Pilih barang yang kondisinya tidak layak',
                  style: TextStyle(fontWeight: FontWeight.w800),
                ),
                const SizedAlt(height: 12),
                for (final product in products)
                  Card(
                    color: Colors.white,
                    elevation: 0,
                    margin: const EdgeInsets.only(bottom: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: ListTile(
                      leading: const CircleAvatar(
                        backgroundColor: Color(0xFFFFF2D5),
                        child: Icon(
                          Icons.assignment_return_rounded,
                          color: Color(0xFFD38A09),
                        ),
                      ),
                      title: Text(
                        product.name,
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                      subtitle: Text(
                        '${product.code} · ${product.quantity} pcs tersedia',
                      ),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ReturnFormScreen(product: product),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
    );
  }
}

class ReturnFormScreen extends StatefulWidget {
  final ProductRecord product;

  const ReturnFormScreen({super.key, required this.product});

  @override
  State<ReturnFormScreen> createState() => _ReturnFormScreenState();
}

class _ReturnFormScreenState extends State<ReturnFormScreen> {
  final _quantityController = TextEditingController(text: '1');
  String reason = 'Produk kedaluwarsa';

  @override
  void dispose() {
    _quantityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ajukan Retur')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            widget.product.name,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
          ),
          const SizedAlt(height: 4),
          Text(
            '${widget.product.code} · ${widget.product.quantity} pcs tersedia',
            style: const TextStyle(color: AppColors.muted),
          ),
          const SizedAlt(height: 18),
          _TextField(
            label: 'Jumlah retur',
            hint: '1',
            controller: _quantityController,
            keyboardType: TextInputType.number,
          ),
          const SizedAlt(height: 16),
          const Text(
            'Alasan retur',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
          ),
          const SizedAlt(height: 8),
          DropdownButtonFormField<String>(
            initialValue: reason,
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Color(0xFFDDE3EA)),
              ),
            ),
            items: const [
              DropdownMenuItem(
                value: 'Produk kedaluwarsa',
                child: Text('Produk kedaluwarsa'),
              ),
              DropdownMenuItem(
                value: 'Kemasan rusak',
                child: Text('Kemasan rusak'),
              ),
              DropdownMenuItem(
                value: 'Produk tidak layak pakai',
                child: Text('Produk tidak layak pakai'),
              ),
            ],
            onChanged: (value) {
              if (value != null) setState(() => reason = value);
            },
          ),
          const SizedAlt(height: 16),
          const _InfoBox(
            text: 'Pengajuan akan menunggu pemeriksaan dan persetujuan.',
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.all(20),
        child: AppButton(text: 'Kirim Pengajuan', onTap: _submit),
      ),
    );
  }

  Future<void> _submit() async {
    final quantity = int.tryParse(_quantityController.text.trim());
    if (quantity == null ||
        quantity <= 0 ||
        quantity > widget.product.quantity) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Jumlah harus antara 1 dan ${widget.product.quantity} pcs',
          ),
        ),
      );
      return;
    }
    final saved = await AppData.addReturnRequest(
      ReturnRequest(
        product: widget.product,
        quantity: quantity,
        reason: reason,
        date: DateTime.now(),
      ),
    );
    if (!mounted) return;
    if (!saved) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pengajuan retur gagal disimpan.')),
      );
      return;
    }
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Pengajuan retur berhasil dikirim')),
    );
  }
}

class ReportScreen extends StatelessWidget {
  const ReportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final incoming = AppData.incoming.reversed.toList();
    final returns = AppData.returnRequests.reversed.toList();
    return Scaffold(
      appBar: AppBar(title: const Text('Riwayat')),
      body: incoming.isEmpty && returns.isEmpty
          ? const Center(
              child: Text(
                'Belum ada riwayat barang masuk atau retur.',
                style: TextStyle(color: AppColors.muted),
              ),
            )
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                for (final record in incoming) ...[
                  _reportItem(
                    context,
                    'Barang masuk',
                    '${record.name} · ${record.quantity} pcs',
                    _formatDate(record.date),
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => HistoryDetailScreen(record: record),
                      ),
                    ),
                  ),
                  const SizedAlt(height: 10),
                ],
                for (final request in returns) ...[
                  _reportItem(
                    context,
                    'Pengajuan retur',
                    '${request.product.name} · ${request.quantity} pcs · Menunggu',
                    _formatDate(request.date),
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            ReturnHistoryDetailScreen(request: request),
                      ),
                    ),
                  ),
                  const SizedAlt(height: 10),
                ],
              ],
            ),
    );
  }

  Widget _reportItem(
    BuildContext context,
    String title,
    String subtitle,
    String date,
    VoidCallback onTap,
  ) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: const BoxDecoration(
                  color: AppColors.greenSoft,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check,
                  color: AppColors.green,
                  size: 20,
                ),
              ),
              const SizedAlt(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                    const SizedAlt(height: 3),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: AppColors.muted,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedAlt(width: 8),
              Text(
                date,
                style: const TextStyle(color: AppColors.muted, fontSize: 11),
              ),
              const Icon(Icons.chevron_right, color: AppColors.muted),
            ],
          ),
        ),
      ),
    );
  }
}

class HistoryDetailScreen extends StatelessWidget {
  final ProductRecord record;

  const HistoryDetailScreen({super.key, required this.record});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Detail Riwayat')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _InfoBox(text: record.name),
          const SizedAlt(height: 12),
          _detailRow('Kode barang', record.code),
          _detailRow('Jumlah masuk', '${record.quantity} pcs'),
          _detailRow('Kode perusahaan', record.companyCode),
          _detailRow('Tanggal input', _formatDate(record.date)),
        ],
      ),
    );
  }

  Widget _detailRow(String title, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(color: AppColors.muted)),
          const SizedAlt(width: 12),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}

class ReturnHistoryDetailScreen extends StatelessWidget {
  final ReturnRequest request;

  const ReturnHistoryDetailScreen({super.key, required this.request});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Detail Pengajuan Retur')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _detailRow('Nama barang', request.product.name),
          _detailRow('Kode barang', request.product.code),
          _detailRow('Jumlah diajukan', '${request.quantity} pcs'),
          _detailRow('Alasan', request.reason),
          _detailRow('Status', 'Menunggu pemeriksaan'),
          _detailRow('Tanggal pengajuan', _formatDate(request.date)),
        ],
      ),
    );
  }

  Widget _detailRow(String title, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(color: AppColors.muted)),
          const SizedAlt(height: 4),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profil')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Center(
            child: SizedBox(
              width: 84,
              height: 84,
              child: ClipOval(
                child: Image(
                  image: AssetImage('assets/profile_imes.png'),
                  fit: BoxFit.cover,
                  alignment: Alignment(0, -0.35),
                ),
              ),
            ),
          ),
          const SizedAlt(height: 12),
          const Text(
            'Imes Amalia',
            textAlign: TextAlign.center,
            style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
          ),
          const Text(
            'EMP-001',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.muted),
          ),
          const SizedAlt(height: 24),
          _profileItem(
            Icons.person_outline,
            'Ubah profil',
            onTap: () => _showProfileInfo(context),
          ),
          _profileItem(
            Icons.lock_outline,
            'Ubah kata sandi',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ForgotPasswordScreen()),
            ),
          ),
          _profileItem(
            Icons.notifications_outlined,
            'Notifikasi',
            onTap: () => _showNotificationInfo(context),
          ),
          const SizedAlt(height: 18),
          OutlinedAppButton(
            text: 'Keluar',
            textColor: AppColors.red,
            onTap: () => Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (_) => const LoginScreen()),
              (_) => false,
            ),
          ),
        ],
      ),
    );
  }

  void _showProfileInfo(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Ubah Profil'),
        content: const Text('Nama: Imes Amalia\nID Karyawan: EMP-001'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Tutup'),
          ),
        ],
      ),
    );
  }

  void _showNotificationInfo(BuildContext context) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Tidak ada notifikasi baru')));
  }

  Widget _profileItem(
    IconData icon,
    String label, {
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: ListTile(
            leading: Icon(icon, color: AppColors.blue),
            title: Text(
              label,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
            trailing: const Icon(Icons.chevron_right, color: AppColors.muted),
          ),
        ),
      ),
    );
  }
}

class _TextField extends StatelessWidget {
  final String label;
  final String hint;
  final bool obscure;
  final TextEditingController? controller;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;

  const _TextField({
    required this.label,
    required this.hint,
    this.obscure = false,
    this.controller,
    this.keyboardType,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: AppColors.text,
          ),
        ),
        const SizedAlt(height: 8),
        TextFormField(
          controller: controller,
          obscureText: obscure,
          keyboardType: keyboardType,
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Color(0xFFA6AFB8), fontSize: 13),
            suffixIcon: obscure
                ? const Icon(
                    Icons.visibility_outlined,
                    size: 20,
                    color: AppColors.muted,
                  )
                : null,
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 14,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFFDDE3EA)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: AppColors.blue, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }
}

class _InfoBox extends StatelessWidget {
  final String text;
  const _InfoBox({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFEAF3FF),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.info_outline, size: 18, color: AppColors.blue),
          const SizedAlt(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 12, color: AppColors.blue),
            ),
          ),
        ],
      ),
    );
  }
}

class AppButton extends StatelessWidget {
  final String text;
  final VoidCallback? onTap;
  final Color color;
  final Color textColor;

  const AppButton({
    super.key,
    required this.text,
    this.onTap,
    this.color = AppColors.red,
    this.textColor = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: textColor,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: Text(
          text,
          style: TextStyle(fontWeight: FontWeight.w800, color: textColor),
        ),
      ),
    );
  }
}

class OutlinedAppButton extends StatelessWidget {
  final String text;
  final IconData? icon;
  final VoidCallback? onTap;
  final Color textColor;

  const OutlinedAppButton({
    super.key,
    required this.text,
    this.icon,
    this.onTap,
    this.textColor = AppColors.blue,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: OutlinedButton(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          foregroundColor: textColor,
          side: BorderSide(color: textColor),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 21),
              const SizedAlt(width: 8),
            ],
            Text(
              text,
              style: TextStyle(fontWeight: FontWeight.w800, color: textColor),
            ),
          ],
        ),
      ),
    );
  }
}

Widget _indomaretLogo() {
  return Image.asset(
    'assets/indomaret_logo.png',
    key: const ValueKey('indomaret-logo'),
    width: 180,
    height: 60,
    fit: BoxFit.contain,
    semanticLabel: 'Logo Indomaret',
  );
}

String _formatDate(DateTime date) {
  const months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'Mei',
    'Jun',
    'Jul',
    'Agu',
    'Sep',
    'Okt',
    'Nov',
    'Des',
  ];
  return '${date.day} ${months[date.month - 1]} ${date.year}';
}

class SizedAlt extends StatelessWidget {
  final double height;
  final double width;

  const SizedAlt({super.key, this.height = 0, this.width = 0});

  @override
  Widget build(BuildContext context) => SizedBox(height: height, width: width);
}
