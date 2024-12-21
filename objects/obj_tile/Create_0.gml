/// @description Laad een tegel in
model		= global.__hex_tile_basic;
texture		= global.__tex_tile;
normal		= global.__tex_normal_tile;
roughness	= global.__tex_roughness_tile;
matrix		= matrix_build(x, y, 0, 0, 0, 0, 1, 1, 1);

var _scale	= random_range(0.89, 1.06);
matrix_tree		= matrix_build(x, y, 0, 0, 0, random(360), _scale, _scale, _scale);

volumetric	= 0;
currently_selected = false;
shadow		= undefined;
texture_shadow = -1;

good_tile	= choose(true, false);
discovered	= false;
no_map		= 0;
do_not_render = false;

tree_speed	= [random_range(2, 8), random_range(2, 8)];
wait_to_show = -100;
