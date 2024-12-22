/// @description De verkoper

/**
 * Dit is Feng, de grote draak, de verkoper
 * Bij de verkoper is het mogelijk om veren in te ruilen voor kaarten.
 * Je kunt ook afdingen bij de verkoper, maar wees voorzichtig: als hij vindt dat je te veel afdingt, schopt
 * hij je zo de winkel uit.
*/

cards_in_stock = [];
repeat(13) {
	array_push(cards_in_stock, irandom(CARD_TYPES.DECK_SIZE - 1));
}

current_card_index = 0;
swap_card = 1;
bidding_not_possible = 0;

// Kiezen van een andere kaart
switch_card = 0;

// Bewegen van kaart
from_x = 0;
to_x = 0;
movement = 0;

// Ogen beweging
eye_rot_x = 0;
eye_rot_y = 0;

eye_rot_xx = 0;
eye_rot_yx = 0;

eye_change = random(41);
eye_speed = 8;

// Snuit
feng_maw_open = 0;
feng_angry = false;

hold_eyes_shut = 240;
blink = 1;
blink_timer = 240;

// Onderhandelen/pingelen
eye_slits = 0;
haggle_movement = 0;
haggle_index = -1;
offered_price = 0;
current_item_price = 0;

await_vendor_response = 240;
made_bid = false;

purchased_card_type = -1;
purchased_card_alpha = 0;

offered_left_start = 0;
offered_left_end = 0;
offered_left_ease = 0;
offered_left = 0;

offered_right_start = 0;
offered_right_end = 0;
offered_right_ease = 0;
offered_right = 0;

force_angry = -20 ;
can_purchase = true;

give_random_card = false;
random_card_timer = 0;
random_card_alpha = 0;

feng_claw_alpha = 0;
feng_strike = 0;
feng_can_harm = false;

hurt_alpha = 0;
heartbeat = 60;

is_leaving = false;
leave_timer = 120;
