varying vec2 v_vTexcoord;
varying vec4 v_vColour;

void main()
{
    gl_FragColor = texture2D( gm_BaseTexture, v_vTexcoord * vec2(1.0, -1.0) );
}
