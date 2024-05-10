class FrRequest {
  String id;
  String date;
  String senderName;
  String senderID;

  // Constructor for initializing a Request object
  FrRequest({
    this.id = '',
    this.date = '',
    this.senderName = '',
    this.senderID = '',
  });

  // Convert Request object to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date,
      'senderName': senderName,
      'senderID': senderID,
    };
  }

  // Create Request object from JSON
  factory FrRequest.fromJson(Map<String, dynamic> json) {
    return FrRequest(
      id: json['id'] ?? '',
      date: json['date'] ?? '',
      senderName: json['senderName'] ?? '',
      senderID: json['senderID'] ?? '',
    );
  }
}
