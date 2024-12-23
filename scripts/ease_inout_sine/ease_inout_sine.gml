/// @description ease_inout_sine(time, start, change, duration)
/// @param time
/// @param  start
/// @param  change
/// @param  duration
function ease_inout_sine(argument0, argument1, argument2, argument3) {

	/*
	you need to set up a timer for the "time" variable

	time        = the point in time along the graph e.g. at the start 0
	start       = value of the starting point e.g. at the start 100
	change      = the change between starting value and end value e.g. 50 so the end value would be 150
	duration    = amount of "time" it should take to reach the end value e.g. 30 
	*/

	return argument2 * 0.5 * (1 - cos(pi * argument0 / argument3)) + argument1;



}

function ease_out_elastic(_x) {
	var _c4 = (2 * pi) / 3;
	if(_x == 0)
		return 0;
	return _x == 1 ? 1 : power(2, -10 * _x) * sin((_x * 10 - 0.75) * _c4) + 1;
}