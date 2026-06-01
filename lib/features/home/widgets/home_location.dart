import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:provider/provider.dart';
import 'package:recommendation_app/core/themes/app_theme.dart';
import 'package:recommendation_app/core/widgets/app_spacing.dart';
import 'package:recommendation_app/features/home/provider/home_location_provider.dart';

class HomeLocation extends StatelessWidget {
  const HomeLocation({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<HomeLocationProvider>();

    return InkWell(
      onTap: provider.isLoading ? null : () => provider.fetchLocation(),
      borderRadius: BorderRadius.circular(32),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: _LocationContent(
          location: provider.readableAddress,
          isLoading: provider.isLoading,
        ),
      ),
    );
  }
}

class _LocationContent extends StatelessWidget {
  final String location;
  final bool isLoading;

  const _LocationContent({required this.location, required this.isLoading});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Row(
            children: [
              HugeIcon(
                icon: HugeIcons.strokeRoundedLocation01,
                size: 20,
                color: context.colors.onSurfaceVariant,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: AnimatedOpacity(
                  opacity: isLoading ? 0.5 : 1.0,
                  duration: const Duration(milliseconds: 200),
                  child: Text(
                    location,
                    style: context.text.titleMedium?.copyWith(
                      color: context.colors.onSurfaceVariant,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ],
          ),
        ),
        AppSpacing.h16,
        if (isLoading)
          const SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.grey),
            ),
          )
        else
          HugeIcon(
            icon: HugeIcons.strokeRoundedArrowRight02,
            size: 22,
            color: context.colors.primary,
          ),
      ],
    );
  }
}
