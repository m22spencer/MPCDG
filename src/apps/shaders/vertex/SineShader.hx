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

class SineShader extends VertexShader
{
	private var sm:RasterMem;
	private var sval:Float;
	private var msize:Int;
	public function new( )
	{
		super( );
		msize = 100;
	}
	
	public override function main( vec: { x:Reg<Float>, y:Reg<Float>, z:Reg<Float> }, mat:_MatrixFloat ): { x:Reg<Float>, y:Reg<Float>, z:Reg<Float> }
	{
		var mr = new MatrixRoutines( _app );
		
		OpReg( vec.x );
		OpFloat( bFloat( 10.0 ) );
		OpMul( );
		
		calc_sine( bv.stackEat, bv.stack );
		
		OpReg( vec.y );
		OpFloat( bFloat( 10.0 ) );
		OpMul( );
		
		calc_sine( bv.stackEat, bv.stack );
		
		OpAdd( );
		
		OpFloat( bFloat( 2 * 10 ) );
		
		OpDiv( );
		OpSetReg( vec.z );
		
		var out_vec = mr.concatVector( vec, mat );
		
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







