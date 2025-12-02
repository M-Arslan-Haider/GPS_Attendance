import 'dart:ui';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';

class CustomDropdownSecond extends StatefulWidget {
  final String label;
  final IconData icon;
  final List<String> items;
  final String? selectedValue;
  final ValueChanged<String?> onChanged;
  final String? Function(String?) validator;
  final InputBorder? inputBorder;
  final Color? borderColor;
  final Color? iconColor;
  final Color? iconBackgroundColor;
  final List<BoxShadow>? boxShadow;
  final bool useBoxShadow;
  final double? maxHeight;
  final double? maxWidth;
  final double? iconSize;
  final double? contentPadding;
  final TextStyle? textStyle;
  final double? width;
  final double? height;
  final bool showSerialNumbers; // نیا پراپرٹی

  const CustomDropdownSecond({
    super.key,
    required this.label,
    required this.icon,
    required this.items,
    required this.selectedValue,
    required this.onChanged,
    required this.validator,
    this.inputBorder,
    this.borderColor,
    this.iconColor,
    this.iconBackgroundColor,
    this.boxShadow,
    this.useBoxShadow = true,
    this.maxHeight,
    this.maxWidth,
    this.iconSize = 24.0,
    this.contentPadding = 16.0,
    this.textStyle,
    this.width,
    this.height,
    this.showSerialNumbers = true, // ڈیفالٹ true
  });

  @override
  _CustomDropdownState createState() => _CustomDropdownState();
}

class _CustomDropdownState extends State<CustomDropdownSecond> {
  late String? _selectedValue;

  @override
  void initState() {
    super.initState();
    _selectedValue = widget.selectedValue;
    _printDebugInfo();
  }

  void _printDebugInfo() {
    print('=== CustomDropdownSecond Debug Info ===');
    print('Label: ${widget.label}');
    print('Total items received: ${widget.items.length}');
    print('Selected value: $_selectedValue');
    print('Show Serial Numbers: ${widget.showSerialNumbers}');

    if (widget.items.isNotEmpty) {
      print('First 10 items with serial numbers:');
      for (int i = 0; i < (widget.items.length < 10 ? widget.items.length : 10); i++) {
        print('  ${i + 1}. ${widget.items[i]}');
      }
    }
    print('====================================');
  }

  @override
  void didUpdateWidget(CustomDropdownSecond oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.items.length != widget.items.length) {
      print('🔄 Items list updated: ${oldWidget.items.length} -> ${widget.items.length}');
      _printDebugInfo();
    }

