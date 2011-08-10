/**
 * ...
 * @author Matthew Spencer
 */

package com.abc;

class CMath 
{

	public static inline function clampf( min:Float, max:Float, val:Float )
	{
		if ( val < min )
			val = min;
		else if ( val > max  )
			val = max;
		return val;
	}
	
}