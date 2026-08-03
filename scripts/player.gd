extends CharacterBody2D

# Simple player controller for the Wheelie Challenge prototype.
# Controls: Right = accelerate, Left = brake, Up = lean back, Down = lean forward

@export var accel = 800.0
@export var max_speed = 600.0
@export var brake_force = 1200.0
@export var gravity = 1200.0
@export var jump_impulse = -420.0

var velocity = Vector2.ZERO
var on_ground = true
var is_wheelie = false
var wheelie_time = 0.0
var rotations = 0.0

signal did_jump(height)
signal did_land(landing_velocity, perfect)
signal did_crash()
signal did_flip(direction)

func _ready():
    pass

func _physics_process(delta):
    handle_input(delta)
    apply_physics(delta)
    update_wheelie(delta)
    apply_motion(delta)

func handle_input(delta):
    var acc = 0.0
    if Input.is_action_pressed("ui_right"):
        acc += 1.0
    if Input.is_action_pressed("ui_left"):
        acc -= 1.0

    # Apply forward/back acceleration
    if acc > 0:
        velocity.x += accel * acc * delta
    else:
        # braking
        velocity.x = lerp(velocity.x, 0, min(1, brake_force * delta / max(1, abs(velocity.x))))

    velocity.x = clamp(velocity.x, -max_speed, max_speed)

    # Leaning
    if Input.is_action_pressed("ui_up"):
        rotation_degrees = clamp(rotation_degrees - 120 * delta, -60, 60)
    elif Input.is_action_pressed("ui_down"):
        rotation_degrees = clamp(rotation_degrees + 120 * delta, -60, 60)
    else:
        # gradually straighten
        rotation_degrees = lerp(rotation_degrees, 0, 5 * delta)

    # Jump (simple trigger when hitting ramp via vertical velocity in real project)
    # For prototype, allow jump when on_ground and pressing up while moving fast
    if on_ground and Input.is_action_just_pressed("ui_up") and abs(velocity.x) > 120:
        velocity.y = jump_impulse
        on_ground = false
        emit_signal("did_jump", -velocity.y)

func apply_physics(delta):
    # gravity
    if not on_ground:
        velocity.y += gravity * delta

    # simplistic ground detection: if below a y threshold
    if position.y >= 520:
        if not on_ground:
            # landed
            on_ground = true
            var landing_v = velocity.y
            velocity.y = 0
            # determine perfect landing
            var perfect = abs(rotation_degrees) < 12 and landing_v < 200
            emit_signal("did_land", landing_v, perfect)
            # reset rotations
            if abs(rotation_degrees) > 180:
                # flip!
                if rotation_degrees > 0:
                    emit_signal("did_flip", 1)
                else:
                    emit_signal("did_flip", -1)
            rotation_degrees = fmod(rotation_degrees, 360)
    else:
        # airborne
        pass

func apply_motion(delta):
    move_and_slide()
    # For CharacterBody2D we should use velocity
    velocity = move_and_slide(velocity, Vector2.UP)

func update_wheelie(delta):
    # Wheelie when rotation back past a small negative angle and moving
    var was_wheelie = is_wheelie
    is_wheelie = on_ground and rotation_degrees < -18 and abs(velocity.x) > 80
    if is_wheelie:
        wheelie_time += delta
    elif was_wheelie and not is_wheelie:
        # wheelie ended
        # Keep wheelie_time until reported
        pass

func reset_wheelie_time():
    wheelie_time = 0.0

func register_crash():
    emit_signal("did_crash")
