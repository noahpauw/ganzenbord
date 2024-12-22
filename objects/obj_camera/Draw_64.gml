/// @description Teken de surfaces
var _dw, _dh;
_dw = display_get_width();
_dh = display_get_height();

var _use_button = keyboard_check_pressed(vk_space) || gp_pressed(gp_face1, global.current_player);

gpu_set_cullmode(cull_noculling);

if(!surface_exists(surf_blur_hor))
	surf_blur_hor = surface_create(_dw / blur_resolution, _dh / blur_resolution, surface_rgba32float);
	
if(!surface_exists(surf_blur_ver))
	surf_blur_ver = surface_create(_dw / blur_resolution, _dh / blur_resolution, surface_rgba32float);
	
if(!surface_exists(surf_occlusion))
	surf_occlusion = surface_create(_dw, _dh);
	
if(!surface_exists(surf_occlusion_shader))
	surf_occlusion_shader = surface_create(_dw, _dh);
	
// Zodat je de ganzen door bomen ziet
surface_set_target(surf_occlusion);
draw_clear(c_black);

gpu_set_blendmode(bm_add);
with(obj_pawn) {
	var _coords = world_to_screen(x, y, z + 6.5, global.view_mat, global.proj_mat);
	draw_sprite_ext(spr_show_goose, 0, _coords[0], _coords[1], 1.8, 1.8, 0, c_white, 1);
}
gpu_set_blendmode(bm_normal);

surface_reset_target();

surface_set_target(surf_occlusion_shader);
draw_clear(c_black);

shader_set(shd_spots);
texture_set_stage(shader_get_sampler_index(shd_spots, "clouds"), sgt(spr_clouds, 0));
shader_set_uniform_f(shader_get_uniform(shd_spots, "advancement"), current_time / 10100, current_time / 12200);
shader_set_uniform_f(shader_get_uniform(shd_spots, "inversion"), 0);
shader_set_uniform_f(shader_get_uniform(shd_spots, "resolution"), display_get_width(), display_get_height());

draw_surface(surf_occlusion, 0, 0);

shader_reset();

surface_reset_target();

// *************************************************************************************************************

// Zet het surface naar surf_blur_hor
gpu_set_blendmode_ext_sepalpha(bm_src_alpha, bm_inv_src_alpha, bm_src_alpha, bm_one);

surface_set_target(surf_blur_hor);
draw_clear(c_black);

shader_set(shd_post_processing);
shader_set_uniform_f(u_pp_brightness, brightness);
draw_surface_stretched(surf, 0, 0, display_get_width() / blur_resolution, display_get_height() / blur_resolution);
draw_surface_stretched(surf_tree, 0, 0, display_get_width() / blur_resolution, display_get_height() / blur_resolution);
shader_reset();

surface_reset_target();

// Zet het surface naar surf_blur_ver
surface_set_target(surf_blur_ver);
draw_clear(c_black);

shader_set(shd_blur_horizontal);
shader_set_uniform_f(shader_get_uniform(shd_blur_horizontal, "resolution"), display_get_width() / blur_resolution, display_get_height() / blur_resolution);
draw_surface_stretched(surf_blur_hor, 0, 0, display_get_width() / blur_resolution, display_get_height() / blur_resolution);
shader_reset();

surface_reset_target();

// Totaalplaatje
shader_set(shd_blur_vertical);
shader_set_uniform_f(shader_get_uniform(shd_blur_vertical, "resolution"), display_get_width() / blur_resolution, display_get_height() / blur_resolution);
draw_surface_stretched_ext(surf_blur_ver, 0, 0, display_get_width(), display_get_height(), c_white, blur_alpha);
shader_reset();

// Eerste surface
shader_set(shd_post_processing);
shader_set_uniform_f(u_pp_brightness, brightness);
draw_surface_ext(surf, 0, 0, 1, 1, 0, c_white, 1 - blur_alpha);
shader_reset();

shader_set(shd_post_processing_trees);
texture_set_stage(shader_get_sampler_index(shd_post_processing_trees, "spots"), surface_get_texture(surf_occlusion_shader));
shader_set_uniform_f(shader_get_uniform(shd_post_processing_trees, "brightness"), brightness);
shader_set_uniform_f(shader_get_uniform(shd_post_processing_trees, "resolution"), display_get_width(), display_get_height());
draw_surface_ext(surf_tree, 0, 0, 1, 1, 0, c_white, 1 - blur_alpha);
shader_reset();

gpu_set_blendmode(bm_normal);

// Teken een vignette
draw_sprite_ext(spr_vignette, 0, 0, 0, vig_x, vig_y, 0, c_white, 1);

