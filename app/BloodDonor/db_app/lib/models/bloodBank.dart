class BloodBank {
  String BloodBankName;
  String BloodBankAddress;
  String BloodBankContact;
  BloodBank(
      {required this.BloodBankAddress,
      required this.BloodBankContact,
      required this.BloodBankName});

  factory BloodBank.fromJson(Map<String, dynamic> json) {
    return BloodBank(
      BloodBankAddress: json['BloodBankAddress'],
      BloodBankContact: json['BloodBankContact'],
      BloodBankName: json['BloodBankName'],
    );
  }
}
