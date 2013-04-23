on run argv
	set outfile to item 1 of argv

	tell application "System Events"
		activate
		set UI elements enabled to true
	end tell

	tell application "QuickTime Player"
	    activate
		document "Screen Recording" stop
	end tell

	tell application "System Events"
		tell process "QuickTime Player"
			delay 1 # Wait for the above to instantiate.
			tell window 1
				keystroke "s" using {command down, shift down}
				delay 5 # Wait for the Save As sheet to appear.
				keystroke outfile
				delay 5 # Wait for the paste to happen corrctly.
				key code 36 # Hit enter
				delay 5 # Wait for the "Go" sheet
				key code 36 # Hit enter
				delay 5 #wait for export    # Wait for export to complete exporting movie.
			end tell
		end tell
	end tell

	tell application "QuickTime Player" to Quit saving no
end
