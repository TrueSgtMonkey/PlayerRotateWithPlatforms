extends Area

export (String) var sig = "toggle"
export (int) var id = 0
export (Dictionary) var dict = {}
export (String) var exitSig = ""
export (int) var exitId = 0
export (Dictionary) var exitDict = {}

func _ready():
	connect("body_entered", self, "bodyIn")
	connect("body_exited", self, "bodyOut")
	$MeshInstance.queue_free()

func bodyIn(body):
	if body is KinematicBody && sig != "":
		Events.emit_signal(sig, id, dict)

func bodyOut(body):
	if body is KinematicBody && exitSig != "":
		Events.emit_signal(exitSig, exitId, exitDict)
