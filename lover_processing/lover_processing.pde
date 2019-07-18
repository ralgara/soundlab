import themidibus.*;
import javax.sound.midi.MidiMessage;
import java.lang.Math;
import java.util.Map;
import java.util.Random;
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

final float X_WIDTH_MSEC = 10000;

PGraphics NWGraphics;
PGraphics NEGraphics;
PGraphics SWGraphics;
PGraphics SEGraphics;

MidiBus myBus; 
final long genesis_ts = System.currentTimeMillis();
final ConcurrentSkipListMap<
    Integer,  // note
    ConcurrentSkipListMap<
      Long,   // timestamp
      Integer // velocity
    >
  > eventMap = new ConcurrentSkipListMap();


final int MIDI_NOTE_MIN = 0;
final int MIDI_NOTE_MAX = 120;
final int TIME_WINDOW_SIZE = 10;
final String RENDERER = P2D;
final boolean MOCK_MIDI = true;
boolean update = false;

void setup() {
  size(800, 600, RENDERER);
  WEST_SECTOR_WIDTH = (int)(width * WEST_SECTOR_CUT);
  EAST_SECTOR_WIDTH = width - WEST_SECTOR_WIDTH;
  NORTH_SECTOR_HEIGHT = (int)(height * NORTH_SECTOR_CUT);
  SOUTH_SECTOR_HEIGHT = height - NORTH_SECTOR_HEIGHT;
  
  NWGraphics = createGraphics(WEST_SECTOR_WIDTH - 1, NORTH_SECTOR_HEIGHT - 1, RENDERER);
  NEGraphics = createGraphics(EAST_SECTOR_WIDTH - 1, NORTH_SECTOR_HEIGHT - 1, RENDERER);
  SWGraphics = createGraphics(WEST_SECTOR_WIDTH - 1, SOUTH_SECTOR_HEIGHT - 1, RENDERER);
  SEGraphics = createGraphics(EAST_SECTOR_WIDTH - 1, SOUTH_SECTOR_HEIGHT - 1, RENDERER);
  
  frameRate(10);
  noStroke();
  initData();
  
  if (MOCK_MIDI) {
    thread("mockMIDI");
  } else {
    MidiBus.list();
    int inDevice  = 0;
    int outDevice = 1;
    myBus = new MidiBus(this, inDevice, outDevice);
  }
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

int MIDI_VELOCITY_MAX = 127;
int scaleVelocity(int velocity) {
  return (int) Math.round(Math.sqrt(velocity * MIDI_VELOCITY_MAX));
}

float getAvgVelocity() {
  int acc = 0;
  int count = 0;
  long timeLowerBound = getCurrentTimestamp() - (int)X_WIDTH_MSEC;
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
  
void renderNorthWest() {
  float avgVelocity = getAvgVelocity();
  NWGraphics.beginDraw();
  NWGraphics.noStroke();
  NWGraphics.colorMode(RGB);
  NWGraphics.background(0);
  NWGraphics.textSize(30);
  NWGraphics.fill(#0080c0);
  NWGraphics.text(avgVelocity, 10, 35);
  NWGraphics.endDraw();
  image(NWGraphics, 0, 0);
}

void render() {
  renderNorthWest();
  SWGraphics.beginDraw();
  SWGraphics.noStroke();
  // Hue: velocity (MIDI, 0:127), Saturation 0:1, Brightness 0:1
  SWGraphics.colorMode(HSB, MIDI_VELOCITY_MAX, 1, 1);
  SWGraphics.background(0);
  long windowEndTs = getCurrentTimestamp();
  float X_SCALE = (float) SWGraphics.width / X_WIDTH_MSEC;
  float barHeight = SWGraphics.height / (float)(MIDI_NOTE_MAX - MIDI_NOTE_MIN);
  for (int note = MIDI_NOTE_MIN; note <= MIDI_NOTE_MAX; note++) {
    ConcurrentSkipListMap noteMap = eventMap.get(note);
    long x0 = 0;
    long y0 = SWGraphics.height - 
      (int)(barHeight * (note - MIDI_NOTE_MIN));
    
    // Iterate over events for a single note
    Iterator<Map.Entry<Long, Integer>> iterator = noteMap.entrySet().iterator();
    while (iterator.hasNext()) {
      long barWidth = 0;
      Map.Entry<Long, Integer> event = iterator.next();
      long ts = event.getKey();
      int velocity = event.getValue();
      if (velocity > 0) {
        x0 = ts;
        int scaledVelocity = scaleVelocity(velocity);
        SWGraphics.fill(scaledVelocity, 1, 1);
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
  println(ts + " " + note + " " + vel);
  ConcurrentSkipListMap noteMap = eventMap.get(note);
  noteMap.put(ts, vel);
  Stats.recordVelocity(ts, vel);
}

long getCurrentTimestamp() {
  return System.currentTimeMillis() - genesis_ts;
}

static class Stats {
  static long eventCount = 0;
  static long velocitySum = 0;
  static long durationSum = 0;
  static final short IDX_COUNT = 0;
  static final short IDX_VELOCITY = 1;
  static final short IDX_DURARTION = 2;
  
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
    println(timestamp + ":" + (velocitySum/eventCount));
    statsMap.put(timestamp, statsEntry);
  }
}

// Bounded brownian generator
class Generator {
  int min, max;
  int value;
  Random random = new Random();
  
  Generator(int min, int max) {
    this.min = min;
    this.max = max;
  }
  
  int getNextValue() {
    int RANGE = 10;
    int sign = random.nextFloat() > 0.5 ? 1 : -1;
    int skip = random.nextInt(RANGE) * sign;
    int nextValue = value + skip;
    if (nextValue > this.max || nextValue < this.min) {
      nextValue = value - skip;
    }
    value = nextValue;
    return value;
  }
}

void mockMIDI() {
  Generator noteGenerator = new Generator(20,100);
  Generator velocityGenerator = new Generator(10,127);
  for (int i=0; i<60; i++) {
    int note = noteGenerator.getNextValue();
    int velocity = velocityGenerator.getNextValue();
    recordEvent(getCurrentTimestamp(), note, velocity);
    delay(300);
    recordEvent(getCurrentTimestamp(), note, 0);
    update = true;
    

  }
}

void midiMessage(MidiMessage message, long tick, String bus_name) { 
  int note = (int)(message.getMessage()[1] & 0xFF);
  int vel = (int)(message.getMessage()[2] & 0xFF);
  long ts = getCurrentTimestamp();
  recordEvent(ts, note, vel);
  update = true;
}
