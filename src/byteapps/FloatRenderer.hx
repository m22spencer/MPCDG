/**
 * ...
 * @author Matthew Spencer
 */

package byteapps;
import byteroutines.RasterFloatRoutines;
import com.codex.c3dex.bcode.app.ByteApplication;
import com.codex.c3dex.mapping.VertexMapper2;
import com.codex.c3dex.shader.PixelShader;
import flash.utils.ByteArray;
import com.abc.Reg;
import format.abc.Data.JumpStyle;
import com.codex.c3dex.memory.MemoryDispatcher;

class FloatRenderer extends ByteApplication
{
	private var _call:FloatRendererClassDef->Void;
	private var _frameBuffer:Int;
	private var _memory:ByteArray;
	private var _vmap:VertexMapper2;
	private var _shader:PixelShader;
	private var _fwid:Int;
	private var _zbuffer:RasterMem;

	public function new( call:FloatRendererClassDef->Void, memory:ByteArray, frameBuffer:Int, swid:Int, shader:PixelShader, ?vmap:VertexMapper2, ?zBuffer:RasterMem ) 
	{
		super( );
		_call = call;
		_frameBuffer = frameBuffer;
		_memory = memory;
		_vmap = vmap;
		_shader = shader;
		_fwid = swid;
		_zbuffer = zBuffer;
		
		init( );
		main( );
		end( );
	}
	
	function init( )
	{
		var c = bBeginClass( "_FloatRenderer" );
		var tInt = _ctx.type("int");
		var m = bBeginMethod( "shade", [tInt, tInt], tAny );
		m.maxStack = 10;
	}
	
	function main( )
	{
		var flroutines = new RasterFloatRoutines( this, _frameBuffer, _fwid );
		
		var param1 = Reg.param( 1, Int );
		var param2 = Reg.param( 2, Int );
		
		var mainloop = bLabel( );
		
		//mainloop START
		OpReg( param1 );
		OpLabel( mainloop );
		
			var poly:Dynamic;
			if ( _vmap == null )
				poly = flroutines.read_vertices( );			
			else
				poly = flroutines.read_vertices_map( _vmap );
				
			untyped _shader._app = this;
			flroutines.scanRows( poly, _shader.main, _zbuffer );
		
		
		//update deltas
		OpDup( );
		OpReg( param2 );
		OpJump( JLt, mainloop );
		//END mainloop
		
		OpRetVoid( );
		
	}
	
	function end( )
	{
		bFinalize( );
		ByteApplication.buildToAsync( _call, this, "_FloatRenderer", _memory );
	}
}

typedef FloatRendererClassDef = 
{
	public function shade( s_addr:Int, e_addr:Int ):Dynamic;
}






















