// class District {
//   final int id;
//   final String name;
//   final String bnName;
//
//   District({required this.id, required this.name, required this.bnName});
//
//   factory District.fromJson(Map<String, dynamic> json) {
//     return District(
//       id: json['id'],
//       name: json['name'],
//       bnName: json['bn_name'],
//     );
//   }
// }
//
// class InvestorProfile {
//   final String name;
//   final String email;
//   final String phone;
//   final String address;
//   final District district;
//   final String mobileBankingNumber;
//   final String mobileBankingMedia;
//   final String bankName;
//   final String branchName;
//   final String accountName;
//   final String accountNumber;
//
//   InvestorProfile({
//     required this.name,
//     required this.email,
//     required this.phone,
//     required this.address,
//     required this.district,
//     required this.mobileBankingNumber,
//     required this.mobileBankingMedia,
//     required this.bankName,
//     required this.branchName,
//     required this.accountName,
//     required this.accountNumber,
//   });
//
//   factory InvestorProfile.fromJson(Map<String, dynamic> json) {
//     return InvestorProfile(
//       name: json['name'] ?? '',
//       email: json['email'] ?? '',
//       phone: json['phone'] ?? '',
//       address: json['address'] ?? '',
//       district: District.fromJson(json['district']),
//       mobileBankingNumber: json['mobile_banking_number'] ?? '',
//       mobileBankingMedia: json['mobile_banking_media'] ?? '',
//       bankName: json['bank_name'] ?? '',
//       branchName: json['branch_name'] ?? '',
//       accountName: json['account_name'] ?? '',
//       accountNumber: json['account_number'] ?? '',
//     );
//   }
// }
// models/investor_profile_model.dart

// ==============================
// MODEL: investor_profile_model.dart
// ==============================

class InvestorProfileResponse {
  final Investor investor;
  final BankingInformation bankingInformation;
  final NomineeInformation? nomineeInformation;
  final ProfileCompletion profileCompletion;

  InvestorProfileResponse({
    required this.investor,
    required this.bankingInformation,
    required this.nomineeInformation,
    required this.profileCompletion,
  });

  factory InvestorProfileResponse.fromJson(Map<String, dynamic> json) {
    return InvestorProfileResponse(
      investor: Investor.fromJson(json['investor']),
      bankingInformation: BankingInformation.fromJson(json['banking_information']),
      nomineeInformation: json['nominee_information'] != null
          ? NomineeInformation.fromJson(json['nominee_information'])
          : null,
      profileCompletion: ProfileCompletion.fromJson(json['profile_completion']),
    );
  }
}

class Investor {
  final String investorCode;
  final String name;
  final String phone;
  final String email;
  final String? nid;
  final dynamic districtId;
  final dynamic upazilaId;
  final String? address;
  final String? image;

  Investor({
    required this.investorCode,
    required this.name,
    required this.phone,
    required this.email,
    this.nid,
    this.districtId,
    this.upazilaId,
    this.address,
    this.image,
  });

  factory Investor.fromJson(Map<String, dynamic> json) {
    return Investor(
      investorCode: json['investor_code'] ?? '',
      name: json['name'] ?? '',
      phone: json['phone'] ?? '',
      email: json['email'] ?? '',
      nid: json['nid'],
      districtId: json['district_id'],
      upazilaId: json['upazila_id'],
      address: json['address'],
      image: json['image'],
    );
  }
}

class BankingInformation {
  final String? bankAccountName;
  final String? bankName;
  final String? branchName;
  final String? accountNumber;
  final String? routingNo;
  final String? bkashNumber;
  final String? rocketNumber;
  final String? nagadNumber;

  BankingInformation({
    this.bankAccountName,
    this.bankName,
    this.branchName,
    this.accountNumber,
    this.routingNo,
    this.bkashNumber,
    this.rocketNumber,
    this.nagadNumber,
  });

  factory BankingInformation.fromJson(Map<String, dynamic> json) {
    return BankingInformation(
      bankAccountName: json['bank_account_name'],
      bankName: json['bank_name'],
      branchName: json['branch_name'],
      accountNumber: json['account_number'],
      routingNo: json['routing_no'],
      bkashNumber: json['bkash_number'],
      rocketNumber: json['rocket_number'],
      nagadNumber: json['nagad_number'],
    );
  }
}

class NomineeInformation {
  final String name;
  final String relation;
  final String contact;
  final String nid;
  final String address;

  NomineeInformation({
    required this.name,
    required this.relation,
    required this.contact,
    required this.nid,
    required this.address,
  });

  factory NomineeInformation.fromJson(Map<String, dynamic> json) {
    return NomineeInformation(
      name: json['name'] ?? '',
      relation: json['relation'] ?? '',
      contact: json['contact'] ?? '',
      nid: json['nid'] ?? '',
      address: json['address'] ?? '',
    );
  }
}

class ProfileCompletion {
  final int percentage;
  final List<String> missingFields;

  ProfileCompletion({
    required this.percentage,
    required this.missingFields,
  });

  factory ProfileCompletion.fromJson(Map<String, dynamic> json) {
    List<String> missing = [];
    if (json['missing_fields'] != null) {
      missing = List<String>.from(json['missing_fields']);
    }
    return ProfileCompletion(
      percentage: json['percentage'] ?? 0,
      missingFields: missing,
    );
  }
}



