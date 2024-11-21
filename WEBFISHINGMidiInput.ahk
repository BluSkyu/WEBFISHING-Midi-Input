#Requires AutoHotkey v2.0
#include "AutoHotkey-Midi\Midi2.ahk"

midi := AHKMidi()
midi.midiEventPassThrough := True
midi.delegate := MidiDelegate()
midi.specificProcessCallback := True

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

LoopNotesOutOfRange(midiNote) {
    ; Webfishing guitar range from E2 (MIDI 40) to G5 (MIDI 79)
    if (midiNote < 40) {
        note := midiNote + 4
	note := Mod(note, 12) + 40 ; Loops over the lowest octave
    } else if (midiNote > 79) {
	note := midiNote + 8
        note := Mod(note, 12) + 64  ; Loops over highest octave
    }
    return note
}


ConvertToTab(noteNumber) {
    global strings
    midiNote := noteNumber

    midiNote := LoopNotesOutOfRange(midiNote)

    closestStringNum := 0

    ; Find string for note.
    Switch(midiNote)
    {
    Case midiNote < 40:
        ToolTip "Error: midiNote too low for strings"
        SetTimer () => ToolTip(), -5000
    Case midiNote < 47:
        stringKey := 'q'
	fretNumber := midiNote - 40
    Case midinote < 54:
        stringKey := 'w'
	fretNumber := midiNote - 45
    Case midiNote < 61:
        stringKey := 'e'
	fretNumber := midiNote - 50
    Case midinote < 68:
        stringKey := 'r'
	fretNumber := midiNote - 55
    Case midiNote < 74:
        stringKey := 't'
	fretNumber := midiNote - 59
    Case midinote < 80:
        stringKey := 'y'
	fretNumber := midiNote - 64
    Default:
        ToolTip "Error: midiNote too high for strings"
        SetTimer () => ToolTip(), -5000
    }
    return {string: stringKey, fret: fretNumber}
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
	mouseYDifference := pos2.y - pos1.y
	mousePosY := pos1.y + ((mouseYDifference / maxFrets) * fret)
	Click pos1.x, mousePosY
	
	Send("{" . string . " down}")
	Sleep(25)
	Send("{" . string . " up}")
}

ProcessNote(noteNumber) {
	convertedTab := ConvertToTab(noteNumber)
	TabToInput(convertedTab.string, convertedTab.fret)
}


Class MidiDelegate
{
    ; if specificProcessCallback is set true
    ; trigger only when the applicable process is front
    ; replace any spaces or "." in the process name with "_".

    ; use "s" instead of "#"

    webfishing_exe_MidiNoteOnA(event) {
		ProcessNote(event.noteNumber)
    }
    webfishing_exe_MidiNoteOnB(event) {
		ProcessNote(event.noteNumber)
    }
    webfishing_exe_MidiNoteOnC(event) {
		ProcessNote(event.noteNumber)
    }
    webfishing_exe_MidiNoteOnD(event) {
		ProcessNote(event.noteNumber)
    }
    webfishing_exe_MidiNoteOnE(event) {
		ProcessNote(event.noteNumber)
    }
    webfishing_exe_MidiNoteOnF(event) {
		ProcessNote(event.noteNumber)
    }
    webfishing_exe_MidiNoteOnG(event) {
		ProcessNote(event.noteNumber)
    }
    webfishing_exe_MidiNoteOnAs(event) {
		ProcessNote(event.noteNumber)
    }
    webfishing_exe_MidiNoteOnBs(event) {
		ProcessNote(event.noteNumber)
    }
    webfishing_exe_MidiNoteOnCs(event) {
		ProcessNote(event.noteNumber)
    }
    webfishing_exe_MidiNoteOnDs(event) {
		ProcessNote(event.noteNumber)
    }
    webfishing_exe_MidiNoteOnEs(event) {
		ProcessNote(event.noteNumber)
    }
    webfishing_exe_MidiNoteOnFs(event) {
		ProcessNote(event.noteNumber)
    }
    webfishing_exe_MidiNoteOnGs(event) {
		ProcessNote(event.noteNumber)
    }

    MidiControlChange(event) {
        ;MsgBox(event.controller . "=" . event.value)

        ; pass through this event to midi out device
        event.eventHandled := false
    }
}
