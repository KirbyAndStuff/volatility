extends Control

func _process(delta):
	var value = (get_node("../player").health)
	if value < 3:
		$"4l3Cr98s3".visible = false
	if value < 2:
		$"4l3Cr98s3".visible = false
		$"4l3Cr98s2".visible = false
	if value < 1:
		$"4l3Cr98s3".visible = false
		$"4l3Cr98s2".visible = false
		$"4l3Cr98s".visible = false
