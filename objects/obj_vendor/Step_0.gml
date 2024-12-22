/// @description Gedrag verkoper
if(is_leaving) {
	leave_timer -= 0.35 * dlt;
	force_angry = 1;
	if(leave_timer <= 90) {
		if(leave_timer >= 85 && !audio_is_playing(snd_match_lit))
			audio_play_sound(snd_match_lit, 10, false, 0.35, 0, 1.5);
			
		with(obj_camera) {
			candle_brightness += (-1 - candle_brightness) / 80 * dlt;
			fade_inventory = 0;
			fade_inventory2 = 0;
			fade_inventory3 = 0;
		}
	}
	if(leave_timer <= 70) {
		hold_eyes_shut = 1;
	}
	if(leave_timer <= 0) {
		is_leaving = false;
		repeat(13) {
			array_push(cards_in_stock, irandom(CARD_TYPES.DECK_SIZE - 1));
		}
		
		// Zet de speler ergens neer
		hold_eyes_shut = 240;
		blink = 1;
		blink_timer = 240;
		
		global.game_progress = GAME_PROGRESS.ROLLING_DIE;
		obj_camera.current_atmosphere = ATMOSPHERE.CALM;
		var _found = false;
		var _ind = 0;
		var _player_pawn = get_current_player();
		while(!_found) {
			var _inst = instance_nth_nearest(_player_pawn.x, _player_pawn.y, obj_tile, _ind);
			if(!_inst.do_not_render && !position_meeting(_inst.x, _inst.y, obj_shop) && !position_meeting(_inst.x, _inst.y, obj_pawn)) {
				with(_player_pawn) {
					to_x = _inst.x;
					to_y = _inst.y;
					cur_x = x;
					cur_y = y;
					move_lerp = 0;
					can_noise = true;
				}
				_found = true;
			}
			_ind++;
		}
		global.music_change_speed = FAST_MUSIC_CHANGE;
	}	
}

if(global.game_progress != GAME_PROGRESS.WITH_TRADER)
	exit;
	
var _return_button = keyboard_check_pressed(vk_enter) || gp_pressed(gp_face4, global.current_player);
var _continue_button = keyboard_check_pressed(vk_f1) || gp_pressed(gp_start, global.current_player);
var _action_button = keyboard_check_pressed(vk_space) || mouse_check_button_pressed(mb_left) || gp_pressed(gp_face1, global.current_player);
var _switch_inventory = keyboard_check_pressed(ord("7")) || keyboard_check_pressed(ord("8")) || gp_pressed(gp_shoulderl, global.current_player) || gp_pressed(gp_shoulderr, global.current_player);

// Scrollen
var _scroll_left = keyboard_check_pressed(vk_left) || gp_pressed(gp_padl, global.current_player);
var _scroll_right = keyboard_check_pressed(vk_right) || gp_pressed(gp_padr, global.current_player);
var _scroll_up = keyboard_check_pressed(vk_up) || gp_pressed(gp_padu, global.current_player);
var _scroll_down = keyboard_check_pressed(vk_down) || gp_pressed(gp_padd, global.current_player);

var _player = get_current_player_in_list();

// Vermijden dat hij wordt gedeïnstantieerd
x = obj_camera.x;
y = obj_camera.y;

if(!made_bid && !is_leaving) {
	if(_scroll_left || _scroll_down) {
		if(obj_camera.current_atmosphere != ATMOSPHERE.HAGGLING) {
			movement = 0;
			if(current_card_index > 0) {
				current_card_index--;
				with(obj_camera) {
					fade_inventory = 0;
					fade_inventory2 = 0;
					fade_inventory3 = 0;
				}
				from_x = to_x;
				to_x = current_card_index * 215;
				audio_play_sound(snd_menu_select, 10, false, 0.8, 0, 1);
			} else {
				current_card_index = 0;
				from_x = to_x;
				to_x = 0;
				audio_play_sound(snd_deny, 10, false, 1, 0, 1);
			}
		} else {
			// Afdingen
			if(offered_price > 0) {
				offered_left_start = offered_price;
				offered_right_start = offered_price;
				offered_price--;
				offered_left_end = offered_price;
				offered_right_end = offered_price;
				offered_left_ease = 0;
				offered_right_ease = 0;
				audio_play_sound(snd_select_tile, 10, false, 1, 0, 2);
				audio_play_sound(snd_bit_alter, 10, false, 1, 0, 1);
			} else {
				audio_play_sound(snd_deny, 10, false, 1, 0, 1);
			}
		}
	} else if(_scroll_right || _scroll_up) {
		if(obj_camera.current_atmosphere != ATMOSPHERE.HAGGLING) {
			movement = 0;
			if(current_card_index < array_length(cards_in_stock) - 1) {
				with(obj_camera) {
					fade_inventory = 0;
					fade_inventory2 = 0;
					fade_inventory3 = 0;
				}
				current_card_index ++;
				switch_card = 1;
				from_x = to_x;
				to_x = current_card_index * 215;
				audio_play_sound(snd_menu_select, 10, false, 0.8, 0, 1);
			} else {
				current_card_index = array_length(cards_in_stock) - 1;
				from_x = to_x;
				to_x = (array_length(cards_in_stock) - 1) * 215;
				audio_play_sound(snd_deny, 10, false, 1, 0, 1);
			}
		} else {
			// Afdingen
			if(offered_price < 99) {
				offered_left_start = offered_price;
				offered_right_start = offered_price;
				offered_price++;
				offered_left_end = offered_price;
				offered_right_end = offered_price;
				offered_left_ease = 0;
				offered_right_ease = 0;
				audio_play_sound(snd_select_tile, 10, false, 1, 0, 2);
				audio_play_sound(snd_bit_alter, 10, false, 1, 0, 1);
			} else {
				audio_play_sound(snd_deny, 10, false, 1, 0, 1);
			}
		}
	}
}

