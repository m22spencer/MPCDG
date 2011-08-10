/**
 * ...
 * @author Matthew Spencer
 * 
 * ByteBase is an underlying class for ByteApplication/ByteRoutine that helps to link them together
 * Do not extend this class by itself
 */

package com.codex.c3dex.bcode;
import apps.FloatingTransformationTester;
import com.abc.Reg;
import com.codex.c3dex.bcode.app.ByteApplication;
import com.abc.Data;
import format.abc.Data;
import com.codex.c3dex.bcode.BVAR;
import haxe.Int32;


class ByteBase 
{

	var _app:ByteApplication;
	
	function new( app:ByteApplication ) 
	{
		_app = app;
		bv = new TOOLSBVAR( _app );
	}
	
	function bInt32( i:Int )
	{
		return ByteApplicationTools.ctx( _app ).int( cast i );
	}
	
	function bUInt( u:Int )
	{
		return ByteApplicationTools.ctx( _app ).uint( cast u );
	}
	
	function bFloat( f:Float )
	{
		return ByteApplicationTools.ctx( _app ).float( f );
	}
	
	static var label_id:Int = 0;
	function bLabel( )
	{
		return "__LABEL__" + label_id++;
	}
	
	function __abc__( ops:Array<Dynamic> )
	{
		//throw( "this function is depriciated, use direct calls from now on" );
		ByteApplicationTools.ops( _app ) = ByteApplicationTools.ops( _app ).concat( ops );
	}
	
	/**
	 * New bytecode creation system, now done through functions instead of enums.
	 */	
	inline function m_injectBCode( op:Dynamic )
	{
		if ( ByteApplicationTools.ops( _app ) == null )
			throw( "Ops are null, open a function" );
		ByteApplicationTools.ops( _app ).push( op );
	}
	
	inline function OpReg( r:Reg<Dynamic> )
	{
		if ( r == null )
			throw( "isNull" );
		m_injectBCode( OReg( r ) ); 
	}
	inline function OpSetReg( r:Reg<Dynamic> )
	{
		if ( r == null )
			throw( "isNull" );
		m_injectBCode( OSetReg( r ) ); 
	}
	inline function OpNop( )
	{
		m_injectBCode( ONop ); 
	}
	inline function OpLabel( s:String )
	{
		m_injectBCode( OLabel( s ) ); 
	}
	inline function OpJump( j:format.abc.JumpStyle, l:String )
	{
		m_injectBCode( OJump( j, l ) ); 
	}
	inline function OpInt( i:Int )
	{
		m_injectBCode( OInt( i ) ); 
	}
	inline function OpPop( )
	{
		m_injectBCode( OPop ); 
	}
	inline function OpDup( )
	{
		m_injectBCode( ODup ); 
	}
	inline function OpSwap( )
	{
		m_injectBCode( OSwap ); 
	}
	inline function OpIntRef( i:format.abc.Index<Int32> )
	{
		m_injectBCode( OIntRef( i ) ); 
	}
	inline function OpFloat( f:format.abc.Index<Float> )
	{
		m_injectBCode( OFloat( f ) ); 
	}
	inline function OpRetVoid( )
	{
		m_injectBCode( ORetVoid ); 
	}
	inline function OpRet( )
	{
		m_injectBCode( ORet ); 
	}
	inline function OpToInt( )
	{
		m_injectBCode( OToInt ); 
	}
	inline function OpToNumber( )
	{
		m_injectBCode( OToNumber ); 
	}
	inline function OpIncrReg( r:Reg<Dynamic> )
	{
		m_injectBCode( OIncrReg( r ) ); 
	}
	inline function OpDecrReg( r:Reg<Dynamic> )
	{
		m_injectBCode( ODecrReg( r ) ); 
	}
	inline function OpIncrIReg( r:Reg<Dynamic> )
	{
		m_injectBCode( OIncrIReg( r ) ); 
	}
	inline function OpDecrIReg( r:Reg<Dynamic> )
	{
		m_injectBCode( ODecrIReg( r ) ); 
	}
	
	inline function OpArray( nvalues:Int )
	{
		m_injectBCode( OArray( nvalues ) );
	}
	
