/**
 * ...
 * @author Matthew Spencer
 */

package byteapps;
import com.codex.c3dex.bcode.app.ByteApplication;
import com.codex.c3dex.bcode.BVAR;
import com.abc.Reg;
import flash.utils.ByteArray;
import format.abc.Data;

typedef MemorySpeedTestDef =
{
	function forwards(i:Int):Void;
	function backwards(i:Int):Void;
	function recip( i:Int ):Void;
	function nrecip( i:Int ):Void;
	function nrecip2( i:Int ):Void;
}

class MemorySpeedTest extends ByteApplication
{

	public function new( call:MemorySpeedTestDef->Void, ba:ByteArray ) 
	{
		super( );
		
		var loop1 = bLabel( );
		var loop2 = bLabel( );
		
		var c = bBeginClass( "_MemorySpeedTest" );
		
		
		var m = bBeginMethod( "forwards", [_ctx.type("int")], null );
		m.maxStack = 3;
		
		var max = Reg.param( 1, Int );
		
		OpInt( 0 );
		OpLabel( loop1 );
			
			OpInt( 1 );
			OpIAdd( );
		
			OpDup( );
			OpReg( max );
		OpJump( JLt, loop1 );
		
		OpRetVoid( );		
		bEndMethod( );
		
		
		var m = bBeginMethod( "backwards", [_ctx.type("int")], null );
		m.maxStack = 3;
		
		var max = Reg.param( 1, Int );
		
		OpReg( max );
		OpLabel( loop2 );
			
			OpInt( -1 );
			OpIAdd( );
			
			OpDup( );
			OpInt( 0 );
		OpJump( JGt, loop2 );
		
		OpRetVoid( );
		bEndMethod( );
		
		
		var m = bBeginMethod( "recip", [_ctx.type("int")], null );
		m.maxStack = 3;
		
		var max = Reg.param( 1, Int );
		
		OpInt( 0 );
		OpLabel( loop1 );
			
			//recip code
			OpFloat( bFloat( 65536 ) );
			OpInt( 0 );
			OpMemGet32( );
			OpToNumber( );
			OpDiv( );
			OpToInt( );
			OpInt( 4 );
			OpMemSet32( );
			
		
			OpInt( 1 );
			OpIAdd( );
		
			OpDup( );
			OpReg( max );
		OpJump( JLt, loop1 );
		
		OpRetVoid( );		
		bEndMethod( );
		
		
		var m = bBeginMethod( "nrecip", [_ctx.type("int")], null );
		m.maxStack = 4;
		
		var max = Reg.param( 1, Int );
		
		OpInt( 0 );
		OpLabel( loop2 );
			
			//recip code
			OpIntRef( bInt32( 256 ) );
			
			OpDup( );
			OpInt( 0 );
			OpMemGet32( );
			OpIMul( );
			OpInt( 8 );
			OpShr( );
			OpIntRef( bInt32( 512 ) );
			OpSwap( );
			OpISub( );
			OpIMul( );
			OpInt( 8 );
			OpShr( );
			
			OpDup( );
			OpInt( 0 );
			OpMemGet32( );
			OpIMul( );
			OpInt( 8 );
			OpShr( );
			OpIntRef( bInt32( 512 ) );
			OpSwap( );
			OpISub( );
			OpIMul( );
			OpInt( 8 );
			OpShr( );
			
			OpDup( );
			OpInt( 0 );
			OpMemGet32( );
			OpIMul( );
			OpInt( 8 );
			OpShr( );
			OpIntRef( bInt32( 512 ) );
			OpSwap( );
			OpISub( );
			OpIMul( );
			OpInt( 8 );
			OpShr( );
			
			
		
			OpInt( 4 );
			OpMemSet32( );
			
		
			OpInt( 1 );
			OpIAdd( );
			
			OpDup( );
			OpReg( max );
		OpJump( JLt, loop2 );
		
		OpRetVoid( );
		bEndMethod( );
		
		var m = bBeginMethod( "nrecip2", [_ctx.type("int")], null );
		m.maxStack = 6;
		
		var max = Reg.param( 1, Int );
		var treg = Reg.int( );
		
		OpInt( 0 );
		OpLabel( loop2 );
			
			//recip code
			OpInt( 0 );
			OpMemGet32( );
			
			OpIntRef( bInt32( 256 ) );
			OpISub( );
			OpInt( 2 );
			OpShl( );
			OpInt( 10 );
			OpIAdd( );
			
			OpMemGet32( );		
			
		
			OpInt( 4 );
			OpMemSet32( );
			
		
			OpInt( 1 );
			OpIAdd( );
			
			OpDup( );
			OpReg( max );
		OpJump( JLt, loop2 );
		
		OpRetVoid( );
		bEndMethod( );
		
		bFinalize( );
		
		ByteApplication.buildToAsync( call, this, "_MemorySpeedTest", ba );
	}
	
}