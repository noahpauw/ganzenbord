/// @description Plaats de speler in de kamer. Ook voor speciale camera's
var _add_player_button = keyboard_check_pressed(vk_enter) || gp_pressed(gp_face4, global.current_player);
var _continue_button = keyboard_check_pressed(vk_f1) || gp_pressed(gp_start, global.current_player);
var _selection_up_button = keyboard_check_pressed(vk_up) || gp_pressed(gp_padu, global.current_player); 
var _inventory_button = keyboard_check_pressed(vk_f5) || gp_pressed(gp_face4, global.current_player); 
var _action_button = keyboard_check_pressed(vk_space) || mouse_check_button_pressed(mb_left) || gp_pressed(gp_face1, global.current_player);
var _switch_inventory = keyboard_check_pressed(ord("7")) || keyboard_check_pressed(ord("8")) || gp_pressed(gp_shoulderl, global.current_player) || gp_pressed(gp_shoulderr, global.current_player);

// Scrollen
var _scroll_left = keyboard_check_pressed(vk_left) || gp_pressed(gp_padl, global.current_player);
var _scroll_right = keyboard_check_pressed(vk_right) || gp_pressed(gp_padr, global.current_player);
var _scroll_up = keyboard_check_pressed(vk_up) || gp_pressed(gp_padu, global.current_player);
var _scroll_down = keyboard_check_pressed(vk_down) || gp_pressed(gp_padd, global.current_player);
var _circle = keyboard_check_pressed(ord("B")) || gp_pressed(gp_face2, global.current_player);

dlt = clamp(60 / 1000000 * delta_time, 0.2, 5);

// Bepalen waar de cursor is
if(!gamepad_is_connected(4)) {
	global.cursor_x = mouse_x;
	global.cursor_y = mouse_y;
} else {
	global.cursor_x += gp_axis(gp_axislh, 0) * 15 * dlt;
	global.cursor_y += gp_axis(gp_axislv, 0) * 15 * dlt;
}

global.cursor_x = clamp(global.cursor_x, 0, display_get_width());
global.cursor_y = clamp(global.cursor_y, 0, display_get_height());

// Change atmosphere
if(keyboard_check_pressed(vk_f4)) {
	if(current_atmosphere != ATMOSPHERE.DRAGON_PRESENT)
		current_atmosphere = ATMOSPHERE.DRAGON_PRESENT;
	else
		current_atmosphere = ATMOSPHERE.CALM;
}

var _gp_shoulderrb = gp_value(gp_shoulderlb, global.current_player) * 0.5;
var _gp_shoulderlb = gp_value(gp_shoulderrb, global.current_player) * 0.5;
if(_gp_shoulderrb > 0.05) {
	zooming += ((1 + _gp_shoulderrb) - zooming) / 10 * dlt;
} else if(_gp_shoulderlb > 0.05) {
	zooming += ((1 - _gp_shoulderlb) - zooming) / 10 * dlt;
} else {
	zooming += (1 - zooming) / 10 * dlt;
}

var _dice_x, _dice_y, _dice_z, _closeness;
_closeness = 0.7;
_dice_x = xx + lengthdir_x(lerp(0, cam_distance, _closeness), cam_rotate);
_dice_y = yy + lengthdir_y(lerp(0, cam_distance, _closeness), cam_rotate);
_dice_z = lerp(0, z, _closeness);

dice_matrix = matrix_build(_dice_x, _dice_y, _dice_z + dice_throw_z, dice_rotation_x, dice_rotation_y, dice_rotation_z, 1, 1, 1);

blur_alpha += (blur_max - blur_alpha) / 8 * dlt;

// Vertaal de kaarsen DS lijsten naar arrays
global.kaarsen = [];
global.kaarsen_kleuren = [];

