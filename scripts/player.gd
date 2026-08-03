extends CharacterBody2D

# Improved player controller for Wheelie Challenge prototype.
# Uses CharacterBody2D built-in floor detection and a single move_and_slide call.
# Controls: Right = accelerate, Left = brake, Up = lean back / jump, Down = lean forward

@export var accel: float = 900.0
@export var max_speed: float = 700.0
@export var brake_force: float = 1200.0
@export var gravity: float = 1400.0
@export var jump_impulse: float = -520.0
@export var rotation_speed: float = 180.0 # degrees per second when leaning
@export var max_rotation_deg: float = 75.0

# Wheelie / flip detection thresholds
@export var wheelie_angle_threshold: float = -18.0
@export var wheelie_speed_threshold: float = 100.0
@export var perfect_landing_angle_threshold: float = 12.0
@export var perfect_landing_speed_threshold: float = 220.0
@export var crash_impact_velocity_threshold: float = 900.0
@export var flip_rotation_required: float = 360.0

signal did_jump(height)
signal did_land(landing_velocity, perfect)
signal did_crash()
signal did_flip(direction)

var velocity: Vector2 = Vector2.ZERO
var was_on_floor: bool = false
var is_wheelie: bool = false
var wheelie_time: float = 0.0

# Track rotation accumulation while airborne for flip detection
var airborne_rotation_accum: float = 0.0
var last_rotation_degrees: float = 0.0

func _ready():
    last_rotation_degrees = rotation_degrees

func _physics_process(delta: float) -> void:
    handle_input(delta)

    # gravity
    if not is_on_floor():
        velocity.y += gravity * delta

    # move once, using CharacterBody2D helper
    # CharacterBody2D.move_and_slide returns the new velocity — capture it
    velocity = move_and_slide(velocity, Vector2.UP)

    # detect transitions between air/ground
    if not was_on_floor and is_on_floor():
        _on_landed()
    elif was_on_floor and not is_on_floor():
        _on_takeoff()

    # Wheelie handling (only valid when on floor)
    _update_wheelie(delta)

    # Track rotation changes while airborne
    if not is_on_floor():
        var delta_rot = rotation_degrees - last_rotation_degrees
        # Normalize delta rotation to -180..180 for accumulation
        delta_rot = (delta_rot + 180.0) % 360.0 - 180.0
        airborne_rotation_accum += delta_rot
    else:
        # keep accumulation bounded
        airborne_rotation_accum = clamp(airborne_rotation_accum, -10000, 10000)

    last_rotation_degrees = rotation_degrees
    was_on_floor = is_on_floor()

func handle_input(delta: float) -> void:
    var drive_input: float = 0.0
    if Input.is_action_pressed("ui_right"):
        drive_input += 1.0
    if Input.is_action_pressed("ui_left"):
        drive_input -= 1.0

    # Apply acceleration or braking
    if drive_input > 0.0:
        velocity.x += accel * drive_input * delta
    elif drive_input < 0.0:
        # allow reverse / light braking
        velocity.x = lerp(velocity.x, velocity.x - brake_force * delta * abs(drive_input), 1.0)
    else:
        # natural friction
        velocity.x = lerp(velocity.x, 0.0, 3.0 * delta)

    velocity.x = clamp(velocity.x, -max_speed, max_speed)

    # Leaning (rotation) input
    if Input.is_action_pressed("ui_up") and not Input.is_action_pressed("ui_down"):
        rotation_degrees = clamp(rotation_degrees - rotation_speed * delta, -max_rotation_deg, max_rotation_deg)
    elif Input.is_action_pressed("ui_down") and not Input.is_action_pressed("ui_up"):
        rotation_degrees = clamp(rotation_degrees + rotation_speed * delta, -max_rotation_deg, max_rotation_deg)
    else:
        # auto straighten toward 0
        rotation_degrees = lerp(rotation_degrees, 0.0, 5.0 * delta)

    # Jump: only if on floor and moving sufficiently fast
    if is_on_floor() and Input.is_action_just_pressed("ui_up") and abs(velocity.x) > wheelie_speed_threshold:
        velocity.y = jump_impulse
        # Leave floor detection to physics loop
        emit_signal("did_jump", -velocity.y)

func _on_takeoff() -> void:
    # reset airborne rotation accumulator when leaving ground
    airborne_rotation_accum = 0.0

func _on_landed() -> void:
    # landing_velocity (positive downwards)
    var landing_v = velocity.y

    # perfect landing if roughly upright and not too hard
    var perfect = abs(rotation_degrees) <= perfect_landing_angle_threshold and abs(landing_v) <= perfect_landing_speed_threshold

    # Flip detection: if accumulated rotation while airborne meets requirement
    if abs(airborne_rotation_accum) >= flip_rotation_required:
        var dir = 1 if airborne_rotation_accum > 0 else -1
        emit_signal("did_flip", dir)
        # normalize rotation to upright on landing
        rotation_degrees = 0.0
        airborne_rotation_accum = 0.0

    # Crash detection: very hard landing or extreme angle
    if abs(landing_v) > crash_impact_velocity_threshold or abs(rotation_degrees) > 100.0:
        emit_signal("did_crash")
        # try to stabilize player orientation after crash
        rotation_degrees = clamp(rotation_degrees, -160, 160)
    else:
        emit_signal("did_land", landing_v, perfect)
        # gently reset rotation to upright over a short time
        rotation_degrees = lerp(rotation_degrees, 0.0, 0.5)

func _update_wheelie(delta: float) -> void:
    var was_wheelie = is_wheelie
    is_wheelie = is_on_floor() and rotation_degrees <= wheelie_angle_threshold and abs(velocity.x) >= wheelie_speed_threshold
    if is_wheelie:
        wheelie_time += delta
    else:
        # if wheelie just ended, leave it to GameManager to sample wheelie_time
        pass

func reset_wheelie_time() -> void:
    wheelie_time = 0.0

func register_crash() -> void:
    emit_signal("did_crash")
