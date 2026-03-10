class LoginModels {
  int? emp_id;
  String? portal_password;
  String? emp_name;
  String? job; // This is the designation/role

  LoginModels({
    this.emp_id,
    this.portal_password,
    this.emp_name,
    this.job,
  });

  factory LoginModels.fromJson(Map<String, dynamic> json) {
    return LoginModels(
      emp_id: json['emp_id'],
      portal_password: json['portal_password'],
      emp_name: json['emp_name'],
      job: json['job'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'emp_id': emp_id,
      'portal_password': portal_password,
      'emp_name': emp_name,
      'job': job,
    };
  }
}