// Werk ook de belichting bij
with(obj_pawn) {
	for(var i = 3; i < ds_list_size(global.ds_kaarsen_kleuren); i += 4) {
		var _id = ds_list_find_value(global.ds_kaarsen_kleuren, i);
		if(_id == -1)
			continue;
		
		if(_id == current_player_id) {
			var _i = i - 3;
			ds_list_set(global.ds_kaarsen, _i, x);
			ds_list_set(global.ds_kaarsen, _i + 1, y);
			ds_list_set(global.ds_kaarsen, _i + 2, z + 6.5);
			
			// Kleur
			if(instance_exists(obj_candle_wax)) {
				var _inst = instance_nearest(x, y, obj_candle_wax);
				var _dis = clamp(point_distance(x, y, _inst.x, _inst.y) / 30, 0, 1);
				ds_list_set(global.ds_kaarsen_kleuren, _i, light_color.r * _dis * scale);
				ds_list_set(global.ds_kaarsen_kleuren, _i + 1, light_color.g * _dis * scale);
				ds_list_set(global.ds_kaarsen_kleuren, _i + 2, light_color.b * _dis * scale);
			}
		}
	}
}

for(var _i = 0; _i < ds_list_size(global.ds_kaarsen); _i++) {
	var _kaars = ds_list_find_value(global.ds_kaarsen, _i);
	var _kaars_kleur = ds_list_find_value(global.ds_kaarsen_kleuren, _i);
	
	array_push(global.kaarsen, _kaars);
	array_push(global.kaarsen_kleuren, _kaars_kleur);
}

// Belichting toevoegen aan speler
array_push(global.kaarsen, xx, yy, 32, 30);
array_push(global.kaarsen_kleuren, 0.89, 0.89, 0.89, -1);

face = point_direction(x, y, xx, yy);

if(keyboard_check(vk_escape))
	game_end();

if(zoom_out < 1) {
	zoom_out += (1 / 900) * dlt;
	cam_distance = lerp(7, 15, 1 - dcos(zoom_out * 180));
	z = lerp(17, 25.5, (1 - dcos(zoom_out * 180)) * zooming);
	pitch = lerp(-30, -43, 1 - dcos(zoom_out * 180));
} else {
	z = 34 * zooming;
	cam_distance = 23 * zooming;
}

xx += (xto - xx) / 6 * dlt;
yy += (yto - yy) / 6 * dlt;

x = xx + lengthdir_x(cam_distance, cam_rotate);
y = yy + lengthdir_y(cam_distance, cam_rotate);

