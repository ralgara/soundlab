import themidibus.*;
import javax.sound.midi.MidiMessage;
import java.util.Map;
import java.util.TreeMap;
import java.util.SortedMap;
import java.util.concurrent.ConcurrentSkipListMap;
import java.util.Iterator;
import java.util.Arrays;

final float WEST_SECTOR_CUT = 0.6;
final float NORTH_SECTOR_CUT = 0.3;

int WEST_SECTOR_WIDTH;
int EAST_SECTOR_WIDTH;
int NORTH_SECTOR_HEIGHT;
int SOUTH_SECTOR_HEIGHT;

PGraphics NWGraphics;
PGraphics NEGraphics;
PGraphics SWGraphics;
PGraphics SEGraphics;

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
final String RENDERER = P2D;
boolean update = false;

void setup() {
  size(800, 600, RENDERER);
  WEST_SECTOR_WIDTH = (int)(width * WEST_SECTOR_CUT);
  EAST_SECTOR_WIDTH = width - WEST_SECTOR_WIDTH;
  NORTH_SECTOR_HEIGHT = (int)(height * NORTH_SECTOR_CUT);
  SOUTH_SECTOR_HEIGHT = height - NORTH_SECTOR_HEIGHT;
  
  NWGraphics = createGraphics(WEST_SECTOR_WIDTH, NORTH_SECTOR_HEIGHT, RENDERER);
  NEGraphics = createGraphics(EAST_SECTOR_WIDTH, NORTH_SECTOR_HEIGHT, RENDERER);
  SWGraphics = createGraphics(WEST_SECTOR_WIDTH, SOUTH_SECTOR_HEIGHT, RENDERER);
  SEGraphics = createGraphics(EAST_SECTOR_WIDTH, SOUTH_SECTOR_HEIGHT, RENDERER);
  
  MidiBus.list();
  int inDevice  = 0;
  int outDevice = 1;
  myBus = new MidiBus(this, inDevice, outDevice);
  frameRate(10);

  colorMode(HSB, 127, 1, 127);
  noStroke();
  
  initData();
}

void initData() {
  for (int note = MIDI_NOTE_MIN; note <= MIDI_NOTE_MAX; note++) {
    eventMap.put(note, new ConcurrentSkipListMap());
  }
}

void grid() {
  stroke(#ffffff);
  fill(#000000);
  line(WEST_SECTOR_WIDTH, 0, WEST_SECTOR_WIDTH, height); // |
  line(0, NORTH_SECTOR_HEIGHT, width, NORTH_SECTOR_HEIGHT); // ---
}

void draw() {
  grid();
  render();
}

void render() {
  SWGraphics.beginDraw();
  SWGraphics.noStroke();
  // Hue: pressure (MIDI, 0:127), Saturation 0:1, Brightness 0:1
  SWGraphics.colorMode(HSB, 127, 1, 1);
  SWGraphics.background(0);
  long windowEndTs = getCurrentTimestamp();
  final float X_WIDTH_MSEC = 10000;
  float X_SCALE = (float) SWGraphics.width / X_WIDTH_MSEC;
  float barHeight = SWGraphics.height / (float)(MIDI_NOTE_MAX - MIDI_NOTE_MIN);
  for (int note = MIDI_NOTE_MIN; note <= MIDI_NOTE_MAX; note++) {
    ConcurrentSkipListMap noteMap = eventMap.get(note);
    long x0 = 0;
    long y0 = (int) (barHeight * (note - MIDI_NOTE_MIN) );
    
    // Iterate over events for a single note
    Iterator<Map.Entry<Long, Integer>> iterator = noteMap.entrySet().iterator();
    while (iterator.hasNext()) {
      long barWidth = 0;
      Map.Entry<Long, Integer> event = iterator.next();
      long ts = event.getKey();
      long pressure = event.getValue();
      if (pressure > 0) {
        x0 = ts;
        SWGraphics.fill(pressure, 1, 1);
      } else {
        barWidth = ts - x0;
        SWGraphics.pushMatrix();
        SWGraphics.scale(X_SCALE, 1);
        if (windowEndTs > X_WIDTH_MSEC) {
          float xlate = -(windowEndTs - X_WIDTH_MSEC);
          SWGraphics.translate(xlate, 0);
        }
        SWGraphics.rect(x0, y0, barWidth, barHeight);
        SWGraphics.popMatrix();
      }
    }
  }
  SWGraphics.endDraw();
  image(SWGraphics, 0, NORTH_SECTOR_HEIGHT);
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
  int note = (int)(message.getMessage()[1] & 0xFF);
  int vel = (int)(message.getMessage()[2] & 0xFF);
  long ts = getCurrentTimestamp();
  recordEvent(ts, note, vel);
  update = true;
}
