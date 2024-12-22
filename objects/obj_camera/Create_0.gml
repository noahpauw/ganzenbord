/// @description De camera in het spel
#macro aspect_ratio display_get_width() / display_get_height()
#macro aa_amount 0
#macro sgt sprite_get_texture
#macro FOREST_MASKS working_directory + "masks/forest_masks.ini"
#macro SHOPS working_directory + "masks/shops_positions.ini"
#macro MUSIC true
#macro SHUFFLE_AMOUNT 1
#macro MUSIC_CHANGE_SPEED_MILLISECONDS 1000
#macro MUSIC_LOUDNESS 0.42
#macro FAST_MUSIC_CHANGE 1000
#macro SLOW_MUSIC_CHANGE 5000
#macro INSTANT_MUSIC_CHANGE 1
#macro DEBUGGING 0
#macro INIT_GAME_PROGRESS GAME_PROGRESS.PRE_MENU
#macro INIT_ATMOSPHERE ATMOSPHERE.CALM

global.music_change_speed = FAST_MUSIC_CHANGE;

// irandom_range(6, 9)

randomize();
audio_bus_main.gain = 0;

globalvar dlt;
dlt = 1;

zooming = 1;

dice_types = [];
dice_types[DICE_TYPES.ONE_TWO_THREE] = {
	title: "Standaard dobbelsteen",
	description: "Met de standaard dobbelsteen kun je 1, 2 en 3 gooien. Iedere uitkomst komt twee keer voor op de dobbelsteen."
};
	
dice_types[DICE_TYPES.QUICK_DICE] = {
	title: "Snelle dobbelsteen",
	description: "Deze snelle steen is een dobbelsteen waar 0, 1, 2 en 4 op voorkomen. Hiermee kun je heel wat stappen zetten als je geluk hebt."
};

dice_types[DICE_TYPES.CARDS] = {
	title: "Kaart dobbelsteen",
	description: "Deze dobbelsteen heeft een kans van 5 op 6 om je een willekeurige kaart te geven. Maar let op! Er is ook een kans om gestraft te worden...",
}

dice_types[DICE_TYPES.LIVES] = {
	title: "Dobbelsteen des levens",
	description: "Met deze dobbelsteen heb je kans op 1 hartje. De rest van de steen geeft je de mogelijkheid om 0 of 1 stap vooruit te komen.",
}

global.keyboard = [
	["Q", "W", "E", "R", "T", "Y", "U", "I", "O", "P"],
	["A", "S", "D", "F", "G", "H", "J", "K", "L"],
	["Z", "X", "C", "V", "B", "N", "M"]
];
current_letter = 0;

dice_shine = [];
dice_shine[DICE_TYPES.ONE_TWO_THREE] = 0.15;
dice_shine[DICE_TYPES.QUICK_DICE] = 0.75;
dice_shine[DICE_TYPES.CARDS] = 0.1;
dice_shine[DICE_TYPES.LIVES] = 0.3;

throwing = false;

// Alleen gebruiken na worp
use_after_throw = [];
use_after_throw[CARD_TYPES.ADD_ONE] = true;
use_after_throw[CARD_TYPES.SECOND_CHANCE] = false;
use_after_throw[CARD_TYPES.SWORD] = true;
use_after_throw[CARD_TYPES.SHIELD] = true;

use_after_move = [];
use_after_move[CARD_TYPES.ADD_ONE] = false;
use_after_move[CARD_TYPES.SECOND_CHANCE] = true;
use_after_move[CARD_TYPES.SWORD] = true;
use_after_move[CARD_TYPES.SHIELD] = true;

is_unusable[CARD_TYPES.ADD_ONE] = false;
is_unusable[CARD_TYPES.SECOND_CHANCE] = false;
is_unusable[CARD_TYPES.SWORD] = true;
is_unusable[CARD_TYPES.SHIELD] = true;

current_atmosphere = INIT_ATMOSPHERE;
global.game_progress = INIT_GAME_PROGRESS;

