import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../domain/entities/auth_credentials.dart';

/// A specialized form field for Chilean RUT input with validation and formatting
class RutFormField extends StatefulWidget {
  final TextEditingController controller;
  final bool enabled;
  final String? labelText;
  final String? hintText;
  final IconData? prefixIcon;

  const RutFormField({
    super.key,
    required this.controller,
    this.enabled = true,
    this.labelText = 'RUT',
    this.hintText = '12.345.678-9',
    this.prefixIcon = Icons.person_outline,
  });

  @override
  State<RutFormField> createState() => _RutFormFieldState();
}

class _RutFormFieldState extends State<RutFormField> {
  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_formatRut);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_formatRut);
    super.dispose();
  }

  void _formatRut() {
    final text = widget.controller.text;
    final credentials = AuthCredentials(rut: text, password: '');
    final formatted = credentials.formattedRut;

    if (formatted != text) {
      final selection = widget.controller.selection;
      widget.controller.value = TextEditingValue(
        text: formatted,
        selection: TextSelection.collapsed(
          offset: formatted.length.clamp(0, formatted.length),
        ),
      );
    }
  }

  String? _validateRut(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Por favor ingresa tu RUT';
    }

    final credentials = AuthCredentials(rut: value, password: '');
    if (!credentials.isValidRut) {
      return 'Por favor ingresa un RUT válido';
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      enabled: widget.enabled,
      keyboardType: TextInputType.text,
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'[\d.kK-]')),
        LengthLimitingTextInputFormatter(12), // Max length for formatted RUT
      ],
      decoration: InputDecoration(
        labelText: widget.labelText,
        hintText: widget.hintText,
        prefixIcon: widget.prefixIcon != null ? Icon(widget.prefixIcon) : null,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF667eea), width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.red.shade400),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.red.shade400, width: 2),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
      ),
      validator: _validateRut,
    );
  }
}
