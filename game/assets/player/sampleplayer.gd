# Script for player sounds

extends SamplePlayer2D

# ID for walking voice
var id_voice_walking = 0

# Plays a walking sound
func play_sample_walking():
	if !is_voice_active(id_voice_walking): # If sound is not active
		id_voice_walking = play("walking") # play walking sound

# Plays a typing sound
func play_sample_typing():
	play("typing")

# Plays a ding sound
func play_sample_ding():
	play("ding")

# Disables sound
func disableSound():
	AudioServer.set_fx_global_volume_scale(0)

# Enables sound
func enableSound():
	AudioServer.set_fx_global_volume_scale(1)

# Set sound volume
func setSoundVolume(vol):
	AudioServer.set_fx_global_volume_scale(vol)

# Get sound volume
func getSoundVolume():
	return AudioServer.get_fx_global_volume_scale()
