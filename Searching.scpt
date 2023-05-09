
set searchFolder to (choose folder with prompt "Select a folder to search in")
set filePath to (choose file with prompt "Select the file containing the list of filenames")
set fileData to read file filePath
set fileList to paragraphs of fileData
set foundFiles to {}

repeat with fileName in fileList
	set fileName to fileName as text
	set {namePart, extensionPartUpper, extensionPartLower} to splitFileNameUpperCase(fileName)
	-- Search with uppercase extension
	set upperSearch to quoted form of (namePart & "." & extensionPartUpper)
	set foundFile to (do shell script "mdfind -onlyin " & quoted form of POSIX path of searchFolder & " 'kMDItemDisplayName==" & upperSearch & "'")
	if foundFile is not equal to "" then
		set end of foundFiles to foundFile
	end if
	-- Search with lowercase extension
	set lowerSearch to quoted form of (namePart & "." & extensionPartLower)
	set foundFile to (do shell script "mdfind -onlyin " & quoted form of POSIX path of searchFolder & " 'kMDItemDisplayName==" & lowerSearch & "'")
	if foundFile is not equal to "" then
		set end of foundFiles to foundFile
	end if
end repeat

if length of foundFiles is greater than 0 then
	set AppleScript's text item delimiters to {return & linefeed}
	set fileListStr to foundFiles as text
	set AppleScript's text item delimiters to ""
	repeat with filePath in paragraphs of fileListStr
		set theFile to (POSIX file filePath) as string
		set AppleScript's text item delimiters to "."
		set file_components to text items of theFile
		set file_extension to last item of file_components
		set file_extension to (do shell script "echo " & quoted form of file_extension & " | tr '[:upper:]' '[:lower:]'")
		if file_extension is in {"jpeg", "jpg", "png", "JPG", "PNG", "gif", "tiff", "bmp", "heic", "heif"} then
			tell application "Preview" to open theFile
		else if file_extension is in {"mov", "mp4", "avi", "flv", "wmv", "mkv"} then
			tell application "QuickTime Player"
				activate
				open theFile
				play document 1
			end tell
		end if
	end repeat
else
	display dialog "No files found"
end if

on splitFileNameUpperCase(fileName)
	set AppleScript's text item delimiters to "."
	set nameParts to text items of fileName
	set AppleScript's text item delimiters to ""
	set namePart to item 1 of nameParts as text
	set extensionPart to item 2 of nameParts as text
	set extensionPartUpper to (do shell script "echo " & quoted form of extensionPart & " | tr '[:lower:]' '[:upper:]'")
	set extensionPartLower to (do shell script "echo " & quoted form of extensionPart & " | tr '[:upper:]' '[:lower:]'")
	return {namePart, extensionPartUpper, extensionPartLower}
end splitFileNameUpperCase