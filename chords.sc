(
var chordProgression = [
    [60, 64, 67],  // C Major: C4, E4, G4
    [57, 60, 64],  // A minor: A3, C4, E4
    [52, 56, 59],  // E minor: E3, G3, B3
    [55, 59, 62]   // G Major: G3, B3, D4
];

// Function to play a chord
var playChord = { |chord, dur = 1|
    chord.do { |note|
        Synth(\default, [\freq, note.midicps, \sustain, dur]);
    };
};

Server.default.options.device_(1);
/*ServerOptions.outDevices;
s.options.sampleRate = 48000;*/
Server.default.reboot;

Task({
    chordProgression.do { |chord|
        playChord.value(chord);
        1.wait;
    };
}).start;
)