music_tracks = [];
music_tracks[ATMOSPHERE.CALM]			= mus_gameplay;
music_tracks[ATMOSPHERE.WOLVES_PRESENT] = mus_gameplay;
music_tracks[ATMOSPHERE.DRAGON_PRESENT] = mus_dragon;
music_tracks[ATMOSPHERE.GATE_OPEN]		= mus_gameplay;
music_tracks[ATMOSPHERE.IN_SHOP]		= mus_vendor;
music_tracks[ATMOSPHERE.HAGGLING]		= mus_vendor_haggling;

global.music = undefined;
start_location = 0;

game_volume = 0;
audio_play_sound(snd_amb_wind, 100, true, 0.7);
audio_play_sound(snd_crickets, 100, true, 0.7);

card_width = [];
var _index = 0;
repeat(8) {
	card_width[_index] = 0;
	_index++;
}
	
card_animation = -1;

owl_timer = random_range(360, 12000);

#region Kaart beschrijvingen
card_descriptions = [];
card_descriptions[CARD_TYPES.SECOND_CHANCE] = {
	title: "Tweede kans",
	description: "Niet tevreden met de uitkomst van je vorige worp? Gooi opnieuw!",
	cost: 10,
};

card_descriptions[CARD_TYPES.ADD_ONE] = {
	title: "+1",
	description: "Voeg 1 toe aan de uitkomst van je worp.",
	cost: 8,
};

card_descriptions[CARD_TYPES.SWORD] = {
	title: "Zilveren zwaard",
	description: "Neem twee hartjes weg van een vijand als je deze raakt. (Werkt niet bij Feng)",
	cost: 15,
};

card_descriptions[CARD_TYPES.SHIELD] = {
	title: "Gouden schild",
	description: "Wordt automatisch gebruikt als je geraakt wordt door een vijand. Deze kaart beschermt je tegen vijandelijke aanvallen. (Werkt niet tegen Feng)",
	cost: 10,
};

card_descriptions[CARD_TYPES.DOUBLE_DICE] = {
	title: "2× dobbelsteen",
	description: "Gooi met twee standaard dobbelstenen tegelijk.",
	cost: 12,
};

card_descriptions[CARD_TYPES.GIVE_DARK_HEARTS] = {
	title: "Donkere harten",
	description: "Geeft je 10 extra donkere harten. Deze harten bieden je niet alleen bescherming tegen tegenstanders en vijanden, maar nemen ook een hartje weg bij je aanvallers.",
	cost: 20,
};

card_descriptions[CARD_TYPES.GIVE_HEART] = {
	title: "Elixer A",
	description: "Geeft je een extra hartje.",
	cost: 10,
};

card_descriptions[CARD_TYPES.GIVE_TWO_HEARTS] = {
	title: "Elixer B",
	description: "Geeft je twee extra hartjes",
	cost: 15,
};

card_descriptions[CARD_TYPES.GO_TO_SHOP] = {
	title: "Afsnijroute",
	description: "Ga direct naar de dichtsbijzijnde winkel.",
	cost: 13,
};

card_descriptions[CARD_TYPES.HALF_OFF] = {
	title: "Uitverkoop",
	description: "Alle voorwerpen bij de verkoper worden 50% goedkoper voor drie rondes.",
	cost: 20,
};

card_descriptions[CARD_TYPES.PUNISH_OTHER] = {
	title: "Hoogverraad",
	description: "Neem een hartje weg van een tegenstander naar keuze.",
	cost: 20,
};

card_descriptions[CARD_TYPES.REVIVE] = {
	title: "Reïncarnatie",
	description: "Kom weer terug tot leven zodra je hartjes op zijn.",
	cost: 40,
};

card_descriptions[CARD_TYPES.TAKE_CARD] = {
	title: "Sluwe dief",
	description: "Steel een kaart van een tegenstander naar keuze. Je kunt niet kiezen welke kaart je steelt.",
	cost: 25,
};

