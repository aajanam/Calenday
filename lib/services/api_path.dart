class APIPath {
  static String event(String eventId) => '/events/$eventId';
  static String events() => '/events';
  static String users() => '/users';
  static String user(String uid) => '/users/$uid';
  static String colleagues(String uid) => '/user/$uid/colleagues';
  static String messages() => '/messages';
}