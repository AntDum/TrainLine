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

signal clear

signal fast_forward_on
signal fast_forward_off

signal train_crashed
signal out_of_time

signal level_success
signal level_failed