if(movement < 1)
	movement += (1 / 30) * dlt;
swap_card = clamp(swap_card, 0, 1);
movement = clamp(movement, 0, 1);

eye_change -= dlt;
if(eye_change <= 0) {
	var _stare = irandom(3);
	if(_stare == 0) {
		eye_rot_xx = 0;
		eye_rot_yx = -5;
	} else {
		eye_rot_xx = random_range(-10, 10);
		eye_rot_yx = random_range(-32, 32);
	}
	eye_change = random_range(15, 240);
	eye_speed = irandom_range(6, 40);
}

feng_maw_open += lerp(-1, 1, real(feng_angry)) * dlt;
feng_maw_open = clamp(feng_maw_open, 0, sprite_get_number(spr_feng_snout) - 1);

eye_rot_x += (eye_rot_xx - eye_rot_x) / eye_speed * dlt;
eye_rot_y += (eye_rot_yx - eye_rot_y) / eye_speed * dlt;

if(hold_eyes_shut <= 0) {
	if(!made_bid) {
		if(blink_timer > 0) {
			blink_timer -= 1 * dlt;
			blink -= 3 / 60 * dlt;
		} else {
			if(blink < 1)
				blink += 3 / 60 * dlt;
			else {
				blink_timer = random_range(180, 300);
				if(obj_camera.current_atmosphere == ATMOSPHERE.HAGGLING && eye_slits != 2)
					eye_slits = 2;
				else if(obj_camera.current_atmosphere != ATMOSPHERE.HAGGLING && eye_slits != 0)
					eye_slits = 0;
			}
		}
	} else {
		blink += (0.75 - blink) / 9 * dlt;
	}
} else {
	hold_eyes_shut -= dlt;
	blink += (1 / 120) * dlt;
}
blink = clamp(blink, 0, 1);

if(obj_camera.current_atmosphere == ATMOSPHERE.HAGGLING) {
	// Checken of de verkoper akkoord gaat met je bod
	if(_action_button && !is_leaving) {
		if(can_purchase) {
			if(!made_bid) {
				made_bid = true;
				await_vendor_response = offered_price < current_item_price ? 240 : 0;
				if(offered_price - current_item_price >= 2) {
					give_random_card = true;
				}
			}
		} else {
			force_angry = 16;
			audio_play_sound(snd_deny, 10, false, 1, 0);
		}
	}
	
	if(_return_button && !is_leaving) {
		obj_camera.current_atmosphere = ATMOSPHERE.IN_SHOP;
		global.music_change_speed = INSTANT_MUSIC_CHANGE;
		current_item_price = 0;
		offered_price = 0;
		feng_angry = false;
		blink_timer = 0;
	}
	if(haggle_movement < 1)
		haggle_movement += 1 / 40 * dlt;
} else {
	if(purchased_card_type == -1) {
		if(haggle_movement > 0) {
			haggle_movement -= 1 / 40 * dlt;
		} else {
			haggle_movement = 0;
			haggle_index = -1;
		}
	}
	
	feng_angry = false;
	
	// Afdingen
	if(_action_button && !is_leaving) {
		obj_camera.current_atmosphere = ATMOSPHERE.HAGGLING;
		global.music_change_speed = INSTANT_MUSIC_CHANGE;
		haggle_index = current_card_index;
		blink_timer = 0;
		
		offered_price = obj_camera.card_descriptions[cards_in_stock[current_card_index]].cost;
				
		// Reset index
		current_item_price = offered_price;
		offered_left_start = 0;
		offered_right_start = 0;
		offered_left_end = offered_price;
		offered_right_end = offered_price;
		offered_left_ease = 0;
		offered_right_ease = 0;
				
		audio_play_sound(snd_bit_alter, 10, false, 1, 0, 1);
					
		feng_angry = false;
	}
}

if(obj_camera.current_atmosphere == ATMOSPHERE.HAGGLING) {
	if(force_angry <= 0) {
		var _payment_ratio = offered_price / current_item_price;
		if(_payment_ratio <= 0.6 && !feng_angry) {
			feng_angry = true;
			eye_rot_xx = -20;
			eye_rot_yx = -20;
			eye_change = 160;
			eye_speed = 10;
		}

		if(_payment_ratio > 0.6)
			feng_angry = false;
	}
}

