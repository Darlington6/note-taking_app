// Validates email input.
String? validateEmail(String? value) {
  if (value == null || value.trim().isEmpty) {
    return 'Email cannot be empty';
  }
  if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w]{2,4}').hasMatch(value)) {
    return 'Enter a valid email address';
  }
  return null;
}

// Validates password input.
String? validatePassword(String? value) {
  if (value == null || value.trim().isEmpty) {
    return 'Password cannot be empty';
  }
  if (value.trim().length < 6) {
    return 'Password must be at least 6 characters';
  }
  return null;
}