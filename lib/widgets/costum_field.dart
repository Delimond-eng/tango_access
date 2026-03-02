import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:taxenew/theme/style.dart';

class CustomField<T> extends StatelessWidget {
  final String hintText;
  final bool? isPassword;
  final String iconPath;
  final TextInputType? inputType;
  final TextEditingController? controller;
  final bool? isDropdown;
  final Function(T? value)? onChangedDrop;
  final List<T>? dropItems;
  final T? selectedItem;
  final GlobalKey? fieldKey;

  const CustomField({
    super.key,
    required this.hintText,
    this.isPassword = false,
    required this.iconPath,
    this.controller,
    this.inputType,
    this.isDropdown = false,
    this.onChangedDrop,
    this.dropItems,
    this.selectedItem,
    this.fieldKey,
  });

  @override
  Widget build(BuildContext context) {
    var obscurText = true;
    return StatefulBuilder(
      builder: (context, setter) {
        return Container(
          height: 50.0,
          margin: const EdgeInsets.only(bottom: 8.0),
          width: MediaQuery.of(context).size.width,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15.0),
            color: Colors.white,
            border: Border.all(color: Colors.grey.shade300, width: 1),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
            child: Row(
              children: [
                Row(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: primaryColor.shade50,
                        shape: BoxShape.circle,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(6.0),
                        child: SvgPicture.asset(
                          "assets/icons/$iconPath.svg",
                          colorFilter: ColorFilter.mode(
                            primaryColor.shade900,
                            BlendMode.srcIn,
                          ),
                          width: 14.0,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10.0),
                  ],
                ),
                if (isDropdown!) ...[
                  Flexible(
                    child: DropdownButtonFormField<T>(
                      key: fieldKey,
                      menuMaxHeight: 400,
                      validator: (value) {
                        if (value == null) {
                          return null;
                        }
                        return value.toString();
                      },
                      value: selectedItem,
                      style: const TextStyle(
                        fontFamily: 'Ubuntu',
                        fontSize: 12.0,
                        color: Colors.black,
                        fontWeight: FontWeight.w700,
                      ),
                      hint: Text(
                        hintText,
                        style: TextStyle(
                          fontFamily: 'Ubuntu',
                          fontSize: 12.0,
                          color: Colors.grey.shade600,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        hintText: hintText,
                        hintStyle: TextStyle(
                          fontFamily: 'Ubuntu',
                          fontSize: 12.0,
                          color: Colors.grey.shade600,
                          fontWeight: FontWeight.w600,
                        ),
                        counterText: '',
                      ),
                      isExpanded: true,
                      items:
                          dropItems!.map((T? e) {
                            return DropdownMenuItem<T>(
                              value: e,
                              child: Text(e.toString()),
                            );
                          }).toList(),
                      onChanged: (T? value) {
                        onChangedDrop!.call(value);
                      },
                    ),
                  ),
                ] else ...[
                  Expanded(
                    child:
                        isPassword!
                            ? TextField(
                              controller: controller,
                              keyboardType: inputType ?? TextInputType.text,
                              style: const TextStyle(
                                fontFamily: 'Ubuntu',
                                fontSize: 12.0,
                                color: Colors.black,
                                fontWeight: FontWeight.w700,
                              ),
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                enabledBorder: InputBorder.none,
                                focusedBorder: InputBorder.none,
                                hintText: hintText,
                                hintStyle: TextStyle(
                                  fontFamily: 'Ubuntu',
                                  fontSize: 12.0,
                                  color: Colors.grey.shade600,
                                  fontWeight: FontWeight.w400,
                                ),
                                counterText: '',
                              ),
                              obscureText: obscurText,
                            )
                            : TextField(
                              keyboardType: inputType ?? TextInputType.text,
                              keyboardAppearance: Brightness.dark,
                              controller: controller,
                              style: const TextStyle(
                                fontFamily: 'Ubuntu',
                                fontSize: 12.0,
                                color: Colors.black,
                                fontWeight: FontWeight.w700,
                              ),
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                enabledBorder: InputBorder.none,
                                focusedBorder: InputBorder.none,
                                hintText: hintText,
                                hintStyle: TextStyle(
                                  fontFamily: 'Ubuntu',
                                  fontSize: 12.0,
                                  color: Colors.grey.shade600,
                                  fontWeight: FontWeight.w400,
                                ),
                                counterText: '',
                              ),
                            ),
                  ),
                  if (isPassword!)
                    GestureDetector(
                      onTap: () {
                        setter(() => obscurText = !obscurText);
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(5.0),
                        child: SvgPicture.asset(
                          obscurText == true
                              ? "assets/icons/eye-alt.svg"
                              : "assets/icons/eye-slash-alt.svg",
                          height: 24,
                          width: 24,
                          colorFilter: ColorFilter.mode(
                            Theme.of(
                              context,
                            ).textTheme.bodyLarge!.color!.withOpacity(0.3),
                            BlendMode.srcIn,
                          ),
                        ),
                      ),
                    ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}

class CustomDateTimeField extends StatelessWidget {
  final String hintText;
  final String iconPath;
  final DateTime? selectedDateTime;
  final Function(DateTime dateTime) onChanged;
  final GlobalKey? fieldKey;

  const CustomDateTimeField({
    super.key,
    required this.hintText,
    required this.iconPath,
    this.selectedDateTime,
    required this.onChanged,
    this.fieldKey,
  });

  Future<void> _pickDateTime(BuildContext context) async {
    /// Pick date
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: selectedDateTime ?? DateTime.now(),
      firstDate: DateTime(2025),
      lastDate: DateTime(2100),
    );

    if (pickedDate == null) return;

    /// Pick time
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime:
          selectedDateTime != null
              ? TimeOfDay.fromDateTime(selectedDateTime!)
              : TimeOfDay.now(),
    );

    if (pickedTime == null) return;

    /// Combine Date + Time
    final DateTime result = DateTime(
      pickedDate.year,
      pickedDate.month,
      pickedDate.day,
      pickedTime.hour,
      pickedTime.minute,
    );

    onChanged(result);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _pickDateTime(context),
      child: Container(
        key: fieldKey,
        height: 50.0,
        margin: const EdgeInsets.only(bottom: 8.0),
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15.0),
          color: Colors.white,
          border: Border.all(color: Colors.grey.shade300, width: 1),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10.0),
          child: Row(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: primaryColor.shade50,
                  shape: BoxShape.circle,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(6.0),
                  child: SvgPicture.asset(
                    "assets/icons/$iconPath.svg",
                    colorFilter: ColorFilter.mode(
                      primaryColor.shade900,
                      BlendMode.srcIn,
                    ),
                    width: 14.0,
                  ),
                ),
              ),
              const SizedBox(width: 10.0),

              Expanded(
                child: Text(
                  selectedDateTime != null
                      ? _formatDateTime(selectedDateTime!)
                      : hintText,
                  style: TextStyle(
                    fontFamily: 'Ubuntu',
                    fontSize: 12.0,
                    fontWeight: FontWeight.w600,
                    color:
                        selectedDateTime != null
                            ? Colors.black
                            : Colors.grey.shade600,
                  ),
                ),
              ),

              const Icon(
                Icons.chevron_right_rounded,
                size: 14,
                color: Colors.grey,
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return "${dateTime.day.toString().padLeft(2, '0')}/"
        "${dateTime.month.toString().padLeft(2, '0')}/"
        "${dateTime.year} "
        "${dateTime.hour.toString().padLeft(2, '0')}:"
        "${dateTime.minute.toString().padLeft(2, '0')}";
  }
}
