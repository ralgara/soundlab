import themidibus.*;
import javax.sound.midi.MidiMessage;
import java.util.Map;
import java.util.TreeMap;
import java.util.SortedMap;
import java.util.Iterator;
import java.util.Arrays;

MidiBus myBus; 
final long genesis_ts = System.currentTimeMillis();
// {note: {t: p}}
final TreeMap<Integer, TreeMap<Long, Integer>> eventMap = new TreeMap();

final int MIDI_NOTE_MIN = 60; //21;
final int MIDI_NOTE_MAX = 60; //108;
final int TIME_WINDOW_SIZE = 10;
final int BAR_HEIGHT = 2;
boolean update = false;

void setup() {
  MidiBus.list();
  int inDevice  = 0;
  int outDevice = 1;
  myBus = new MidiBus(this, inDevice, outDevice);
  println("Frame rate: " + frameRate);

  size(480, 320);
  noStroke();
  
  initData();
}

void initData() {
  for (int note = MIDI_NOTE_MIN; note <= MIDI_NOTE_MAX; note++) {
    eventMap.put(note, new TreeMap());
  }
}

void draw() {
  if (update) {
    background(#000000);
    render();
    update = false;
  }
}

void render() {
  long windowEndTs = getCurrentTimestamp();
  long windowStartTs = windowEndTs - (TIME_WINDOW_SIZE * 1000);
  for (int note = MIDI_NOTE_MIN; note <= MIDI_NOTE_MAX; note++) {
    TreeMap noteMap = eventMap.get(note);
    SortedMap<Long, Integer> pressMap = noteMap.subMap(windowStartTs, windowEndTs);
    println(note, windowStartTs, windowEndTs, "noteMap: " + noteMap, "pressMap: " + pressMap);
    //if (noteMap.size() > 0) println(note, noteMap);
    boolean ready = false;
    long x0 = 0;
    int y0 = note * BAR_HEIGHT;
    int x1 = 0;
    int currentFill = 0;
    // Iterate over events for a single note
    Iterator<Map.Entry<Long, Integer>> iterator = pressMap.entrySet().iterator();
    while (iterator.hasNext()) {
      Map.Entry<Long, Integer> event = iterator.next();
      long ts = event.getKey();
      long pressure = event.getValue();
      if (pressure > 0) {
        x0 = ts - windowStartTs;
        currentFill = (int) pressure;
      } else {
        long barWidth = ts - x0;
        fill(pressure, 0, 0);
        rect(x0, y0, barWidth, BAR_HEIGHT);
        println(String.format("x0:%d, y0:%d, w:%d, c:%d", x0, y0, barWidth, currentFill));
      }
        
    }
  }
}

void recordEvent(long ts, int note, int vel) {
  TreeMap noteMap = eventMap.get(note);
  noteMap.put(ts, vel);
}

long getCurrentTimestamp() {
  return System.currentTimeMillis() - genesis_ts;
}

void midiMessage(MidiMessage message, long tick, String bus_name) { 
  int note = (int)(message.getMessage()[1] & 0xFF) ;
  int vel = (int)(message.getMessage()[2] & 0xFF);
  long ts = getCurrentTimestamp();
  recordEvent(ts, note, vel);
  update = true;
}
