/**
 * ...
 * @author Matthew Spencer
 */

package com.codex.c3dex.bcode.types;
import com.abc.Data;
import com.abc.Reg;

class BSingle
{

	var m0:Dynamic;
	
	function new() 
	{
		
	}
	
	public function get( )
	{
		if( m0 == 
	}
	
	public static var stack():BSingle
	{
		var b = new BSingle( );
		b.m0 = -1;
		return b;
	}
	
	public static var reg( r:Reg ):BSingle
	{
		var b = new BSingle( );
		b.m0 = r;
		return b;
	}
	
}