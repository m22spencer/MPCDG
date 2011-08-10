/**
 * ...
 * @author Matthew Spencer
 */

package com.codex.c3dex.mapping;

import com.abc.Reg;
import com.codex.c3dex.bcode.app.ByteApplication;
import com.codex.c3dex.bcode.ByteBase;

class VertexMapper2 extends ByteBase
{

	public var vertex_size_bytes:Int;
	
	function new( vertex_size_bytes:Int, a:Array<Void->Void> ) 
	{
		super( null );
		this.vertex_size_bytes = vertex_size_bytes;
		map( a );
	}
	
	function xyz( )
	{
		readf( 0, "x" );	
		readf( 4, "y" );	
		readf( 8, "z" );
	}
	
	function map( a:Array<Void->Void> )
	{
		fMap = a;	
	}
	
	public function genByteCode( app:ByteApplication )
	{
		_app = app;
		opcodes = new Array( );
		vstruct = { };
		
		for ( f in fMap )
		{
			stackSize == 0;
			f( );
			for ( i in 0...stackSize )
				OpPop( );			//TODO Extra opcodes.. write a better system avoiding pops
		}
		
		if ( vstruct.x == null || vstruct.y == null || vstruct.z == null ) throw( "Requires x, y, z" );
		
		return vstruct;
	}
	
	public function genByteCodeXYZ( app:ByteApplication )
	{
		_app = app;
		vstruct = { };
		
		stackSize == 0;
		xyz( );
		for ( i in 0...stackSize )
			OpPop( );			//TODO Extra opcodes.. write a better system avoiding pops
		
		return vstruct;
	}
	
	/**
	 * Evaluate int at position {code}byte{/code} as a 32b pointer.
	 * @param	byte Offset of pointer
	 */
	function resolve( byte:Int )
	{
		
		OpDup( );
		OpInt( byte );
		OpIAdd( );			//addr + pos
		OpMemGet32( );
		stackSize++;
	}
	
	/**
	 * Read a float from the vertex
	 * @param	byte Offset from current position
	 * TODO add varying, attribute, uniform types
	 */	
	function readf( byte:Int, name:String )
	{
		var t:Reg<Float>;
		
			OpDup( );
			OpInt( byte );
			OpIAdd( );			//addr + pos
			OpMemGetFloat( );
			OpSetReg( t = Reg.float( ) );
		
		Reflect.setField( vstruct, name, t );
	}
	
	/**
	 * Read an int from the vertex
	 * @param	byte Offset from current position
	 * @param	?type TODO varying/atrribute/uniform
	 */	
	function readi( byte:Int, name:String )
	{
		var t:Reg<Int>;
			OpDup( );
			OpInt( byte );
			OpIAdd( );			//addr + pos
			OpMemGet32( );
			OpSetReg( t = Reg.int( ) );
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
	
	var opcodes:Array<Dynamic>;
	var vstruct:Dynamic;
	var stackSize:Int;
	var fMap:Array<Void->Void>;
}