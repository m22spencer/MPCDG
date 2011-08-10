/**
 * ...
 * @author Matthew Spencer
 */

package apps.shaders;
import apps.FloatingTransformationTester;
import com.abc.Reg;
import com.codex.c3dex.bcode.BVAR;
import com.codex.c3dex.shader.PixelShader;
import format.abc.Data.JumpStyle;

class LumShader extends PixelShader
{
	
	public override function main( data:Dynamic<Reg<Float>> )
	{
		
		OpDup( );	//dupe our memory address
		
		
		//*
		OpFloat( bFloat( 1 ) );
		OpReg( data.z );
		OpDiv( );
		OpFloat( bFloat( 255*80 ) );
		OpMul( );
		//*/
		
		OpToInt( );
		
		calculate_lum( bv.stackEat.int(), bv.stack.int() );
		
		//write pixel
		OpSwap( );
		OpMemSet32( );
	}
	
	function calculate_lum( color:BVAR<Int>, out:BVAR<Int> )
	{
		var a:Reg<Int> = Reg.int( );
		var r:Reg<Int> = Reg.int( );
		var g:Reg<Int> = Reg.int( );
		var b:Reg<Int> = Reg.int( );
		var min:Reg<Int> = Reg.int( );
		var max:Reg<Int> = Reg.int( );
		
		color.get( );
		OpIntRef( bInt32( cast 0x00FFFFFF ) );
		OpAnd( );
		
		
		
		//separate each channel
		OpDup( );
		OpInt( 0xFF );
		OpAnd( );
		OpSetReg( b );
		
		OpDup( );
		OpInt( 8 );
		OpUShr( );
		OpInt( 0xFF );
		OpAnd( );
		OpSetReg( g );
		
		OpInt( 16 );
		OpUShr( );
		OpInt( 0xFF );
		OpAnd( );
		OpSetReg( r );
		
		minf( r, g, min );
		minf( b, min, min );
		
		maxf( r, g, max );
		maxf( b, max, max );
		
		OpReg( min );
		OpReg( max );
		OpIAdd( );
		OpInt( 1 );
		OpUShr( );
		
		OpDup( );			//{r, r }
		OpDup( );			//{r, r, r}
		OpInt( 8 );
		OpShl( );
		OpOr( );			//{rr,r}
		OpInt( 8 );
		OpShl( );
		OpOr( );			//{rrr}
		
		
		out.set( );
	}
	
	function minf( a:Reg<Int>, b:Reg<Int>, out:Reg<Int> )
	{
		OpReg( a );
		OpReg( b );
		
		OpIf( JLt );
		{
			OpReg( a );
			OpSetReg( out );
		}
		OpElse( );
		{
			OpReg( b );
			OpSetReg( out );
		}
		OpFi( );
	}
	
	function maxf( a:Reg<Int>, b:Reg<Int>, out:Reg<Int> )
	{
		OpReg( a );
		OpReg( b );
		
		OpIf( JGt );
		{
			OpReg( a );
			OpSetReg( out );
		}
		OpElse( );
		{
			OpReg( b );
			OpSetReg( out );
		}
		OpFi( );
	}
	
}