    if (oldWidget.selectedValue != widget.selectedValue) {
      setState(() {
        _selectedValue = widget.selectedValue;
      });
    }
  }

  // Serial number کے ساتھ item بنانے کا فنکشن
  String _getItemWithSerial(int index, String item) {
    if (widget.showSerialNumbers) {
      return '${index + 1}. $item';
    }
    return item;
  }

  // Serial number ہٹانے کا فنکشن (جب value select کریں)
  String _removeSerialNumber(String valueWithSerial) {
    if (!widget.showSerialNumbers) return valueWithSerial;

    // "1. Karachi" -> "Karachi"
    final regex = RegExp(r'^\d+\.\s*');
    return valueWithSerial.replaceFirst(regex, '');
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 1, right: 2, bottom: 16),
      child: Container(
        width: widget.width ?? double.infinity,
        height: widget.height ?? 55.0,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(3),
          boxShadow: widget.useBoxShadow
              ? widget.boxShadow ??
              [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  offset: const Offset(3, 5),
                  blurRadius: 6,
                ),
              ]
              : null,
          border: Border.all(
            color: widget.borderColor ?? Colors.transparent,
            width: 1.0,
          ),
        ),
        child: Row(
          children: [
            // Icon Container
            Container(
              decoration: BoxDecoration(
                color: widget.iconBackgroundColor ?? Colors.transparent,
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.all(5.0),
              child: Icon(
                widget.icon,
                size: widget.iconSize,
                color: widget.iconColor ?? Colors.black,
              ),
            ),

            // Dropdown
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: widget.contentPadding!),
                child: FormField<String>(
                  validator: widget.validator,
                  builder: (FormFieldState<String> state) {
                    return InputDecorator(
                      decoration: InputDecoration(
                        labelText: _selectedValue == null || _selectedValue!.isEmpty
                            ? widget.label
                            : null,
                        border: widget.inputBorder ?? InputBorder.none,
                        errorText: state.hasError ? state.errorText : null,
                        contentPadding: const EdgeInsets.symmetric(
                            vertical: 0.0, horizontal: 0.0),
                        floatingLabelBehavior: FloatingLabelBehavior.auto,
                      ),
                      isEmpty: _selectedValue == null || _selectedValue!.isEmpty,
                      child: DropdownButtonHideUnderline(
                        child: DropdownSearch<String>(
                          popupProps: PopupProps.bottomSheet(
                            showSearchBox: true,
                            searchFieldProps: TextFieldProps(
                              decoration: InputDecoration(
                                hintText: "Search ${widget.label}...",
                                border: const OutlineInputBorder(),
                                prefixIcon: const Icon(Icons.search),
                              ),
                            ),
                            itemBuilder: (context, item, isSelected) {
                              // اصل value حاصل کریں (serial number کے بغیر)
                              final originalValue = _removeSerialNumber(item);
                              // index حاصل کریں
                              final index = widget.items.indexOf(originalValue);

                              return Container(
                                decoration: BoxDecoration(
                                  color: isSelected ? Colors.blue.withOpacity(0.1) : Colors.transparent,
                                  border: Border(
                                    bottom: BorderSide(color: Colors.grey.shade200),
                                  ),
                                ),
                                child: ListTile(
                                  leading: widget.showSerialNumbers
                                      ? Container(
                                    width: 30,
                                    height: 30,
                                    decoration: BoxDecoration(
                                      color: Colors.blue,
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                    child: Center(
                                      child: Text(
                                        '${index + 1}',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                          // fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  )
                                      : null,
                                  title: Text(
                                    widget.showSerialNumbers
                                        ? '${index + 1}. $originalValue'
                                        : originalValue,
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 16,
                                      // fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                    ),
                                  ),
                                  trailing: isSelected
                                      ? const Icon(Icons.check, color: Colors.blue, size: 20)
                                      : null,
                                ),
                              );
                            },
                            constraints: BoxConstraints(
                              maxHeight: MediaQuery.of(context).size.height * 0.7,
                            ),
                            title: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.blue.shade50,
                                border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    '${widget.label} (${widget.items.length} items)',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: Colors.blue,
                                    ),
                                  ),
                                  if (widget.showSerialNumbers)
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: Colors.blue,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: const Text(
                                        'Serial #',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),

                          // Items list - serial numbers کے ساتھ
                          items: widget.showSerialNumbers
                              ? widget.items.asMap().entries.map((entry) {
                            final index = entry.key;
                            final item = entry.value;
                            return _getItemWithSerial(index, item);
                          }).toList()
                              : widget.items,

                          // Selected item
                          selectedItem: _selectedValue != null
                              ? widget.showSerialNumbers
                              ? _getItemWithSerial(
                              widget.items.indexOf(_selectedValue!),
                              _selectedValue!
                          )
                              : _selectedValue
                              : null,

                          // Dropdown decoration
                          dropdownDecoratorProps: DropDownDecoratorProps(
                            dropdownSearchDecoration: InputDecoration(
                              labelText: 'Select ${widget.label}',
                              border: InputBorder.none,
                              hintText: 'Choose from ${widget.items.length} options',
                              suffixIcon: widget.showSerialNumbers
                                  ? Tooltip(
                                message: 'Serial numbers enabled',
                                child: Icon(Icons.format_list_numbered, color: Colors.blue),
                              )
                                  : null,
                            ),
                          ),

                          // Dropdown builder
                          dropdownBuilder: (context, selectedItem) {
                            String displayText;
                            if (selectedItem == null) {
                              displayText = 'Select ${widget.label}';
                            } else if (widget.showSerialNumbers) {
                              // Serial number ہٹا کر صرف شہر کا نام دکھائیں
                              displayText = _removeSerialNumber(selectedItem);
                            } else {
                              displayText = selectedItem;
                            }

                            return Text(
                              displayText,
                              style: widget.textStyle ?? const TextStyle(
                                fontSize: 16,
                                color: Colors.black,
                                fontWeight: FontWeight.w500,
                              ),
                              overflow: TextOverflow.ellipsis,
                            );
                          },

                          // On changed
                          onChanged: (value) {
                            if (value != null) {
                              // Serial number ہٹا کر اصل value حاصل کریں
                              final originalValue = widget.showSerialNumbers
                                  ? _removeSerialNumber(value)
                                  : value;

                              print('🎯 ${widget.label} selected: $originalValue');
                              setState(() {
                                _selectedValue = originalValue;
                              });
                              widget.onChanged(originalValue);
                              state.didChange(originalValue);
                            }
                          },
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// import 'dart:ui';
//
// import 'package:flutter/material.dart';
// import 'package:dropdown_search/dropdown_search.dart';
//
// class CustomDropdownSecond extends StatefulWidget {
//   final String label;
//   final IconData icon;
//   final List<String> items;
//   final String? selectedValue;
//   final ValueChanged<String?> onChanged;
//   final String? Function(String?) validator;
//   final InputBorder? inputBorder;
//   final Color? borderColor;
//   final Color? iconColor;
//   final Color? iconBackgroundColor;
//   final List<BoxShadow>? boxShadow;
//   final bool useBoxShadow;
//   final double? maxHeight;
//   final double? maxWidth;
//   final double? iconSize;
//   final double? contentPadding;
//   final TextStyle? textStyle;
//   final double? width;
//   final double? height;
//   const CustomDropdownSecond({
//     super.key,
//     required this.label,
//     required this.icon,
//     required this.items,
//     required this.selectedValue,
//     required this.onChanged,
//     required this.validator,
//     this.inputBorder,
//     this.borderColor,
//     this.iconColor,
//     this.iconBackgroundColor,
//     this.boxShadow,
//     this.useBoxShadow = true,
//     this.maxHeight,
//     this.maxWidth,
//     this.iconSize = 24.0,
//     this.contentPadding = 16.0,
//     //this.font
//     this.textStyle,
//     this.width,
//     this.height,
//   });
//
//   @override
//   _CustomDropdownState createState() => _CustomDropdownState();
// }
//
// class _CustomDropdownState extends State<CustomDropdownSecond> {
//   late String? _selectedValue;
//
//   @override
//   void initState() {
//     super.initState();
//     _selectedValue = widget.selectedValue;
//   }
//
//   @override
//   void didUpdateWidget(CustomDropdownSecond oldWidget) {
//     super.didUpdateWidget(oldWidget);
//     if (oldWidget.selectedValue != widget.selectedValue) {
//       setState(() {
//         _selectedValue = widget.selectedValue;  // 👈 Sync with updated value
//       });
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.only(left: 1, right: 2, bottom: 16),
//       child: Container(
//         width: widget.width ?? double.infinity,
//         height: widget.height ?? 68.0,
//         decoration: BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.circular(3),
//           boxShadow: widget.useBoxShadow
//               ? widget.boxShadow ??
//               [
//                 BoxShadow(
//                   color: Colors.black.withOpacity(0.3),
//                   offset: Offset(3, 5),
//                   blurRadius: 6,
//                 ),
//               ]
//               : null,
//           border: Border.all(
//             color: widget.borderColor ?? Colors.transparent,
//             width: 1.0,
//           ),
//         ),
//         child: Row(
//           children: [
//             if (widget.icon != null)
//               Container(
//                 decoration: BoxDecoration(
//                   color: widget.iconBackgroundColor ?? Colors.transparent,
//                   borderRadius: BorderRadius.circular(10),
//                 ),
//                 padding: const EdgeInsets.all(5.0),
//                 child: Icon(
//                   widget.icon,
//                   size: widget.iconSize,
//                   color: widget.iconColor ?? Colors.black,
//                 ),
//               ),
//             Expanded(
//               child: Padding(
//                 padding:
//                 EdgeInsets.symmetric(horizontal: widget.contentPadding!),
//                 child: FormField<String>(
//                   validator: widget.validator,
//                   builder: (FormFieldState<String> state) {
//                     return InputDecorator(
//                       decoration: InputDecoration(
//                         labelText: _selectedValue == null
//                             ? widget.label
//                             : null,
//                         border: widget.inputBorder ?? InputBorder.none,
//                         errorText: state.hasError ? state.errorText : null,
//                         contentPadding: const EdgeInsets.symmetric(
//                             vertical: 0.0, horizontal: .0),
//                         floatingLabelBehavior: FloatingLabelBehavior.auto,
//                       ),
//                       isEmpty: _selectedValue == null,
//                       child: DropdownButtonHideUnderline(
//                         child: DropdownSearch<String>(
//                           popupProps: PopupProps.bottomSheet(
//                             showSearchBox: true,
//                             itemBuilder: (context, item, isSelected) =>
//                                 Padding(
//                                   padding: const EdgeInsets.all(8.0),
//                                   child: Text(
//                                     item,
//                                     style: const TextStyle(
//                                         color: Colors.black, fontSize: 15),
//                                   ),
//                                 ),
//                           ),
//                           items: widget.items,
//                           selectedItem: _selectedValue,
//                           dropdownDecoratorProps: DropDownDecoratorProps(
//                             dropdownSearchDecoration: InputDecoration(
//                               labelText: 'Select ${widget.label}',
//                               border: InputBorder.none,
//                             ),
//                           ),
//                           dropdownBuilder: (context, selectedItem) => Text(
//                             selectedItem ?? 'Select ${widget.label}',
//                             style: const TextStyle(
//                                 fontSize: 15, color: Colors.black),
//                           ),
//                           onChanged: (value) {
//                             setState(() {
//                               _selectedValue = value;
//                               widget.onChanged(value);
//                             });
//                             state.didChange(value);
//                           },
//                         ),
//                       ),
//                     );
//                   },
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
//
