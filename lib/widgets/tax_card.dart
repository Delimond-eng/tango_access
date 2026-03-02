import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../theme/style.dart';

class TaxCard extends StatelessWidget {
  const TaxCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: 65.0,
      decoration: const BoxDecoration(color: Colors.white),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {},
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Image.asset("assets/icons/data-analysis.png", height: 30.0),
                const SizedBox(width: 8.0),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Liste des taxes pour vous !',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          color: primaryColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        "Sélectionnez le taxe !",
                        style: TextStyle(
                          fontSize: 12.0,
                          fontWeight: FontWeight.w400,
                          color: Colors.deepPurple.shade200,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  CupertinoIcons.chevron_right,
                  color: Colors.deepPurple.shade200,
                  size: 16.0,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
