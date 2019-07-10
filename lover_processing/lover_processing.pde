import themidibus.*;
import javax.sound.midi.MidiMessage;
import java.util.TreeMap;
import java.util.Arrays;

MidiBus myBus; 
long genesis_tick = 0;
long genesis_ts = System.currentTimeMillis();
TreeMap<Integer, Float> timeMap = new TreeMap();
TreeMap<Integer, Integer> velMap = new TreeMap();
final int MIDI_NOTE_MIN = 21;
final int MIDI_NOTE_MAX = 108;
final int BAR_HEIGHT = 2;
boolean update = false;

void setup() {
  MidiBus.list();
  int inDevice  = 0;
  int outDevice = 1;
  myBus = new MidiBus(this, inDevice, outDevice);
  println("Frame rate: " + frameRate);

  size(480, 320);
  fill(#800000);
  noStroke();
}

void draw() {
  if (update) {
    background(#000000);
    render();
    update = false;
  }
}

void render() {
  for (
    int midiNote = MIDI_NOTE_MIN; 
    midiNote < MIDI_NOTE_MAX; 
    midiNote++
  ) {
    int x0 = 0;
    int barWidth = velMap.containsKey(midiNote) ? velMap.get(midiNote) : 0;
    int y0 = midiNote * BAR_HEIGHT;
    int barHeight = BAR_HEIGHT;
    if (barWidth > 0) {
      println(String.format("x0:%d, y0:%d, w:%d, h:%d", x0, y0, barWidth, barHeight));
      rect(x0, y0, barWidth, barHeight);
    }
  }
}

void midiMessage(MidiMessage message, long tick, String bus_name) { 
  int note = (int)(message.getMessage()[1] & 0xFF) ;
  int vel = (int)(message.getMessage()[2] & 0xFF);
  if (genesis_tick == 0) genesis_tick = tick;
  long delta_tick = tick - genesis_tick;
  long current_ts = System.currentTimeMillis();
  float delta_ts = (current_ts - genesis_ts) / 1000.0;
  if (vel == 0) {
    velMap.put(note, 0);
    timeMap.put(note, 0f);
  } else {
    velMap.put(note, vel);
    timeMap.put(note, delta_ts);
  }
  //println("vel: " + Arrays.toString(velMap.entrySet().toArray()));
  //println("time: " + Arrays.toString(timeMap.entrySet().toArray()));
  update = true;
}
