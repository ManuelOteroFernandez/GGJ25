class_name MusicManagerClass
extends Node

# ---------------------------------------------------------------------------
# Signals
# ---------------------------------------------------------------------------

## Emitted on every new bar boundary. bar_number resets to 0 on each loop.
signal bar_ended(bar_number: int)

## Emitted when the playback position wraps back to bar 0 (loop restart).
signal loop_ended()

## Emitted once the new track is fully active (crossfade complete).
signal track_changed(new_track: MusicTrackRes)

## Emitted the moment a crossfade begins.
signal crossfade_started()

## Emitted the moment a crossfade finishes.
signal crossfade_finished()

# ---------------------------------------------------------------------------
# Constants
# ---------------------------------------------------------------------------

const _SETTING_PITCH_FOLLOWS_TIME := "music_manager/pitch_follows_time_scale"

# ---------------------------------------------------------------------------
# Private state
# ---------------------------------------------------------------------------

var _player_a: AudioStreamPlayer
var _player_b: AudioStreamPlayer

## Points to the currently audible player.
var _active_player: AudioStreamPlayer

## Points to the standby player (silent, may be playing during crossfade).
var _next_player: AudioStreamPlayer

var _active_track: MusicTrackRes

## Last bar index emitted. -1 means no bar has fired yet.
var _last_bar: int = -1

var _crossfade_tween: Tween

## Current logical stem mix: { stem_name: volume_db }
var _stem_volumes: Dictionary

# ---------------------------------------------------------------------------
# Lifecycle
# ---------------------------------------------------------------------------

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_setup_players()
	var lt := get_node_or_null("/root/LevelTransition")
	if lt:
		lt.scene_changed.connect(_on_scene_changed)
		
	_on_scene_changed()


func _process(_delta: float) -> void:
	_update_pitch_scale()
	_update_bar_tracking()

# ---------------------------------------------------------------------------
# Public API
# ---------------------------------------------------------------------------

## Play a track immediately, with an optional crossfade duration.
## Pass crossfade = 0.0 for an instant cut.
func play_track(track: MusicTrackRes, crossfade: float = 1.5) -> void:
	if track == null:
		push_warning("MusicManager: play_track called with null track.")
		return
	if track.stems.is_empty():
		push_warning("MusicManager: track has no stems: ", track.resource_path)
		return
	_do_crossfade(track, crossfade)


## Activate or silence a stem by name.
## Equivalent to set_stem_volume(name, 0.0 or -80.0).
func set_stem_active(stem_name: String, active: bool) -> void:
	set_stem_volume(stem_name, 0.0 if active else -80.0)


## Set the volume of a stem by name (in dB). Affects live playback immediately.
func set_stem_volume(stem_name: String, volume_db: float) -> void:
	if _active_track == null:
		return
	var idx := _active_track.stem_names.find(stem_name)
	if idx == -1:
		push_warning("MusicManager: stem not found: ", stem_name)
		return
	_stem_volumes[stem_name] = volume_db
	var synced := _active_player.stream as AudioStreamSynchronized
	if synced:
		synced.set_sync_stream_volume(idx, volume_db)


## Returns the current volume of a stem in dB, or 0.0 if not found.
func get_stem_volume(stem_name: String) -> float:
	return _stem_volumes.get(stem_name, 0.0)


## Fade out and stop all music over fade_duration seconds.
func stop(fade_duration: float = 1.0) -> void:
	_kill_tween()
	if not _active_player.playing:
		return
	var tween := create_tween().set_process_mode(Tween.TWEEN_PROCESS_IDLE)
	tween.tween_property(_active_player, "volume_db", -80.0, fade_duration)
	tween.tween_callback(_active_player.stop)


## Returns the current bar index within the playing track.
func get_current_bar() -> int:
	return _last_bar


## Returns the raw playback position in seconds of the active player.
func get_playback_position() -> float:
	return _active_player.get_playback_position()


## Returns the active MusicTrackRes, or null if nothing is playing.
func get_active_track() -> MusicTrackRes:
	return _active_track

# ---------------------------------------------------------------------------
# Internal – setup
# ---------------------------------------------------------------------------

func _setup_players() -> void:
	_player_a = AudioStreamPlayer.new()
	_player_b = AudioStreamPlayer.new()
	_player_a.name = "PlayerA"
	_player_b.name = "PlayerB"
	# Start silent so the first crossfade fades in cleanly.
	_player_a.volume_db = -80.0
	_player_b.volume_db = -80.0
	add_child(_player_a)
	add_child(_player_b)
	_active_player = _player_a
	_next_player = _player_b

