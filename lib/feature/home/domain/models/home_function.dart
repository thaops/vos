class HomeFunctionItem {
  final String id;
  final String type;
  final String title;
  final String color;
  final String imageUrl;
  final String action;
  final String actionUrl;
  final String status;
  final String updatedDate;

  HomeFunctionItem({
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
}

class HomeFunctionSession {
  final String sessionID;
  final String sessionName;
  final List<HomeFunctionItem> listItems;

  HomeFunctionSession({
    required this.sessionID,
    required this.sessionName,
    required this.listItems,
  });
}

