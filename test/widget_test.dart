// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_1/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('login uses the provided logo image', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: LoginScreen()));

    expect(find.byKey(const ValueKey('indomaret-logo')), findsOneWidget);
    expect(find.text('Indomaret'), findsNothing);
  });

  testWidgets('fingerprint sheet opens the app as the employee', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: LoginScreen()));
    await tester.tap(find.text('Masuk dengan Sidik Jari'));
    await tester.pumpAndSettle();

    expect(find.text('Sentuh sensor sidik jari'), findsOneWidget);
    await tester.tap(find.text('Gunakan sidik jari').last);
    await tester.pumpAndSettle();

    expect(find.text('Halo, Imes Amalia!'), findsOneWidget);
    await tester.tap(find.text('Profil'));
    await tester.pumpAndSettle();
    expect(find.text('Imes Amalia'), findsOneWidget);
    expect(find.text('EMP-001'), findsOneWidget);
  });

  testWidgets('scanner opens details for the selected product', (
    WidgetTester tester,
  ) async {
    AppData.incoming.clear();
    await tester.pumpWidget(const MaterialApp(home: ScannerScreen()));

    await tester.tap(find.byType(DropdownButtonFormField<ProductRecord>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Tepung Terigu · TTR-001'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Mulai Scan'));
    await tester.pumpAndSettle();

    expect(find.text('Tepung Terigu'), findsOneWidget);
    expect(find.text('TTR-001'), findsOneWidget);
  });

  testWidgets('App opens splash screen', (WidgetTester tester) async {
    await tester.pumpWidget(const IndomaretApp());
    expect(find.text('Catat Barang Masuk'), findsOneWidget);
    await tester.pump(const Duration(milliseconds: 1400));
    await tester.pumpAndSettle();
    expect(find.text('Masuk ke akun'), findsOneWidget);
  });

  testWidgets('manual input uses the entered product data', (
    WidgetTester tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    AppData.incoming.clear();
    await tester.pumpWidget(const MaterialApp(home: ManualIncomingScreen()));

    final fields = find.byType(TextFormField);
    await tester.enterText(fields.at(0), 'SUSU ULTRA MILK');
    await tester.enterText(fields.at(1), 'ULM-006');
    await tester.enterText(fields.at(2), '50');
    await tester.tap(find.text('Cek Data'));
    await tester.pumpAndSettle();

    expect(find.text('SUSU ULTRA MILK'), findsOneWidget);
    expect(find.text('ULM-006'), findsOneWidget);
    expect(find.text('50'), findsOneWidget);

    await tester.tap(find.text('Lanjut ke Konfirmasi'));
    await tester.pumpAndSettle();
    expect(find.text('ULM-006 · 50 pcs'), findsOneWidget);
    expect(find.text('Kode perusahaan: IND-001'), findsOneWidget);

    await tester.tap(find.text('Konfirmasi & Simpan'));
    await tester.pumpAndSettle();
    expect(AppData.incoming.single.name, 'SUSU ULTRA MILK');
    expect(AppData.incoming.single.quantity, 50);
  });

  testWidgets('return request validates and saves the selected quantity', (
    WidgetTester tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    AppData.returnRequests.clear();
    await tester.pumpWidget(const MaterialApp(home: ReturnScreen()));

    await tester.tap(find.text('Indomie Goreng'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField), '2');
    await tester.tap(find.text('Kirim Pengajuan'));
    await tester.pumpAndSettle();

    expect(AppData.returnRequests.single.quantity, 2);
    expect(AppData.returnRequests.single.reason, 'Produk kedaluwarsa');
  });

  testWidgets('history opens product details', (WidgetTester tester) async {
    AppData.incoming
      ..clear()
      ..add(
        ProductRecord(
          name: 'SUSU ULTRA MILK',
          code: 'ULM-006',
          quantity: 50,
          companyCode: AppData.companyCode,
          date: DateTime(2026, 11, 18),
        ),
      );
    AppData.returnRequests.clear();
    await tester.pumpWidget(const MaterialApp(home: ReportScreen()));

    await tester.tap(find.text('Barang masuk'));
    await tester.pumpAndSettle();

    expect(find.text('SUSU ULTRA MILK'), findsOneWidget);
    expect(find.text('ULM-006'), findsOneWidget);
    expect(find.text('50 pcs'), findsOneWidget);
    expect(find.text('IND-001'), findsOneWidget);
    expect(find.text('18 Nov 2026'), findsOneWidget);
  });
}
