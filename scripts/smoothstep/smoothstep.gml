function smoothstep( _from, _to, _amount, _offset = 1 )
{
    var diff = _to - _from;
    var diff_sign = sign(diff);
    if diff_sign == 0
        return _to;
       
    diff *= diff_sign;
    return _from + diff_sign * min( (diff + _offset) * _amount, diff );
}