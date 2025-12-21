import 'package:url_launcher/url_launcher.dart';

class LaunchLink {
  static launchPhone(String telephoneNumber) async {
    try {
      launchURL(telephoneNumber);
    } catch (e) {
      throw "Error occured trying to call that number.";
    }
  }

  static launchURL(String link) async {
    Uri url = Uri.parse(link);
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      throw "Error occured, cannot launch url.";
    }
  }
}

void makePhoneCall(
  String phoneNumber,
) async {
  try {
    // Clean the phone number - remove any extra whitespace
    final cleanedNumber = phoneNumber.trim();
    
    // For international format with +, use it directly in the tel: scheme
    // The + character is valid in tel: URIs
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: cleanedNumber,
    );
    
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    } else {
      // If canLaunchUrl returns false, the phone call cannot be made
      // This might happen if there's no phone app or the format is invalid
      // We'll let the calling code handle the error
      throw Exception('Cannot launch phone call');
    }
  } catch (e) {
    // Re-throw to let calling code handle the error
    rethrow;
  }
}

// Helper function to validate and format phone number
String? validateAndFormatPhoneNumber(String phoneNumber) {
  try {
    // Clean the phone number - remove any spaces, dashes, or other characters
    String cleanedNumber = phoneNumber.replaceAll(RegExp(r'[^\d]'), '');

    // Check if the number is empty
    if (cleanedNumber.isEmpty) {
      return null; // Invalid: empty
    }

    // Ensure the number starts with 0
    if (!cleanedNumber.startsWith('0')) {
      cleanedNumber = '0$cleanedNumber';
    }

    // Check if number is too long
    if (cleanedNumber.length > 11) {
      return null; // Invalid: too long
    }

    // Ensure the final number is exactly 11 digits
    if (cleanedNumber.length < 11) {
      // If shorter than 11, pad with zeros at the beginning (after the leading 0)
      int paddingNeeded = 11 - cleanedNumber.length;
      cleanedNumber = '0' + '0' * paddingNeeded + cleanedNumber.substring(1);
    }

    // Validate that we have exactly 11 digits starting with 0
    if (cleanedNumber.length == 11 && cleanedNumber.startsWith('0')) {
      return cleanedNumber;
    } else {
      return null; // Invalid format
    }
  } catch (e) {
    return null; // Error in processing
  }
}
