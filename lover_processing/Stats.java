
import java.util.Map;
import java.util.concurrent.ConcurrentSkipListMap;

public class Stats {
  static long eventCount = 0;
  static long velocitySum = 0;
  static long durationSum = 0;
  static final short IDX_COUNT = 0;
  static final short IDX_VELOCITY = 1;
  static final short IDX_DURARTION = 2;
  static final long genesis_ts = System.currentTimeMillis();
  
  public static long getCurrentTimestamp() {
    return System.currentTimeMillis() - genesis_ts;
  }
  
  static ConcurrentSkipListMap<
    Integer,  // note
    ConcurrentSkipListMap<
      Long,   // timestamp
      Integer // velocity
    >
  > eventMap = new ConcurrentSkipListMap();
  
  public Stats() {
  }
  
  public static void recordEvent(Event event) {
    System.out.println(event.timestamp + " " + event.note + " " + event.timestamp);
    ConcurrentSkipListMap noteMap = eventMap.get(event.note);
    noteMap.put(event.timestamp, event.timestamp);
    Stats.recordVelocity(event.timestamp, event.timestamp);
  }
  
  static float getAvgVelocity() {
  int acc = 0;
  int count = 0;
  long timeLowerBound = getCurrentTimestamp() - (int)Config.X_WIDTH_MSEC;
  for (Map.Entry<Integer, ConcurrentSkipListMap<Long, Integer>> noteMapEntry : eventMap.entrySet()) {
    Map<Long, Integer> eventSubmap = noteMapEntry.getValue().tailMap(timeLowerBound);
    for (Map.Entry<Long, Integer> eventEntry : eventSubmap.entrySet()) {
      int velocity = eventEntry.getValue();
      if (velocity > 0) {
        count++;
        acc += velocity;
      }
    }
  }
  return ((float) acc)/count;
}

  
  /*
  (time) -> [count, sum(velocity), sum(duration)] 
  */
  static final ConcurrentSkipListMap<
    Long,   // timestamp
    long[] // count, velocity, duration
  > statsMap = new ConcurrentSkipListMap();
  
  static void recordVelocity(long timestamp, int velocity) {
    if (velocity == 0) 
      return;
    long[] statsEntry;
    if (statsMap.containsKey(timestamp)) {
      statsEntry = statsMap.get(timestamp);
    } else {
      statsEntry = new long[3];
    }
    eventCount++;
    velocitySum += velocity;
    statsEntry[IDX_COUNT] = eventCount;
    statsEntry[IDX_VELOCITY] = velocitySum;
    statsMap.put(timestamp, statsEntry);
  }
}
