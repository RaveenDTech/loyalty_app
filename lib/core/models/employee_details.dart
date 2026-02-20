/// Data passed between onboarding steps (EPF → Employee Details → OTP).
class EmployeeDetails {
  final String? epfNo;
  final String? nic;
  final String? initials;
  final String? titleDescription;
  final String? firstName;
  final String? lastName;
  final String? email;
  final String? mobileNo;
  final DateTime? dob;
  final int? age;
  final String? gender;
  final String? policyType;
  final String? houseNo;
  final String? street1;
  final String? street2;
  final String? city;
  final String? companyName;
  final String? staffCategory;
  final String? staffType;
  final String? permanentDate;
  final String? designation;
  final bool isTemp;
  final String? tempId;

  EmployeeDetails({
    this.epfNo,
    this.nic,
    this.initials,
    this.titleDescription,
    this.firstName,
    this.lastName,
    this.email,
    this.mobileNo,
    this.dob,
    this.age,
    this.gender,
    this.policyType,
    this.houseNo,
    this.street1,
    this.street2,
    this.city,
    this.companyName,
    this.staffCategory,
    this.staffType,
    this.permanentDate,
    this.designation,
    this.isTemp = false,
    this.tempId,
  });

  EmployeeDetails copyWith({
    String? email,
    String? mobileNo,
  }) {
    return EmployeeDetails(
      epfNo: epfNo,
      nic: nic,
      initials: initials,
      titleDescription: titleDescription,
      firstName: firstName,
      lastName: lastName,
      email: email ?? this.email,
      mobileNo: mobileNo ?? this.mobileNo,
      dob: dob,
      age: age,
      gender: gender,
      policyType: policyType,
      houseNo: houseNo,
      street1: street1,
      street2: street2,
      city: city,
      companyName: companyName,
      staffCategory: staffCategory,
      staffType: staffType,
      permanentDate: permanentDate,
      designation: designation,
      isTemp: isTemp,
      tempId: tempId,
    );
  }
}
