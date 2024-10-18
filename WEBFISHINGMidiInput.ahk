#Requires AutoHotkey v2.0
#include "Midi2.ahk"

midi := AHKMidi()
midi.midiEventPassThrough := True
midi.delegate := MidiDelegate()
;midi.specificProcessCallback := True

; open midi device manually
; midi.OpenMidiInByName("name")
; midi.OpenMidiOutByName("name")
;
; or save and load devices setting with ini file
; auto save selection from task tray menu
midi.settingFilePath := A_ScriptDir . "\setting.ini"

maxFrets := 15

; Define the base note for each string in terms of MIDI note numbers and corresponding string number
strings := Map("E2", {baseNote: 40, stringNum: "q"},  ; Low E (6th string)
               "A2", {baseNote: 45, stringNum: "w"},  ; A (5th string)
               "D3", {baseNote: 50, stringNum: "e"},  ; D (4th string)
               "G3", {baseNote: 55, stringNum: "r"},  ; G (3rd string)
               "B3", {baseNote: 59, stringNum: "t"},  ; B (2nd string)
               "E4", {baseNote: 64, stringNum: "y"})  ; High E (1st string)

; Mapping of piano notes to their MIDI numbers, including octaves
notes := Map(
    "C-2", 0,   "Cs-2", 1, "D-2", 2,   "Ds-2", 3, "E-2", 4,   "F-2", 5,
    "Fs-2", 6, "G-2", 7,   "Gs-2", 8, "A-2", 9,   "As-2", 10, "B-2", 11,
    "C-1", 12, "Cs-1", 13, "D-1", 14, "Ds-1", 15, "E-1", 16, "F-1", 17,
    "Fs-1", 18, "G-1", 19, "Gs-1", 20, "A-1", 21, "As-1", 22, "B-1", 23,
    "C0", 24, "Cs0", 25, "D0", 26, "Ds0", 27, "E0", 28, "F0", 29,
    "Fs0", 30, "G0", 31, "Gs0", 32, "A0", 33, "As0", 34, "B0", 35,
    "C1", 36, "Cs1", 37, "D1", 38, "Ds1", 39, "E1", 40, "F1", 41,
    "Fs1", 42, "G1", 43, "Gs1", 44, "A1", 45, "As1", 46, "B1", 47,
    "C2", 48, "Cs2", 49, "D2", 50, "Ds2", 51, "E2", 52, "F2", 53,
    "Fs2", 54, "G2", 55, "Gs2", 56, "A2", 57, "As2", 58, "B2", 59,
    "C3", 60, "Cs3", 61, "D3", 62, "Ds3", 63, "E3", 64, "F3", 65,
    "Fs3", 66, "G3", 67, "Gs3", 68, "A3", 69, "As3", 70, "B3", 71,
    "C4", 72, "Cs4", 73, "D4", 74, "Ds4", 75, "E4", 76, "F4", 77,
    "Fs4", 78, "G4", 79, "Gs4", 80, "A4", 81, "As4", 82, "B4", 83,
    "C5", 84, "Cs5", 85, "D5", 86, "Ds5", 87, "E5", 88, "F5", 89,
    "Fs5", 90, "G5", 91, "Gs5", 92, "A5", 93, "As5", 94, "B5", 95,
    "C6", 96, "Cs6", 97, "D6", 98, "Ds6", 99, "E6", 100, "F6", 101,
    "Fs6", 102, "G6", 103, "Gs6", 104, "A6", 105, "As6", 106, "B6", 107,
    "C7", 108, "Cs7", 109, "D7", 110, "Ds7", 111, "E7", 112, "F7", 113,
    "Fs7", 114, "G7", 115, "Gs7", 116, "A7", 117, "As7", 118, "B7", 119,
    "C8", 120, "Cs8", 121, "D8", 122, "Ds8", 123, "E8", 124, "F8", 125,
    "Fs8", 126, "G8", 127, "Gs8", 128
)

