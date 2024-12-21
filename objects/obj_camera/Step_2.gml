/// @description Aan het einde van iedere stap
if(MUSIC) {
	if(intro_has_played && !audio_is_playing(snd_intro)) {
		if(is_undefined(global.music)) {
			global.music = audio_play_sound(music_tracks[current_atmosphere], 100, true, 0);
			audio_sound_gain(global.music, MUSIC_LOUDNESS, global.music_change_speed);
		} else {
			if(audio_is_playing(global.music) && !audio_is_playing(music_tracks[current_atmosphere])) {
				audio_sound_gain(global.music, 0, global.music_change_speed);
				if(audio_sound_get_gain(global.music) <= 0.03) {
					audio_stop_sound(global.music);
					global.music = audio_play_sound(music_tracks[current_atmosphere], 100, true, 0);
					audio_sound_gain(global.music, MUSIC_LOUDNESS, global.music_change_speed);
				}
			}
		}
	}
}