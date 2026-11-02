import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:product_list_auth_app/core/api_service.dart';
import 'package:product_list_auth_app/core/auth_repository.dart';
import 'package:product_list_auth_app/features/auth/bloc/auth_bloc.dart';
import 'package:product_list_auth_app/features/auth/login_page.dart';

void main() {
  testWidgets('login form shows required-field errors', (tester) async {
    await tester.pumpWidget(
      BlocProvider(
        create: (_) => AuthBloc(AuthRepository(ApiService())),
        child: const MaterialApp(home: LoginPage()),
      ),
    );
    await tester.tap(find.text('Sign in'));
    await tester.pump();
    expect(find.text('Enter your username.'), findsOneWidget);
    expect(find.text('Enter your password.'), findsOneWidget);
  });

  testWidgets('login fields and password visibility respond to input', (
    tester,
  ) async {
    final bloc = AuthBloc(AuthRepository(ApiService()));
    await tester.pumpWidget(
      BlocProvider(
        create: (_) => bloc,
        child: const MaterialApp(home: LoginPage()),
      ),
    );
    final fields = find.byType(TextField);
    await tester.enterText(fields.at(0), 'emilys');
    await tester.enterText(fields.at(1), 'emilyspass');
    await tester.pump();
    expect(bloc.state.username, 'emilys');
    expect(bloc.state.password, 'emilyspass');
    expect(tester.widget<TextField>(fields.at(1)).obscureText, isTrue);
    await tester.tap(find.byIcon(Icons.visibility_outlined));
    await tester.pump();
    expect(tester.widget<TextField>(fields.at(1)).obscureText, isFalse);
  });
}
