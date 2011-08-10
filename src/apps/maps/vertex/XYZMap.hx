/**
 * ...
 * @author Matthew Spencer
 */

package apps.maps.vertex;
import com.codex.c3dex.mapping.VertexMapper;

class XYZMap extends VertexMapper
{
    //x,y,z can be redifined, but by default are set to 0,4,8th bytes respectively

    public function new( )
    {
        map( [x,y,z] );
        super( 4*3 );   //our vertices use 20b each: (x,y,z)*4;
    }
}