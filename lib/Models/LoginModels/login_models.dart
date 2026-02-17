class LoginModels{
  String? user_id;
  String? password;
  String? user_name;
  String? city;
  dynamic designation;
  dynamic brand;
  dynamic images;
  dynamic rsm;
  dynamic sm;
  dynamic nsm;
  dynamic dispatcher;
  dynamic rsm_id;
  dynamic sm_id;
  dynamic nsm_id;
  dynamic dispatcher_id;

  LoginModels({
    this.user_id,
    this.password,
    this.user_name,
    this.city,
    this.designation,
    this.brand,
    this.images,
    this.nsm,
    this.nsm_id,
    this.rsm,
    this.rsm_id,
    this.sm,
    this.sm_id,
    this.dispatcher,
    this.dispatcher_id,


  });
  factory
  LoginModels.fromMap(Map<dynamic,dynamic>json){
    return LoginModels(
      user_id: json['user_id'],
      password: json['password'],
      user_name: json['user_name'],
      city: json['city'],
      rsm_id: json['rsm_id'],
      rsm: json['rsm'],
      nsm_id: json['nsm_id'],
      nsm: json['nsm'],
      sm_id: json['sm_id'],
      sm: json['sm'],
      dispatcher_id: json['dispatcher_id'],
      dispatcher: json['dispatcher'],
      designation: json['designation'],
      brand: json['brand'],
      images: json['images'],

    );
  }
  // factory LoginModels.fromMap(Map<dynamic, dynamic> map) {
  //   return LoginModels(
  //     user_id: map['user_id'] ?? '', // Ensure this matches the database column name
  //     password: map['password'] ?? '',
  //     city: map['city'] ?? '',
  //     user_name: map['user_name'] ?? '',
  //     designation: map['designation'] ?? '',
  //     brand: map['brand'] ?? '',
  //     images: map['images'] ?? '',
  //     rsm: map['rsm'] ?? '',
  //     rsm_id: map['rsm_id'] ?? '',
  //     sm: map['sm'] ?? '',
  //     SM_ID: map['SM_ID'] ?? '',
  //     nsm: map['nsm'] ?? '',
  //     nsm_id: map['nsm_id'] ?? '',
  //   );
  // }
  Map<String,dynamic>toMap(){
    return{
      'user_id':user_id,
      'password':password,
      'user_name':user_name,
      'city': city,
      'brand': brand,
      'designation': designation,
      'images': images,
      'nsm': nsm,
      'nsm_id': nsm_id,
      'rsm': rsm,
      'rsm_id': rsm_id,
      'sm': sm,
      'sm_id': sm_id,
      'dispatcher' : dispatcher,
      'dispatcher_id' : dispatcher_id,

    };

  }
}