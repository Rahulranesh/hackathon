import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

// Venue list skeleton
class VenueListSkeleton extends StatelessWidget {
  const VenueListSkeleton({super.key});

  @override
  Widget build(BuildContext context) => ListView.builder(
        itemCount: 5,
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemBuilder: (_, i) => const _VenueSkeletonCard(),
      );
}

class _VenueSkeletonCard extends StatelessWidget {
  const _VenueSkeletonCard();

  @override
  Widget build(BuildContext context) => Shimmer.fromColors(
        baseColor: const Color(0xFF2A2A2A),
        highlightColor: const Color(0xFF3A3A3A),
        child: Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  width: 56, height: 56,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(height: 16, width: 140, color: Colors.white),
                      const SizedBox(height: 8),
                      Container(height: 12, width: 200, color: Colors.white),
                      const SizedBox(height: 8),
                      Container(height: 16, width: 80, color: Colors.white),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
}

// Slot grid skeleton
class SlotGridSkeleton extends StatelessWidget {
  const SlotGridSkeleton({super.key});

  @override
  Widget build(BuildContext context) => Shimmer.fromColors(
        baseColor: const Color(0xFF2A2A2A),
        highlightColor: const Color(0xFF3A3A3A),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              childAspectRatio: 0.85,
            ),
            itemCount: 16,
            itemBuilder: (_, i) => Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      );
}

// Bookings list skeleton
class BookingListSkeleton extends StatelessWidget {
  const BookingListSkeleton({super.key});

  @override
  Widget build(BuildContext context) => ListView.builder(
        itemCount: 3,
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemBuilder: (_, i) => Shimmer.fromColors(
          baseColor: const Color(0xFF2A2A2A),
          highlightColor: const Color(0xFF3A3A3A),
          child: Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 48, height: 48,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(height: 15, width: 120, color: Colors.white),
                        const SizedBox(height: 8),
                        Container(height: 13, width: 180, color: Colors.white),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
}
