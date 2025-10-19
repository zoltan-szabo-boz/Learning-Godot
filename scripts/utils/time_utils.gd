class_name TimeUtils
extends RefCounted

## Time utility functions for formatting and working with time values.
##
## This class provides static utility functions for time-related operations
## such as formatting time values for display.

## Formats the current system time as HH:MM:SS.
##
## Returns a string representation of the current time in 24-hour format
## with zero-padded hours, minutes, and seconds.
##
## Example: "14:23:45"
static func format_current_time() -> String:
	var time = Time.get_time_dict_from_system()
	return "%02d:%02d:%02d" % [time.hour, time.minute, time.second]

## Formats a time dictionary as HH:MM:SS.
##
## [param time_dict]: Dictionary with 'hour', 'minute', 'second' keys
##
## Returns a formatted string representation.
static func format_time(time_dict: Dictionary) -> String:
	return "%02d:%02d:%02d" % [time_dict.hour, time_dict.minute, time_dict.second]

## Formats seconds into a readable string (HH:MM:SS or MM:SS).
##
## [param seconds]: Total seconds to format
## [param show_hours]: If true, always show hours. If false, only show hours if >= 1 hour
##
## Returns a formatted time string.
##
## Examples:
##   format_seconds(90) -> "01:30"
##   format_seconds(3661) -> "01:01:01"
static func format_seconds(seconds: float, show_hours: bool = false) -> String:
	var total_seconds = int(seconds)
	var hours = total_seconds / 3600
	var minutes = (total_seconds % 3600) / 60
	var secs = total_seconds % 60

	if hours > 0 or show_hours:
		return "%02d:%02d:%02d" % [hours, minutes, secs]
	else:
		return "%02d:%02d" % [minutes, secs]
