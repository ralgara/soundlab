#!/usr/bin/env python3

import mido

required_version = "1.2.9"
installed_version = mido.__version__

if required_version != installed_version:
    print(f"Error: Required version of mido is {required_version}, but installed version is {installed_version}.")
    print("Please install the correct version before running this code.")
    exit()

# Continue with the rest of the code

# Define the chord progression and melody notes
chord_progression = [['C4', 'E4', 'G4'], ['G4', 'B4', 'D5'], ['A4', 'C5', 'E5'], ['F4', 'A4', 'C5']]
melody_notes = ['C5', 'D5', 'E5', 'G5', 'E5', 'D5', 'C5']

# Set the time signature and tempo
time_signature = 4  # 4/4 time signature
tempo = 120  # Beats per minute

# Create a note name to note number lookup dictionary
note_lookup = {
    'C': 60, 'C#': 61, 'Db': 61, 'D': 62, 'D#': 63, 'Eb': 63, 'E': 64, 'F': 65, 'F#': 66, 'Gb': 66,
    'G': 67, 'G#': 68, 'Ab': 68, 'A': 69, 'A#': 70, 'Bb': 70, 'B': 71
}

# Create a new MIDI file
midi = mido.MidiFile()

# Create a track for the chord progression
chord_track = mido.MidiTrack()
midi.tracks.append(chord_track)

# Add the chord progression to the track
ticks_per_beat = midi.ticks_per_beat
quarter_note_duration = ticks_per_beat * 60 / tempo
for i, chord in enumerate(chord_progression):
    for note in chord:
        note_name, octave = note[:-1], int(note[-1])
        note_number = note_lookup[note_name] + (octave + 1) * 12
        chord_track.append(mido.Message('note_on', note=note_number, velocity=64, time=int(i * quarter_note_duration)))
    for note in chord:
        note_name, octave = note[:-1], int(note[-1])
        note_number = note_lookup[note_name] + (octave + 1) * 12
        chord_track.append(mido.Message('note_off', note=note_number, velocity=64, time=int(quarter_note_duration)))

# Create a track for the melody notes
melody_track = mido.MidiTrack()
midi.tracks.append(melody_track)

# Add the melody notes to the track
for i, note in enumerate(melody_notes):
    note_name, octave = note[:-1], int(note[-1])
    note_number = note_lookup[note_name] + (octave + 1) * 12
    melody_track.append(mido.Message('note_on', note=note_number, velocity=64, time=int(i * quarter_note_duration)))
    melody_track.append(mido.Message('note_off', note=note_number, velocity=64, time=int(quarter_note_duration)))

# Write the MIDI file to disk
output_file = 'output.mid'
midi.save(output_file)

print(f"MIDI file '{output_file}' created successfully!")