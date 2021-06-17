

class Discussion {


  List message;
  String messageId;

  Discussion({
    this.message,
    this.messageId,


});

  factory Discussion.fromJson(Map<String, dynamic> json){
    return Discussion(
      messageId: json['messageId'],
      message: json['message'],
    );
  }
  Map<String, dynamic> toMap() {
    return {
      'messageId': messageId,
      'message': message,
    };
  }
}