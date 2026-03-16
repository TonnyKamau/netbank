import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'routes/app_router.dart';

class CompressItApp extends StatelessWidget {
  const CompressItApp({super.key, this.skipOnboarding = false});

  final bool skipOnboarding;

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Netbank',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      routerConfig: buildRouter(skipOnboarding),
      builder: (context, child) {
        Widget result = MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaler: MediaQuery.textScalerOf(context).clamp(
              minScaleFactor: 0.8,
              maxScaleFactor: 1.2,
            ),
          ),
          child: child!,
        );
        if (MediaQuery.sizeOf(context).width >= 600) {
          return ColoredBox(
            color: Theme.of(context).scaffoldBackgroundColor,
            child: Center(
              child: SizedBox(width: 480, child: result),
            ),
          );
        }
        return result;
      },
    );
  }
}
