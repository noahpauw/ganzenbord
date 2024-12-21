/// @description Laad een kaars in
event_inherited();

model		= global.__hex_candle_wax;
texture		= global.__tex_candle;
roughness	= global.__tex_bear_trap;
normal		= global.__tex_bear_trap_n;
matrix		= matrix_build(x, y, 0, 0, 0, irandom(360), 1, 1, 1);

volumetric	= 1;

flame_offset = {
	x: 0,
	y: 0,
	z: 0,
}

var _light_color = {
	r: 0.93 * 0.65,
	g: 0.46 * 0.65,
	b: 0.27 * 0.65,
};

currently_selected = false;
no_map = 1;

// Maak een belichting aan
//var _light_color = {
//	r: 1 * 0.85,
//	g: 0.65 * 0.85,
//	b: 0.31 * 0.85,
//};

add_light(x, y, 13, 40, _light_color.r, _light_color.g, _light_color.b);