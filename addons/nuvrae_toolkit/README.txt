----------------------------------------
ANIMATION SYSTEM
----------------------------------------

OVERVIEW

The AnimationSystem allows you to create and play animations using structured data instead of manually writing individual tween instructions every time.

It supports multiple animation presets, sequential and parallel execution, custom targets, and animation controls.

GETTING STARTED

Use play_animation() to start an animation.

The method accepts four arguments:

- animation: An array containing the animation timeline.
- id: An optional unique identifier for the animation.
- looped: Whether the animation should repeat.
- default_target: An optional default node to animate.

ANIMATION STRUCTURE

Each animation operation contains three main properties:

- type: Determines whether the operation runs sequentially or in parallel.
- preset: Determines which animation behavior to use.
- params: Contains the parameters required by the selected preset.

Example structure:

var animation = [
    {
        "type": "sequential",
        "preset": "move",
        "params": {
            "target_position": Vector2(400, 200),
            "duration": 1.0
        }
    }
]

play_animation(animation)

SEQUENTIAL AND PARALLEL EXECUTION

Sequential:
An operation starts after the previous operation finishes.

Parallel:
An operation runs alongside the previous operation.

This allows multiple animation operations to be combined into a single timeline.

AVAILABLE PRESETS

- move: Moves a node to a specified position.
- slide: Slides a node in a specified direction.
- orbit: Moves a node around a center point.
- scale: Changes a node's scale.
- rotate: Rotates a node.
- fade: Changes a node's opacity.
- change_property: Tweens a specified property.
- shake: Applies a shaking effect to a node.

TARGETING

You can specify a target_node inside an operation's params to determine which node gets animated.

Alternatively, you can provide a default_target when calling play_animation().

The default target makes it easier to reuse animation definitions without specifying the same node repeatedly.

ANIMATION CONTROLS

The AnimationSystem provides three main controls:

- play_animation(): Starts an animation.
- stop_animation(): Stops an active animation.
- toggle_animation_pause(): Pauses or resumes an active animation.

Animations can be identified using their assigned ID.

----------------------------------------
AUDIO SYSTEM
----------------------------------------

OVERVIEW

The AudioSystem provides a simple way to manage and play audio using dedicated audio channels.

It separates music and sound effects into different channel groups.

CHANNELS

The AudioSystem currently provides:

- 2 Music channels.
- 5 SFX channels.

Music channels are assigned to the Music audio bus.

SFX channels are assigned to the SFX audio bus.

PLAYING AUDIO

Use play_on_channel() to play an audio stream on a selected channel.

Example:

AudioSystem.play_on_channel(sound, "SFX", 0, true)

Arguments:

- sound: The AudioStream resource to play.
- "SFX": The channel group to use. Use "Music" for music.
- 0: The channel index.
- true: Enables skip_busy, skips the audio from playing on a specific channel if it's already playing one.

CHANNEL CONTROLS

The AudioSystem provides:

- play_on_channel(): Plays an audio stream on a selected channel.
- stop_channel(): Stops playback on a selected channel.
- toggle_channel_playback(): Toggles playback on a selected channel.

Use these methods to control audio without manually managing individual AudioStreamPlayer nodes.

----------------------------------------
NOTES
----------------------------------------

- Make sure the toolkit is properly installed and initialized before using its systems.
- Animation presets have their own parameters. Refer to their implementation or examples for the supported options.
- Audio channel indices start at 0.
- Music and sound effects use separate channel groups.
- The toolkit is designed to make common animation and audio operations easier to organize and reuse.