menu_fade_in = min(menu_fade_in, 1);
// Het spel speler
switch(global.game_progress) {
	case GAME_PROGRESS.PRE_MENU:
	// blur_max = 1;
		if(!pressed_start) {
			if(menu_intensity > 0) {
				menu_intensity -= menu_intensity / 200 * dlt;
			}
			menu_fade_in += 1 / 300 * dlt;
			if(_action_button) {
				audio_play_sound(snd_start_game, 10, false, 1);
				pressed_start = true;
			}
		} else {
			menu_intensity += (2 - menu_intensity) / 300 * dlt;
			if(menu_intensity > 1.25) {
				global.game_progress = GAME_PROGRESS.CREATING_PLAYERS;
			}
			menu_fade_in = 0;
		}
		break;
	case GAME_PROGRESS.INTRO_CUTSCENE:
		blur_max = 0;
		//if(zoom_out < 1) {
		//	zoom_out += (1 / 900);
		//	cam_distance = lerp(7, 15, 1 - dcos(zoom_out * 180));
		//	z = lerp(17, 25.5, 1 - dcos(zoom_out * 180));
		//	pitch = lerp(-30, -43, 1 - dcos(zoom_out * 180));
		//}
		break;
	case GAME_PROGRESS.CREATING_PLAYERS:
		blur_max = 0;
		
		// Als de speler klaar is
		if(_continue_button) {
			global.game_progress = GAME_PROGRESS.GENERATING_ORDER;
			lerp_player_names = 0;
			init_player_position = [];
			longest_name_offset = 0;
			audio_play_sound(snd_start_game, 10, false, 1);
			for(var _i = 0; _i < ds_list_size(global.players); _i++) {
				var _player = ds_list_find_value(global.players, _i);
				array_push(init_player_position, {
					_x: _player.name_x,
					_y: _player.name_y,
				});
				if(string_length(_player.name) > longest_name_offset)
					longest_name_offset = string_length(_player.name);
			}
			draw_set_font(fnt_subtitle);
			longest_name_offset *= string_width("M");
		}
		if(!global.adding_player) {
			brightness += (0 - brightness) / 10;
	
			if(_add_player_button && !global.game_has_started) {
				global.adding_player = true;
			}
		} else {
			brightness += (0.25 - brightness) / 10;
		
			if(keyboard_check_pressed(vk_enter)) {
				if(string_length(new_player_name) >= 3) {
					global.adding_player = false;
					audio_play_sound(snd_done, 1, false, 1);
				
					var _index = ds_list_size(global.players);
					
					var _beat_sizes = [];
					repeat(15) 
						array_push(_beat_sizes, 0);
					
					var _beat_offsets = [];
					repeat(15) 
						array_push(_beat_offsets, random(180));
				
					// Toevoegen speler aan lijst
					ds_list_add(global.players, {
						name: new_player_name,
						name_x: 32,
						name_y: 32 + _index * 42,
						inversion: 0,
						special_dices: [],
						cards: [CARD_TYPES.SECOND_CHANCE, CARD_TYPES.ADD_ONE, CARD_TYPES.SWORD, CARD_TYPES.SHIELD],
						hearts: 0,
						beat_offset: _beat_offsets,
						beat_size: _beat_sizes,
						feathers: 10,
					});
				
					new_player_name = "";
					
					// Spawn plek
					var _tiles = ds_list_create();
					var _num_tiles = collision_circle_list(x, y + 21, 15, obj_tile,  false, true, _tiles, true);
					
					for(var _i = 0; _i < ds_list_size(_tiles); _i++) {
						var _tile = ds_list_find_value(_tiles, _i);
						if(!position_meeting(_tile.x, _tile.y, obj_pawn) && !position_meeting(_tile.x, _tile.y, obj_candle_wax)) {
							// Maak een pion aan
							with(instance_create_depth(_tile.x, _tile.y, -10, obj_pawn)) {
								current_player_id = _index;
							}
							break;
						}
					}
					
					ds_list_destroy(_tiles);
					
				} else if(!string_length(new_player_name)) {
					global.adding_player = false;
				}
			} else {	
				if(keyboard_check_pressed(vk_anykey)) {
					new_player_name = enter_character(new_player_name, keyboard_lastkey, true);
				}
			}
		}
		break;
	case GAME_PROGRESS.GENERATING_ORDER:
		if(lerp_player_names < 90 && shuffling > 0) {
			lerp_player_names += (90 / interpolation_speed) * dlt;
		}
		
		var _convert_lerp_player_names = dsin(lerp_player_names);
		
		brightness += (0.45 - brightness) / 10 * dlt;
		blur_max = 1;
		
		for(var _i = 0; _i < ds_list_size(global.players); _i++) {
			var _player = ds_list_find_value(global.players, _i);
			var _start_pos = init_player_position[_i];
			var _center = display_get_width() / 2 - longest_name_offset / 2;
			var _center_y = round(display_get_height() / 2 - (ds_list_size(global.players) * line(fnt_subtitle)) + _i * line() * 2);
			
			_player.name_x = lerp(_start_pos._x, _center, _convert_lerp_player_names);
			_player.name_y = lerp(_start_pos._y, _center_y, _convert_lerp_player_names);
		}
		
		shuffle_players -= 1 * dlt;
		
		if(shuffle_players <= 0 && shuffling > 0) {
			interpolation_speed = 22.5;
			lerp_player_names = 0;
			shuffle_players = 30
			
			if(shuffling > 1) {
				init_player_position = [];
				
				var _last = global.players;
				ds_list_shuffle(global.players);
			
				repeat(20) {
					if(ds_list_is_identical(global.players, _last)) {
						ds_list_shuffle(global.players);
					}
				}
			
				for(var _i = 0; _i < ds_list_size(global.players); _i++) {
					var _player = ds_list_find_value(global.players, _i);
					array_push(init_player_position, {
						_x: _player.name_x,
						_y: _player.name_y,
					});
				}
				audio_play_sound(snd_whoosh, 10, false, 1);
			}
			
			shuffling--;
			if(shuffling <= 0) {
				lerp_player_names = 90;
				interpolation_speed = 90;
			}
		}
		
		if(shuffle_players <= 0 && shuffling <= 0) {
			if(lerp_player_names > 0 && cloud_alpha >= 1) {
				lerp_player_names -= (90 / interpolation_speed) * dlt;
			}
			
			if(lerp_player_names <= 0) {
				global.game_progress = GAME_PROGRESS.ROLLING_DIE;
				// make_tiles_available();
			}			
		
			for(var _i = 0; _i < ds_list_size(global.players); _i++) {
				var _player = ds_list_find_value(global.players, _i);
				var _start_pos = {
					_x: 32,
					_y: 32 + _i * line(fnt_subtitle) * 2,
				};
				var _center = display_get_width() / 2 - longest_name_offset / 2;
				var _center_y = round(display_get_height() / 2 - (ds_list_size(global.players) * line(fnt_subtitle)) + _i * line() * 2);
			
				_player.name_x = lerp(_start_pos._x, _center, _convert_lerp_player_names);
				_player.name_y = lerp(_start_pos._y, _center_y, _convert_lerp_player_names);
			}
		}
		break;
	case GAME_PROGRESS.PICKING_DIE_OR_CARDS:
		brightness += (0.25 - brightness) / 10 * dlt;
		blur_max = 1;
		
		var _player = get_current_player();
		
		if(_switch_inventory) {
			if(_player.can_throw_dice) {
				inventory_type = !inventory_type;
				current_inventory = 0;
				fade_inventory = 0;
				fade_inventory2 = 0;
				fade_inventory3 = 0;
				audio_play_sound(snd_menu_select, 1, false, 1, 0, 0.5);
			} else {
				audio_play_sound(snd_deny, 1, false, 1, 0, 1);
			}
		}
		
		if(_inventory_button) {
			global.game_progress = GAME_PROGRESS.ROLLING_DIE;
			current_inventory = 0;
			fade_inventory = 0;
			fade_inventory2 = 0;
			fade_inventory3 = 0;
			inventory_type = _player.can_throw_dice ? INVENTORY_TYPES.DICE : INVENTORY_TYPES.CARDS;
			audio_play_sound(snd_menu_select, 1, false, 1, 0, 0.5);
		}
	
		if(inventory_type == INVENTORY_TYPES.DICE) {
			if(_scroll_up) {
				current_inventory--;
				if(current_inventory < 0)
					current_inventory = DICE_TYPES.LENGTH - 1;
				audio_play_sound(snd_menu_select, 1, false, 1, 0, 1);
				fade_inventory = 0;
				fade_inventory2 = 0;
			}
	
			if(_scroll_down) {
				current_inventory++;
				if(current_inventory > DICE_TYPES.LENGTH - 1)
					current_inventory = 0;
				audio_play_sound(snd_menu_select, 1, false, 1, 0, 1);
				fade_inventory = 0;
				fade_inventory2 = 0;
			}
			
			if(_action_button) {
				audio_play_sound(snd_menu_select, 1, false, 1, 0, 1);
				global.game_progress = GAME_PROGRESS.ROLLING_DIE;
				_player.current_dice = current_inventory;
				current_inventory = 0;
			}
		} else {
			if(card_animation == -1) {
				if(_scroll_left) {
					if(current_inventory - 1 < 0) {
						current_inventory = 3;
						audio_play_sound(snd_select_card, 1, false, 1, 0, 1);
					} else if(current_inventory - 1 == 3) {
						audio_play_sound(snd_select_card, 1, false, 1, 0, 1);
						current_inventory = 7;
					}else {
						audio_play_sound(snd_select_card, 1, false, 1, 0, 1);
						current_inventory --;
					}
					fade_inventory = 0;
					fade_inventory2 = 0;
				}
			
				if(_scroll_right) {
					if(current_inventory + 1 == 4) {
						audio_play_sound(snd_select_card, 1, false, 1, 0, 1);
						current_inventory = 0;
					} else if(current_inventory + 1 == 8) {
						audio_play_sound(snd_select_card, 1, false, 1, 0, 1);
						current_inventory = 4;
					} else {
						audio_play_sound(snd_select_card, 1, false, 1, 0, 1);
						current_inventory ++;
					}
					fade_inventory = 0;
					fade_inventory2 = 0;
				}
			
				if(_scroll_up) {
					if(current_inventory - 4 < 0) {
						audio_play_sound(snd_select_card, 1, false, 1, 0, 1);
						current_inventory += 4;
						
					} else {
						audio_play_sound(snd_select_card, 1, false, 1, 0, 1);
						current_inventory -= 4;
					}
					fade_inventory = 0;
					fade_inventory2 = 0;
				}
			
				if(_scroll_down) {
					if(current_inventory + 4 >= 8) {
						audio_play_sound(snd_select_card, 1, false, 1, 0, 1);
						current_inventory -= 4;
					} else {
						audio_play_sound(snd_select_card, 1, false, 1, 0, 1);
						current_inventory += 4;
					}
					fade_inventory = 0;
					fade_inventory2 = 0;
				}
			}
		}
		break;			
	case GAME_PROGRESS.ROLLING_DIE:
		brightness += (0 - brightness) / 10 * dlt;
		blur_max = 0;
		
		if(_inventory_button) {
			var _player = get_current_player();
			global.game_progress = GAME_PROGRESS.PICKING_DIE_OR_CARDS;
			current_inventory = 0;
			fade_inventory = 0;
			fade_inventory2 = 0;
			fade_inventory3 = 0;
			inventory_type = _player.can_throw_dice ? INVENTORY_TYPES.DICE : INVENTORY_TYPES.CARDS;
			audio_play_sound(snd_menu_select, 1, false, 1, 0, 0.5);
		}
		
		// Beweeg de camera naar de gans in kwestie
		var _x, _y;
		with(obj_pawn) {
			if(current_player_id == global.current_player) {
				_x = x;
				_y = y;
			}
		}
		
		// Ervoor zorgen dat de speler naar het geselecteerde blokje 
		if(_action_button) {
			if(ds_list_size(global.available_tiles) > 0) {
				var _x, _y;
				_x = 0;
				_y = 0;
	
				with(obj_tile) {
					if(currently_selected) {
						_x = x;
						_y = y;
					}
				}
	
				ds_list_clear(global.available_tiles);
	
				with(obj_pawn) {
					if(global.current_player == current_player_id) {
						cur_x = x;
						cur_y = y;
						to_x = _x;
						to_y = _y;
						move_lerp = 0;
						can_noise = true;
						
						if(position_meeting(to_x, to_y, obj_shop)) {
							audio_play_sound(snd_enter_store, 10, false, 1, 0, 0.5);
							with(obj_camera) {
								current_atmosphere = ATMOSPHERE.IN_SHOP;
							}
						}
					}
				}
			} else {
				if(get_current_player().can_throw_dice) {
					global.game_progress = GAME_PROGRESS.DICE_IS_ROLLING;
					throwing = false;
					
					dice_fade_in = 0;
					
					audio_play_sound(snd_whoosh, 1, false, 1);
					
					dice_throw_z_speed = 2 / 4;
					finish_throw = false;
					dice_interpolation = 0;
				
					// Rollen van dobbelsteen
					dice_rotation_xspeed	= random_range(8, 12);
					dice_rotation_yspeed	= random_range(8, 12);
					dice_rotation_zspeed	= random_range(8, 12);
					
					dice_rotation_x = 0;
					dice_rotation_y = 0;
					dice_rotation_z = 0;
				} else {
					next_turn();
					display_mouse_set(display_get_width() / 2, display_get_height() / 2);
					global.cursor_x = display_get_width() / 2;
					global.cursor_y = display_get_height() / 2;
				}
			}
		}
		
		var _offset_x = global.cursor_x - display_get_width() / 2;
		var _offset_y = global.cursor_y - display_get_height() / 2;
		
		_x += lengthdir_x(-_offset_x / 37.5, face - 90);
		_y += lengthdir_y(-_offset_y / 21, face);
		
		xto += (_x - xto) / 10 * dlt;
		yto += (_y - yto) / 10 * dlt;
	
		// Checken waar je met de muis overheen gaat
		if(!is_undefined(global.view_mat) && !is_undefined(global.proj_mat)) {
			var _closest = {
				_id: undefined,
				_dist: infinity,
			}
	
			with(obj_tile) {
				currently_selected = false;
				if(object_get_name(object_index) == "obj_tile") {
					if(is_tile_available()) {
						var _x, _y, _coords;
						_coords = world_to_screen(x, y, 3, global.view_mat, global.proj_mat);
						var _dist = point_distance(global.cursor_x, global.cursor_y, _coords[0], _coords[1]);
						if(_dist < _closest._dist) {
							_closest._id = id;
							_closest._dist = _dist;
						}
					}
				}
			}
	
			with(_closest._id) {
				currently_selected = true;
				if(global.current_tile != _closest._id) {
					audio_play_sound(snd_select_tile, 1, false, 0.25, 0, 2);
					global.current_tile = _closest._id;
				}
				
				if(keyboard_check_pressed(vk_f12)) {
					with(obj_tile) {
						if(currently_selected) {
							instance_create_depth(x, y, -10, obj_shop);
						}
					}
				}
			}
		}
		break;
	case GAME_PROGRESS.DICE_IS_ROLLING:
		brightness += (0.25 - brightness) / 10 * dlt;
		blur_max = 1;
		
		if(dice_fade_in < 1) {
			dice_fade_in += (1 / 30) * dlt;
		}
			
		if(!throwing) {
			var _gp_h, _gp_v;
			_gp_h = gp_axis(gp_axisrh, global.current_player);
			_gp_v = gp_axis(gp_axisrv, global.current_player);
		
			comb_speed_x += (_gp_h - comb_speed_x) / 16;
			comb_speed_y += (_gp_v - comb_speed_y) / 16;
		
			dice_rotation_xspeed = 0;
			dice_rotation_yspeed = 0;
			dice_rotation_zspeed = 0;
		
			dice_rotation_x += (comb_speed_y * dsin(dice_rotation_y)) + (comb_speed_x * dcos(dice_rotation_z)) * dlt * 16;
			dice_rotation_y += (comb_speed_y * dsin(dice_rotation_x)) + (comb_speed_x * dcos(dice_rotation_z)) * dlt * 16;
			dice_rotation_z += (comb_speed_y * dsin(dice_rotation_x)) + (comb_speed_x * dcos(dice_rotation_y)) * dlt * 16;
			
			if(_action_button) {
				throwing = true;
				dice_rotation_xspeed = random_range(8, 12);
				dice_rotation_yspeed = random_range(8, 12);
				dice_rotation_zspeed = random_range(8, 12);
				audio_play_sound(snd_whoosh_dice, 10, false, 1, 0, 0.7);
			}
			
			if(_inventory_button) {
				global.game_progress = GAME_PROGRESS.ROLLING_DIE;
			}
		} else {
			dice_throw_z_speed -= 0.07 / 4 * dlt;
			dice_throw_z += dice_throw_z_speed * dlt;
			
			if(_action_button) {
				dice_throw_z_speed = 0;
			}
		
			if(dice_throw_z <= 0) {
				if(abs(dice_throw_z_speed) > 0.07) {
					dice_throw_z = 0.01;
					dice_throw_z_speed = -dice_throw_z_speed / 1.5;
			
					dice_rotation_xspeed = random_range(4, 7);
					dice_rotation_yspeed = random_range(3, 7);
					dice_rotation_zspeed = random_range(4, 8);
					
					global.dual_shock_left = 0.5;
					global.dual_shock_right = global.dual_shock_left;
				
					audio_play_sound(snd_move_piece, 1, false, 0.7, 0, random_range(0.96, 1.04));
				} else {
					dice_rotation_xspeed = 0
					dice_rotation_yspeed = 0;
					dice_rotation_zspeed = 0;
				
					dice_throw_z_speed = 0;
					dice_throw_z = 0.01;
				
					if(!finish_throw) {
						finish_throw = true;
					
						dice_rotation_x = abs(dice_rotation_x);
						dice_rotation_y = abs(dice_rotation_y);
						dice_rotation_z = abs(dice_rotation_z);
					
						// Normalize
						dice_rotation_x %= 360;
						dice_rotation_y %= 360;
						dice_rotation_z %= 360;
					
						outcome = choose(1, 2, 3);
						outcome = 3;
						global.last_outcome = outcome;
					
						if(outcome == 1) {
							dice_rotation_x = 31;
							dice_rotation_y = 21;
							dice_rotation_z = -16;
						
							final_dice_rotation_x = 0;
							final_dice_rotation_y = 0;
							final_dice_rotation_z = 0;
						} else if(outcome == 2) {
							dice_rotation_x = 81;
							dice_rotation_y = 41;
							dice_rotation_z = 21;
						
							final_dice_rotation_x = 90;
							final_dice_rotation_y = 0;
							final_dice_rotation_z = 0;
						} else {
							dice_rotation_x = 159;
							dice_rotation_y = 13;
							dice_rotation_z = -11;
						
							final_dice_rotation_x = 180;
							final_dice_rotation_y = 0;
							final_dice_rotation_z = 0;
						}
					
						last_dice_rotation_x = dice_rotation_x;
						last_dice_rotation_y = dice_rotation_y;
						last_dice_rotation_z = dice_rotation_z;
					}
				}
			}
		
			if(finish_throw) {
				if(dice_interpolation < 90) {
					dice_interpolation += 90 / 13 * dlt;
				
					var _dice_interpolation = power(dsin(dice_interpolation), 2.0);
					dice_rotation_x = lerp(last_dice_rotation_x, final_dice_rotation_x, _dice_interpolation);
					dice_rotation_y = lerp(last_dice_rotation_y, final_dice_rotation_y, _dice_interpolation);
					dice_rotation_z = lerp(last_dice_rotation_z, final_dice_rotation_z, _dice_interpolation);
				} else {
					dice_rotation_x %= 360;
					dice_rotation_y %= 360;
					dice_rotation_z %= 360;
				
					dice_rotation_x = round(dice_rotation_x);
					dice_rotation_y = round(dice_rotation_y);
					dice_rotation_z = round(dice_rotation_z);
				
					wait_after_dice -= 1 * dlt;
					if(wait_after_dice <= 0) {
						global.game_progress = GAME_PROGRESS.ROLLING_DIE;
						get_current_player().can_throw_dice = false;
						make_tiles_available(outcome);
						wait_after_dice	= 60;
					}
				}
			}
		}
		break;
	case GAME_PROGRESS.WITH_TRADER:
		brightness += (1 - brightness) / 60 * dlt;
		if(brightness >= 0.9) {
			if(candle_brightness == -1 && !audio_is_playing(snd_match_lit)) {
				audio_play_sound(snd_match_lit, 1, false, 1);
			}

			if(!obj_vendor.is_leaving) {
				candle_brightness += (0 - candle_brightness) / 120 * dlt;
				flame_alpha += (1 - flame_alpha) / 7 * dlt;
			} else {
				if(obj_vendor.leave_timer <= 90)
					flame_alpha -= flame_alpha / 7 * dlt;
			}
		}
		
		// Leave hut
		if(_inventory_button) {
			if(current_atmosphere != ATMOSPHERE.HAGGLING && obj_vendor.haggle_movement == 0 && !obj_vendor.is_leaving) {
				obj_vendor.is_leaving = true;
			}
		}
		break;
}

