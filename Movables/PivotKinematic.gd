extends KinematicBody

func getVelocity():
	return get_parent().getVelocity()
	
func getRotation():
	return get_parent().getRotation()
