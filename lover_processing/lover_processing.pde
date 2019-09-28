import themidibus.*;
import javax.sound.midi.MidiMessage;
import java.lang.Math;
import java.util.TreeMap;
import java.util.SortedMap;
import java.util.Iterator;
import java.util.Arrays;
import java.sql.Connection;  
import java.sql.DriverManager;  
import java.sql.SQLException;

int WEST_SECTOR_WIDTH;
int EAST_SECTOR_WIDTH;
int NORTH_SECTOR_HEIGHT;
int SOUTH_SECTOR_HEIGHT;

final String RENDERER = P2D;

PGraphics NWGraphics;
PGraphics NEGraphics;
PGraphics SWGraphics;
PGraphics SEGraphics;

MidiBus myBus; 

final boolean MOCK_MIDI = true;
boolean update = false;

void setup() {
  size(800, 600, RENDERER);
  WEST_SECTOR_WIDTH = (int)(width * Config.WEST_SECTOR_CUT);
  EAST_SECTOR_WIDTH = width - WEST_SECTOR_WIDTH;
  NORTH_SECTOR_HEIGHT = (int)(height * Config.NORTH_SECTOR_CUT);
  SOUTH_SECTOR_HEIGHT = height - NORTH_SECTOR_HEIGHT;
  
  NWGraphics = createGraphics(
    WEST_SECTOR_WIDTH - 1, 
    NORTH_SECTOR_HEIGHT - 1, 
    RENDERER);
  NEGraphics = createGraphics(
    EAST_SECTOR_WIDTH - 1, 
    NORTH_SECTOR_HEIGHT - 1, 
    RENDERER);
  SWGraphics = createGraphics(
    WEST_SECTOR_WIDTH - 1,
    SOUTH_SECTOR_HEIGHT - 1,
    RENDERER);
  SEGraphics = createGraphics(
    EAST_SECTOR_WIDTH - 1,
    SOUTH_SECTOR_HEIGHT - 1, 
    RENDERER);
  
  frameRate(10);
  noStroke();
  
  if (MOCK_MIDI) {
    thread("mockMIDI");
  } else {
    MidiBus.list();
    int inDevice  = 0;
    int outDevice = 1;
    myBus = new MidiBus(this, inDevice, outDevice);
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
  //render();
}

int MIDI_VELOCITY_MAX = 127;
int scaleVelocity(int velocity) {
  return (int) Math.round(Math.sqrt(velocity * MIDI_VELOCITY_MAX));
}

void renderNorthWest() {
  float avgVelocity = Stats.getAvgVelocity();
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

//void render() {
//  renderNorthWest();
//  SWGraphics.beginDraw();
//  SWGraphics.noStroke();
//  // Hue: velocity (MIDI, 0:127), Saturation 0:1, Brightness 0:1
//  SWGraphics.colorMode(HSB, MIDI_VELOCITY_MAX, 1, 1);
//  SWGraphics.background(0);
//  long windowEndTs = Stats.getCurrentTimestamp();
//  float X_SCALE = (float) SWGraphics.width / Config.X_WIDTH_MSEC;
//  float barHeight = SWGraphics.height / (float)(Config.MIDI_NOTE_MAX - Config.MIDI_NOTE_MIN);
//  for (int note = Config.MIDI_NOTE_MIN; note <= Config.MIDI_NOTE_MAX; note++) {
//    long x0 = 0;
//    long y0 = SWGraphics.height - 
//      (int)(barHeight * (note - Config.MIDI_NOTE_MIN));
    
//    ConcurrentSkipListMap noteMap = eventMap.get(note);
//    // Iterate over events for a single note
//    Iterator<Map.Entry<Long, Integer>> iterator = noteMap.entrySet().iterator();
//    while (iterator.hasNext()) {
//      long barWidth = 0;
//      Map.Entry<Long, Integer> event = iterator.next();
//      long ts = event.getKey();
//      int velocity = event.getValue();
//      if (velocity > 0) {
//        x0 = ts;
//        int scaledVelocity = scaleVelocity(velocity);
//        SWGraphics.fill(scaledVelocity, 1, 1);
//      } else {
//        barWidth = ts - x0;
//        SWGraphics.pushMatrix();
//        SWGraphics.scale(X_SCALE, 1);
//        if (windowEndTs > X_WIDTH_MSEC) {
//          float xlate = -(windowEndTs - X_WIDTH_MSEC);
//          SWGraphics.translate(xlate, 0);
//        }
//        SWGraphics.rect(x0, y0, barWidth, barHeight);
//        SWGraphics.popMatrix();
//      }
//    }
//  }
//  SWGraphics.endDraw();
//  image(SWGraphics, 0, NORTH_SECTOR_HEIGHT);
//  update = false;
//}

void mockMIDI() {
  EventGenerator.getEventStream()
    .limit(10)
    .forEach((event) -> {
        Stats.recordEvent(event);
        delay(300);
        return event;
    }).flatMap((event) -> {
      Event up = new Event(event);
      up.velocity = 0;
      return Stream.concat(
        Stream.of(event),
        Stream.of(up)
      );
    }
    
    update = true;
  }
}

void midiMessage(MidiMessage message, long tick, String bus_name) { 
  int note = (int)(message.getMessage()[1] & 0xFF);
  int vel = (int)(message.getMessage()[2] & 0xFF);
  long ts = Stats.getCurrentTimestamp();
  Stats.recordEvent(ts, note, vel);
  update = true;
}
