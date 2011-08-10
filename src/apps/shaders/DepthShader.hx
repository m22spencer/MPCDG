/**
 * ...
 * @author Matthew Spencer
 */

package apps.shaders;
import com.abc.Reg;
import com.codex.c3dex.shader.PixelShader;
import format.abc.Data.JumpStyle;

class DepthShader extends PixelShader
{
	
	public override function main( data:Dynamic<Reg<Float>> )
	{
		
		
		
		OpDup( );
			
		
		OpReg( data.z );
		OpFloat( bFloat( 255 ) );
		OpMul( );
		
		OpToInt( );
		
		OpInt( 0xFF );
		OpAnd( );
		
		
		
		OpDup( );
		OpDup( );
		
		OpInt( 8 );
		OpShl( );
		OpOr( );
		OpInt( 8 );
		OpShl( );
		OpOr( );
		
		
		//write pixel
		OpSwap( );
		OpMemSet32( );
	}
	
}