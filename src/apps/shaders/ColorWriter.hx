/**
 * ...
 * @author Matthew Spencer
 */

package apps.shaders;
import com.abc.Reg;
import com.codex.c3dex.shader.PixelShader;
import format.abc.Data.JumpStyle;

class ColorWriter extends PixelShader
{
	
	public override function main( data:Dynamic<Reg<Float>> )
	{
		
		
		
		OpDup( );
		
		OpInt( 0xFF );
		OpReg( data.pixcolor );
		OpToInt( );
		OpSub( );
		OpInt( 16 );
		OpShl( );
		OpReg( data.pixcolor );
		OpToInt( );
		OpOr( );		
		
		//write pixel
		OpSwap( );
		OpMemSet32( );
	}
	
}