card_descriptions[CARD_TYPES.TAKE_FEATHERS] = {
	title: "Geldwolf",
	description: "Steel de helft van de veren van een tegenstander naar keuze.",
	cost: 25,
};

card_descriptions[CARD_TYPES.DOUBLE_PRICE] = {
	title: "Inflatie",
	description: "Alle items in de shop worden voor je tegenstanders 100% duurder.",
	cost: 30,
};
#endregion

inventory_type = INVENTORY_TYPES.DICE;

instance_create_depth(x, y, -10, obj_vendor);

// Positie van de speler
xx			= x;
yy			= y;

blur_alpha	= 0;
blur_max	= 0;

face		= -90;
pitch		= -50;
z			= 0.99;

fov			= 47;
zoom_out	= 0.99;

global.view_mat = undefined;
global.proj_mat = undefined;

global.cursor_x = display_get_width() / 2;
global.cursor_y = display_get_height() / 2;
display_mouse_set(display_get_width() / 2, display_get_height() / 2);

global.available_tiles = ds_list_create();

shuffle_players	= 120;
shuffling		= SHUFFLE_AMOUNT;
interpolation_speed = 90;

// 3D aanzetten
gpu_set_zwriteenable(true);
gpu_set_ztestenable(true);

gpu_set_tex_repeat(true);

display_reset(aa_amount, false);

// Inschakelen mipmapping
gpu_set_tex_mip_enable(mip_on);
gpu_set_tex_mip_filter(tf_anisotropic);
gpu_set_cullmode(cull_counterclockwise);

// Surfaces
application_surface_enable(false);
surf = -1;
brightness = 0;

// Uniforms
u_pp_brightness = shader_get_uniform(shd_post_processing, "brightness");
global.current_tile = -1;

#region Vertex formaat
var _vertex_format;
vertex_format_begin();
vertex_format_add_position_3d();
vertex_format_add_normal();
vertex_format_add_color();
vertex_format_add_texcoord();
vertex_format_add_custom(vertex_type_float3, vertex_usage_texcoord);
_vertex_format = vertex_format_end();
#endregion

// 3D modellen inladen
global.__hex_tile_basic = open_vertex_buffer("tiles/hex_tile_basic.vb", _vertex_format, true);
global.__hex_candle_wax = open_vertex_buffer("tiles/hex_candle_wax.vb", _vertex_format, true);
global.__hex_candle_flame = open_vertex_buffer("tiles/hex_candle_flame.vb", _vertex_format, true);
global.__hex_effect = open_vertex_buffer("tiles/hex_effect.vb", _vertex_format, true);
global.__hex_bear_trap = open_vertex_buffer("tiles/hex_bear_trap.vb", _vertex_format, true);
global.__hex_bear_trap_shade = open_vertex_buffer("tiles/hex_bear_trap_shade.vb", _vertex_format, true);

// Dobbelstenen
global.__dice_123 = open_vertex_buffer("die/dice_123.vb", _vertex_format, true);
global.__dice_fast = open_vertex_buffer("die/dice_fast.vb", _vertex_format, true);

// Mijn mooie Feng
global.__feng_eye = open_vertex_buffer("feng/feng_eye.vb", _vertex_format, true);

// Plane 16
global.__plane_16 = open_vertex_buffer("ui/plane_16.vb", _vertex_format, true);

// Shops
global.__shop = open_vertex_buffer("special_blocks/shop.vb", _vertex_format, true);
global.__ao_shop = open_vertex_buffer("special_blocks/ao_shop.vb", _vertex_format, true);

dice_model = [];
dice_model[DICE_TYPES.ONE_TWO_THREE] = global.__dice_123;
dice_model[DICE_TYPES.QUICK_DICE] = global.__dice_fast;

dice_texture = [];
dice_texture[DICE_TYPES.ONE_TWO_THREE] = {
	albedo: sgt(tex_dice, 0),
	normal: sgt(spr_tile_normal, 0)
}

