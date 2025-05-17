class Phong {
  final int idPhong;
  final String? tenPhong;
  final int soLuong;
  final int? trangThai;
  final int? idCoSo;
  Phong({
    required this.idPhong,
    this.tenPhong,
    required this.soLuong,
    this.trangThai,
    this.idCoSo,
  });

  // Phương thức chuyển đổi từ JSON
  factory Phong.fromJson(Map<String, dynamic> json) {
    return Phong(
      idPhong: json['idPhong'],
      tenPhong: json['tenPhong'],
      soLuong: json['soLuong'],
      trangThai: json['trangThai'],
      idCoSo: json['idCoSo'],
    );
  }

  // Phương thức chuyển đổi sang JSON
  Map<String, dynamic> toJson() {
    return {
      'idPhong': idPhong,
      'tenPhong': tenPhong,
      'soLuong': soLuong,
      'trangThai': trangThai,
      'idCoSo': idCoSo,
    };
  }
}