if(global.game_progress != GAME_PROGRESS.WITH_TRADER) {
	flame_alpha -= flame_alpha / 7 * dlt;
	candle_brightness = -1;
}

dice_rotation_x += dice_rotation_xspeed * dlt;
dice_rotation_y += dice_rotation_yspeed * dlt;
dice_rotation_z += dice_rotation_zspeed * dlt;

global.selection_glow += 3;
global.selection_glow %= 360;


// Bewegen
/*
xto += (keyboard_check(ord("D")) - keyboard_check(ord("A"))) * 0.25;
yto += (keyboard_check(ord("W")) - keyboard_check(ord("S"))) * 0.25;
*/

// Toon aan wie er aan de beurt is
if(shuffling == 0) {
	if(cloud_alpha < 5) {
		cloud_alpha += (1 / 90) * dlt;
	}
	// Geef alle spelers wat hartjes
	if(cloud_alpha > 0.5) {
		if(global.game_progress == GAME_PROGRESS.GENERATING_ORDER) {
			var _p1 = global.players[| 0];
			if(_p1.hearts < 5) {
				add_heart -= 1 * dlt;
				if(add_heart <= 0) {
					for(var _i = 0; _i < ds_list_size(global.players); _i++) {
						global.players[| _i].hearts++;
					}
					audio_play_sound(snd_add_heart, 1, false, 1, 0, 1.5 + _p1.hearts / 4);
					add_heart = 3;
				}
			}
		}
	}
}

