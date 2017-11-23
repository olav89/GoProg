extends SamplePlayer2D

var id_voice_walking = 0

func play_sample_walking():
	if !is_voice_active(id_voice_walking):
		id_voice_walking = play("walking")

func play_sample_typing():
	play("typing")
	
func play_sample_ding():
	play("ding")

func disableSound():
	AudioServer.set_fx_global_volume_scale(0)

func enableSound():
	AudioServer.set_fx_global_volume_scale(1)

func setSoundVolume(vol):
	AudioServer.set_fx_global_volume_scale(vol)

func getSoundVolume():
	return AudioServer.get_fx_global_volume_scale()
