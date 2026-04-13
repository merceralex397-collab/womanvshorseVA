extends Node2D

signal joystick_direction_changed(direction: Vector2)

var _touch_index: int = -1
var _touch_origin: Vector2 = Vector2.ZERO
var _current_direction: Vector2 = Vector2.ZERO

func _input(event: InputEvent) -> void:
    if event is InputEventScreenTouch:
        if event.pressed and _is_in_joystick_zone(event.position):
            _touch_index = event.index
            _touch_origin = event.position
        elif not event.pressed and event.index == _touch_index:
            _touch_index = -1
            _current_direction = Vector2.ZERO
            joystick_direction_changed.emit(Vector2.ZERO)
    elif event is InputEventScreenDrag:
        if event.index == _touch_index:
            var drag_vector = event.position - _touch_origin
            var max_distance = 50.0  # Joystick radius
            if drag_vector.length() > max_distance:
                drag_vector = drag_vector.normalized() * max_distance
            _current_direction = drag_vector / max_distance
            joystick_direction_changed.emit(_current_direction)

func _is_in_joystick_zone(pos: Vector2) -> bool:
    return pos.x < get_viewport_rect().size.x / 2.0

# Property to get current direction for player
var direction: Vector2:
    get:
        return _current_direction