# ---------------------------------------------------------------------------
# Internal – pitch scale
# ---------------------------------------------------------------------------

func _update_pitch_scale() -> void:
	var target_pitch := Engine.time_scale \
		if ProjectSettings.get_setting(_SETTING_PITCH_FOLLOWS_TIME, false) \
		else 1.0
	_active_player.pitch_scale = target_pitch
	_next_player.pitch_scale = target_pitch

# ---------------------------------------------------------------------------
# Internal – bar tracking
# ---------------------------------------------------------------------------

func _update_bar_tracking() -> void:
	if _active_track == null or not _active_player.playing:
		return
	var bar_dur := _active_track.bar_duration()
	if bar_dur <= 0.0:
		return
	var pos := _active_player.get_playback_position()
	var cur_bar := int(pos / bar_dur)
	if cur_bar == _last_bar:
		return
	# Detect loop wrap: position jumped backwards.
	if cur_bar < _last_bar:
		_apply_stem_randomization()
		loop_ended.emit()
	_last_bar = cur_bar
	bar_ended.emit(cur_bar)

# ---------------------------------------------------------------------------
# Internal – scene integration
# ---------------------------------------------------------------------------

func _on_scene_changed() -> void:
	var node := _find_track_node()
	if node == null or node.track == null:
		return
	if node.track == _active_track:
		return
	_do_crossfade(node.track, node.crossfade_duration)


func _find_track_node() -> MusicTrackNode:
	var scene := get_tree().current_scene
	if scene == null:
		return null
	var results := scene.find_children("*", "MusicTrackNode", true, false)
	if results.is_empty():
		return null
	return results[0] as MusicTrackNode

# ---------------------------------------------------------------------------
# Internal – crossfade
# ---------------------------------------------------------------------------

func _do_crossfade(track: MusicTrackRes, duration: float) -> void:
	_kill_tween()
	crossfade_started.emit()

	# Build the new synchronized stream and load it into the standby player.
	_next_player.stream = _build_synced(track)
	_next_player.volume_db = -80.0
	_next_player.pitch_scale = _active_player.pitch_scale
	_next_player.play()

	# Capture local references before the swap so the tween closure is safe.
	var fading_out := _active_player
	var fading_in := _next_player

	# Swap immediately: _active_player reflects reality during the fade.
	_active_player = fading_in
	_next_player = fading_out
	_active_track = track
	_last_bar = -1

	# Rebuild stem volumes dictionary from track's initial state.
	_stem_volumes.clear()
	for i in range(track.stem_names.size()):
		_stem_volumes[track.stem_names[i]] = track.get_initial_volume(i)

	if duration <= 0.0:
		# Instant cut: no tween needed.
		fading_out.volume_db = -80.0
		fading_out.stop()
		fading_in.volume_db = 0.0
		track_changed.emit(track)
		crossfade_finished.emit()
		return

	# Crossfade tween uses idle processing (same frame as audio updates).
	_crossfade_tween = create_tween().set_process_mode(Tween.TWEEN_PROCESS_IDLE)
	_crossfade_tween.set_parallel(true)
	_crossfade_tween.tween_property(fading_out, "volume_db", -20.0, duration)
	_crossfade_tween.tween_property(fading_in, "volume_db", 0.0, duration)
	_crossfade_tween.set_parallel(false)
	_crossfade_tween.tween_callback(func() -> void:
		fading_out.stop()
		track_changed.emit(track)
		crossfade_finished.emit()
	)


func _build_synced(track: MusicTrackRes) -> AudioStreamSynchronized:
	var synced := AudioStreamSynchronized.new()
	synced.stream_count = track.stems.size()
	for i in range(track.stems.size()):
		synced.set_sync_stream(i, track.stems[i])
		synced.set_sync_stream_volume(i, track.get_initial_volume(i))
	return synced


func _apply_stem_randomization() -> void:
	if _active_track == null or _active_track.random_stems.is_empty():
		return
	for stem_name in _active_track.random_stems:
		set_stem_active(stem_name, randi() % 2 == 0)


func _kill_tween() -> void:
	if _crossfade_tween and _crossfade_tween.is_running():
		_crossfade_tween.kill()
		# Snap volumes to the post-swap expected state:
		# _active_player should be fully audible, standby silent and stopped.
		_active_player.volume_db = 0.0
		_next_player.volume_db = -80.0
		_next_player.stop()
	_crossfade_tween = null