dice_texture[DICE_TYPES.QUICK_DICE] = {
	albedo: sgt(tex_dice, 1),
	normal: sgt(tex_normal_special, 0)
}

// Big plane
global.__big_plane = open_vertex_buffer("big_plane.vb", _vertex_format, true);

// Pionnen modellen
global.__hex_pawn = open_vertex_buffer("pawns/hex_pawn.vb", _vertex_format, true);

// Omgeving
global.__tree = open_vertex_buffer("environment/tree.vb", _vertex_format, true);

// Textures
global.__tex_tile = sprite_get_texture(spr_tile, 0);
global.__tex_candle = sprite_get_texture(spr_candle_wax, 0);
global.__tex_normal_tile = sprite_get_texture(spr_tile_normal, 0);
global.__tex_roughness_tile = sprite_get_texture(spr_tile_roughness, 0);
global.__tex_candle_flame = sprite_get_texture(spr_candle_flame, 0);
global.__tex_lens_flare = sprite_get_texture(spr_lens_flare, 0);

// Berenval
global.__tex_bear_trap = sprite_get_texture(tex_bear_trap, 0);
global.__tex_bear_trap_n = sprite_get_texture(tex_bear_trap_normal, 0);
global.__tex_bear_trap_r = sprite_get_texture(tex_bear_trap_roughness, 0);
global.__tex_bear_trap_s = sprite_get_texture(tex_bear_trap_ao, 0);

// Spawn de tegels
for(var i = 0; i < 30; i++) {
	for(var j = 0; j < 30; j++) {
		var _top = i % 2 != 0 ? 3.5 : 0;
		instance_create_depth(x + i * 6.1, y + _top - j * 7, -10, obj_tile);
	}
}

// Teken ze niet allemaal
global.center_x = x + 15 * 6.1;
global.center_y = y - 15 * 7;

var _max_map_size = 90;
with(obj_tile) {
	if(point_distance(x, y, global.center_x, global.center_y) > _max_map_size)
		do_not_render = true;
}

cam_distance = 28;
cam_rotate = 90;
zoomer = 0;

xx += 6.1 * 15;
yy -= 7 * 15 - 3.5;

alarm[0] = 5;

x = xx;
y = yy;

dice_fade_in = 0;

blur_resolution = 2;

// Belichting plekken
global.kaarsen = [];
global.kaarsen_kleuren = [];

global.ds_kaarsen = ds_list_create();
global.ds_kaarsen_kleuren = ds_list_create();

// instance_create_depth(xx, yy, -10, obj_candle_wax);
instance_create_depth(xx - 6.1 * 9, yy + 7 * 4 + 3.5, -10, obj_candle_wax);

xto = xx;
yto = yy;

global.is_using_inventory = false;

with(instance_nearest(xx, yy, obj_tile))
	currently_selected = true;
	
global.selection_glow = 0;
global.even = 0;
global.adding_player = false;

new_player_name = "";

global.players = ds_list_create();
global.color_players = [c_white, c_white, c_white, c_white];
global.game_has_started = false;

// Geluid harder
audio_bus_main.gain = 1.5;
window_set_cursor(cr_none);

global.current_player = 0;
intro_has_played = false;
start_music = false;

// Voor het bepalen van de volgorde
lerp_player_names = 1;
init_player_position = [];

cloud_alpha = 0;
longest_name_offset = 0;

global.current_player_x = 0;
global.current_player_y = 0;
wait_to_make_available = -100;

surf_blur_hor			= -1;
surf_blur_ver			= -1;
surf_dice				= -1;
surf_tree				= -1;
surf_occlusion			= -1;
surf_occlusion_shader	= -1;

dice_matrix				= -1;

dice_rotation_x			= 0;
dice_rotation_y			= 0;
dice_rotation_z			= 0;

final_dice_rotation_x	= 0;
final_dice_rotation_y	= 0;
final_dice_rotation_z	= 0;

last_dice_rotation_x	= 0;
last_dice_rotation_y	= 0;
last_dice_rotation_z	= 0;

