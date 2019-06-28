import themidibus.*;
import javax.sound.midi.MidiMessage; 

MidiBus myBus; 

int currentColor = 0;
long genesis_tick = 0;
long genesis_ts = System.currentTimeMillis();

void setup() {
  size(480, 320);
  MidiBus.list();
  int inDevice  = 0;
  int outDevice = 1;
  myBus = new MidiBus(this, inDevice, outDevice); 
}

void draw() {
  background(currentColor);
}

void midiMessage(MidiMessage message, long tick, String bus_name) { 
  int note = (int)(message.getMessage()[1] & 0xFF) ;
  int vel = (int)(message.getMessage()[2] & 0xFF);
  if (genesis_tick == 0) genesis_tick = tick;
  float delta_tick = (tick - genesis_tick) / 1000.0;
  long current_ts = System.currentTimeMillis();
  float delta_ts = (current_ts - genesis_ts) / 1000.0;
  println(bus_name + ":" + delta_tick + ":" + delta_ts + ":" + note + ":" + vel);
  if (vel > 0 ) {
   currentColor = vel*2;
  }
}
