varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform float brightness;
uniform vec2 resolution;
uniform sampler2D spots;

float blendOverlay(float base, float blend) {
	return base<0.5?(2.0*base*blend):(1.0-2.0*(1.0-base)*(1.0-blend));
}

vec3 blendOverlay(vec3 base, vec3 blend) {
	return vec3(blendOverlay(base.r,blend.r),blendOverlay(base.g,blend.g),blendOverlay(base.b,blend.b));
}

vec3 blendOverlay(vec3 base, vec3 blend, float opacity) {
	return (blendOverlay(base, blend) * opacity + base * (1.0 - opacity));
}

float blendScreen(float base, float blend) {
	return 1.0-((1.0-base)*(1.0-blend));
}

vec3 blendScreen(vec3 base, vec3 blend) {
	return vec3(blendScreen(base.r,blend.r),blendScreen(base.g,blend.g),blendScreen(base.b,blend.b));
}

vec3 blendScreen(vec3 base, vec3 blend, float opacity) {
	return (blendScreen(base, blend) * opacity + base * (1.0 - opacity));
}

vec3 aces(vec3 x) {
  const float a = 2.51;
  const float b = 0.03;
  const float c = 2.43;
  const float d = 0.59;
  const float e = 0.14;
  return clamp((x * (a * x + b)) / (x * (c * x + d) + e), 0.0, 1.0);
}

float aces(float x) {
  const float a = 2.51;
  const float b = 0.03;
  const float c = 2.43;
  const float d = 0.59;
  const float e = 0.14;
  return clamp((x * (a * x + b)) / (x * (c * x + d) + e), 0.0, 1.0);
}

void main()
{
	float occlusion		= texture2D(spots, v_vTexcoord).r;
	
    vec4 main_color		= v_vColour * texture2D( gm_BaseTexture, v_vTexcoord ) * 0.2;
	main_color			+= v_vColour * texture2D( gm_BaseTexture, v_vTexcoord + vec2(-1.0, 0.0) / resolution ) * 0.2;
	main_color			+= v_vColour * texture2D( gm_BaseTexture, v_vTexcoord + vec2(1.0, 0.0) / resolution ) * 0.2;
	main_color			+= v_vColour * texture2D( gm_BaseTexture, v_vTexcoord + vec2(0.0, -1.0) / resolution ) * 0.2;
	main_color			+= v_vColour * texture2D( gm_BaseTexture, v_vTexcoord + vec2(0.0, 1.0) / resolution ) * 0.2;
	
	main_color.a		+= 0.1;
	
	main_color.a		*= mix(1.0, 0.0, occlusion);
	
	
	main_color.rgb		-= 0.04;
	main_color.rgb		*= 1.04;
	main_color.rgb		= clamp(main_color.rgb, vec3(0.0), vec3(1.0));
	
	main_color.rgb		= pow(main_color.rgb, vec3(1.22));
	
	main_color.rgb		= mix(blendOverlay(main_color.rgb, main_color.rgb), main_color.rgb, 0.35);
	
	main_color.rgb		= clamp(main_color.rgb, vec3(0.), vec3(1.));
	
	main_color.rgb		= mix(blendScreen(main_color.rgb, main_color.rgb), main_color.rgb, 0.5);
	
	main_color.rgb		= clamp(main_color.rgb, vec3(0.), vec3(1.));
	
	main_color.rgb		-= 0.055 + (brightness);
	main_color.rgb		= clamp(main_color.rgb, vec3(0.0), vec3(1.0));
	main_color.rgb		*= (1.0 - (brightness * 2.0));
	
	main_color.rgb		= clamp(main_color.rgb, vec3(0.0), vec3(1.0));
	
	main_color.rgb		= aces(main_color.rgb);
	main_color.rgb		= clamp(main_color.rgb, vec3(0.0), vec3(1.0));
	
	gl_FragColor		= main_color;
}
