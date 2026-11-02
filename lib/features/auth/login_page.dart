import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/strings.dart';
import 'bloc/auth_bloc.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 430),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(28),
              child: Form(
                autovalidateMode: AutovalidateMode.onUserInteraction,
                child: BlocBuilder<AuthBloc, AuthState>(
                  builder: (context, state) => Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      CircleAvatar(
                        radius: 34,
                        backgroundColor: scheme.primaryContainer,
                        child: Icon(
                          Icons.person,
                          size: 34,
                          color: scheme.onPrimaryContainer,
                        ),
                      ),
                      const SizedBox(height: 30),
                      Text(
                        tr(context, 'loginTitle'),
                        style: Theme.of(context).textTheme.headlineLarge
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        tr(context, 'loginSubtitle'),
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      const SizedBox(height: 32),
                      TextFormField(
                        onChanged: (value) => context.read<AuthBloc>().add(
                          UsernameChanged(value),
                        ),
                        validator: (value) =>
                            value == null || value.trim().isEmpty
                            ? tr(context, 'usernameRequired')
                            : null,
                        textInputAction: TextInputAction.next,
                        decoration: InputDecoration(
                          labelText: tr(context, 'username'),
                          prefixIcon: const Icon(Icons.person_outline),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        onChanged: (value) => context.read<AuthBloc>().add(
                          PasswordChanged(value),
                        ),
                        validator: (value) => value == null || value.isEmpty
                            ? tr(context, 'passwordRequired')
                            : null,
                        obscureText: state.obscure,
                        onFieldSubmitted: (_) => _submit(context),
                        decoration: InputDecoration(
                          labelText: tr(context, 'password'),
                          prefixIcon: const Icon(Icons.lock_outline),
                          suffixIcon: IconButton(
                            icon: Icon(
                              state.obscure
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                            ),
                            onPressed: () => context.read<AuthBloc>().add(
                              PasswordVisibilityToggled(),
                            ),
                          ),
                        ),
                      ),
                      if (state.error.isNotEmpty) ...[
                        const SizedBox(height: 14),
                        Text(
                          tr(context, state.error),
                          style: TextStyle(color: scheme.error),
                        ),
                      ],
                      const SizedBox(height: 24),
                      FilledButton(
                        onPressed: state.status == AuthStatus.submitting
                            ? null
                            : () => _submit(context),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          child: state.status == AuthStatus.submitting
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : Text(tr(context, 'signIn')),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _submit(BuildContext context) {
    if (!Form.of(context).validate()) return;
    FocusScope.of(context).unfocus();
    context.read<AuthBloc>().add(LoginSubmitted());
  }
}
