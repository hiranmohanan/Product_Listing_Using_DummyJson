import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/strings.dart';
import '../auth/bloc/auth_bloc.dart';
import 'bloc/locale_bloc.dart';
import 'theme_bloc/theme_bloc.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(tr(context, 'settings'))),
    body: BlocBuilder<LocaleBloc, LocaleState>(
      builder: (context, state) => ListView(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 28, 20, 8),
            child: Text(
              tr(context, 'language'),
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
          RadioGroup<String>(
            groupValue: state.language,
            onChanged: (value) {
              if (value != null) {
                context.read<LocaleBloc>().add(LocaleChanged(value));
              }
            },
            child: Column(
              children: [
                RadioListTile<String>(
                  title: Text(tr(context, 'english')),
                  value: 'en',
                ),
                RadioListTile<String>(
                  title: Text(tr(context, 'arabic')),
                  value: 'ar',
                ),
              ],
            ),
          ),
          const Divider(height: 24),
          BlocBuilder<ThemeBloc, ThemeState>(
            builder: (context, appearance) => SwitchListTile(
              secondary: const Icon(Icons.dark_mode_outlined),
              title: Text(tr(context, 'darkMode')),
              value: appearance.darkMode,
              onChanged: (enabled) =>
                  context.read<ThemeBloc>().add(ThemeChanged(enabled)),
            ),
          ),
          const Divider(height: 40),
          ListTile(
            leading: const Icon(Icons.logout),
            title: Text(tr(context, 'logout')),
            onTap: () => context.read<AuthBloc>().add(LogoutRequested()),
          ),
        ],
      ),
    ),
  );
}
