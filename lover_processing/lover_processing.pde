import themidibus.*;
import javax.sound.midi.MidiMessage;
import java.util.Map;
import java.util.TreeMap;
import java.util.SortedMap;
import java.util.concurrent.ConcurrentSkipListMap;
import java.util.Iterator;
import java.util.Arrays;

MidiBus myBus; 
final long genesis_ts = System.currentTimeMillis();
// {note: {t: p}}
final ConcurrentSkipListMap<
    Integer, 
    ConcurrentSkipListMap<Long, Integer>
  > eventMap = new ConcurrentSkipListMap();
// {note: {t: {p, d} } }

final int MIDI_NOTE_MIN = 0;
final int MIDI_NOTE_MAX = 120;
final int TIME_WINDOW_SIZE = 10;
boolean update = false;

void setup() {
  MidiBus.list();
  int inDevice  = 0;
  int outDevice = 1;
  myBus = new MidiBus(this, inDevice, outDevice);
  frameRate(10);

  size(800, 500);
  colorMode(HSB, 127, 1, 127);
  noStroke();
  
  initData();
}

void initData() {
  for (int note = MIDI_NOTE_MIN; note <= MIDI_NOTE_MAX; note++) {
    eventMap.put(note, new ConcurrentSkipListMap());
  }
}

void draw() {
  background(#000000);
  render();
}

void render() {
  background(#000000);
  long windowEndTs = getCurrentTimestamp();
  final float X_WIDTH_MSEC = 10000;
  float X_SCALE = (float) width / X_WIDTH_MSEC;
  for (int note = MIDI_NOTE_MIN; note <= MIDI_NOTE_MAX; note++) {
    ConcurrentSkipListMap noteMap = eventMap.get(note);
    long x0 = 0;
    long y0 = (int) (
      height *
      (float)(note - MIDI_NOTE_MIN) / (MIDI_NOTE_MAX - MIDI_NOTE_MIN)
    );
    
    // Iterate over events for a single note
    Iterator<Map.Entry<Long, Integer>> iterator = noteMap.entrySet().iterator();
    while (iterator.hasNext()) {
      long barWidth = 0;
      Map.Entry<Long, Integer> event = iterator.next();
      long ts = event.getKey();
      long pressure = event.getValue();
      if (pressure > 0) {
        x0 = ts;
        fill(pressure, 1, 127);
      } else {
        barWidth = ts - x0;
        pushMatrix();
        scale(X_SCALE, 1);
        if (windowEndTs > X_WIDTH_MSEC) {
          float xlate = -(windowEndTs - X_WIDTH_MSEC);
          translate(xlate, 0);
        }
        
        rect(x0, y0, barWidth, 10);
        popMatrix();
      }
    }
  }
  update = false;
}

void recordEvent(long ts, int note, int vel) {
  ConcurrentSkipListMap noteMap = eventMap.get(note);
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
