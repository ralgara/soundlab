#!/usr/bin/env python3

import mido
from mido import MidiFile, MidiTrack, Message

def create_midi_file(chord_progression, melody_notes, output_file):
    mid = MidiFile()
    chord_track = MidiTrack()
    melody_track = MidiTrack()
    mid.tracks.append(chord_track)
    mid.tracks.append(melody_track)

    # Set the tempo of the MIDI file (optional)
    bpm = 120
    chord_track.append(Message('set_tempo', tempo=mido.bpm2tempo(bpm)))
    melody_track.append(Message('set_tempo', tempo=mido.bpm2tempo(bpm)))

    # Set the time signature of the MIDI file (optional)
    numerator = 4
    denominator = 4
    clocks_per_click = 24
    notated_32nd_notes_per_beat = 8
    time_signature = (numerator, denominator, clocks_per_click, notated_32nd_notes_per_beat)
    chord_track.append(Message('time_signature', numerator=numerator, denominator=denominator,
                               clocks_per_click=clocks_per_click, notated_32nd_notes_per_beat=notated_32nd_notes_per_beat))
    melody_track.append(Message('time_signature', numerator=numerator, denominator=denominator,
                                clocks_per_click=clocks_per_click, notated_32nd_notes_per_beat=notated_32nd_notes_per_beat))

    # Convert each chord in the progression to MIDI notes and add them to the chord track
    for chord in chord_progression:
        for note in chord:
            chord_track.append(Message('note_on', note=note, velocity=64, time=0))
        for note in chord:
            chord_track.append(Message('note_off', note=note, velocity=64, time=480))  # Adjust the time value as needed

    # Add melody notes with syncopated rhythm to the melody track
    time = 0
    for note in melody_notes:
        melody_track.append(Message('note_on', note=note, velocity=80, time=time))
        melody_track.append(Message('note_off', note=note, velocity=80, time=240))  # Adjust the time value as needed
        time += 240  # Increase the time value to create syncopation

    # Save the MIDI file
    mid.save(output_file)

# Example usage
chord_progression = [['C4', 'E4', 'G4'], ['G4', 'B4', 'D5'], ['A4', 'C5', 'E5'], ['F4', 'A4', 'C5']]
melody_notes = ['C5', 'D5', 'E5', 'G5', 'E5', 'D5', 'C5']
output_file = 'output.mid'

create_midi_file(chord_progression, melody_notes, output_file)