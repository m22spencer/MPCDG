/**
 * ...
 * @author Matthew Spencer
 */

package com.codex.c3dex.mapping;

import com.abc.Data;
import com.abc.Reg;
import format.abc.Data;

class VertexMapper 
{

	public var vertex_size_bytes:Int;
	
	public function new( vertex_size_bytes:Int ) 
	{
		this.vertex_size_bytes = vertex_size_bytes;
	}
	
	function x( )
	{
		readf( 0, "x" );		
	}
	
	function y( )
	{
		readf( 4, "y" );		
	}
	
	function z( )
	{
		readf( 8, "z" );		
	}
	
	function map( a:Array<Void->Void> )
	{
		fMap = a;	
	}
	
	public function genByteCode( )
	{
		opcodes = new Array( );
		vstruct = { };
		
		for ( f in fMap )
		{
			stackSize == 0;
			f( );
			for ( i in 0...stackSize )
				__abc__([OPop]);
		}
		
		return { ops:opcodes, regs:vstruct };
	}
	
	/**
	 * Evaluate int at position {code}byte{/code} as a 32b pointer.
	 * @param	byte Offset of pointer
	 */
	function resolve( byte:Int )
	{
		__abc__([
			ODup,
			OInt( byte ),
			OOp( OpIAdd ),			//addr + pos
			OOp( OpMemGet32 ),
		]);
		stackSize++;
	}
	
	/**
	 * Read a float from the vertex
	 * @param	byte Offset from current position
	 * TODO add varying, attribute, uniform types
	 * TODO This is floored to fix a rasterization error, This is INCORRECT
	 */	
	function readf( byte:Int, name:String )
	{
		var t:Reg<Float>;
		__abc__([
			ODup,
			OInt( byte ),
			OOp( OpIAdd ),			//addr + pos
			OOp( OpMemGetFloat ),
			OToInt,
			OToNumber,
			OSetReg( t = Reg.float( ) ),
		]);
		Reflect.setField( vstruct, name, t );
	}
	
	/**
	 * Read an int from the vertex
	 * @param	byte Offset from current position
	 * @param	?type @TODO varying/atrribute/uniform
	 */	
	function readi( byte:Int, name:String )
	{
		var t:Reg<Int>;
		__abc__([
			ODup,
			OInt( byte ),
			OOp( OpIAdd ),			//addr + pos
			OOp( OpMemGet32 ),
			OSetReg( t = Reg.int( ) ),
		]);
		Reflect.setField( vstruct, name, t );
	}
	
	/**
	 * Read a fixed point of format type.
	 * @param	byte Offset from current position
	 * @param   format Declaration of fixed point type
	 * @param	?type @TODO varying/atrribute/uniform
	 */	
	function readx( byte:Int, format:Int, name:String )
	{
		throw( "Not yet implemented" );
	}
	
	function __abc__( a:Array<Dynamic> )
	{
		if ( opcodes != null )
		{
			opcodes = opcodes.concat( a );
		}
	}
	
	var opcodes:Array<Dynamic>;
	var vstruct:Dynamic;
	var stackSize:Int;
	var fMap:Array<Void->Void>;
}