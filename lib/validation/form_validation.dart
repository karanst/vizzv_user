class FormValidation {
  static String? validateMobile(value) {
// Indian Mobile number are of 10 digit only
    if (value.length != 10)
      return 'Mobile Number must be of 10 digit';
    else
      return null;
  }

  static String? aadharNumber(value) {
    if (value.length != 12)
      return 'Aadhar number must be of 12 digit';
    else
      return null;
  }

  static String? emailVeledetion(val) {
    print(val);
    var validemailadat = val.contains('@');
    var isEmaildort = val.contains('.');
    if (validemailadat == true && isEmaildort == true) {
      var newvale = val.length;
      var lveleded = val[newvale - 1].contains(RegExp(r'[a-z]'));
      if (lveleded == true) {
        return null;
      } else {
        return 'Please enter a valid email';
      }
    } else {
      return 'Please enter a valid email';
    }
  }

  static String? checkEmptyValidator(String? value) {
    if (value!.isEmpty) return 'This field is required';
    return null;
  }
}
