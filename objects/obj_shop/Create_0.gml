/// @description Dit model wordt getekend door één object
event_inherited();

model			= global.__shop;
matrix			= matrix_build(x, y, 0, 0, 0, 130, 1, 1, 1);

// Textures
albedo			= sgt(tex_shop, 0);
normal			= sgt(tex_shop, 1);
roughness		= sgt(spr_tile_roughness, 0);

// Overig
is_volumetric	= 0;
alarm[0]		= 5;
bounce			= 0;

light_color = {
	r: 0.93 * 0.65,
	g: 0.46 * 0.65,
	b: 0.27 * 0.65,
};


ao_model		= global.__ao_shop;
ao_texture		= sgt(tex_ao_shop, 0);
can_change_to_shop	= false;
shadow_matrix	= matrix_build(x, y, 0, 0, 0, 130, 1, 1, 1);
