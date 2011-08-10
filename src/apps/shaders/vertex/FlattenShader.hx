/**
 * ...
 * @author Matthew Spencer
 */

package apps.shaders.vertex;
import com.abc.Reg;
import byteroutines.MatrixRoutines;
import com.codex.c3dex.shader.VertexShader;

class FlattenShader extends VertexShader
{
	public override function main( vec: { x:Reg<Float>, y:Reg<Float>, z:Reg<Float> }, mat:_MatrixFloat ): { x:Reg<Float>, y:Reg<Float>, z:Reg<Float> }
	{
		var mr = new MatrixRoutines( _app );
		
		OpFloat( bFloat( 0.0 ) );
		OpSetReg( vec.z );
		
		var out_vec = mr.concatVector( vec, mat );
		
		return out_vec;
	}	
}
