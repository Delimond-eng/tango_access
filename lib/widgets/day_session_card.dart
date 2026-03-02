import 'package:flutter/material.dart';

import 'svg.dart';

class DaySessionCard extends StatelessWidget {
  final bool isStarted;
  const DaySessionCard({super.key, this.isStarted = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        // border: Border.all(color: Colors.white, width: 2.0),
        borderRadius: BorderRadius.circular(12.0),
        gradient: LinearGradient(
          colors:
              isStarted
                  ? const [Color(0xFF04805c), Color.fromARGB(255, 60, 237, 187)]
                  : const [
                    Color(0xFFc41f1f),
                    Color.fromARGB(255, 242, 130, 130),
                  ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(60.0),
                    color:
                        isStarted
                            ? const Color(0xFF2aa27d)
                            : const Color(0xFFda4444),
                  ),
                  height: 60.0,
                  width: 60.0,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Svg(
                        path: isStarted ? "calendar-check" : "lock",
                        color: Colors.white,
                        size: 35.0,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8.0),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (isStarted) ...[
                        const Text(
                          "Journée en cours",
                          style: TextStyle(
                            fontSize: 16.0,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 5.0),
                        Text(
                          "Collecte des taxes en cours",
                          style: TextStyle(
                            fontSize: 10.0,
                            color: Colors.grey.shade200,
                          ),
                        ),
                      ] else ...[
                        const Text(
                          "Journée non démarrée",
                          style: TextStyle(
                            fontSize: 16.0,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 5.0),
                        Text(
                          "Contactez votre chef pour démarrer la journée",
                          style: TextStyle(
                            fontSize: 10.0,
                            color: Colors.grey.shade200,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
            if (isStarted) ...[
              const SizedBox(height: 8.0),
              Container(
                height: 50.0,
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15.0),
                  border: Border.all(
                    color: const Color.fromARGB(255, 149, 218, 199),
                    width: 1.5,
                  ),
                  color: const Color(0xFF2aa27d),
                ),
                child: Material(
                  borderRadius: BorderRadius.circular(15.0),
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(15.0),
                    onTap: () {},
                    child: const Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Terminer la journée",
                          style: TextStyle(
                            fontSize: 14.0,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
