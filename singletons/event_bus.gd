extends Node

signal rail_placed(coord: Vector2i)
signal rail_removed(coord: Vector2i)

signal start
signal restart

signal station_happy(current:int, max: int)
signal all_station_satisfied

signal step(time: int)

signal time_changed(time: int, max: int)
signal delay_changed(delay: float)

signal flip_reality
signal flip_back

signal started_tuto
signal finished_tuto

signal change_mode(mode: ModeHelper.Mode)

signal clear

signal fast_forward_on
signal fast_forward_off

signal train_crashed(reason: String)
signal out_of_time

signal need_restart
