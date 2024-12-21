/// @description Maak een projectie voor de spelers
if(!surface_exists(surf))
	surf = surface_create(display_get_width(), display_get_height(), surface_rgba32float);
	
if(!surface_exists(surf_dice))
	surf_dice = surface_create(display_get_width(), display_get_height(), surface_rgba32float);
	
if(!surface_exists(surf_tree))
	surf_tree = surface_create(display_get_width(), display_get_height(), surface_rgba32float);

surface_set_target(surf);
draw_clear(c_red);

var _xx, _yy, _zz;
_xx = x + dcos(face);
_yy = y - dsin(face);
_zz = z + dtan(pitch);

global.view_mat = matrix_build_lookat(x, y, z, _xx, _yy, _zz, 0, 0, 1);
global.proj_mat = matrix_build_projection_perspective_fov(-fov, aspect_ratio, 1, 1000);

var _camera = camera_get_active();
camera_set_view_mat(_camera, global.view_mat);
camera_set_proj_mat(_camera, global.proj_mat);
camera_apply(_camera);

// Big plane
shader_set(shd_sparks);

// Belichting
shader_set_uniform_f_array(shader_get_uniform(shd_sparks, "candles"), global.kaarsen);
shader_set_uniform_f_array(shader_get_uniform(shd_sparks, "candles_colors"), global.kaarsen_kleuren);
shader_set_uniform_i(shader_get_uniform(shd_sparks, "max_candles"), array_length(global.kaarsen) / 4);
shader_set_uniform_f(shader_get_uniform(shd_sparks, "camera_position"), x, y, z);
shader_set_uniform_f(shader_get_uniform(shd_sparks, "sky_color"), sky_color.r, sky_color.g, sky_color.b);
shader_set_uniform_f(shader_get_uniform(shd_sparks, "sky_color_accent"), accent_sky_color.r, accent_sky_color.g, accent_sky_color.b);

texture_set_stage(shader_get_sampler_index(shd_sparks, "normal_map"), sgt(spr_ground_normal, 0));

matrix_set(matrix_world, matrix_build(x, y, 0, 0, 0, 0, 1, 1, 1));
vertex_submit(global.__big_plane, pr_trianglelist, sgt(spr_map, 0));
matrix_set(matrix_world, matrix_build_identity());

shader_reset();

// Draw debug
gpu_set_blendenable(false);
shader_set(shd_lighting);

shader_set_uniform_f(shader_get_uniform(shd_lighting, "reflection_strength"), 0);
shader_set_uniform_f_array(shader_get_uniform(shd_lighting, "candles"), global.kaarsen);
shader_set_uniform_f_array(shader_get_uniform(shd_lighting, "candles_colors"), global.kaarsen_kleuren);
shader_set_uniform_i(shader_get_uniform(shd_lighting, "max_candles"), array_length(global.kaarsen) / 4);
shader_set_uniform_f(shader_get_uniform(shd_lighting, "camera_position"), x, y, z);
shader_set_uniform_f(shader_get_uniform(shd_lighting, "time"), current_time / 1000);
shader_set_uniform_f(shader_get_uniform(shd_lighting, "ignore_ndotl"), 0);
shader_set_uniform_f(shader_get_uniform(shd_lighting, "sky_color"), sky_color.r, sky_color.g, sky_color.b);
shader_set_uniform_f(shader_get_uniform(shd_lighting, "sky_color_accent"), accent_sky_color.r, accent_sky_color.g, accent_sky_color.b);

texture_set_stage(shader_get_sampler_index(shd_lighting, "world_map"), sgt(spr_map, 0));
texture_set_stage(shader_get_sampler_index(shd_lighting, "reflection_map"), sgt(hdr_reflection, 0));

shader_set_uniform_f(shader_get_uniform(shd_lighting, "wind_affection"), 0);

with(obj_tile) {
	if(!do_not_render) {
		texture_set_stage(shader_get_sampler_index(shd_lighting, "normal_map"), normal);
		texture_set_stage(shader_get_sampler_index(shd_lighting, "roughness_map"), roughness);
		
		shader_set_uniform_f(shader_get_uniform(shd_lighting, "volumetric"), volumetric);
		shader_set_uniform_f(shader_get_uniform(shd_lighting, "no_map"), no_map);
		shader_set_uniform_f(shader_get_uniform(shd_lighting, "currently_selected"), wait_to_show < 0 ? abs(dcos(global.selection_glow)) * currently_selected * 0.5 + (currently_selected * 0.25) + is_tile_available() * 0.05 : 0);
		matrix_set(matrix_world, matrix);
		vertex_submit(model, pr_trianglelist, texture);
		matrix_set(matrix_world, matrix_build_identity());
	}
}

