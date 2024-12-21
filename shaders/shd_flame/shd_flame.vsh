attribute vec3 in_Position;                 // (x,y,z)
attribute vec3 in_Normal;					// (x,y,z)
attribute vec4 in_Colour;                   // (r,g,b,a)
attribute vec2 in_TextureCoord;             // (u,v)
attribute vec3 in_Tangents;					// (x,y,z)

varying vec2 v_vTexcoord;
varying vec4 v_vColour;
varying mat3 v_vNMatrix;
varying vec3 v_vNormal;
varying vec3 v_vVertexPosition;
varying vec3 v_vTangent;

uniform vec3 flame_offset;

void main()
{
    vec4 object_space_pos = vec4( vec3(in_Position + flame_offset * in_Colour.r), 1.0);
    gl_Position = gm_Matrices[MATRIX_WORLD_VIEW_PROJECTION] * object_space_pos;
    
    v_vColour = in_Colour;
    v_vTexcoord = in_TextureCoord;
}
