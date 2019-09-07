class User {
  final String id;
  final String email;
  final String token;
  final String name;
  final String address;
  final String phone;
  final String sector;
  final String adminOrUser;
  final List<String> rights;
  final String imageUrl;

  User({this.name, this.address, this.phone, this.sector, this.adminOrUser, this.rights, this.imageUrl, this.id, this.email, this.token, });
}