	//OOps
	inline function OpNeg( )
	{
		m_injectBCode( OpCode.OOp( Operation.OpNeg ) ); 
	}
	inline function OpIncr( )
	{
		m_injectBCode( OpCode.OOp( Operation.OpIncr ) ); 
	}
	inline function OpDecr( )
	{
		m_injectBCode( OpCode.OOp( Operation.OpDecr ) ); 
	}
	inline function OpNot( )
	{
		m_injectBCode( OpCode.OOp( Operation.OpNot ) ); 
	}
	inline function OpAdd( )
	{
		m_injectBCode( OpCode.OOp( Operation.OpAdd ) ); 
	}
	inline function OpSub( )
	{
		m_injectBCode( OpCode.OOp( Operation.OpSub ) ); 
	}
	inline function OpMul( )
	{
		m_injectBCode( OpCode.OOp( Operation.OpMul ) ); 
	}
	inline function OpDiv( )
	{
		m_injectBCode( OpCode.OOp( Operation.OpDiv ) ); 
	}
	inline function OpMod( )
	{
		m_injectBCode( OpCode.OOp( Operation.OpMod ) ); 
	}
	inline function OpShl( )
	{
		m_injectBCode( OpCode.OOp( Operation.OpShl ) ); 
	}
	inline function OpShr( )
	{
		m_injectBCode( OpCode.OOp( Operation.OpShr ) ); 
	}
	inline function OpUShr( )
	{
		m_injectBCode( OpCode.OOp( Operation.OpUShr ) ); 
	}
	inline function OpAnd( )
	{
		m_injectBCode( OpCode.OOp( Operation.OpAnd ) ); 
	}
	inline function OpOr( )
	{
		m_injectBCode( OpCode.OOp( Operation.OpOr ) ); 
	}
	inline function OpXor( )
	{
		m_injectBCode( OpCode.OOp( Operation.OpXor ) ); 
	}
	inline function OpEq( )
	{
		m_injectBCode( OpCode.OOp( Operation.OpEq ) ); 
	}
	inline function OpLt( )
	{
		m_injectBCode( OpCode.OOp( Operation.OpLt ) ); 
	}
	inline function OpLte( )
	{
		m_injectBCode( OpCode.OOp( Operation.OpLte ) ); 
	}
	inline function OpGt( )
	{
		m_injectBCode( OpCode.OOp( Operation.OpGt ) ); 
	}
	inline function OpGte( )
	{
		m_injectBCode( OpCode.OOp( Operation.OpGte ) ); 
	}
	inline function OpIIncr( )
	{
		m_injectBCode( OpCode.OOp( Operation.OpIIncr ) ); 
	}
	inline function OpIDecr( )
	{
		m_injectBCode( OpCode.OOp( Operation.OpIDecr ) ); 
	}
	inline function OpINeg( )
	{
		m_injectBCode( OpCode.OOp( Operation.OpINeg ) ); 
	}
	inline function OpIAdd( )
	{
		m_injectBCode( OpCode.OOp( Operation.OpIAdd ) ); 
	}
	inline function OpISub( )
	{
		m_injectBCode( OpCode.OOp( Operation.OpISub ) ); 
	}
	inline function OpIMul( )
	{
		m_injectBCode( OpCode.OOp( Operation.OpIMul ) ); 
	}
	inline function OpMemGet8( )
	{
		m_injectBCode( OpCode.OOp( Operation.OpMemGet8 ) ); 
	}
	inline function OpMemGet16( )
	{
		m_injectBCode( OpCode.OOp( Operation.OpMemGet16 ) ); 
	}
	inline function OpMemGet32( )
	{
		m_injectBCode( OpCode.OOp( Operation.OpMemGet32 ) ); 
	}
	inline function OpMemGetFloat( )
	{
		m_injectBCode( OpCode.OOp( Operation.OpMemGetFloat ) ); 
	}
	inline function OpMemGetDouble( )
	{
		m_injectBCode( OpCode.OOp( Operation.OpMemGetDouble ) ); 
	}
	inline function OpMemSet8( )
	{
		m_injectBCode( OpCode.OOp( Operation.OpMemSet8 ) ); 
	}
	inline function OpMemSet16( )
	{
		m_injectBCode( OpCode.OOp( Operation.OpMemSet16 ) ); 
	}
	inline function OpMemSet32( )
	{
		m_injectBCode( OpCode.OOp( Operation.OpMemSet32 ) ); 
	}
	inline function OpMemSetFloat( )
	{
		m_injectBCode( OpCode.OOp( Operation.OpMemSetFloat ) ); 
	}
	inline function OpMemSetDouble( )
	{
		m_injectBCode( OpCode.OOp( Operation.OpMemSetDouble ) ); 
	}
	inline function OpIf( j:format.abc.JumpStyle )
	{
		m_injectBCode( OpCodeE.OIf( j ) );
	}
	inline function OpElse( )
	{
		m_injectBCode( OpCodeE.OElse );
	}
	inline function OpFi( )
	{
		m_injectBCode( OpCodeE.OFi );
	}

	var bv:TOOLSBVAR;
}

private typedef ByteApplicationFriend =
{
	private var _ctx:format.abc.Context;
	private var _ops:Array<Dynamic>;
}

private class ByteApplicationTools
{
	public static inline function ctx( app:ByteApplicationFriend )
	{
		return app._ctx;
	}
	public static inline function ops( app:ByteApplicationFriend )
	{
		return app._ops;
	}
}
