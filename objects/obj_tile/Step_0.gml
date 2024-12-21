/// @description Maak een geluidje om te laten zien
if(wait_to_show > 0) {
	wait_to_show -= 1 * dlt;
}

if(wait_to_show <= 0 && wait_to_show > -10) {
	wait_to_show = -100;
	audio_play_sound(snd_select_tile, 10, false, 0.25, 0, 2.5);
}