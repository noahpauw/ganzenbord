/// @description Update de gans
matrix		= matrix_build(x, y, z, 0, 0, 0, scale, scale, scale);

// Opslaan van huidige positie
if(move_lerp == 0) {
	last_x = x;
	last_y = y;
}

if(move_lerp < 1) {
	move_lerp += (1 / 60) * dlt;
	move_lerp = clamp(power(move_lerp, 0.97), 0, 1);
	z = abs(dsin(move_lerp * 180)) * 4.2;
	
	x = lerp(cur_x, to_x, move_lerp);
	y = lerp(cur_y, to_y, move_lerp);
	
	// Gaat hij naar een shop?
	if(position_meeting(to_x, to_y, obj_shop)) {
		scale = lerp(1, 0, move_lerp);
	} else {
		if(scale < 1)
			scale = lerp(0, 1, move_lerp);
	}
} else {
	if(can_noise) {
		// Je kunt hier ook een andere gans raken
		var _goose = collision_line(x, y, x, y, obj_pawn, false, true);
		var _shop = collision_line(x, y, x, y, obj_shop, false, true);
		if(_goose) {
			with(_goose) {
				get_player_by_id(current_player_id).hearts--;
			}
			
			audio_play_sound(snd_move_piece, 10, false, 0.8);
			x = instance_nearest(x, y, obj_tile).x;
			y = instance_nearest(x, y, obj_tile).y;
			
			move_lerp = 0;
			
			cur_x = x;
			cur_y = y;
			
			to_x = last_x;
			to_y = last_y;
		} else if(_shop) {
			with(_shop) {
				bounce = 0;
				audio_play_sound(snd_add_heart, 0, false, 1, 0, 0.5);
			}
			can_noise = false;
		} else {
			audio_play_sound(snd_move_piece, 10, false, 0.8);
			can_noise = false;
			x = instance_nearest(x, y, obj_tile).x;
			y = instance_nearest(x, y, obj_tile).y
		}
	}
}

if(global.game_progress > GAME_PROGRESS.GENERATING_ORDER)
	inversion += ( (global.current_player == current_player_id ? 1 : 0) - inversion) / 15 * dlt;
else
	inversion = 0;
