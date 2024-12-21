/// @description Object tekent alles
model			= global.__dice_123;
matrix			= matrix_build(x, y, 0, 0, 0, 0, 1, 1, 1);
shadow_matrix	= matrix_build(x, y, 0, 0, 0, 0, 1, 1, 1);

no_map			= 1;

albedo			= -1;
normal			= -1;
roughness		= sgt(spr_spark, 0);

is_volumetric	= 0;
volumetric		= 0;

ao_model		= undefined;
ao_texture		= undefined;