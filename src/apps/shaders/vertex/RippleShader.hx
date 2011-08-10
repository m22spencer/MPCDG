/**
 * ...
 * @author Matthew Spencer
 */

package apps.shaders.vertex;
import com.abc.Reg;
import byteroutines.MatrixRoutines;
import com.codex.c3dex.bcode.BVAR;
import com.codex.c3dex.memory.MemoryDispatcher;
import com.codex.c3dex.shader.VertexShader;
import flash.events.Event;
import flash.Lib;
import format.abc.Data.JumpStyle;

class RippleShader extends VertexShader
{
	private var sm:RasterMem;
	private var sval:Float;
	private var msize:Int;
	private var time:Int;
	
	public function new( )
	{
		super( );
		msize = 100;
		
		sm = MemoryDispatcher.alloc( 4 );
		sval = -Math.PI;
		
		time = Lib.getTimer( );
		Lib.current.stage.addEventListener( Event.ENTER_FRAME, onEnterFrame );
	}
	
	function onEnterFrame( e )
	{
		var dt:Int = Lib.getTimer( ) - time;
		time = Lib.getTimer( );
		
		sval -= dt/400;
		if ( sval < -Math.PI )
			sval = Math.PI;
		sm.setFloat( 0, sval );
	}
	
	public override function main( vec: { x:Reg<Float>, y:Reg<Float>, z:Reg<Float> }, mat:_MatrixFloat ): { x:Reg<Float>, y:Reg<Float>, z:Reg<Float> }
	{
		var mr = new MatrixRoutines( _app );
		
		OpReg( vec.x );
		OpDup( );
		OpMul( );
		OpReg( vec.y );
		OpDup( );
		OpMul( );
		OpAdd( );
		OpFloat( bFloat( 30 ) );
		OpMul( );
		OpDup( );
		
		OpIntRef( bInt32( sm.addr ) );
		OpMemGetFloat( );
		OpFloat( bFloat( 2 ) );
		OpMul( );
		OpAdd( );
			
		calc_sine( bv.stackEat.float(), bv.stack.float() );
		
		
		OpSwap( );
		OpFloat( bFloat( 2.5 ) );
		OpAdd( );
		OpDiv( );
		
		OpDup( );
		OpSetReg( vec.z );
		
		var out_vec = vec;
		
		
		OpFloat( bFloat( 128*2.2 ) );
		OpMul( );
		OpFloat( bFloat( 128 ) );
		OpAdd( );
		
		varying( bv.stackEat.float( ), "pixcolor" );
		
		return out_vec;
	}	
	
	function calc_sine( a:BVAR<Float>, out:BVAR<Float> )
	{
		a.get( );
		
		var WHILE_TOOSMALL = bLabel( );
		var WHILE_TOOBIG = bLabel( );
		
		OpDup( );
		OpFloat( bFloat( -Math.PI ) );
		OpIf( JLt );
			OpLabel( WHILE_TOOSMALL );
				OpFloat( bFloat( Math.PI * 2) );
				OpAdd( );			
			OpDup( );
			OpFloat( bFloat( -Math.PI ) );
			OpJump( JLt, WHILE_TOOSMALL );
		OpFi( );
		
		OpDup( );
		OpFloat( bFloat( Math.PI ) );
		OpIf( JGt );
			OpLabel( WHILE_TOOBIG );
				OpFloat( bFloat( -Math.PI * 2) );
				OpAdd( );			
			OpDup( );
			OpFloat( bFloat( Math.PI ) );
			OpJump( JGt, WHILE_TOOBIG );
		OpFi( );
		
		OpDup( );
		OpFloat( bFloat( 0 ) );
		OpIf( JLt );
			OpDup( );
			OpDup( );	
			OpMul( );		//{x, x*x}
			OpFloat( bFloat( .405284735 ) );
			OpMul( );		//{x,x*x*n}
			OpSwap( );
			OpFloat( bFloat( 1.27323954 ) );
			OpMul( );
			OpAdd( );		//{sine}		
		OpElse( );
			OpDup( );
			OpDup( );	
			OpMul( );		//{x, x*x}
			OpFloat( bFloat( -.405284735 ) );
			OpMul( );		//{x,x*x*n}
			OpSwap( );
			OpFloat( bFloat( 1.27323954 ) );
			OpMul( );
			OpAdd( );		//{sine}
		OpFi( );
		
		
		out.set( );
	}
}







