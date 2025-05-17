class KhachHang {
  int idKh;
  String tenKh;
  String sdt;
  int idPhong;
  String tenPhong;
  String ngayDen;
  int tinhTrang;
  String tenCoSo;
  int idCoSo;
  KhachHang({
    required this.idKh,
    required this.tenKh,
    required this.sdt,
    required this.idPhong,
    required this.tenPhong,
    required this.ngayDen,
    required this.tinhTrang,
    required this.tenCoSo,
    required this.idCoSo,
  });

  factory KhachHang.fromJson(Map<String, dynamic> json) {
    return KhachHang(
      idKh: json['idKh'],
      tenKh: json['tenKh'],
      sdt: json['sdt'],
      idPhong: json['idPhong'],
      tenPhong: json['tenPhong'],
      ngayDen: json['ngayDen'],
      tinhTrang: json['tinhtrang'],
      tenCoSo: json['tenCoSo'],
      idCoSo: json['idCoSo'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'idKh': idKh,
      'tenKh': tenKh,
      'sdt': sdt,
      'idPhong': idPhong,
      'tenPhong': tenPhong,
      'ngayDen': ngayDen,
      'tinhtrang': tinhTrang,
      'tenCoSo': tenCoSo,
    };
  }
}
