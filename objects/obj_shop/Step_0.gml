/// @description Update de shop
if(bounce < 1) {
	can_change_to_shop = true;
	bounce += 1 / 60 * dlt;
	if(bounce >= 1) {
		if(can_change_to_shop) {
			can_change_to_shop = false;
			if(position_meeting(x, y, obj_pawn)) {
				global.game_progress = GAME_PROGRESS.WITH_TRADER;
			}
		}
	}
}
	
bounce			= clamp(bounce, 0, 1);
matrix			= matrix_build(x, y, 0, 0, 0, 130, 1, 1, lerp(0.7, 1, ease_in_out_back(bounce)));
