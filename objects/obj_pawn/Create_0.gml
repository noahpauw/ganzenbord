/// @description Een pion die hoort bij een speler
model		= global.__hex_pawn;
texture		= sgt(spr_goose_pawn, 0);
normal		= global.__tex_normal_tile;
roughness	= sgt(tex_goose_roughness, 0);
matrix		= matrix_build(x, y, 0, 0, 0, 0, 1, 1, 1);

volumetric	= 0;
currently_selected = false;
shadow		= undefined;
texture_shadow = -1;

current_player_id = 0;
scale		= 1;

light_color = {
	r: 0.93 * 0.65,
	g: 0.46 * 0.65,
	b: 0.27 * 0.65,
};

current_dice = DICE_TYPES.ONE_TWO_THREE;

alarm[0]	= 5;
to_x		= x;
to_y		= y;

cur_x		= x;
cur_y		= y;

move_lerp	= 1;
z			= 0;
can_noise	= false;
inversion	= 0;

can_throw_dice = true;

last_x		= x;
last_y		= y;