class_name MusicTrackNode
extends Node

## Place this node in any scene to declare which music track should play.
## MusicManager automatically detects it after each scene change.
## No code required in the scene — just configure in the Inspector.

## The track to play when this scene is active.
## Set to null to keep whatever music is already playing.
@export var track: MusicTrackRes

## Duration in seconds of the crossfade into this track.
## Set to 0.0 for an instant switch.
@export var crossfade_duration: float = 1.5