with(parent_drawable) {
	texture_set_stage(shader_get_sampler_index(shd_lighting, "normal_map"), normal);
	texture_set_stage(shader_get_sampler_index(shd_lighting, "roughness_map"), roughness);
		
	shader_set_uniform_f(shader_get_uniform(shd_lighting, "volumetric"), volumetric);
	shader_set_uniform_f(shader_get_uniform(shd_lighting, "no_map"), no_map);
	shader_set_uniform_f(shader_get_uniform(shd_lighting, "currently_selected"), 0);
	matrix_set(matrix_world, matrix);
	vertex_submit(model, pr_trianglelist, albedo);
	matrix_set(matrix_world, matrix_build_identity());
}

surface_set_target(surf_tree);
draw_clear_alpha(make_color_rgb(sky_color.r, sky_color.g, sky_color.b), 0);

var _camera = camera_get_active();
camera_set_view_mat(_camera, global.view_mat);
camera_set_proj_mat(_camera, global.proj_mat);
camera_apply(_camera);

shader_set_uniform_f(shader_get_uniform(shd_lighting, "ignore_ndotl"), 0);

// Dit is een boom
shader_set_uniform_f(shader_get_uniform(shd_lighting, "wind_affection"), 2);		
shader_set_uniform_f(shader_get_uniform(shd_lighting, "no_map"), 1);
shader_set_uniform_f(shader_get_uniform(shd_lighting, "volumetric"), 0);
shader_set_uniform_f(shader_get_uniform(shd_lighting, "currently_selected"), 0);
		
texture_set_stage(shader_get_sampler_index(shd_lighting, "normal_map"), sgt(spr_tree, 1));
texture_set_stage(shader_get_sampler_index(shd_lighting, "roughness_map"), sgt(spr_roughness_tree, 0));
		
with(obj_tile) {
	if(do_not_render) {
		shader_set_uniform_f(shader_get_uniform(shd_lighting, "tree_speed"), tree_speed[0], tree_speed[1]);
		matrix_set(matrix_world, matrix_tree);
		vertex_submit(global.__tree, pr_trianglelist, sgt(spr_tree, 0));
		matrix_set(matrix_world, matrix_build_identity());
	}
}

shader_set_uniform_f(shader_get_uniform(shd_lighting, "wind_affection"), 0);
surface_reset_target();

shader_set_uniform_f(shader_get_uniform(shd_lighting, "ignore_ndotl"), 0);

with(obj_candle_wax) {
	texture_set_stage(shader_get_sampler_index(shd_lighting, "normal_map"), normal);
	texture_set_stage(shader_get_sampler_index(shd_lighting, "roughness_map"), roughness);

	shader_set_uniform_f(shader_get_uniform(shd_lighting, "volumetric"), volumetric);
	shader_set_uniform_f(shader_get_uniform(shd_lighting, "no_map"), no_map);
	shader_set_uniform_f(shader_get_uniform(shd_lighting, "currently_selected"), 0);
	matrix_set(matrix_world, matrix);
	vertex_submit(model, pr_trianglelist, texture);
	matrix_set(matrix_world, matrix_build_identity());
}
gpu_set_blendenable(true);

shader_set_uniform_f(shader_get_uniform(shd_lighting, "no_map"), 1);


with(obj_pawn) {
	texture_set_stage(shader_get_sampler_index(shd_lighting, "normal_map"), normal);
	texture_set_stage(shader_get_sampler_index(shd_lighting, "roughness_map"), roughness);

	shader_set_uniform_f(shader_get_uniform(shd_lighting, "volumetric"), 0);
	matrix_set(matrix_world, matrix);
	vertex_submit(model, pr_trianglelist, texture);
	
	matrix_set(matrix_world, matrix_build_identity());
}

// Teken een pawn
vertex_submit(global.__hex_pawn, pr_trianglelist, -1);

with(obj_tile) {
	if(!is_undefined(shadow)) {
		texture_set_stage(shader_get_sampler_index(shd_lighting, "roughness_map"), sprite_get_texture(tex_full_roughness, 0));
		
		matrix_set(matrix_world, matrix);
		gpu_set_zwriteenable(false);
	
		vertex_submit(shadow, pr_trianglelist, texture_shadow);
		
		gpu_set_zwriteenable(true);
		matrix_set(matrix_world, matrix_build_identity());
	}
}

