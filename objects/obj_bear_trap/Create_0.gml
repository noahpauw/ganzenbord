/// @description Laad een berenval in
event_inherited();

model		= global.__hex_bear_trap;

texture		= global.__tex_bear_trap;
normal		= global.__tex_bear_trap_n;
roughness	= global.__tex_bear_trap_r;

matrix		= matrix_build(x, y, 0, 0, 0, irandom(360), 1, 1, 1);

volumetric	= 0;
currently_selected = false;

shadow		= global.__hex_bear_trap_shade;
texture_shadow = global.__tex_bear_trap_s;
no_map = 1;