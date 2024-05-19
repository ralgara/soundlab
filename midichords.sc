(

// Find the MIDI device named "GarageBand Virtual In"
var midiOutDevice = MIDIClient.destinations.detect { |dest| dest.device == "GarageBand Virtual In" };
if (midiOutDevice.isNil) {
	"MIDI device 'GarageBand Virtual In' not found.".postln;
}

// Import the required libraries
MIDIClient.init;
MIDIIn.connectAll;

// Print out the names of all MIDI devices
"MIDI Sources:".postln;
MIDIClient.sources.do { |src| src.postln };

"MIDI Destinations:".postln;
MIDIClient.destinations.do { |dest| dest.postln };



// Define a function to create a MIDI chord
~makeChord = { |midiChannel, midiNote, velocity = 64, duration = 0.5|
	var chord = [midiNote, midiNote + 4, midiNote + 7]; // A simple major chord: root, major third, perfect fifth
	var midiOut = MIDIOut.new(midiChannel, midiOutDevice.uid);
	chord.do { |note|
		midiOut.noteOn(note, velocity);
		(duration).wait;
		midiOut.noteOff(note);
	};
};

// Example usage: play a C major chord on MIDI channel 1
~makeChord.value(1, 60);
)
