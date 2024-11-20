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


ConvertToTab(noteNumber) {
    global strings
    midiNote := noteNumber

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
	mouseYDifference := pos2.y - pos1.y
	mousePosY := pos1.y + ((mouseYDifference / maxFrets) * fret)
	Click pos1.x, mousePosY
	
	Send("{" . string . " down}")
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