ConvertToTab(note) {
    global strings, notes
    midiNote := notes[note]  ; Get the MIDI number for the note

    ; Guitar range typically from E2 (MIDI 40) to E6 (MIDI 88)
    ; Clamp the note to the closest playable note within this range
    if (midiNote < 40)
        midiNote := 40  ; Closest is E2 (6th string)
    else if (midiNote > 88)
        midiNote := 88  ; Closest is E6 (1st string)

    closestStringNum := 0
    closestFret := 100  ; High number to ensure we find the closest fret

    ; Loop through each guitar string
    for _, stringData in strings {
        fret := midiNote - stringData.baseNote  ; Calculate the fret number
        if (fret >= 0 && fret < closestFret) {  ; Ensure it's a valid fret
            if (fret > maxFrets)  ; Clamp the fret number to 15 if it's greater than 15
                fret := maxFrets
            closestStringNum := stringData.stringNum
            closestFret := fret
        }
    }

    ; Return the closest string number and fret number
    return {string: closestStringNum, fret: closestFret}
}

pos1 := {x:550, y:95}
pos2 := {x:550, y:1018}

; Hotkey for Page Up key
+PgUp:: {
	global pos1
    ; Get the current mouse position
    pos1 := GetMousePos()
}
+PgDn:: {
	global pos2
    ; Get the current mouse position
    pos2 := GetMousePos()
}

; Function to get the mouse position
GetMousePos() {
    MouseGetPos(&x, &y)  ; Get the current mouse position
    return { x: x, y: y }  ; Return the coordinates as an object
}

TabToInput(string, fret) {
	global pos1, pos2
	if (WinActive("ahk_exe webfishing.exe")) {
		mouseYDifference := pos2.y - pos1.y
		mousePosY := pos1.y + ((mouseYDifference / maxFrets) * fret)
		Click pos1.x, mousePosY
		
		Send("{" . string . " down}")
		Sleep(25)
		Send("{" . string . " up}")
	}
}


Class MidiDelegate
{
    ; if specificProcessCallback is set true
    ; trigger only when the applicable process is front
    ; replace any spaces or "." in the process name with "_".

    ; use "s" instead of "#"
    MidiNoteOnA(event) {
		convertedTab := ConvertToTab(event.note . event.octave)
        TabToInput(convertedTab.string, convertedTab.fret)
    }
    MidiNoteOnB(event) {
		convertedTab := ConvertToTab(event.note . event.octave)
        TabToInput(convertedTab.string, convertedTab.fret)
    }
    MidiNoteOnC(event) {
		convertedTab := ConvertToTab(event.note . event.octave)
        TabToInput(convertedTab.string, convertedTab.fret)
    }
    MidiNoteOnD(event) {
		convertedTab := ConvertToTab(event.note . event.octave)
        TabToInput(convertedTab.string, convertedTab.fret)
    }
    MidiNoteOnE(event) {
		convertedTab := ConvertToTab(event.note . event.octave)
        TabToInput(convertedTab.string, convertedTab.fret)
    }
    MidiNoteOnF(event) {
		convertedTab := ConvertToTab(event.note . event.octave)
        TabToInput(convertedTab.string, convertedTab.fret)
    }
    MidiNoteOnG(event) {
		convertedTab := ConvertToTab(event.note . event.octave)
        TabToInput(convertedTab.string, convertedTab.fret)
    }
    MidiNoteOnAs(event) {
		convertedTab := ConvertToTab(event.note . event.octave)
        TabToInput(convertedTab.string, convertedTab.fret)
    }
    MidiNoteOnBs(event) {
		convertedTab := ConvertToTab(event.note . event.octave)
        TabToInput(convertedTab.string, convertedTab.fret)
    }
    MidiNoteOnCs(event) {
		convertedTab := ConvertToTab(event.note . event.octave)
        TabToInput(convertedTab.string, convertedTab.fret)
    }
    MidiNoteOnDs(event) {
		convertedTab := ConvertToTab(event.note . event.octave)
        TabToInput(convertedTab.string, convertedTab.fret)
    }
    MidiNoteOnEs(event) {
		convertedTab := ConvertToTab(event.note . event.octave)
        TabToInput(convertedTab.string, convertedTab.fret)
    }
    MidiNoteOnFs(event) {
		convertedTab := ConvertToTab(event.note . event.octave)
        TabToInput(convertedTab.string, convertedTab.fret)
    }
    MidiNoteOnGs(event) {
		convertedTab := ConvertToTab(event.note . event.octave)
        TabToInput(convertedTab.string, convertedTab.fret)
    }

    MidiControlChange(event) {
        ;MsgBox(event.controller . "=" . event.value)

        ; pass through this event to midi out device
        event.eventHandled := false
    }
}
