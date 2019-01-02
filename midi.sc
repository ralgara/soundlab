(
var inPorts = 1;
var outPorts = 1;
MIDIClient.init(inPorts,outPorts);    // explicitly intialize the client
inPorts.do({ arg i;
	MIDIIn.connect(i, MIDIClient.sources.at(i));
});
s.boot;

// register functions:
~noteOff = { arg src, chan, num, vel; "noteOff".postln;   [chan,num,vel].postln; };
~noteOn = { arg src, chan, num, vel; "noteOn".postln;   [chan,num,vel].postln; };
~polytouch = { arg src, chan, num, vel; "polytouch".postln;   [chan,num,vel].postln; };
~control = { arg src, chan, num, val;  "control".postln;  [chan,num,val].postln; };
~program = { arg src, chan, prog;   "program".postln;     [chan,prog].postln; };
~touch = { arg src, chan, pressure;  "touch".postln;  [chan,pressure].postln; };
~bend = { arg src, chan, bend; "bend".postln;       [chan,bend - 8192].postln; };
~sysex = { arg src, sysex;  "sysex".postln;      sysex.postln; };
~sysrt = { arg src, chan, val;   "sysrt".postln;     [chan,val].postln; };
~smpte = { arg src, chan, val;   "smpte".postln;     [chan,val].postln; };
MIDIIn.addFuncTo(\noteOn, ~noteOn);
MIDIIn.addFuncTo(\noteOff, ~noteOff);
MIDIIn.addFuncTo(\polytouch, ~polytouch);
MIDIIn.addFuncTo(\control, ~control);
MIDIIn.addFuncTo(\program, ~program);
MIDIIn.addFuncTo(\touch, ~touch);
MIDIIn.addFuncTo(\bend, ~bend);
MIDIIn.addFuncTo(\sysex, ~sysex);
MIDIIn.addFuncTo(\sysrt, ~sysrt);
MIDIIn.addFuncTo(\smpte, ~smpte);


)

//cleanup
(
MIDIIn.removeFuncFrom(\noteOn, ~noteOn);
MIDIIn.removeFuncFrom(\noteOff, ~noteOff);
MIDIIn.removeFuncFrom(\polytouch, ~polytouch);
MIDIIn.removeFuncFrom(\control, ~control);
MIDIIn.removeFuncFrom(\program, ~program);
MIDIIn.removeFuncFrom(\touch, ~touch);
MIDIIn.removeFuncFrom(\bend, ~bend);
MIDIIn.removeFuncFrom(\sysex, ~sysex);
MIDIIn.removeFuncFrom(\sysrt, ~sysrt);
MIDIIn.removeFuncFrom(\smpte, ~smpte);
)