# polacz
set irc [socket irc.atw-inter.net 6667]
puts $irc "NICK pisg"
puts $irc "USER pisg * * :PiSG"
puts $irc "JOIN #jakiskanal"

# ustaw baze sqlite
package require sqlite3
set db [sqlite3 open "irc.db"]

# funkcja insertujaca wpisy
proc log {nick message} {
	set stmt [$db prepare "INSERT INTO logs (timestamp, nick, message) VALUES (datetime('now'), ?, ?)"]
	$stmt bind 1 $nick
	$stmt bind 2 $message
	$stmt step
	$stmt reset
}

# przeczytaj msgi i procesuj je
while {1} {
	set line [gets $irc]
	if {[string match "PING*" $line]} {
		# Respond to PING message to keep connection alive
		puts $irc "PONG [lindex $line 1]"
	} elseif {[string match "PRIVMSG #channel :*" $line]} {
		# Extract nick and message from PRIVMSG
		set nick [lindex [split [lindex [split $line ":"] 0] "!"] 0]
		set message [string range $line [string last ": " $line] end]
		# Log message to database
		log $nick $message
	}
}
