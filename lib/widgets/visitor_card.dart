import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../models/qrcode.dart';
import '../theme/style.dart';

class VisitorCard extends StatelessWidget {
  final VoidCallback onPressed;
  final Qrcode data;
  const VisitorCard({super.key, required this.onPressed, required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Icon Box
          Container(
            height: 54,
            width: 54,
            decoration: BoxDecoration(
              color: secondary.withOpacity(0.05),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Icon(Icons.qr_code_2_rounded, color: secondary, size: 28),
          ),
          const SizedBox(width: 16),
          // Info Section
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data.visitor?.name ?? "Inconnu",
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                    color: Colors.black87,
                    fontFamily: 'Ubuntu',
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "Expire : ${data.validTo}",
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Ubuntu',
                  ),
                ),
              ],
            ),
          ),
          // Menu Button (Round icon button)
          Material(
            color: secondary.withOpacity(0.08),
            shape: const CircleBorder(),
            child: InkWell(
              onTap: onPressed,
              customBorder: const CircleBorder(),
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Icon(CupertinoIcons.ellipsis_vertical, size: 18, color: secondary),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
