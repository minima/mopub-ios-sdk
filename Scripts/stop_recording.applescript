tell application "QuickTime Player"
    activate
	document "Screen Recording" stop
end tell

delay 1

tell application "QuickTime Player" to Quit saving no