shader_reset();

// Schaduw onder objecten
gpu_set_zwriteenable(false);

shader_set(shd_ambient_occlusion);
with(parent_drawable) {
	if(!is_undefined(ao_model) && !is_undefined(ao_texture)) {
		matrix_set(matrix_world, shadow_matrix);
		vertex_submit(ao_model, pr_trianglelist, ao_texture ?? sgt(tex_ao_shop, 0));
		matrix_set(matrix_world, matrix_build_identity());
	}
}
gpu_set_zwriteenable(true);

shader_reset();

shader_set(shd_flame);
gpu_set_blendmode(bm_max);

with(obj_candle_wax) {
	shader_set_uniform_f(shader_get_uniform(shd_flame, "flame_offset"), flame_offset.x * 0.2, flame_offset.y * 0.2, flame_offset.z * 0.2);
	var _mat = matrix_build(x, y, 12.5, 0, 0, obj_camera.face + 180, 1, 1, 1);
	matrix_set(matrix_world, _mat);
	vertex_submit(global.__hex_candle_flame, pr_trianglelist, global.__tex_candle_flame);
	matrix_set(matrix_world, matrix_build_identity());
}

gpu_set_ztestenable(false);
with(obj_candle_wax) {
	shader_set_uniform_f(shader_get_uniform(shd_flame, "flame_offset"), 0, 0, 0);
	var _mat = matrix_build(x, y, 13.5, 0, -obj_camera.pitch, obj_camera.face + 180, 13, 13, 13);
	matrix_set(matrix_world, _mat);
	vertex_submit(global.__hex_effect, pr_trianglelist, global.__tex_lens_flare);
	matrix_set(matrix_world, matrix_build_identity());
}
gpu_set_ztestenable(true);

gpu_set_blendmode(bm_normal);
shader_reset();

surface_reset_target();

// Dobbelsteen
surface_set_target(surf_dice);
draw_clear_alpha(c_black, 0.0);

// Camera
var _xx, _yy, _zz;
_xx = x + dcos(face);
_yy = y - dsin(face);
_zz = z + dtan(pitch);

global.view_mat = matrix_build_lookat(x, y, z, _xx, _yy, _zz, 0, 0, 1);
global.proj_mat = matrix_build_projection_perspective_fov(-fov, aspect_ratio, 1, 1000);

var _camera = camera_get_active();
camera_set_view_mat(_camera, global.view_mat);
camera_set_proj_mat(_camera, global.proj_mat);
camera_apply(_camera);

// Teken dobbelsteen
var _player = get_current_player();
if(_player) {
	shader_set(shd_lighting);

	shader_set_uniform_f_array(shader_get_uniform(shd_lighting, "candles"), global.kaarsen);
	shader_set_uniform_f_array(shader_get_uniform(shd_lighting, "candles_colors"), global.kaarsen_kleuren);
	shader_set_uniform_i(shader_get_uniform(shd_lighting, "max_candles"), array_length(global.kaarsen) / 4);
	shader_set_uniform_f(shader_get_uniform(shd_lighting, "camera_position"), x, y, z);
	texture_set_stage(shader_get_sampler_index(shd_lighting, "world_map"), sgt(tex_full_roughness, 0));

	texture_set_stage(shader_get_sampler_index(shd_lighting, "normal_map"), dice_texture[_player.current_dice].normal);
	texture_set_stage(shader_get_sampler_index(shd_lighting, "roughness_map"), sgt(spr_spark, 0));

	shader_set_uniform_f(shader_get_uniform(shd_lighting, "volumetric"), 0);
	shader_set_uniform_f(shader_get_uniform(shd_lighting, "currently_selected"), 0);

	shader_set_uniform_f(shader_get_uniform(shd_lighting, "reflection_strength"), dice_shine[_player.current_dice]);
	
	matrix_set(matrix_world, dice_matrix);
	vertex_submit(dice_model[_player.current_dice], pr_trianglelist, dice_texture[_player.current_dice].albedo);
	matrix_set(matrix_world, matrix_build_identity());
	
	shader_set_uniform_f(shader_get_uniform(shd_lighting, "reflection_strength"), 0);

	shader_reset();
}

surface_reset_target();