for(var _i = 0; _i < ds_list_size(global.players); _i++) {
	for(var _j = 0; _j < global.players[| _i].hearts; _j++) {
		if(global.players[| _i].beat_size[_j] < 1)
			global.players[| _i].beat_size[_j] += (1 / 30) * dlt;
	}
}

fade_inventory += (1 - fade_inventory) / 8 * dlt;
fade_inventory3 += (1 - fade_inventory3) / 8 * dlt;

if(fade_inventory > 0.8) 
	fade_inventory2 += (1 - fade_inventory2) / 8 * dlt;
	
if(keyboard_check_pressed(vk_f11)) {
	instance_activate_all();
	if(!file_exists(FOREST_MASKS)) {
		var _fn = file_text_open_write(FOREST_MASKS);
		file_text_close(_fn);
	}
	
	ini_open(FOREST_MASKS);
	var _ind = 0;
	with(obj_forest_mask) {
		var _section = string("sect{0}", _ind);
		ini_write_real(_section, "x", x);
		ini_write_real(_section, "y", y);
		_ind++;
	}
	ini_close();
	
	// Shops opslaan
	if(!file_exists(SHOPS)) {
		var _fn = file_text_open_write(SHOPS);
		file_text_close(_fn);
	}
	
	ini_open(SHOPS);
	var _ind = 0;
	with(obj_shop) {
		var _section = string("sect{0}", _ind);
		ini_write_real(_section, "x", x);
		ini_write_real(_section, "y", y);
		_ind++;
	}
	ini_close();
	
	audio_play_sound(snd_done, 1, false, 1);
}