dice_throw_z			= 0;
dice_throw_z_speed		= 0;

dice_rotation_xspeed	= random_range(8, 12);
dice_rotation_yspeed	= random_range(8, 12);
dice_rotation_zspeed	= random_range(8, 12);

finish_throw			= false;
dice_interpolation		= 0;
wait_after_dice			= 60;

outcome					= -1;
add_heart				= 3;

// Inventory
fade_inventory			= 0;
fade_inventory2			= 0;
fade_inventory3			= 0;
current_inventory		= 0;

// Bestand met maskers
if(file_exists(FOREST_MASKS)) {
	ini_open(FOREST_MASKS);
	var _ind = 0;
	var _sect = string("sect{0}", _ind);
	while(ini_section_exists(_sect)) {
		show_debug_message("Init");
		var _x, _y;
		_x = ini_read_real(_sect, "x", 0);
		_y = ini_read_real(_sect, "y", 0);
		
		instance_create_depth(_x, _y, -10, obj_forest_mask);
		
		_ind++;
		_sect = string("sect{0}", _ind);
	}
	ini_close();
}

// Shops
if(file_exists(SHOPS)) {
	ini_open(SHOPS);
	var _ind = 0;
	var _sect = string("sect{0}", _ind);
	while(ini_section_exists(_sect)) {
		show_debug_message("Init");
		var _x, _y;
		_x = ini_read_real(_sect, "x", 0);
		_y = ini_read_real(_sect, "y", 0);
		
		instance_create_depth(_x, _y, -10, obj_shop);
		
		_ind++;
		_sect = string("sect{0}", _ind);
	}
	ini_close();
}

// Gebruik de maskers
with(obj_tile) {
	if(place_meeting(x, y, obj_forest_mask))
			do_not_render = true;
}

global.last_card_picked = -1;
global.last_outcome = -1;

dice_boredom		= 0.8;
comb_speed_x		= 0;
comb_speed_y		= 0;

// Vignette setup
vig_x				= display_get_width() / sprite_get_width(spr_vignette);
vig_y				= display_get_height() / sprite_get_height(spr_vignette);

// Uniforms
u_brightness_brightness = shader_get_uniform(shd_brightness, "brightness");

// 2D vlam
u_flame_2d_time = shader_get_uniform(shd_flame_2d, "time");
u_flame_2d_cloud = shader_get_sampler_index(shd_flame_2d, "clouds");
u_flame_2d_alpha = shader_get_uniform(shd_flame_2d, "alpha");
u_flame_2d_intensity = shader_get_uniform(shd_flame_2d, "intensity");
u_flame_2d_cloud_size = shader_get_uniform(shd_flame_2d, "cloud_size");
u_flame_2d_threshold = shader_get_uniform(shd_flame_2d, "threshold");

flame_alpha = 0;
candle_brightness = -1;
menu_fade_in = -1;

draw_set_font(fnt_subtitle);

// Lucht kleuren
sky_color = {
	r: 32 / 192,
	g: 41 / 192,
	b: 56 / 192,
}

accent_sky_color = {
	r: 0.15,
	g: 0.176,
	b: 0.188,
}

menu_intensity = 1.6;
pressed_start = false;

// Testing
if(DEBUGGING) {
	var _beat_sizes = [];
	repeat(15) 
		array_push(_beat_sizes, 0);
					
	var _beat_offsets = [];
	repeat(15) 
		array_push(_beat_offsets, random(180));
						
	ds_list_add(global.players, {
		name: "Feng",
		name_x: 32,
		name_y: 32,
		inversion: 0,
		special_dices: [],
		cards: [CARD_TYPES.SECOND_CHANCE, CARD_TYPES.ADD_ONE, CARD_TYPES.SWORD, CARD_TYPES.SHIELD],
		hearts: 5,
		beat_offset: _beat_offsets,
		beat_size: _beat_sizes,
		feathers: 35,
	});
}

global.dual_shock_left = 0;
global.dual_shock_right = 0;