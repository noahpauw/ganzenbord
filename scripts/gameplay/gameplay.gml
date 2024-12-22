function enter_character(word = "", key, noise = false) {
	if(key == 8) {
		if(noise)
			audio_play_sound(snd_type, 1, false, 1, 0, random_range(0.96, 1.04));
			
		if(!string_length(word))
			return "";
			
		return string_copy(word, 0, string_length(word) - 1);
	}
	
	if(key == 32) {
		if(noise)
			audio_play_sound(snd_type, 1, false, 1, 0, random_range(0.96, 1.04));
		return word + " ";
	}
	
	if(key == 15)
		return word;
	
	var _word = word;
	var _letters = [];
	
	for(var i = 65; i <= 90; i++) {
		array_push(_letters, i);
	}
	
	var _char = chr(key);
	
	if(array_contains(_letters, key)) {
		if(noise)
			audio_play_sound(snd_type, 1, false, 1, 0, random_range(0.96, 1.04));
		if(keyboard_check(vk_shift)) {
			return _word + string_upper(_char);
		}
		return _word + string_lower(_char);
	}
	
	return word;
}

function add_light(_x, _y, _z, _range, _r, _g, _b, _follow_id = -1) {
	ds_list_add(global.ds_kaarsen, _x, _y, _z, _range);
	ds_list_add(global.ds_kaarsen_kleuren, _r, _g, _b, _follow_id);
}

function draw_text_shadow(_x, _y, _string, _color, _alpha) {
	var _coords = [-1, -1, 0, -1, 1, -1, 1, 0, 1, 1, 0, 1, -1, 1, -1, 0];
	
	/*
	for(var i = 0; i < array_length(_coords); i += 2) {
		draw_text_color(_x + _coords[i], _y + _coords[i + 1], _string, c_black, c_black, c_black, c_black, _alpha);
	}
	*/
	
	draw_text_color(_x, _y, _string, _color, _color, _color, _color, _alpha);	
}

function line(_font = undefined) {
	if(!is_undefined(_font)) {
		draw_set_font(_font);
	}
	return string_height("M");
}

function next_turn() {
	global.current_player ++;
	if(global.current_player >= ds_list_size(global.players))
		global.current_player = 0;
	get_current_player().can_throw_dice = true;
		
}

function make_tiles_available(_outcome = 1) {
	instance_activate_object(obj_tile);
	ds_list_clear(global.available_tiles);
	with(obj_pawn) {
		if(current_player_id == global.current_player) {
			global.current_player_x = x;
			global.current_player_y = y;
			
			var _tiles = 8;
			if(_outcome == 2) {
				_tiles += 12;
			} else if(_outcome == 3) {
				_tiles += 24;
			}
			
			// Selecteer
			for(var _i = 0; _i < _tiles; _i++) {
				with(instance_nth_nearest(x, y, obj_tile, _i)) {
					if(!collision_line(x, y, global.current_player_x, global.current_player_y, obj_candle_wax, false, true) && !do_not_render) {
						ds_list_add(global.available_tiles, id);
						wait_to_show = _i * 1;
					}
				}
			}
		}
	}

	//with(obj_tile) {
	//	if(point_distance(x, y, global.current_player_x, global.current_player_y) <= 7.5) {
	//		ds_list_add(global.available_tiles, id);
	//	}
	//}
}

function is_tile_available() {
	return ds_list_find_index(global.available_tiles, id);
}

function get_player_by_id(_id) {
	return ds_list_find_value(global.players, _id);
}

function ds_list_is_identical(_list1, _list2) {
	var _same = true;
	for(var _i = 0; _i < ds_list_size(_list1); _i++) {
		var _item = _list1[| _i];
		var _item2 = _list2[| _i];
		if(_item != _item2) {
			_same = false;
			break;
		}
	}
	return _same;
}

function get_current_player() {
	var _id = undefined;
	with(obj_pawn) {
		if(current_player_id == global.current_player)
			_id = id;
	}
	return _id;
}

function get_current_player_in_list() {
	return ds_list_find_value(global.players, global.current_player);
}

function instance_nth_nearest(pointx, pointy, object, n) {
    var list,nearest;
    n = min(max(1,n),instance_number(object));
	
    list = ds_priority_create();
    nearest = noone;
	
    with (object) ds_priority_add(list,id,distance_to_point(pointx,pointy));
    repeat (n) nearest = ds_priority_delete_min(list);
    ds_priority_destroy(list);
    return nearest;
}

function ease_in_out_back(_x) {
    var _c1 = 1.70158;
    var _c2 = _c1 * 1.525;
    return _x < 0.5
       ? (power(2 * _x, 2) * ((_c2 + 1) * 2 * _x - _c2)) / 2
       : (power(2 * _x - 2, 2) * ((_c2 + 1) * (_x * 2 - 2) + _c2) + 2) / 2;
}

function ease_out_bounce(_x) {
    var _n1 = 7.5625;
    var _d1 = 2.75;
    if (_x < 1 / _d1) {
    return _n1 * _x * _x;
    } else if (_x < 2 / _d1) {
        return _n1 * (_x - 1.5 / _d1) * _x + 0.75;
    } else if (_x < 2.5 / _d1) {
        return _n1 * (_x - 2.25 / _d1) * _x + 0.9375;
    } else {
        return _n1 * (_x - 2.625 / _d1) * _x + 0.984375;
    }
}

function ease_quint(_x) {
    return _x < 0.5 ? 16 * _x * _x * _x * _x * _x : 1 - power(-2 * _x + 2, 5) / 2;
}

function gamepad_default(_controller_id) {
	if(gamepad_is_connected(_controller_id))
		return 1;
	if(gamepad_is_connected(4))
		return 0;
	return -1;
}

function gp_pressed(_button, _controller_id) {
	var _check = gamepad_default(_controller_id + 4);
	if(!_check == -1)
		return false;
	return gamepad_button_check_pressed(_check == 1 ? _controller_id + 4 : 4, _button);
}

function gp_hold(_button, _controller_id) {
	var _check = gamepad_default(_controller_id + 4);
	if(!_check == -1)
		return false;
	return gamepad_button_check(_check == 1 ? _controller_id + 4 : 4, _button);
}

function gp_axis(_axis, _controller_id, _deadzone = 0.07) {
	var _check = gamepad_default(_controller_id + 4);
	if(gamepad_default(_controller_id + 4) == -1)
		return 0;
	var _axis_value = gamepad_axis_value(_check == 1 ? _controller_id + 4 : 4, _axis);
	var _sign = sign(_axis_value);
	
	if(abs(_axis_value) < _deadzone)
		return 0;
	return _axis_value - (_deadzone * _sign)
}

function gp_value(_button, _controller_id) {
	var _check = gamepad_default(_controller_id + 4);
	if(_check == -1)
		return 0;
	return gamepad_button_value(_check == 1 ? _controller_id + 4 : 4, _button);
}

function gp_vibrations() {
	for(var _i = 4; _i < 12; _i++) {
		if(!gamepad_is_connected(_i))
			continue;
		gamepad_set_vibration(_i, global.dual_shock_left, global.dual_shock_right);
	}
}