extends OmniLight

export (bool) var shifting = false
export (float) var minLight = 1.0
export (float) var maxLight = 2.0
export (float) var speed = 0.1
export (float) var delayMinTime = 3.0
export (float) var delayMaxTime = 3.0


var currLight := 0.0
var adding := true
var delay := false
var delayTimer := Timer.new()
var delayMaxTimer := Timer.new()

func _ready():
	delayTimer = addTimer(delayTimer, delayMinTime, "endDelay")
	delayMaxTimer = addTimer(delayMaxTimer, delayMaxTime, "endDelay")
	currLight = minLight

func _process(delta):
	if shifting && !delay:
		if adding:
			currLight += speed * delta
			if currLight > maxLight:
				currLight = maxLight
				adding = false
				delay = true
				delayMaxTimer.start()
		else:
			currLight -= speed * delta
			if currLight < minLight:
				currLight = minLight
				adding = true
				delay = true
				delayTimer.start()
		light_energy = currLight
		
func endDelay():
	delay = false
	
func addTimer(timer : Timer, wait : float, function : String):
	timer.wait_time = wait
	timer.one_shot = true
	timer.connect("timeout", self, function)
	add_child(timer)
	return timer
