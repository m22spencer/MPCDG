/**
 * ...
 * @author Matthew Spencer
 */

package ;
import com.codex.c3dex.mapping.VertexMapper;

class MyVertexMapper extends VertexMapper {
    //x,y,z can be redifined, but by default are set to 0,4,8th bytes respectively

    function uv( )
    {
        resolve( 16 );                 //uses the item in byte 16 as a pointer
        readf( 0, "u" );   //read u and set it to interpolate by pixel
        readf( 4, "v" );    //ditto with v
    }

    public function new( )
    {
        map( [x,y,z,uv] );
        super( 16 );   //our vertices use 20b each: (x,y,z,uv,tex)*4;
    }
}