if(force_angry >= 0) {
	force_angry -= dlt;
	feng_angry = true;
}

// Afwachten verkoper
if(made_bid) {
	await_vendor_response -= dlt;
	if(await_vendor_response <= 0) {
		var payment_ratio = offered_price / current_item_price;
		var _accept_bid = false;
		if(payment_ratio >= 1) {
			_accept_bid = true;
		} else if(payment_ratio >= 0.8 && payment_ratio < 1) {
			_accept_bid = choose(true, false);
		} else if(payment_ratio >= 0.6 && payment_ratio < 0.8) {
			if(irandom(4) == 0)
				_accept_bid = true;
		} else if(payment_ratio >= 0.4 && payment_ratio < 0.6) {
			if(irandom(7) == 0)
				_accept_bid = true;
		} else if(payment_ratio >= 0.2 && payment_ratio < 0.4) {
			if(irandom(10) == 0)
				_accept_bid = true;
		} else if(payment_ratio < 0.2) {
			_accept_bid = false;
		}
		if(!_accept_bid) {
			// _player.hearts--;
			audio_play_sound(snd_whoosh, 1, false, 1);
			feng_can_harm = true;
			feng_strike = 0;
			feng_claw_alpha = 0;
			force_angry = 200;
		} else {
			_player.feathers -= offered_price;
			audio_play_sound(snd_bid_won, 1, false, 0.85);
			obj_camera.current_atmosphere = ATMOSPHERE.IN_SHOP;
			
			// Kaart tonen
			purchased_card_alpha = 0;
			purchased_card_type = cards_in_stock[current_card_index];
			array_push(_player.cards, purchased_card_type);
			obj_camera.movement = 0;
		}
		await_vendor_response = 240;
		made_bid = false;
		feng_angry = false;
		blink_timer = 0;
	}
}

haggle_movement = clamp(haggle_movement, 0, 1);

if(purchased_card_type != -1) {
	if(purchased_card_alpha < 2.75)
		purchased_card_alpha += 1 / 40 * dlt;
	else {
		purchased_card_alpha = 0;
		purchased_card_type = -1;
		array_delete(cards_in_stock, current_card_index, 1);
		current_card_index--;
		current_card_index = max(current_card_index, 0);
		
		if(give_random_card) {
			random_card_timer = 240;
			audio_play_sound(snd_bid_won, 10, false, 0.7, 0, 2);
			give_random_card = false;
			if(array_length(_player.cards) < 8)
				array_push(_player.cards, irandom(CARD_TYPES.DECK_SIZE));
		}
	}
}

// Linker en rechter draaier
if(offered_left_ease < 1)
	offered_left_ease += 1 / 18 * dlt;
if(offered_right_ease < 1)
	offered_right_ease += 1 / 18 * dlt;
	
offered_left_ease = clamp(offered_left_ease, 0, 1);
offered_right_ease = clamp(offered_right_ease, 0, 1);

offered_left = lerp(floor(offered_left_start / 10) * 12, floor(offered_left_end / 10) * 12, ease_in_out_back(offered_left_ease));
offered_right = lerp(floor(offered_right_start) * 12, floor(offered_right_end) * 12, ease_in_out_back(offered_right_ease));

// Bieden
var _bidding_not_possible = 0;
can_purchase = true;
if((current_item_price > _player.feathers || _player.feathers == 0 || offered_price > _player.feathers)) {
	_bidding_not_possible = -0.3;
	can_purchase = false;
}
if(offered_price <= _player.feathers) {
	_bidding_not_possible = 0;
	can_purchase = true;
}

bidding_not_possible += (_bidding_not_possible - bidding_not_possible) / 6 * dlt;

if(random_card_timer >= 0) {
	random_card_alpha += (1 - random_card_alpha) / 7 * dlt;
	random_card_timer -= 1 * dlt;
} else {
	random_card_alpha -= random_card_alpha / 7 * dlt;
}

if(feng_can_harm) {
	feng_claw_alpha += (1 - feng_claw_alpha) / 4 * dlt;
	if(feng_strike >= 12) {
		feng_can_harm = false;
		audio_play_sound(snd_bid_lost, 1, false, 0.25);
		_player.hearts--;
		hurt_alpha = 1;
	}
}

if(feng_strike < sprite_get_number(spr_feng_claws) - 1) {
	feng_strike += 0.75 * dlt;
}
feng_strike = clamp(feng_strike, 0, sprite_get_number(spr_feng_claws) - 1);

if(hurt_alpha > 0)
	hurt_alpha -= 1 / 140 * dlt;
	
// Player is hurt
if(_player.hearts == 1) {
	heartbeat -= 1 * dlt;
	if(heartbeat <= 0) {
		heartbeat = 80;
		hurt_alpha += 0.4;
	}
}