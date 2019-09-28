class Time {
  final static long genesis_ts = getCurrentTimestamp();
  
  static long getCurrentTimestamp() {
    return System.currentTimeMillis() - genesis_ts;
  }
}
