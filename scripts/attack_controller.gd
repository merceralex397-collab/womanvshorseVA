extends Node2D

signal melee_attack(facing: Vector2)
signal ranged_attack(facing: Vector2)

var _hold_start_time: float = -1.0
var _hold_origin: Vector2 = Vector2.ZERO
const HOLD_THRESHOLD: float = 0.25  # 250ms for ranged

func _input(event: InputEvent) -> void:
    if event is InputEventScreenTouch:
        if event.pressed and _is_in_attack_zone(event.position):
            _hold_start_time = Time.get_ticks_msec() / 1000.0
            _hold_origin = event.position
        elif not event.pressed and event.index == 0:
            if _hold_start_time > 0:
                var hold_duration: float = (Time.get_ticks_msec() / 1000.0) - _hold_start_time
                if hold_duration < HOLD_THRESHOLD:
                    melee_attack.emit(Vector2.RIGHT)  # Emit toward facing
                else:
                    ranged_attack.emit(Vector2.RIGHT)  # Emit toward facing
                _hold_start_time = -1.0

func _is_in_attack_zone(pos: Vector2) -> bool:
    return pos.x >= get_viewport_rect().size.x / 2.0
