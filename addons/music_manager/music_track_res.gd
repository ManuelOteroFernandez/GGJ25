@tool
class_name MusicTrackRes
extends Resource

## Defines one music track: its stems, names, initial mix, and timing metadata.
## Create instances of this as .tres files in your game's audio folder.
## Assign them to MusicTrackNode in any scene to set that scene's music.

## The audio streams for each stem (drums.ogg, bass.ogg, melody.ogg, …)
## All streams must have the exact same length and loop settings.
@export var stems: Array[AudioStream] = []

## Human-readable name for each stem, used by the MusicManager API.
## Must match stems array length and order.
## Example: ["drums", "bass", "harmony", "melody"]
@export var stem_names: Array[String] = []

## Initial volume in dB for each stem at the moment the track starts.
## Use 0.0 for audible, -80.0 to start muted.
## If shorter than stems array, remaining stems default to 0.0.
@export var initial_volumes_db: Array[float] = []

## Beats per minute of the track. Used to calculate bar boundaries.
@export var bpm: float = 120.0

## How many beats make one bar (time signature numerator).
@export var beats_per_bar: int = 4

## How many bars compose one loop of the track.
## bar_ended signal fires every bar; loop_ended fires every bars_per_loop bars.
@export var bars_per_loop: int = 4

## Stems that are randomly toggled on/off at every loop boundary.
## Stems not listed here keep their current volume unchanged.
## Example: ["noise", "pad_amb"]
@export var random_stems: Array[String] = []


## Duration of a single bar in seconds.
func bar_duration() -> float:
	return 60.0 / bpm * beats_per_bar


## Duration of a full loop in seconds.
func loop_duration() -> float:
	return bar_duration() * bars_per_loop


## Returns the initial volume for stem at index i, defaulting to 0.0.
func get_initial_volume(i: int) -> float:
	if i < initial_volumes_db.size():
		return initial_volumes_db[i]
	return 0.0
