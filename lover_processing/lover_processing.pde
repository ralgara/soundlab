import themidibus.*;
import javax.sound.midi.MidiMessage;
import java.util.TreeMap;
import java.util.Arrays;

MidiBus myBus; 
int currentColor = 0;
long genesis_tick = 0;
long genesis_ts = System.currentTimeMillis();
TreeMap timeMap = new TreeMap();
TreeMap velMap = new TreeMap();

void setup() {
  //size(480, 320);
  MidiBus.list();
  int inDevice  = 0;
  int outDevice = 1;
  myBus = new MidiBus(this, inDevice, outDevice); 
}

void draw() {
  //background(currentColor);
}

void midiMessage(MidiMessage message, long tick, String bus_name) { 
  int note = (int)(message.getMessage()[1] & 0xFF) ;
  int vel = (int)(message.getMessage()[2] & 0xFF);
  if (genesis_tick == 0) genesis_tick = tick;
  long delta_tick = tick - genesis_tick;
  long current_ts = System.currentTimeMillis();
  float delta_ts = (current_ts - genesis_ts) / 1000.0;
  //println(delta_tick + ":" + delta_ts + ":" + note + ":" + vel);
  if (vel == 0) {
    if (true) {
      velMap.put(note, 0);
      timeMap.put(note, 0);
    } else {
      velMap.remove(note);
      timeMap.remove(note);
    }
  } else {
    velMap.put(note, vel);
    timeMap.put(note, delta_ts);
  }
  println("vel: " + Arrays.toString(velMap.entrySet().toArray()));
  println("time: " + Arrays.toString(timeMap.entrySet().toArray()));
}
