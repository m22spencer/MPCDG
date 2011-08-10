/**
 * ...
 * @author Matthew Spencer
 */

package com.codex.c3dex.bcode;

class BytecodeGroup 
{
	var __abc__:Array<Dynamic>->Void;
	var ctx:format.abc.Context;
	
	public function new( abcfunc:Array<Dynamic>->Void, ctx:format.abc.Context ) 
	{
		__abc__ = abcfunc;
		this.ctx = ctx;
	}

}