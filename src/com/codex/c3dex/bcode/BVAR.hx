/**
 * ...
 * @author Matthew Spencer
 */

package com.codex.c3dex.bcode;
import com.codex.c3dex.bcode.app.ByteApplication;
import com.abc.Reg;

class BVAR#if !FD <T> #end extends ByteBase
{
	var m0:Dynamic;
	var btype:BTYPE;
	public var type(default, null):Class<Dynamic>;
	
	public function new( app:ByteApplication, type:Class<T>, btype:BTYPE, ?prop:Dynamic ) 
	{
		super( app );
		m0 = prop;
		this.type = type;
		this.btype = btype;
	}
	
	public function get( )
	{
		
		switch( type )
		{
			case Int:
				switch( btype )
				{
					case STACK:
						OpDup( );
					case STACK_EAT:
					case REGISTER( reg ):
						OpReg( reg );
					case CONSTANT_INT( i ):
						OpIntRef( bInt32( i ) );
					default:
						throw( "Not implemented" );					
				}
			case Float:
				switch( btype )
				{	
					
					case STACK:
						OpDup( );
					case STACK_EAT:
					case REGISTER( reg ):
						OpReg( reg );
					case CONSTANT_FLOAT( f ):
						OpFloat( bFloat( f ) );
					default:
						throw( "Not implemented" );			
						
				}
			case Dynamic:
				switch( btype )
				{
					case STACK:
						OpDup( );
					case STACK_EAT:
					default:
						throw( "Not supported" );
				}
		}
	}
	
	public function set( )
	{
		
		switch( type )
		{
			case Int:
				switch( btype )
				{
					case STACK:
					case REGISTER( reg ):
						OpSetReg( reg );
					default:
						throw( "Not implemented" );					
				}
			case Float:
				switch( btype )
				{	
					
					case STACK:
					case REGISTER( reg ):
						OpSetReg( reg );
					default:
						throw( "Not implemented" );			
						
				}
			
		}
	}
	
	function toString( )
	{
		return "[BVAR:" + btype + ":" + Type.getClassName(type) + "]";
	}
	
}

class BVAR_STK
{
	private var _app:ByteApplication;
	private var _btype:BTYPE;
	public function new( app:ByteApplication, btype:BTYPE )
	{
		_app = app;
		_btype = btype;
	}
	
	public function int( )
	{
		return new BVAR<Int>( _app, Int, _btype );
	}
	public function float( )
	{
		return new BVAR<Float>( _app, Float, _btype );
	}
	
}

class TOOLSBVAR
{
	var _app:ByteApplication;
	public function new( app:ByteApplication )
	{
		_app = app;
	}
	
	public var stack(GET_STACK, null):Dynamic;
	function GET_STACK( )
	{
		return new BVAR_STK( _app, BTYPE.STACK );
	}
	
	public var stackEat(GET_STACK_EAT, null):Dynamic;
	function GET_STACK_EAT( )
	{
		return new BVAR_STK( _app, BTYPE.STACK_EAT );
	}
	
	public function reg<T>( reg:Reg<T> )
	{
		return new BVAR<T>( _app, reg.cls, BTYPE.REGISTER( reg ) );
	}
	
	public function int( i:Int )
	{
		return new BVAR<Int>( _app, Int, BTYPE.CONSTANT_INT( i ) );
	}
	
	public function float( f:Float )
	{
		return new BVAR<Float>( _app, Float, BTYPE.CONSTANT_FLOAT( f ) );
	}

}

typedef BINT = BVAR<Int>;
typedef BFLOAT = BVAR<Float>;

enum BTYPE
{
	STACK;
	STACK_EAT;
	REGISTER( reg:Reg<Dynamic> );
	CONSTANT_INT( i:Int );
	CONSTANT_FLOAT( f:Float );
}