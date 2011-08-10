/**
 * ...
 * @author Matthew Spencer
 */

package apps.maps.vertex;
import com.codex.c3dex.mapping.VertexMapper;

class XYZUVMap extends VertexMapper
{
    //x,y,z can be redifined, but by default are set to 0,4,8th bytes respectively

	public function uv( )
	{
		readf( 12, "u" );
		readf( 16, "v" );
	}
	
    public function new( )
    {
        map( [x,y,z,uv] );
        super( 4*5 );   //our vertices use 20b each: (x,y,z,uv,tex)*4;
    }
}