/// @description Verander het vlammetje
flame_offset.x += (perlin_noise(current_time / 400) - flame_offset.x) / 10;
flame_offset.y += (perlin_noise(current_time / 500) - flame_offset.y) / 10;
flame_offset.z += (perlin_noise(current_time / 350) - flame_offset.z) / 10;