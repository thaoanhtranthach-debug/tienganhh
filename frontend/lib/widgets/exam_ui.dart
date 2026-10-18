import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class ExamPage extends StatelessWidget {
  const ExamPage({
    required this.title,
    required this.child,
    this.actions = const [],
    this.bottomNavigationBar,
    this.leading,
    super.key,
  });

  final String title;
  final Widget child;
  final List<Widget> actions;
  final Widget? bottomNavigationBar;
  final Widget? leading;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: leading,
        titleSpacing: 8,
        title: Text(
          title,
          style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
        ),
        actions: actions,
      ),
      body: SafeArea(
        top: false,
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: child,
          ),
        ),
      ),
      bottomNavigationBar: bottomNavigationBar,
    );
  }
}

class PageBody extends StatelessWidget {
  const PageBody({
    required this.children,
    this.padding = const EdgeInsets.fromLTRB(16, 10, 16, 24),
    super.key,
  });

  final List<Widget> children;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: padding,
      children:
          children
              .expand((child) => [child, const SizedBox(height: 14)])
              .toList()
            ..removeLast(),
    );
  }
}

class SurfaceCard extends StatelessWidget {
  const SurfaceCard({
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.color = AppColors.surface,
    this.onTap,
    super.key,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color color;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: color,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Padding(padding: padding, child: child),
      ),
    );
  }
}

class ScreenHeading extends StatelessWidget {
  const ScreenHeading(this.title, {this.subtitle, super.key});

  final String title;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleLarge
              ?.copyWith(color: AppColors.primary, fontWeight: FontWeight.w800),
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 4),
          Text(
            subtitle!,
            style: const TextStyle(color: AppColors.muted, height: 1.4),
          ),
        ],
      ],
    );
  }
}

class InfoPill extends StatelessWidget {
  const InfoPill(
    this.label, {
    this.icon,
    this.color = AppColors.surfaceLow,
    this.textColor = AppColors.primary,
    super.key,
  });

  final String label;
  final IconData? icon;
  final Color color;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 14, color: textColor),
            const SizedBox(width: 5),
          ],
          Text(
            label,
            style: TextStyle(
              color: textColor,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class AppBottomNav extends StatelessWidget {
  const AppBottomNav({
    required this.selectedIndex,
    required this.onSelected,
    super.key,
  });

  final int selectedIndex;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      selectedIndex: selectedIndex,
      onDestinationSelected: onSelected,
      destinations: const [
        NavigationDestination(
          icon: Icon(Icons.article_outlined),
          label: 'Đề thi',
        ),
        NavigationDestination(
          icon: Icon(Icons.assignment_outlined),
          label: 'Quản lý',
        ),
        NavigationDestination(icon: Icon(Icons.query_stats), label: 'Thống kê'),
        NavigationDestination(
          icon: Icon(Icons.person_outline),
          label: 'Tài khoản',
        ),
      ],
    );
  }
}

void showAppMessage(BuildContext context, String message) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(message)));
}
