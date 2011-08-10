/**
 * ...
 * @author Matthew Spencer
 */

package apps;
import apps.maps.vertex.XYZMap;
import com.codex.c3dex.bcode.app.FloatRaster;
import com.codex.c3dex.GraphicsBuffer;
import com.codex.c3dex.mapping.VertexMapper;
import com.codex.c3dex.memory.MemoryDispatcher;
import models.Cube;

class GraphicsBufferTest 
{

	public function new() 
	{
		MemoryDispatcher.init( 64, 1048576 );	//1mb upper, 64b lower (for matrices)
		
		//Basic model import
		var cube = new Cube( );
		var ind = cube.indices( );
		var ver = cube.vertices( );
		var vbuffer = MemoryDispatcher.alloc( 12 * ind.length );
		
		//Here, we just want a simple non indexed vertix list, so we do that now.
		var pos:Int = 0;
		for ( indice in ind )
		{
			trace( ver[indice * 3] + ":" + ver[indice * 3 + 1] + ":" + ver[indice * 3 + 2] );
			vbuffer.setFloat( pos, ver[indice * 3] );
			vbuffer.setFloat( pos+4, ver[indice * 3+1] );
			vbuffer.setFloat( pos + 8, ver[indice * 3 + 2] );
			pos += 12;
		}
		
		
		
		var vmap = new XYZMap( );
		var gb = new GraphicsBuffer( 1024, vmap );
		
		var matrix_ref = gb.pushMatrix([
			1.0, 0.0, 0.0, 0.0,
			0.0, 1.0, 0.0, 0.0,
			0.0, 0.0, 1.0, 0.0,
			0.0, 0.0, 0.0, 1.0,
		]);
		
		gb.pushVertexBuffer( vbuffer );
		
		new FloatRaster( function( o ) { o.render(0, 1); } );
	}
	
}






















