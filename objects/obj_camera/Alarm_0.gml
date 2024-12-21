/// @description Speel een muziekje af
// audio_play_sound(snd_intro, 100, false, 0.5);
intro_has_played = true;

with(obj_tile) {
	if(place_meeting(x, y, obj_forest_mask))
		do_not_render = true;
}