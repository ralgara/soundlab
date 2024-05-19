(
// Define a function to create a wind chime SynthDef
~createWindChime = { |id, freqs, amps, decays|
    SynthDef("windchime" ++ id, {
        var env, exciter, chime;

        // Create an envelope to control the excitation of the chimes
        env = Env.perc(0.01, 1, 0.1, -4).kr(2);

        // Generate random impulses as the exciter for the chimes
        exciter = Dust.ar(4) * env;

        // Create the Klank resonator
        chime = Klank.ar(`[freqs, decays, amps], exciter);

        // Output the sound
        Out.ar(0, chime ! 2); // Stereo output
    }).add;
};

// Frequencies for A minor pentatonic scale: A, C, D, E, G
~pentatonicFrequencies = [220, 261.63, 293.66, 329.63, 392.00] * 4; // A3, C4, D4, E4, G4

// Amplitudes and decays for each wind chime
~amps = [0.5, 0.4, 0.3, 0.2, 0.1];
~decays = [1, 0.8, 0.6, 0.4, 0.2] * 4;

// Create a SynthDef for each wind chime tuned to the A minor pentatonic scale
5.do { |i|
    ~createWindChime.value(i.asString, ~pentatonicFrequencies, ~amps, ~decays);
};

// Function to randomly trigger wind chimes
~triggerChimes = Routine({
    inf.do {
        Synth("windchime" ++ (0..4).choose.asString);
        (1.rand + 0.5).wait; // Wait for a random time between 0.5 and 1.5 seconds
    }
});

// Start the random triggering of wind chimes
~triggerChimes.play;
)
