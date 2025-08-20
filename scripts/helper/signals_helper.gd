extends Object
class_name Signals

static func all(signal_list: Array[Signal]) -> void:
	for sig in signal_list:
		await sig

static func any(signal_list: Array[Signal]) -> void:
	var listener = _SignalListener.new(signal_list)
	await listener.AnySignal


class _SignalListener extends RefCounted:
	signal AnySignal
	
	var signals: Array[Signal] = []
	var completed : bool = false
	
	func _init(signal_list: Array[Signal]) -> void:
		for sig in signal_list:
			signals.append(sig)
			sig.connect(_on_signal, CONNECT_ONE_SHOT)
	
	func _on_signal() -> void:
		if completed: return
		completed = true
		for sig in signals:
			if sig and sig.is_connected(_on_signal):
				sig.disconnect(_on_signal)
		AnySignal.emit()
