/**
 * ...
 * @author Matthew Spencer
 * 
 * This class may be extended to help in keeping algorithms separated
 * A ByteApplication (or even another ByteRoutine), may use external routines
 * in the following way:
 * 
 * var myRoutines = new MyRoutineClass( this );
 * myRoutines.someFunc( );
 */

package com.codex.c3dex.bcode.routines;
import com.codex.c3dex.bcode.app.ByteApplication;
import com.codex.c3dex.bcode.ByteBase;
import com.abc.Data;
import format.abc.Data;

class ByteRoutine extends ByteBase
{
	function new( app:ByteApplication ) 
	{
		super( app );
	}
	
}