(
var inPorts = 1;
var outPorts = 1;
MIDIClient.init();
MIDIClient.list.postln;
("clientID: " + MIDIClient.getClientID).postln;
("myinports: " + MIDIClient.myinports).postln;
("myoutports: " + MIDIClient.myoutports).postln;
("initialized: " + MIDIClient.initialized).postln;
("sources: " + MIDIClient.sources).postln;
("destinations: " + MIDIClient.destinations).postln;
"end".postln;
nil;
inPorts.do({ arg i;
	MIDIIn.connect(i, MIDIClient.sources.at(i));
});
var velocity = 20;
var channel = 2;
var note = 33;
m = MIDIOut(channel);
m.noteOn(channel, note, velocity);
m.allNotesOff(16);
m.allNotesOff(channel);

m.noteOn(16, 60, velocity);
m.noteOn(16, 61, velocity);
m.noteOff(16, 61, velocity);
m.allNotesOff(16);
)