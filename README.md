# WEBFISHING Midi Input
Created this in AutoHotkey (v2) as a way to translate midi inputs from something like a midi keyboard to keystrokes in WEBFISHING.

Please download the compiled exe in the releases section! Otherwise, you will also need the midi2.ahk library I am using, as seen in the project and also listed in the credits.

#### To Use:
- Run script, in your tray right click and choose a midi input channel. (Don't set anything for the output channel.)
- In game, it should already just work if you play the game at 1920x1080 and fullscreen as that's what I play on. If you don't, though, then you need to:
  1. Hover over the top fret (fret 0) and press Shift+PgUp
  2. Hover over the bottom-most fret (fret 15) and press Shift+PgDn

That's it! Make sure that WEBFISHING is the active process (it won't work if it isn't) then you should be able to play notes on your midi keyboard!

Things to keep in mind:
- This is made for midi input, from things like midi instruments such as keyboards. That was my intended use case, but nothing is stopping you from using midi files to play music either. In order to achieve that, you will need a third party program to play the midi file on, and something to create a midi input. Some midi players have built in output and can create their own midi channel, but you might also have to download a third party program to create a virtual midi channel to use.
- WEBFISHING only has 15 frets. This limits the amount of notes you can hit. Anything outside of the range of E2 to E6 will be clamped. I may change this behavior in the future to just ignore notes out of range as they often sound bad, but am not sure.
- If you play fast enough, notes that use the same string will interrupt other notes that you play that also use the same string. Some chords work well as they use different strings, some don't sound the best.
- Lag can affect it's performance, as it relies on clicking on frets and sending input.
- I don't play guitar lol so I tried my best but yk





#### Credits
Makes use of [Hetima's fork](https://github.com/hetima/AutoHotkey-Midi/tree/master "Hetima's fork") of [dannywarren's autohotkey midi lib](http://https://github.com/dannywarren/AutoHotkey-Midi "dannywarren's autohotkey midi lib")
With some help from ChatGPT, specifically for the piano note to guitar tab conversion. I don't play guitar, so didn't know how to go about achieving that at all.