if(global.adding_player) {
	draw_set_font(fnt_title);
	draw_set_halign(fa_center);
	
	var _x, _y, dw, dh;
	dw = display_get_width();
	dh = display_get_height();
	_x = dw / 2;
	_y = dh / 2;

	draw_text_shadow(_x, _y, "Nieuwe speler", c_white, 1);
	
	_y += string_height("M") * 2;
	draw_set_font(fnt_subtitle);
	draw_set_valign(fa_bottom);
	
	var l = string_width(new_player_name);
	
	draw_set_alpha(abs(dsin(current_time / 3)));
	draw_line_color(_x + l / 2, _y, _x + l / 2, _y - string_height("M"), c_ltgray, c_ltgray);
	draw_set_alpha(1);

	draw_line_color(_x - dw / 4, _y, _x + dw / 4, _y, c_ltgray, c_ltgray);
	draw_text_shadow(_x, _y, new_player_name, c_white, 1);
	
	draw_set_halign(fa_center);
	draw_set_valign(fa_middle);
	
	// Een toetsenbord
	_x = _dw / 2;
	_y += 120;
	var _ind = 0;
	
	for(var _i = 0; _i < array_length(global.keyboard); _i++) {
		// Drie rijen toetsen
		var _calc_row_width = 0;
		var _row = global.keyboard[_i];
		for(var _j = 0; _j < array_length(_row); _j++) {
			_calc_row_width += string_width("M") + 8;
		}
		_x = round(_dw / 2 - _calc_row_width / 2);
		for(var _j = 0; _j < array_length(_row); _j++) {
			draw_text(_x, _y, gp_hold(gp_shoulderlb, 0) ? string_upper(_row[_j]) : string_lower(_row[_j]));
			var _w = round(string_width("M") / 2);
			draw_set_alpha(0.3);
			draw_rectangle_color(_x - _w - 8, _y - line() / 2 - 4, _x + _w + 8, _y + line() / 2 + 4, c_white, c_white, c_white, c_white, true);
			
			if(current_letter == _ind) {
				draw_set_alpha(0.2);
				draw_rectangle_color(_x - _w - 8, _y - line() / 2 - 4, _x + _w + 8, _y + line() / 2 + 4, c_white, c_white, c_white, c_white, false);
				
				if(gp_pressed(gp_face1, 0)) {
					new_player_name += gp_hold(gp_shoulderlb, 0) ? string_upper(_row[_j]) : string_lower(_row[_j]);
					audio_play_sound(snd_type, 10, false, 1);
				}
			}
			
			draw_set_alpha(1);
			
			_x += string_width("M") + 16;
			_ind++;
		}
		_y += line() + 8;
	}
	
	draw_set_halign(fa_left);
	draw_set_valign(fa_top);
}

if(!array_contains([GAME_PROGRESS.PICKING_DIE_OR_CARDS, GAME_PROGRESS.PICKING_DIE_OR_CARDS, GAME_PROGRESS.DICE_IS_ROLLING, GAME_PROGRESS.WITH_TRADER], global.game_progress)) {
	for(var _i = 0; _i < ds_list_size(global.players); _i++) {
		var _player = ds_list_find_value(global.players, _i);
		draw_set_font(fnt_subtitle);
		draw_set_halign(fa_left);
		draw_set_valign(fa_top);
	
		var _x, _y;
		_x = round(_player.name_x);
		_y = round(_player.name_y);
	
		_player.inversion += ((global.current_player == _i ? 1 : 0) - _player.inversion) / 15 * dlt;
	
		shader_set(shd_name_trail);
		texture_set_stage(shader_get_sampler_index(shd_name_trail, "clouds"), sgt(spr_clouds, 0));
		shader_set_uniform_f(shader_get_uniform(shd_name_trail, "advancement"), current_time / 10100, current_time / 12200);
		shader_set_uniform_f(shader_get_uniform(shd_name_trail, "inversion"), _player.inversion);
		draw_sprite_ext(spr_name_trail, 0, _x + string_width(_player.name) / 2 + (12 * _player.hearts), _y + line() / 2, (string_width(_player.name) + 72) / 98, 1, 0, c_white, clamp(cloud_alpha, 0, 1) * 0.85);
		shader_reset();
	
		draw_text_shadow(_x, _y, _player.name, c_white, 1);
		
		_x += string_width(_player.name) + 26;
		
		for(var _j = 0; _j < _player.hearts; _j++) {
			var _beat_x = lerp(0.9, 1.1, power(abs(dcos(current_time / 6 + _player.beat_offset[_j])), 8));
			var _beat_y = lerp(0.92, 1.05, power(abs(dsin(current_time / 6 - 40 + _player.beat_offset[_j])), 8));
			var _s = lerp(0, 1, ease_in_out_back(_player.beat_size[_j]));
			draw_sprite_ext(spr_heart, 0, _x, _y + line() / 2 + dsin(current_time / 1000 * 180 + _player.beat_offset[_j]), _beat_x * _s, _beat_y * _s, 0, c_white, 1);
			_x += 24;
		}
		_x += 24;
		draw_sprite_ext(spr_feather_currency, 0, _x, _y + line() / 2, 0.5 + perlin_noise(current_time / 630 + _i * 29) * 0.1, 0.5 + perlin_noise(current_time / 422 + _i * 32) * 0.1, perlin_noise(current_time / 494 + _i * 16) * 5, c_white, 1);
		_x += 24;
		draw_text(_x, _y, string("×{0}", _player.feathers));
	
		draw_set_halign(fa_left);
		draw_set_valign(fa_top);
	}
}

if(!array_contains([GAME_PROGRESS.PICKING_DIE_OR_CARDS, GAME_PROGRESS.PICKING_DIE_OR_CARDS, GAME_PROGRESS.GENERATING_ORDER, GAME_PROGRESS.DICE_IS_ROLLING, GAME_PROGRESS.WITH_TRADER], global.game_progress)) {
	with(obj_pawn) {
		var _x, _y, _coords;
		_coords = world_to_screen(x, y, z + 10, global.view_mat, global.proj_mat);
		_x = round(_coords[0]);
		_y = round(_coords[1]);
	
		var _goose = ds_list_find_value(global.players, current_player_id);
		var _color = global.color_players[current_player_id];
		
		shader_set(shd_name_trail);
		texture_set_stage(shader_get_sampler_index(shd_name_trail, "clouds"), sgt(spr_clouds, 0));
		shader_set_uniform_f(shader_get_uniform(shd_name_trail, "advancement"), current_time / 10100, current_time / 12200);
		shader_set_uniform_f(shader_get_uniform(shd_name_trail, "inversion"), inversion);
		draw_sprite_ext(spr_name_trail, 0, _x, _y + line(fnt_subtitle) / 2, string_width(_goose.name) / 98, 1, 0, c_white, 1 - inversion * 0.15);
		shader_reset();
		
		draw_set_halign(fa_center);
		draw_text_shadow(_x, _y, _goose.name, _color, 1);
		draw_set_halign(fa_left);
	}
}

