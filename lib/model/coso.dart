import 'phong.dart';

class CoSo {
  final int idCoSo;
  final String tenCoSo;
  final String diaChi;
  final int idChu;
  final int trangThai;
  final int soLuong;
  CoSo({
    required this.idCoSo,
    required this.tenCoSo,
    required this.diaChi,
    required this.idChu,
    required this.trangThai,
    required this.soLuong,
  });

  // Phương thức chuyển đổi từ JSON
  factory CoSo.fromJson(Map<String, dynamic> json) {
    return CoSo(
      idCoSo: json['idCoSo'],
      tenCoSo: json['tenCoSo'],
      soLuong: json['soLuong'],
      diaChi: json['diaChi'],
      idChu: json['idChu'],
      trangThai: json['trangThai'],
    );
  }

  // Phương thức chuyển đổi sang JSON
  Map<String, dynamic> toJson() {
    return {
      'idCoSo': idCoSo,
      'tenCoSo': tenCoSo,
      'diaChi': diaChi,
      'idChu': idChu,
      'trangThai': trangThai,
      'soLuong': soLuong,
    };
  }
}
