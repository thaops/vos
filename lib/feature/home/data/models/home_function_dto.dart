import 'package:vos_flutter/feature/home/domain/models/home_function.dart';

class HomeFunctionItemDto {
  final String id;
  final String type;
  final String title;
  final String color;
  final String imageUrl;
  final String action;
  final String actionUrl;
  final String status;
  final String updatedDate;

  HomeFunctionItemDto({
    required this.id,
    required this.type,
    required this.title,
    required this.color,
    required this.imageUrl,
    required this.action,
    required this.actionUrl,
    required this.status,
    required this.updatedDate,
  });

  factory HomeFunctionItemDto.fromJson(Map<String, dynamic> json) {
    return HomeFunctionItemDto(
      id: json['ID'] as String? ?? '',
      type: json['Type'] as String? ?? '',
      title: json['Title'] as String? ?? '',
      color: json['Color'] as String? ?? '#000000',
      imageUrl: json['ImageUrl'] as String? ?? '',
      action: json['Action'] as String? ?? '',
      actionUrl: json['ActionUrl'] as String? ?? '',
      status: json['Status'] as String? ?? '',
      updatedDate: json['UpdatedDate'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ID': id,
      'Type': type,
      'Title': title,
      'Color': color,
      'ImageUrl': imageUrl,
      'Action': action,
      'ActionUrl': actionUrl,
      'Status': status,
      'UpdatedDate': updatedDate,
    };
  }

  HomeFunctionItem toDomain() {
    return HomeFunctionItem(
      id: id,
      type: type,
      title: title,
      color: color,
      imageUrl: imageUrl,
      action: action,
      actionUrl: actionUrl,
      status: status,
      updatedDate: updatedDate,
    );
  }
}

class HomeFunctionSessionDto {
  final String sessionID;
  final String sessionName;
  final List<HomeFunctionItemDto> listItems;

  HomeFunctionSessionDto({
    required this.sessionID,
    required this.sessionName,
    required this.listItems,
  });

  factory HomeFunctionSessionDto.fromJson(Map<String, dynamic> json) {
    final items = json['ListItems'] as List<dynamic>? ?? [];
    return HomeFunctionSessionDto(
      sessionID: json['SessionID'] as String? ?? '',
      sessionName: json['SessionName'] as String? ?? '',
      listItems: items
          .map((item) => HomeFunctionItemDto.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'SessionID': sessionID,
      'SessionName': sessionName,
      'ListItems': listItems.map((item) => item.toJson()).toList(),
    };
  }

  HomeFunctionSession toDomain() {
    return HomeFunctionSession(
      sessionID: sessionID,
      sessionName: sessionName,
      listItems: listItems.map((item) => item.toDomain()).toList(),
    );
  }
}

