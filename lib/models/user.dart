class User {
  final String id;
  final String email;
  final String token;
  String name;
  String address;
  String phone;
  String sector;
  String adminOrUser;
  List<String> rights;
  String imageUrl;

  User({
    this.name,
    this.address,
    this.phone,
    this.sector,
    this.adminOrUser,
    this.rights,
    this.imageUrl,
    this.id,
    this.email,
    this.token,
  });
}
