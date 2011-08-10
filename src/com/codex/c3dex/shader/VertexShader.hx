/**
 * ...
 * @author Matthew Spencer
 */

package com.codex.c3dex.shader;
import byteroutines.MatrixRoutines;
import com.abc.Reg;
import com.codex.c3dex.bcode.app.ByteApplication;
import com.codex.c3dex.bcode.BVAR;
import com.codex.c3dex.bcode.ByteBase;

class VertexShader extends ByteBase
{

	var varying:BVAR<Dynamic>->String->Void;
	
	public function new() 
	{
		super( null );
	}
	
	public function setTarget( app:ByteApplication, vfunc:BVAR<Dynamic>->String->Void )
	{
		_app = app;
		untyped bv._app = app;
		varying = vfunc;
	}
	
	public function main( vec:{x:Reg<Float>, y:Reg<Float>, z:Reg<Float>}, mat:_MatrixFloat ):{x:Reg<Float>, y:Reg<Float>, z:Reg<Float>}
	{
		return vec;
	}
	
}