extends Node

signal rail_placed(coord: Vector2i)
signal rail_removed(coord: Vector2i)

signal start
signal restart

signal station_happy(current:int, max: int)
signal all_station_satisfied

signal step

signal time_changed(time: float)
signal delay_changed(delay: float)

signal train_crashed
signal out_of_time

signal level_success
signal level_failed
