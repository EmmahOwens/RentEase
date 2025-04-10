import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/theme_provider.dart';
import '../widgets/glass_card.dart';

class DashboardLayout extends StatelessWidget {
  final String title;
  final Widget body;
  final List<Widget>? actions;
  final Widget? floatingActionButton;
  final Widget? bottomNavigationBar;

  const DashboardLayout({
    super.key,
    required this.title,
    required this.body,
    this.actions,
    this.floatingActionButton,
    this.bottomNavigationBar,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          title,
          style: theme.textTheme.titleLarge?.copyWith(
            color: isDark ? Colors.white : theme.colorScheme.primary,
          ),
        ),
        actions: [
          if (actions != null) ...actions!,
          IconButton(
            icon: Icon(
              isDark ? Icons.light_mode : Icons.dark_mode,
              color: isDark ? Colors.white : theme.colorScheme.primary,
            ),
            onPressed: () {
              context.read<ThemeProvider>().toggleTheme();
            },
          ),
        ],
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              theme.colorScheme.primary.withOpacity(0.1),
              theme.colorScheme.secondary.withOpacity(0.05),
            ],
          ),
        ),
        child: body,
      ),
      floatingActionButton: floatingActionButton != null
          ? GlassCard(
              padding: EdgeInsets.zero,
              child: floatingActionButton!,
            )
          : null,
      bottomNavigationBar: bottomNavigationBar != null
          ? GlassCard(
              padding: EdgeInsets.zero,
              borderRadius: 0,
              child: bottomNavigationBar!,
            )
          : null,
    );
  }
}