if(game_volume < 1) {
	game_volume += (1 / 160) * dlt;
}
	
audio_bus_main.gain = game_volume * 2;

// Uil
owl_timer -= 1 * dlt;
if(owl_timer <= 0) {
	owl_timer = random_range(360, 12000);
	audio_play_sound(snd_owl, 1, false, 0.2);
}

if(card_animation >= 0) {
	if(card_width[card_animation] < 1) {
		card_width[card_animation] += 1 / 30 * dlt;
	} else {
		var _player = get_current_player_in_list();
		var _player_pawn = get_current_player();
		
		card_width[card_animation] = 0;
		global.game_progress = GAME_PROGRESS.ROLLING_DIE;
		array_delete(_player.cards, current_inventory, 1);
		card_animation = -1;
		
		switch(global.last_card_picked) {
			case CARD_TYPES.SECOND_CHANCE:
				with(_player_pawn)
					can_throw_dice = true;
				break;
			case CARD_TYPES.ADD_ONE:
				global.last_outcome++;
				make_tiles_available(global.last_outcome);
				break;
		}
	}
}

// Hoe erg de controller trilt
global.dual_shock_left -= global.dual_shock_left / 10 * dlt;
global.dual_shock_right -= global.dual_shock_right / 10 * dlt;

gp_vibrations();
gamepad_set_color(4, c_red);

// Letters invoeren
if(global.adding_player) {
	if(_scroll_right) {
		if(current_letter < 25) {
			current_letter++;
			audio_play_sound(snd_select_tile, 1, 0, 0.5, 0, 2);
		} else {
			audio_play_sound(snd_deny, 10, false, 1);
		}
	} else if(_scroll_left) {
		if(current_letter > 0) {
			current_letter--;
			audio_play_sound(snd_select_tile, 1, 0, 0.5, 0, 2);
		} else {
			audio_play_sound(snd_deny, 10, false, 1);
		}
	}
	current_letter = clamp(current_letter, 0, 25);
}
