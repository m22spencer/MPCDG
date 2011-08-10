/**
 * ...
 * @author Matthew Spencer
 */

package byteroutines;
import com.codex.c3dex.bcode.app.ByteApplication;
import com.codex.c3dex.bcode.routines.ByteRoutine;
import com.codex.c3dex.bcode.BVAR;

class MemoryRoutines extends ByteRoutine
{

	public function new( app:ByteApplication ) 
	{
		super( app );
	}
	
	public function readI32( addr:BVAR<Int>, offset:BVAR<Int>, out:BVAR<Int> )
	{
		addr.get( );
		if ( offset != null )
		{
			offset.get( );
			OpIAdd( );
		}
		OpMemGet32( );
		out.set( );
	}
	
	public function readI16( addr:BVAR<Int>, offset:BVAR<Int>, out:BVAR<Int> )
	{
		addr.get( );
		if ( offset != null )
		{
			offset.get( );
			OpIAdd( );
		}
		OpMemGet16( );
		out.set( );
	}
	
	public function readFloat( addr:BVAR<Int>, offset:BVAR<Int>, out:BVAR<Float> )
	{
		addr.get( );
		if ( offset != null )
		{
			offset.get( );
			OpIAdd( );
		}
		OpMemGetFloat( );
		out.set( );
	}
	
	public function readDouble( addr:BVAR<Int>, offset:BVAR<Int>, out:BVAR<Float> )
	{
		addr.get( );
		if ( offset != null )
		{
			offset.get( );
			OpIAdd( );
		}
		OpMemGetDouble( );
		out.set( );
	}
	
	public function readByte( addr:BVAR<Int>, offset:BVAR<Int>, out:BVAR<Int> )
	{
		addr.get( );
		if ( offset != null )
		{
			offset.get( );
			OpIAdd( );
		}
		OpMemGet8( );
		out.set( );
	}
	
}













