/**
 * ...
 * @author Matthew Spencer
 */

package apps.shaders;
import com.abc.Reg;
import com.codex.c3dex.shader.PixelShader;

class OverdrawShader extends PixelShader
{
	
	public override function main( data:Dynamic<Reg<Float>> )
	{
		OpDup( );
			
		//*overwrite shader
		OpDup( );
		OpMemGet32( );
		OpIntRef( bInt32( cast 0x000500CE ) );
		OpIAdd( );
		//*/
		
		//write pixel
		OpSwap( );
		OpMemSet32( );
	}
	
}