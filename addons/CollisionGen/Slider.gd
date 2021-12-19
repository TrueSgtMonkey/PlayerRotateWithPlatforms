extends HBoxContainer

var mouseInBody := false
var hSlider

func _ready():
	hSlider = $HSlider

func _input(event):
	if(mouseInBody && Input.is_mouse_button_pressed(BUTTON_LEFT)):
		hSlider = getRatioOfSlider(hSlider)
		$MarginContainer/Value.text = str(hSlider.value)
		
func getRatioOfSlider(text):
	var ratio = text.ratioInBody()
	text.value = ratio * text.max_value
	return text

func _on_Resolution_mouse_entered():
	mouseInBody = true
	

func _on_Resolution_mouse_exited():
	mouseInBody = false
