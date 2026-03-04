// lib/modules/admin/dashboard/widgets/activity_tile.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../data/models/activity_model.dart';

class ActivityTile extends StatelessWidget {
  final ActivityModel activity;
  final VoidCallback? onTap;

  const ActivityTile({
    Key? key,
    required this.activity,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            // Icon with background
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: activity.getColor().withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                activity.getIcon(),
                color: activity.getColor(),
                size: 18,
              ),
            ),
            const SizedBox(width: 12),
            
            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RichText(
                    text: TextSpan(
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: const Color(0xFF1E1E2F),
                      ),
                      children: [
                        TextSpan(
                          text: activity.userName,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        TextSpan(
                          text: ' ${activity.action} ',
                        ),
                        TextSpan(
                          text: activity.productName,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: activity.getColor().withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          '${activity.quantity} units',
                          style: GoogleFonts.inter(
                            fontSize: 10,
                            color: activity.getColor(),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(
                        Icons.access_time,
                        size: 12,
                        color: Colors.grey.shade400,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        activity.timeAgo,
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            // More options
            PopupMenuButton<String>(
              icon: Icon(
                Icons.more_vert,
                size: 18,
                color: Colors.grey.shade500,
              ),
              onSelected: (value) {
                // Handle menu actions
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'view',
                  child: Text('View Details'),
                ),
                const PopupMenuItem(
                  value: 'mark_read',
                  child: Text('Mark as Read'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}