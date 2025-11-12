// class _NotificationCard extends StatelessWidget {
//   final NotificationModel alert;

//   const _NotificationCard({required this.alert});

//   @override
//   Widget build(BuildContext context) {
//     final iconData = _alertIcon(alert.type);
//     final bgColor = _alertColor(alert.type);

//     return Container(
//       decoration: BoxDecoration(
//         border: Border.all(color: Colors.grey.withOpacity(0.2)),
//         borderRadius: BorderRadius.circular(16),
//         color: Theme.of(context).colorScheme.surface,
//       ),
//       child: InkWell(
//         borderRadius: BorderRadius.circular(16),
//         onTap: () {
//           // optional analytics or navigation
//         },
//         child: Padding(
//           padding: const EdgeInsets.all(14),
//           child: Row(
//             crossAxisAlignment: CrossAxisAlignment.center,
//             children: [
//               Container(
//                 width: 48,
//                 height: 48,
//                 decoration: BoxDecoration(
//                   color: bgColor,
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//                 child: Icon(iconData, color: Colors.black54, size: 26),
//               ),
//               const SizedBox(width: 12),
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       alert.title,
//                       style: const TextStyle(
//                         fontSize: 16,
//                         fontWeight: FontWeight.w600,
//                       ),
//                       overflow: TextOverflow.ellipsis,
//                     ),
//                     const SizedBox(height: 2),
//                     Text(
//                       alert.message,
//                       style: TextStyle(
//                         color: Theme.of(context).colorScheme.onSurfaceVariant,
//                       ),
//                       maxLines: 2,
//                       overflow: TextOverflow.ellipsis,
//                     ),
//                   ],
//                 ),
//               ),
//               const SizedBox(width: 8),
//               Text(
//                 _timeAgo(alert.timestamp),
//                 style: TextStyle(
//                   fontSize: 12,
//                   color: Theme.of(context).colorScheme.onSurfaceVariant,
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   IconData _alertIcon(String type) {
//     switch (type.toLowerCase()) {
//       case 'emergency':
//         return Icons.warning_amber_rounded;
//       case 'medical':
//         return Icons.health_and_safety_outlined;
//       case 'security':
//         return Icons.shield_outlined;
//       case 'info':
//         return Icons.menu_book_outlined;
//       default:
//         return Icons.notifications_none_outlined;
//     }
//   }

//   Color _alertColor(String type) {
//     switch (type.toLowerCase()) {
//       case 'emergency':
//         return const Color(0xFFFFE2E1);
//       case 'medical':
//         return const Color(0xFFEFF2F6);
//       case 'security':
//         return const Color(0xFFEFF2F6);
//       case 'info':
//         return const Color(0xFFEFF2F6);
//       default:
//         return const Color(0xFFEFF2F6);
//     }
//   }

//   String _timeAgo(DateTime timestamp) {
//     final diff = DateTime.now().difference(timestamp);
//     if (diff.inMinutes < 1) return 'Now';
//     if (diff.inMinutes < 60) return '${diff.inMinutes} min ago';
//     if (diff.inHours < 24) return '${diff.inHours} hr ago';
//     return DateFormat('dd MMM').format(timestamp);
//   }
// }
