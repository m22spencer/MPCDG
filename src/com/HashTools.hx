/**
 * ...
 * @author Matthew Spencer
 */

package com;

class HashTools 
{

	public static function keysExcluding<T>( hash:Hash<T>, exclude:Array<String> )
	{
		var a:Array<String> = new Array( );
		
		for ( key in hash.keys( ) )
		{

			var isValid:Bool = true;
			for ( inv in exclude )
			{
				if ( inv == key )
					isValid = false;
			}
			if ( isValid )
				a.push( key );
		}
		return a;
	}
	
}