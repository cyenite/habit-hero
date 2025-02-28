import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habit_tracker/features/auth/presentation/widgets/animated_button.dart';
import 'package:habit_tracker/features/auth/presentation/widgets/custom_text_field.dart';
import 'package:habit_tracker/features/auth/presentation/providers/auth_providers.dart';
import 'package:habit_tracker/features/auth/presentation/state/auth_state.dart';
import 'package:habit_tracker/features/auth/presentation/widgets/google_sign_in_button.dart';
import 'package:habit_tracker/features/habits/presentation/pages/home_page.dart';

class AuthPage extends ConsumerStatefulWidget {
  const AuthPage({super.key});

  @override
  ConsumerState<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends ConsumerState<AuthPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  void _handleLogin() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields')),
      );
      return;
    }

    await ref.read(authStateProvider.notifier).signIn(
          email: email,
          password: password,
        );
  }

  void _handleSignUp() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final name = _nameController.text.trim();

    if (email.isEmpty || password.isEmpty || name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields')),
      );
      return;
    }

    await ref.read(authStateProvider.notifier).signUp(
          email: email,
          password: password,
          name: name,
        );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final screenSize = MediaQuery.of(context).size;
    final isLargeScreen = screenSize.width > 900;
    final isMediumScreen = screenSize.width > 600 && screenSize.width <= 900;

    ref.listen<AuthState>(authStateProvider, (previous, next) {
      if (next.status == AuthStatus.error && next.errorMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.errorMessage!),
            backgroundColor: Colors.red,
          ),
        );
      } else if (next.status == AuthStatus.authenticated && context.mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const HomePage(),
          ),
        );
      }
    });

    return Scaffold(
      body: Container(
        height: screenSize.height,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              if (Theme.of(context).brightness == Brightness.light)
                colorScheme.primary.withOpacity(0.1),
              if (Theme.of(context).brightness == Brightness.dark)
                colorScheme.surface.withOpacity(0.1),
              colorScheme.surface,
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: isLargeScreen ? screenSize.width * 0.1 : 24.0,
                  vertical: 24.0,
                ),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: isLargeScreen ? 1200 : 600,
                  ),
                  child: isLargeScreen
                      ? _buildTwoColumnLayout(colorScheme)
                      : _buildSingleColumnLayout(colorScheme, isMediumScreen),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTwoColumnLayout(ColorScheme colorScheme) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Left column - Branding
        Expanded(
          flex: 5,
          child: Padding(
            padding: const EdgeInsets.only(right: 40.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Welcome to\nHabit Hero',
                  style: GoogleFonts.poppins(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Transform your life, one habit at a time',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    color: colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
                const SizedBox(height: 32),
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHighest.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.check_circle_outline,
                            color: colorScheme.primary,
                            size: 24,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'Track your daily habits',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Icon(
                            Icons.check_circle_outline,
                            color: colorScheme.primary,
                            size: 24,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'Visualize your progress',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Icon(
                            Icons.check_circle_outline,
                            color: colorScheme.primary,
                            size: 24,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'Earn achievements',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
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
        ),

        // Right column - Auth forms
        Expanded(
          flex: 4,
          child: Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: colorScheme.surface.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(25),
                      border: Border.all(
                        color: colorScheme.onSurface.withOpacity(0.1),
                      ),
                    ),
                    child: TabBar(
                      controller: _tabController,
                      indicatorSize: TabBarIndicatorSize.tab,
                      dividerColor: Colors.transparent,
                      indicator: BoxDecoration(
                        color: colorScheme.secondary.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(25),
                      ),
                      labelColor: Colors.white,
                      unselectedLabelColor:
                          colorScheme.onSurface.withOpacity(0.7),
                      tabs: const [
                        Tab(text: 'Login'),
                        Tab(text: 'Sign Up'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    height: 300,
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        _buildLoginForm(),
                        _buildSignUpForm(),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      const Expanded(child: Divider()),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          'OR',
                          style: TextStyle(
                            color: colorScheme.onSurface.withOpacity(0.5),
                          ),
                        ),
                      ),
                      const Expanded(child: Divider()),
                    ],
                  ),
                  const SizedBox(height: 24),
                  const GoogleSignInButton(),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSingleColumnLayout(
      ColorScheme colorScheme, bool isMediumScreen) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 40),
        Text(
          'Welcome to\nHabit Hero',
          style: GoogleFonts.poppins(
            fontSize: isMediumScreen ? 44 : 40,
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface,
            height: 1.2,
          ),
        ),
        const SizedBox(height: 20),
        Text(
          'Transform your life, one habit at a time',
          style: GoogleFonts.poppins(
            fontSize: isMediumScreen ? 18 : 16,
            color: colorScheme.onSurface.withOpacity(0.7),
          ),
        ),
        const SizedBox(height: 40),
        Container(
          decoration: BoxDecoration(
            color: colorScheme.surface.withOpacity(0.6),
            borderRadius: BorderRadius.circular(25),
            border: Border.all(
              color: colorScheme.onSurface.withOpacity(0.1),
            ),
          ),
          child: TabBar(
            controller: _tabController,
            indicatorSize: TabBarIndicatorSize.tab,
            dividerColor: Colors.transparent,
            indicator: BoxDecoration(
              color: colorScheme.secondary.withOpacity(0.7),
              borderRadius: BorderRadius.circular(25),
            ),
            labelColor: Colors.white,
            unselectedLabelColor: colorScheme.onSurface.withOpacity(0.7),
            tabs: const [
              Tab(text: 'Login'),
              Tab(text: 'Sign Up'),
            ],
          ),
        ),
        const SizedBox(height: 32),
        SizedBox(
          height: 300,
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildLoginForm(),
              _buildSignUpForm(),
            ],
          ),
        ),
        const SizedBox(height: 24),
        Row(
          children: [
            const Expanded(child: Divider()),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'OR',
                style: TextStyle(
                  color: colorScheme.onSurface.withOpacity(0.5),
                ),
              ),
            ),
            const Expanded(child: Divider()),
          ],
        ),
        const SizedBox(height: 24),
        const GoogleSignInButton(),
      ],
    );
  }

  Widget _buildLoginForm() {
    final isLoading = ref.watch(authStateProvider).status == AuthStatus.loading;

    return Column(
      children: [
        CustomTextField(
          controller: _emailController,
          hintText: 'Email',
          icon: Icons.email_outlined,
          enabled: !isLoading,
        ),
        const SizedBox(height: 16),
        CustomTextField(
          controller: _passwordController,
          hintText: 'Password',
          icon: Icons.lock_outline,
          isPassword: true,
          enabled: !isLoading,
        ),
        const SizedBox(height: 24),
        AnimatedButton(
          onPressed: _handleLogin,
          text: 'Login',
          isLoading: isLoading,
        ),
      ],
    );
  }

  Widget _buildSignUpForm() {
    final isLoading = ref.watch(authStateProvider).status == AuthStatus.loading;

    return Column(
      children: [
        CustomTextField(
          controller: _nameController,
          hintText: 'Full Name',
          icon: Icons.person_outline,
          enabled: !isLoading,
        ),
        const SizedBox(height: 16),
        CustomTextField(
          controller: _emailController,
          hintText: 'Email',
          icon: Icons.email_outlined,
          enabled: !isLoading,
        ),
        const SizedBox(height: 16),
        CustomTextField(
          controller: _passwordController,
          hintText: 'Password',
          icon: Icons.lock_outline,
          isPassword: true,
          enabled: !isLoading,
        ),
        const SizedBox(height: 24),
        AnimatedButton(
          onPressed: _handleSignUp,
          text: 'Create Account',
          isLoading: isLoading,
        ),
      ],
    );
  }
}