// Mogelijkheden tonen
if(global.game_progress == GAME_PROGRESS.ROLLING_DIE) {
	var _x, _y;
	_x = display_get_width() / 3;
	_y = display_get_height() - 100;
	
	var _player = get_current_player();
	var _str = string("{0} gooien", dice_types[_player.current_dice].title);
	var _alpha = 1;
	
	if(!_player.can_throw_dice) {
		_str = "Naar tegel";
		if(_player.move_lerp < 1)
			_alpha = 0.5;
	}
	
	if(!_player.can_throw_dice && ds_list_size(global.available_tiles) == 0 && _player.move_lerp >= 1)
		_str = "Volgende beurt";
	
	shader_set(shd_name_trail);
	texture_set_stage(shader_get_sampler_index(shd_name_trail, "clouds"), sgt(spr_clouds, 0));
	shader_set_uniform_f(shader_get_uniform(shd_name_trail, "advancement"), current_time / 10100, current_time / 12200);
	shader_set_uniform_f(shader_get_uniform(shd_name_trail, "inversion"), 0);
	
	draw_sprite_ext(spr_name_trail, 0, _x + 59 + string_width(_str) / 2, _y, string_width(_str) / 98, 1, 0, c_white, _alpha);
	
	shader_reset();
	
	draw_sprite_ext(spr_ps4_face_buttons, 0, _x, _y, 1, 1, 0, c_white, _alpha);
	_x += 59;
	
	draw_set_valign(fa_middle);
	
	draw_text_color(_x, _y, _str, c_white, c_white, c_white, c_white, _alpha);
	
	_x += string_width(_str) + 50;
	_str = "Inventaris";
	
	shader_set(shd_name_trail);
	texture_set_stage(shader_get_sampler_index(shd_name_trail, "clouds"), sgt(spr_clouds, 0));
	shader_set_uniform_f(shader_get_uniform(shd_name_trail, "advancement"), current_time / 10100, current_time / 12200);
	shader_set_uniform_f(shader_get_uniform(shd_name_trail, "inversion"), 0);
	
	draw_sprite_ext(spr_name_trail, 0, _x + 59 + string_width(_str) / 2, _y, string_width(_str) / 98, 1, 0, c_white, 1);
	
	shader_reset();
	
	draw_sprite(spr_ps4_face_buttons, 3, _x, _y);
	_x += 59;
	
	draw_set_valign(fa_middle);
	
	draw_text_color(_x, _y, "Inventaris", c_white, c_white, c_white, c_white, 1);
	
	draw_sprite_ext(spr_ui_cursor, 0, global.cursor_x, global.cursor_y, 1, 1, -current_time / 8, c_white, 1);
	
	draw_set_valign(fa_top);
} else if(global.game_progress == GAME_PROGRESS.PRE_MENU) {
	// gpu_set_blendmode(bm_add);
	
	shader_set(shd_flame_2d);
	shader_set_uniform_f(u_flame_2d_time, current_time / 600);
	shader_set_uniform_f(u_flame_2d_alpha, 1);
	shader_set_uniform_f(u_flame_2d_intensity, menu_intensity);
	shader_set_uniform_f(u_flame_2d_cloud_size, 1500);
	shader_set_uniform_f(u_flame_2d_threshold, menu_intensity);
	texture_set_stage(u_flame_2d_cloud, sgt(spr_clouds, 0));
	
	draw_sprite_ext(spr_main_logo, 0, _dw / 2, _dh / 2, 0.7, -0.7, 0, c_white, 1);
	
	shader_reset();
	
	var _x, _y;
	_x = _dw / 2;
	_y = _dh / 2;
	
	var _alpha = lerp(0.5, 1, (dsin(current_time / 3)) / 2 + 0.5) * menu_fade_in;
	
	_x -= 59 + string_height("Beginnen");
	_y += sprite_get_height(spr_main_logo) / 2;
	draw_sprite_ext(spr_ps4_face_buttons, PS4_BUTTONS.CROSS, _x, _y, 1, 1, 0, c_white, _alpha);
	_x += 59;
	draw_text_color(_x, _y - line() / 2, "Beginnen", c_white, c_white, c_white, c_white, _alpha);
} else if(global.game_progress == GAME_PROGRESS.DICE_IS_ROLLING) {
	var _str = "Gooien";
	var _alpha = throwing ? 0.5 : 1;
	
	var _x, _y;
	_x = display_get_width() / 2 - (string_width("Gooien") + 168 + string_width("Annuleren")) / 2;
	_y = display_get_height() - 100;
	
	shader_set(shd_name_trail);
	texture_set_stage(shader_get_sampler_index(shd_name_trail, "clouds"), sgt(spr_clouds, 0));
	shader_set_uniform_f(shader_get_uniform(shd_name_trail, "advancement"), current_time / 10100, current_time / 12200);
	shader_set_uniform_f(shader_get_uniform(shd_name_trail, "inversion"), 0);
	
	draw_sprite_ext(spr_name_trail, 0, _x + 59 + string_width(_str) / 2, _y, string_width(_str) / 98, 1, 0, c_white, _alpha);
	
	shader_reset();
	
	draw_sprite_ext(spr_ps4_face_buttons, 0, _x, _y, 1, 1, 0, c_white, _alpha);
	_x += 59;
	
	draw_set_valign(fa_middle);
	
	draw_text_color(_x, _y, _str, c_white, c_white, c_white, c_white, _alpha);
	
	_x += string_width("Gooien") + 50;
	_str = "Annuleren";
	
	shader_set(shd_name_trail);
	texture_set_stage(shader_get_sampler_index(shd_name_trail, "clouds"), sgt(spr_clouds, 0));
	shader_set_uniform_f(shader_get_uniform(shd_name_trail, "advancement"), current_time / 10100, current_time / 12200);
	shader_set_uniform_f(shader_get_uniform(shd_name_trail, "inversion"), 0);
	
	draw_sprite_ext(spr_name_trail, 0, _x + 59 + string_width(_str) / 2, _y, string_width(_str) / 98, 1, 0, c_white, _alpha);
	
	shader_reset();
	
	draw_sprite_ext(spr_ps4_face_buttons, 3, _x, _y, 1, 1, 0, c_white, _alpha);
	_x += 59;
	
	draw_set_valign(fa_middle);
	
	draw_text_color(_x, _y, "Annuleren", c_white, c_white, c_white, c_white, _alpha);
	
	_x += string_width("Annuleren");
	
	draw_set_valign(fa_top);
} else if(global.game_progress == GAME_PROGRESS.PICKING_DIE_OR_CARDS) {
	var _player = get_current_player_in_list();
	var _player_pawn = get_current_player();
	
	var _x, _y;
	_x = 129;
	_y = 129;
	
	var _title = inventory_type == INVENTORY_TYPES.DICE ? "Dobbelstenen" : "Kaarten";
	
	draw_set_font(fnt_title);
	draw_text_color(_x, _y, _title, c_white, c_white, c_ltgray, c_ltgray, fade_inventory3);
	
	_y = 417;
	
	var _cen_x, _cen_y;
	_cen_x = display_get_width() / 2;
	_cen_y = display_get_height() / 2;
	
	var _offset, _offset2;
	_offset = lerp(-60, 0, fade_inventory);
	_offset2 = lerp(-80, 0, fade_inventory2);
	
	var _s = ease_in_out_back(fade_inventory);
	var _s2 = ease_in_out_back(fade_inventory2);
	var _s3 = ease_in_out_back(fade_inventory3);
	
	if(inventory_type == INVENTORY_TYPES.DICE) {
		var d = dice_types[current_inventory];
	
		draw_text_transformed_color(_x + _offset, _y, d.title, _s, _s, 0, c_white, c_white, c_ltgray, c_ltgray, fade_inventory);
		_y += line() * 1.5;
		draw_set_font(fnt_subtitle);
		draw_text_ext_transformed_color(_x + _offset2, _y, d.description, string_height("M"), 600, _s2, _s2, 0, c_white, c_white, c_ltgray, c_ltgray, fade_inventory2);
	
		draw_sprite_ext(spr_dice_previews, current_inventory, _cen_x + _offset2 + sprite_get_width(spr_dice_previews) / 2, _cen_y, _s2, _s2, 0, c_white, fade_inventory2);
		
		// Knoppen om te kiezen
		draw_set_font(fnt_subtitle);
		
		_x = 129;
		_y = display_get_height() - 96;
		
		draw_sprite(spr_ps4_face_buttons, PS4_BUTTONS.CROSS, _x, _y);
		
		_x += 37;
		draw_text_color(_x, _y - line() / 2, "Kiezen", c_white, c_white, c_white, c_white, 1);
		
		_x += string_width("Kiezen") + 50;
		draw_sprite(spr_ps4_face_buttons, PS4_BUTTONS.TRIANGLE, _x, _y);
		
		_x += 37;
		draw_text_color(_x, _y - line() / 2, "Sluiten", c_white, c_white, c_white, c_white, 1);
		
		_x += string_width("Sluiten") + 50;
		draw_sprite(spr_ps4_face_buttons, PS4_BUTTONS.DPAD_VER, _x, _y);
		
		_x += 37;
		draw_text_color(_x, _y - line() / 2, "Wisselen", c_white, c_white, c_white, c_white, 1);
		
		_x += string_width("Wisselen") + 50;
		draw_sprite(spr_ps4_face_buttons, PS4_BUTTONS.L1, _x, _y);
		_x += 63;
		draw_sprite(spr_ps4_face_buttons, PS4_BUTTONS.R1, _x, _y);
		_x += 37;
		
		draw_text_color(_x, _y - line() / 2, "Kaarten", c_white, c_white, c_white, c_white, 1);
	} else {
		var d = {
			title: "Lege kaart",
			description: "Vrije ruimte voor een kaart",
		};
		
		if(current_inventory < array_length(_player.cards)) {
			d = card_descriptions[_player.cards[current_inventory]];
		}
	
		draw_text_transformed_color(_x + _offset, _y, d.title, _s, _s, 0, c_white, c_white, c_ltgray, c_ltgray, fade_inventory);
		_y += line() * 1.5;
		draw_set_font(fnt_subtitle);
		draw_text_ext_transformed_color(_x + _offset2, _y, d.description, string_height("M"), 600, _s2, _s2, 1, c_white, c_white, c_ltgray, c_ltgray, fade_inventory2);
		
		_x = _cen_x + 107.5;
		_y = _cen_y - (307 / 2);
		for(var _i = 0; _i < 8; _i++) {
			var _active_rot = 0;
			var _active = 0.5;
			if(current_inventory == _i) {
				_active = lerp(0.8, 1, abs(dcos(current_time / 8)));
				_active_rot = dcos(current_time / 7) * 3;
			}
			if(_i < array_length(_player.cards))
				draw_sprite_ext(card_width[_i] < 0.5 ? spr_cards : spr_undiscovered_card, _player.cards[_i], _x, _y, lerp(1, -1, ease_in_out_back(card_width[_i])) * _s3, _s3, _active_rot, c_white, fade_inventory3 * _active);
			else
				draw_sprite_ext(spr_undiscovered_card, 0, _x, _y, _s3, _s3, _active_rot, c_white, fade_inventory3 * _active);
				
			_x += 215 + 24;
			if(_i == 3) {
				_x = _cen_x + 107.5;
				_y += 307 + 24;
			}
		}
		
		var _can_use = 0.5;
		
		if(current_inventory < array_length(_player.cards)) {
			if(use_after_throw[_player.cards[current_inventory]] && !_player_pawn.can_throw_dice && ds_list_size(global.available_tiles)) {
				_can_use = 1;
			}
			
			if(use_after_move[_player.cards[current_inventory]] && !_player_pawn.can_throw_dice && !ds_list_size(global.available_tiles)) {
				_can_use = 1;
			}
			
			// Toch terugzetten als je er niks aan hebt
			if(is_unusable[_player.cards[current_inventory]])
				_can_use = 0.5;
		}
		
		if(_use_button) {
			if(_can_use && card_animation == -1 && card_width[current_inventory] == 0) {
				audio_play_sound(snd_menu_select, 1, 0, 1);
				audio_play_sound(snd_use_card, 1, 0, 0.25);
				card_animation = current_inventory;
				global.last_card_picked = _player.cards[current_inventory];
			}
		}
		
		// Knoppen om te kiezen
		draw_set_font(fnt_subtitle);
		
		_x = 129;
		_y = display_get_height() - 96;
		
		draw_sprite_ext(spr_ps4_face_buttons, PS4_BUTTONS.CROSS, _x, _y, 1, 1, 0, c_white, _can_use);
		
		_x += 37;
		draw_text_color(_x, _y - line() / 2, "Gebruiken", c_white, c_white, c_white, c_white, _can_use);
		
		_x += string_width("Gebruiken") + 50;
		draw_sprite(spr_ps4_face_buttons, PS4_BUTTONS.TRIANGLE, _x, _y);
		
		_x += 37;
		draw_text_color(_x, _y - line() / 2, "Sluiten", c_white, c_white, c_white, c_white, 1);
		
		_x += string_width("Sluiten") + 50;
		draw_sprite(spr_ps4_face_buttons, PS4_BUTTONS.DPAD_FULL, _x, _y);
		
		_x += 37;
		draw_text_color(_x, _y - line() / 2, "Wisselen", c_white, c_white, c_white, c_white, 1);
		
		_x += string_width("Wisselen") + 50;
		draw_sprite(spr_ps4_face_buttons, PS4_BUTTONS.L1, _x, _y);
		_x += 63;
		draw_sprite(spr_ps4_face_buttons, PS4_BUTTONS.R1, _x, _y);
		_x += 37;
		
		draw_text_color(_x, _y - line() / 2, "Dobbelstenen", c_white, c_white, c_white, c_white, 1);
		_x += string_width("Dobbelstenen") + 50;
		
		draw_sprite(spr_ps4_face_buttons, PS4_BUTTONS.CIRCLE, _x, _y);
		_x += 37;
		draw_text_color(_x, _y - line() / 2, "Weggooien", c_white, c_white, c_white, c_white, current_inventory < array_length(_player.cards) ? 1 : 0.5);
	}
} else if(global.game_progress == GAME_PROGRESS.WITH_TRADER) {
	var _flicker = lerp(-0.09, 0, perlin_noise(current_time / 200) / 2 + 0.5);
	
	// De kaars
	if(brightness > 0.9) {
		shader_set(shd_brightness);
		shader_set_uniform_f(u_brightness_brightness, candle_brightness + _flicker);
		draw_sprite(spr_shop_candle, 0, _dw / 2, _dh / 2);
		shader_reset();
	}
	
	// Teken de vlam van de kaars
	gpu_set_blendmode(bm_add);
	
	shader_set(shd_flame_2d);
	shader_set_uniform_f(u_flame_2d_time, current_time / 1000);
	shader_set_uniform_f(u_flame_2d_alpha, flame_alpha + _flicker);
	texture_set_stage(u_flame_2d_cloud, sgt(spr_clouds, 0));
	shader_set_uniform_f(u_flame_2d_intensity, 1);
	shader_set_uniform_f(u_flame_2d_cloud_size, 5000);
	shader_set_uniform_f(u_flame_2d_threshold, 0);
	matrix_set(matrix_world, matrix_build(_dw / 2 - 8, _dh / 2 - 108, 0, 0, 0, 0, 244, 244, 1));
	vertex_submit(global.__plane_16, pr_trianglelist, sgt(spr_candle_flame, 0));
	matrix_set(matrix_world, matrix_build_identity());
	shader_reset();
	
	gpu_set_blendmode(bm_normal);
	
	var _offset = lerp(-60, 0, fade_inventory);
	var _offset2 = lerp(-80, 0, fade_inventory2);
	
	var _s = ease_in_out_back(fade_inventory);
	var _s2 = ease_in_out_back(fade_inventory2);
	
	// Teken de status van deze speler
	var _x = 129;
	var _y = 89;
	var _player = get_current_player_in_list();
	
	draw_set_font(fnt_title);
	
	if(!obj_vendor.is_leaving) {
		draw_text_shadow(_x, _y, _player.name, c_white, 1);
		_y += line(fnt_title);
	
		draw_set_font(fnt_subtitle);
		draw_sprite_ext(spr_feather_currency, 0, _x, _y, 1 + perlin_noise(current_time / 630) * 0.2, 1 + perlin_noise(current_time / 433) * 0.2, 0, c_white, 1);
		_x += 26.5;
		draw_text_color(_x, _y - line() / 2, "×" + string(_player.feathers), c_white, c_white, c_white, c_white, 1);
	
		_x += 100;
		draw_sprite_ext(spr_heart, 0, _x, _y, 1 + perlin_noise(current_time / 630) * 0.2, 1 + perlin_noise(current_time / 433) * 0.2, 0, c_white, 1);
		_x += 19;
		draw_text_color(_x, _y - line() / 2, "×" + string(_player.hearts), c_white, c_white, c_white, c_white, 1);
	}
	
	// Teken ook de kaarten die hij heeft
	with(obj_vendor) {
		if(instance_exists(obj_camera)) {
			var _x = 129;
			var _y = _dh / 2.5;
		
			// Kaarten in rij
			if(obj_vendor.purchased_card_type == -1) {
				for(var _i = 0; _i < array_length(cards_in_stock); _i += 1) {
					var __x = 400 - lerp(from_x, to_x, ease_in_out_back(movement)) + _i * 215;
					var __y = _y;
					var _in_view = power(lerp(1, 0, min(point_distance(400, 0, __x, 0) / 500, 1)), 1.5);
				
					if(haggle_index == _i) {
						__x = lerp(400, _dw / 2, ease_in_out_back(haggle_movement));
						__y = lerp(_dh / 2.5, _dh / 2, ease_in_out_back(haggle_movement));
					}
				
					var __in_view_scale = lerp(0.75, 1, _in_view);
					var _alpha_mult = 1;
					if(haggle_index != -1 && haggle_index != _i)
						_alpha_mult = lerp(1, 0, haggle_movement);
					
					draw_sprite_ext(spr_cards, cards_in_stock[_i], __x, __y, __in_view_scale + perlin_noise(current_time / 823 + _i * 16) * 0.02, __in_view_scale + perlin_noise(current_time / 766 + _i * 16) * 0.01, perlin_noise(current_time / 601 + _i * 16) * 1.7, c_white, _in_view * obj_camera.flame_alpha * _alpha_mult);
					
					if(haggle_index != -1 && haggle_index == _i) {
						shader_set(shd_card);
						shader_set_uniform_f(shader_get_uniform(shd_card, "alpha"), haggle_movement);
						shader_set_uniform_f(shader_get_uniform(shd_card, "flame_intensity"), 1 - _flicker);
						gpu_set_blendmode_ext(bm_dest_colour, bm_zero);
						draw_sprite_ext(spr_card_candle, 0, __x, __y,  __in_view_scale + perlin_noise(current_time / 823 + _i * 16) * 0.02, __in_view_scale + perlin_noise(current_time / 766 + _i * 16) * 0.01, perlin_noise(current_time / 601 + _i * 16) * 1.7, c_white, 1);
						gpu_set_blendmode(bm_normal);
						shader_reset();
					}
				}
		
				_y = lerp(_dh / 2.5 + 153.5 + line(), _dh / 2.5 - 76.5, ease_in_out_back(haggle_movement));
		
				var _card = obj_camera.card_descriptions[cards_in_stock[current_card_index]];
		
				draw_set_font(fnt_title);
				draw_text_transformed_color(_x + _offset, _y, _card.title, _s, _s, 0, c_white, c_white, c_ltgray, c_ltgray, obj_camera.fade_inventory * obj_camera.flame_alpha);
			
				_x += string_width(_card.title + ": ");
				_y += line() / 2;
			
				draw_set_font(fnt_subtitle);
				draw_sprite_ext(spr_feather_currency, 0, _x, _y, 1 + perlin_noise(current_time / 610) * 0.2, 1 + perlin_noise(current_time / 443) * 0.2, 0, c_white, obj_camera.fade_inventory2 * obj_camera.flame_alpha);
				_x += 26.5;
				_y -= line() / 2;
				draw_text_ext_transformed_color(_x + _offset2, _y, string("×{0}", _card.cost), string_height("M"), 600, _s2, _s2, 1, c_white, c_white, c_ltgray, c_ltgray, obj_camera.fade_inventory2 * obj_camera.flame_alpha);
			
				_x = 129;
				_y += line(fnt_title) / 1.5;
				draw_set_font(fnt_subtitle);
				draw_text_ext_transformed_color(_x + _offset2, _y, _card.description, string_height("M"), 600, _s2, _s2, 1, c_white, c_white, c_ltgray, c_ltgray, obj_camera.fade_inventory2 * obj_camera.flame_alpha);
			
				// Keihard afdingen
				if(obj_camera.current_atmosphere == ATMOSPHERE.HAGGLING) {
					_x = _dw / 2;
					_y = _dh - 260;
					
					var _alpha = made_bid ? 0.5 : 1;
				
					shader_set(shd_brightness);
					shader_set_uniform_f(obj_camera.u_brightness_brightness, _flicker + bidding_not_possible);
					
					draw_sprite_ext(spr_counter_left, offered_left, _x, _y, 1, 1, 0, c_white, 1);
					draw_sprite_ext(spr_counter_right, offered_right, _x, _y, 1, 1, 0, c_white, 1);
					
					shader_reset();
				}
				// draw_sprite_ext(spr_feather_currency, 0, _x, _y, 1.5 + perlin_noise(current_time / 610) * 0.2, 1.5 + perlin_noise(current_time / 443) * 0.2, 0, c_white, obj_camera.fade_inventory2 * obj_camera.flame_alpha * haggle_movement);
				// _x += 26.5 * 1.5;
				// draw_text_color(_x, _y - line() / 1.5, string("×{0} | ×{1}", offered_price, current_item_price), c_white, c_white, c_white, c_white, 1 * haggle_movement);
			}
			
			// Feng
			_x = 1512;
			_y = 399;
			
			// Feng's ogen
			gpu_set_ztestenable(false);
			
			// gpu_set_blendenable(false);
			shader_set(shd_passthrough);
			shader_set_uniform_f(shader_get_uniform(shd_passthrough, "invert_x"), 1);
			shader_set_uniform_f(shader_get_uniform(shd_passthrough, "alpha"), 1);
			shader_set_uniform_f(shader_get_uniform(shd_passthrough, "brightness"), 0);
			
			matrix_set(matrix_world, matrix_build(_x, _y, -100, eye_rot_x, eye_rot_y, 0, 200, 200, 200));
			vertex_submit(global.__feng_eye, pr_trianglelist, sgt(tex_feng_eye, eye_slits));
			matrix_set(matrix_world, matrix_build_identity());
			
			shader_set_uniform_f(shader_get_uniform(shd_passthrough, "brightness"), obj_camera.candle_brightness);
			
			// Eye lids
			matrix_set(matrix_world, matrix_build(_x, _y + lerp(-140, -100, blink), -4, 0, 0, 0, 200, 200, 200));
			vertex_submit(global.__plane_16, pr_trianglelist, sgt(spr_black, 0));
			matrix_set(matrix_world, matrix_build_identity());
			
			matrix_set(matrix_world, matrix_build(_x, _y + lerp(140, 100, blink), -4, 0, 0, 0, 200, 200, 200));
			vertex_submit(global.__plane_16, pr_trianglelist, sgt(spr_black, 0));
			matrix_set(matrix_world, matrix_build_identity());
			
			matrix_set(matrix_world, matrix_build(_x, _y, -4, 0, 0, 0, 273, 273, 273));
			vertex_submit(global.__plane_16, pr_trianglelist, sgt(spr_feng_eye_socket, 0));
			matrix_set(matrix_world, matrix_build_identity());
			
			shader_set_uniform_f(shader_get_uniform(shd_passthrough, "brightness"), 0);
			
			gpu_set_blendmode(bm_add);
			shader_set_uniform_f(shader_get_uniform(shd_passthrough, "alpha"), max(0.3 + _flicker * 4, 0));
			matrix_set(matrix_world, matrix_build(_x, _y, -1, 0, 0, 0, 273, 273, 273));
			vertex_submit(global.__plane_16, pr_trianglelist, sgt(spr_feng_eye_socket, 0));
			matrix_set(matrix_world, matrix_build_identity());
			
			shader_set_uniform_f(shader_get_uniform(shd_passthrough, "alpha"), 1);
			gpu_set_blendmode(bm_normal);
			
			
			// Andere oog
			_x -= 249;
			shader_set_uniform_f(shader_get_uniform(shd_passthrough, "alpha"), 1);
			
			matrix_set(matrix_world, matrix_build(_x, _y, -100, eye_rot_x, eye_rot_y + 15, 0, 200, 200, 200));
			vertex_submit(global.__feng_eye, pr_trianglelist, sgt(tex_feng_eye, eye_slits));
			matrix_set(matrix_world, matrix_build_identity());
			
			shader_set_uniform_f(shader_get_uniform(shd_passthrough, "brightness"), obj_camera.candle_brightness);
			
			// Eye lids
			matrix_set(matrix_world, matrix_build(_x, _y + lerp(-140, -100, blink), -4, 0, 0, 0, 200, 200, 200));
			vertex_submit(global.__plane_16, pr_trianglelist, sgt(spr_black, 0));
			matrix_set(matrix_world, matrix_build_identity());
			
			matrix_set(matrix_world, matrix_build(_x, _y + lerp(140, 100, blink), -4, 0, 0, 0, 200, 200, 200));
			vertex_submit(global.__plane_16, pr_trianglelist, sgt(spr_black, 0));
			matrix_set(matrix_world, matrix_build_identity());
			
			shader_set_uniform_f(shader_get_uniform(shd_passthrough, "invert_x"), -1);
			matrix_set(matrix_world, matrix_build(_x, _y, -4, 0, 0, 0, 273, 273, 273));
			vertex_submit(global.__plane_16, pr_trianglelist, sgt(spr_feng_eye_socket, 0));
			matrix_set(matrix_world, matrix_build_identity());
			
			shader_set_uniform_f(shader_get_uniform(shd_passthrough, "brightness"), 0);
			
			gpu_set_blendmode(bm_add);
			shader_set_uniform_f(shader_get_uniform(shd_passthrough, "alpha"), max(0.3 + _flicker * 4, 0));
			matrix_set(matrix_world, matrix_build(_x, _y, -1, 0, 0, 0, 273, 273, 273));
			vertex_submit(global.__plane_16, pr_trianglelist, sgt(spr_feng_eye_socket, 0));
			matrix_set(matrix_world, matrix_build_identity());
			
			shader_set_uniform_f(shader_get_uniform(shd_passthrough, "alpha"), 1);
			shader_set_uniform_f(shader_get_uniform(shd_passthrough, "invert_x"), 1);
			
			// Snuit
			shader_set_uniform_f(shader_get_uniform(shd_passthrough, "brightness"), -0.25 + obj_camera.candle_brightness + _flicker);
			
			matrix_set(matrix_world, matrix_build(_x + 129.5, _y + 170, -0.5, 0, 0, 0, 373, 373, 373));
			vertex_submit(global.__plane_16, pr_trianglelist, sgt(spr_feng_snout, feng_maw_open));
			
			shader_set_uniform_f(shader_get_uniform(shd_passthrough, "brightness"), 0);
			
			// Oogglans
			shader_set_uniform_f(shader_get_uniform(shd_passthrough, "alpha"), lerp(1, 0, power(blink, 1.5)));
			matrix_set(matrix_world, matrix_build(_x + 249, _y, -1, 0, 0, 0, 273 * 2, 273 * 2, 273 * 2));
			vertex_submit(global.__plane_16, pr_trianglelist, sgt(tex_feng_eye, 1 + eye_slits));
			matrix_set(matrix_world, matrix_build_identity());
			
			matrix_set(matrix_world, matrix_build(_x, _y, -1, 0, 0, 0, 273 * 2, 273 * 2, 273 * 2));
			vertex_submit(global.__plane_16, pr_trianglelist, sgt(tex_feng_eye, 1 + eye_slits));
			matrix_set(matrix_world, matrix_build_identity());
			shader_set_uniform_f(shader_get_uniform(shd_passthrough, "alpha"), 1);
			gpu_set_blendmode(bm_normal);
			
			shader_reset();
			gpu_set_ztestenable(true);
			// gpu_set_blendenable(true);
			
			/*
			gpu_set_blendmode(bm_add);
			draw_sprite_ext(spr_feng_eye_socket, 1, _x, _y, 1, 1, 0, c_white, obj_camera.flame_alpha);
			gpu_set_blendmode(bm_normal);
			*/
			
			if(purchased_card_type != -1)
				draw_sprite_ext(purchased_card_alpha < 0.5 ? spr_cards : spr_undiscovered_card, purchased_card_type, _dw / 2, _dh / 2, lerp(1, -1, ease_in_out_back(min(purchased_card_alpha, 1))) * (1 + purchased_card_alpha * 0.02), 1 + purchased_card_alpha * 0.02, 0, c_white, 1);
				
			// Je hebt een kaart gekregen
			draw_set_alpha(random_card_alpha * 0.87);
			draw_rectangle_color(0, 0, _dw, _dh, c_black, c_black, c_black, c_black, false);
			draw_set_alpha(1);
			
			draw_set_halign(fa_center);
			draw_set_valign(fa_middle);
			
			draw_text_color(_dw / 2, _dh / 2, "Feng heeft je een extra kaart gegeven.", c_white, c_white, c_white, c_white, random_card_alpha);
			
			draw_set_halign(fa_left);
			draw_set_valign(fa_top);
		}
		
		// Controls
		_x = _dw / 2;
		_y = display_get_height() - 100;
		var _options = [];
		
		if(!is_leaving) {
			if(obj_camera.current_atmosphere == ATMOSPHERE.IN_SHOP) {
				_options[0] = {
					prompt: "Bieden",
					button: PS4_BUTTONS.CROSS,
				};
				_options[1] = {
					prompt: "Verlaten",
					button: PS4_BUTTONS.TRIANGLE,
				}
			} else {
				_options[0] = {
					prompt: "Bod doen",
					button: PS4_BUTTONS.CROSS,
				};
				_options[1] = {
					prompt: "Bod aanpassen",
					button: PS4_BUTTONS.DPAD_FULL,
				};
				_options[2] = {
					prompt: "Annuleren",
					button: PS4_BUTTONS.TRIANGLE,
				}
			}
		}
		
		for(var _i = 0; _i < array_length(_options); _i++) {
			_x -= string_width(_options[_i].prompt) / 2 + 25;
			_x -= 37 / 2;
		}
		
		for(var _i = 0; _i < array_length(_options); _i++) {
			draw_sprite_ext(spr_ps4_face_buttons, _options[_i].button, _x, _y, 1, 1, 0, c_white, 1);
			_x += 37;
			draw_text_color(_x, _y - line() / 2, _options[_i].prompt, c_white, c_white, c_white, c_white, 1);
			_x += string_width(_options[_i].prompt) + 50;
		}
		
		// Feng's klauwen
		draw_sprite_ext(spr_feng_claws, feng_strike, _dw / 2, _dh / 2, -1, 1, 0, c_white, feng_claw_alpha);
		
		shader_set(shd_hurt);
		draw_sprite_ext(spr_vignette, 0, 0, 0, _dw / 512, _dh / 512, 0, c_white, hurt_alpha);
		shader_reset();
	}
}

// Dobbelsteen tekenen
if(global.game_progress == GAME_PROGRESS.DICE_IS_ROLLING) {
	var _dice_fade_in = max(ease_in_out_back(dice_fade_in), 0);
	shader_set(shd_gamma_correction);
	draw_surface_ext(surf_dice, lerp(_dw / 2, 0, _dice_fade_in), lerp(_dh / 2, 0, _dice_fade_in), _dice_fade_in, _dice_fade_in, 0, c_white, 1);
	shader_reset();
	
	// draw_text(96, 96, string("Rotation x: {0}\nRotation y: {1}\nRotation z: {2}", dice_rotation_x, dice_rotation_y, dice_rotation_z));
}

// draw_text(32, 32, string("z: {0}, distance: {1}", z, cam_distance));
gpu_set_cullmode(cull_clockwise);