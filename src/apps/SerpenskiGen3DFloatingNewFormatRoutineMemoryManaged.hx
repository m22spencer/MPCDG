/**
 * ...
 * @author Matthew Spencer
 */

package apps;
import apps.maps.v2.XYZ20Step;
import apps.maps.vertex.XYZUVMap;
import apps.shaders.DepthShader;
import apps.shaders.LumShader;
import apps.shaders.OverdrawShader;
import byteapps.FloatRenderer;
import com.abc.CMath;
import com.codex.c3dex.mapping.VertexMapper2;
import com.codex.c3dex.memory.MemoryDispatcher;
import com.codex.c3dex.shader.PixelShader;
import com.Matrix4mem;
import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.PixelSnapping;
import flash.events.Event;
import flash.events.KeyboardEvent;
import flash.events.MouseEvent;
import flash.filters.BitmapFilterQuality;
import flash.filters.BlurFilter;
import flash.geom.Point;
import flash.Lib;
import flash.Memory;
import flash.text.TextField;
import flash.ui.Keyboard;
import flash.utils.ByteArray;
import flash.utils.Endian;

class SerpenskiGen3DFloatingNewFormatRoutineMemoryManaged
{
	
	var vmap:VertexMapper2;
	var pix_shader:PixelShader;
	static var width:Int = 1024;
	static var height:Int = 600;
	var frameBuffer:RasterMem;
	
	var rawMem:RasterMem;
	
	public function new() 
	{
		
		MemoryDispatcher.init( 10, 26 );			//1k -> 67MB
		Memory.select( MemoryDispatcher.ba );	
		
		
		mrot = new Matrix4mem( MemoryDispatcher.alloc(64).addr );
		mrot2 = new Matrix4mem( MemoryDispatcher.alloc(64).addr );
		
		//allocate framebuffer
		frameBuffer = MemoryDispatcher.alloc( width * height * 4 );
		
		rawMem = MemoryDispatcher.alloc( 1024 );		//1024 of raw space
		
		vmap = new XYZ20Step( );
		pix_shader = new OverdrawShader( );
		
		new FloatRenderer( preinit, MemoryDispatcher.ba, frameBuffer.addr, width, new DepthShader( ), vmap );
	}
	
	function preinit( shade_debug:FloatRendererClassDef )
	{
		shader_debug = shade_debug;
		new FloatRenderer( init, MemoryDispatcher.ba, frameBuffer.addr, width, pix_shader, vmap );
	}
	
	function bmdToTex( bmd:BitmapData )
	{
		var texture = MemoryDispatcher.alloc( Std.int(bmd.width) * Std.int(bmd.height) * 4 );
		for ( y in 0...Std.int(bmd.height) )
		{
			for ( x in 0...Std.int(bmd.width) )
			{
				texture.setI32( ((y * Std.int(bmd.height)) + x) * 4, bmd.getPixel32( x, y ) );		
			}			
		}
	}
	
	static var cur_shader:FloatRendererClassDef;
	static var shader:FloatRendererClassDef;
	static var shader_debug:FloatRendererClassDef;
	private var canvas:BitmapData;
	private var tf:TextField;
	
	var subdivide_ptr:Int;
	public static inline var m_start:Int = 5000000;
	
	function subDivide3D( x:Float, y:Float, z:Float, size:Float, drawLevel:Int, ?level:Int = 0  )
	{
		var hsize:Float = size * .5;
		var qsize:Float = size * .25;
		var esize:Float = size * .8;
		if ( level == drawLevel )
		{
			//draw me!
			var pr:Int = subdivide_ptr;
			
			//front face
			vertmem.setFloat( pr, x );
			vertmem.setFloat( pr+4, y-hsize );
			vertmem.setFloat( pr + 8, z );
			vertmem.setFloat( pr+12, cast Math.random()*0xFF );
			vertmem.setFloat( pr+16,cast Math.random()*0xFF );
			pr += 20;
			
			vertmem.setFloat( pr, x+hsize );
			vertmem.setFloat( pr+4, y + hsize );
			vertmem.setFloat( pr+8, z-hsize );
			vertmem.setFloat( pr+12,cast Math.random()*0xFF );
			vertmem.setFloat( pr+16,cast Math.random()*0xFF );
			pr += 20;
			
			vertmem.setFloat( pr, x-hsize );
			vertmem.setFloat( pr+4, y + hsize );
			vertmem.setFloat( pr + 8, z-hsize );
			vertmem.setFloat( pr+12, cast Math.random()*0xFF );
			vertmem.setFloat( pr+16,cast Math.random()*0xFF );
			pr += 20;
			subdivide_ptr += 60;
			
			//back-right face
			vertmem.setFloat( pr, x );
			vertmem.setFloat( pr+4, y-hsize );
			vertmem.setFloat( pr+8, z );
			vertmem.setFloat( pr+12, cast Math.random()*0xFF );
			vertmem.setFloat( pr+16,cast Math.random()*0xFF );
			pr += 20;
			
			vertmem.setFloat( pr, x+hsize );
			vertmem.setFloat( pr+4, y + hsize );
			vertmem.setFloat( pr+8, z-hsize );
			vertmem.setFloat( pr+12, cast Math.random()*0xFF );
			vertmem.setFloat( pr+16,cast Math.random()*0xFF );
			pr += 20;
			
			vertmem.setFloat( pr, x );
			vertmem.setFloat( pr+4, y + hsize );
			vertmem.setFloat( pr + 8, z+hsize );
			vertmem.setFloat( pr+12, cast Math.random()*0xFF );
			vertmem.setFloat( pr+16,cast Math.random()*0xFF );
			pr += 20;
			subdivide_ptr += 60;
			
			//back-left face
			vertmem.setFloat( pr, x );
			vertmem.setFloat( pr+4, y-hsize );
			vertmem.setFloat( pr+8, z );
			vertmem.setFloat( pr+12, cast Math.random()*0xFF );
			vertmem.setFloat( pr+16,cast Math.random()*0xFF );
			pr += 20;
			
			vertmem.setFloat( pr, x-hsize );
			vertmem.setFloat( pr+4, y + hsize );
			vertmem.setFloat( pr+8, z-hsize );
			vertmem.setFloat( pr+12, cast Math.random()*0xFF );
			vertmem.setFloat( pr+16,cast Math.random()*0xFF );
			pr += 20;
			
			vertmem.setFloat( pr, x );
			vertmem.setFloat( pr+4, y + hsize );
			vertmem.setFloat( pr + 8, z+hsize );
			vertmem.setFloat( pr+12, cast Math.random()*0xFF );
			vertmem.setFloat( pr+16,cast Math.random()*0xFF );
			pr += 20;
			subdivide_ptr += 60;
			
			//bottom face
			vertmem.setFloat( pr, x+hsize );
			vertmem.setFloat( pr+4, y+hsize );
			vertmem.setFloat( pr+8, z-hsize );
			vertmem.setFloat( pr+12, cast Math.random()*0xFF );
			vertmem.setFloat( pr+16,cast Math.random()*0xFF );
			pr += 20;
			
			vertmem.setFloat( pr, x-hsize );
			vertmem.setFloat( pr+4, y + hsize );
			vertmem.setFloat( pr+8, z-hsize );
			vertmem.setFloat( pr+12, cast Math.random()*0xFF );
			vertmem.setFloat( pr+16,cast Math.random()*0xFF );
			pr += 20;
			
			vertmem.setFloat( pr, x );
			vertmem.setFloat( pr+4, y + hsize );
			vertmem.setFloat( pr + 8, z+hsize );
			vertmem.setFloat( pr+12, cast Math.random()*0xFF );
			vertmem.setFloat( pr+16,cast Math.random()*0xFF );
			pr += 20;
			subdivide_ptr += 60;
						
		}
		else
		{
			//gots to descened. Lets see if I can code this right the first fucking time...
			
			//triangle 1 (top)
			subDivide3D( x, y-qsize, z, hsize, drawLevel, level+1 );
			
			//triangle 2 (bottom left front)
			subDivide3D( x - qsize, y + qsize, z - qsize, hsize, drawLevel, level+1 );
			
			//triangle 3 (bottom right front)
			subDivide3D( x + qsize, y + qsize, z - qsize, hsize, drawLevel, level + 1 );
			
			//triangle 4 (bottom center back)
			subDivide3D( x, y + qsize, z + qsize, hsize, drawLevel, level + 1 );
		}
	}
	
	function subDivideCube3D( x:Float, y:Float, z:Float, size:Float, ncubes:Int )
	{
		var ntotalcubes:Int = ncubes * 2 - 1;
		var hsize:Float = size * .5;
		
		var cubewidth:Float = size / ntotalcubes;
		var hcubewidth:Float = cubewidth * .5;
		var dcubewidth:Float = cubewidth * 2;
		
		var startx:Float = x - hsize + hcubewidth;
		var starty:Float = y - hsize + hcubewidth;
		var startz:Float = z - hsize + hcubewidth;
		
		var endx:Float = x + hsize;
		var endy:Float = y + hsize;
		var endz:Float = z + hsize;
		
		var ix:Float;
		var iy:Float;
		var iz:Float;
		
		iz = startz;
		while ( iz < endz )
		{
			iy = starty;
			while ( iy < endy )
			{
				ix = startx;
				while ( ix < endx )
				{
					drawCube( ix, iy, iz, cubewidth );
					ix += dcubewidth;
				}
				iy += dcubewidth;
			}
			iz += dcubewidth;
		}
		
		
	}
	
	//@FIXME Bad winding
	function drawCube( x:Float, y:Float, z:Float, cubewidth:Float )
	{
		var pr:Int = subdivide_ptr;
		var hw:Float = cubewidth * .5;
		
		//front face a
		{vertmem.setFloat( pr, x+hw );
		 vertmem.setFloat( pr+4, y-hw );
		 vertmem.setFloat( pr + 8, z - hw );
		 vertmem.setFloat( pr+12, cast 63 );
		 vertmem.setFloat( pr+16, cast 127 );
		 pr += 20;
		
		 vertmem.setFloat( pr, x-hw );
		 vertmem.setFloat( pr+4, y-hw );
		 vertmem.setFloat( pr+8, z-hw );
		 vertmem.setFloat( pr+12, cast 0 );
		 vertmem.setFloat( pr+16, cast 127 );
		 pr += 20;
		
		 vertmem.setFloat( pr, x-hw );
		 vertmem.setFloat( pr+4, y+hw );
		 vertmem.setFloat( pr + 8, z-hw );
		 vertmem.setFloat( pr+12, cast 0 );
		 vertmem.setFloat( pr+16, cast 63 );
		 pr += 20;
	     subdivide_ptr += 60;}
		
		pr = subdivide_ptr;
		//front face b
		{vertmem.setFloat( pr, x+hw );
		 vertmem.setFloat( pr+4, y+hw );
		 vertmem.setFloat( pr+8, z-hw );
		 vertmem.setFloat( pr+12, cast 63 );
	     vertmem.setFloat( pr+16, cast 63 );
		 pr += 20;
		
		 vertmem.setFloat( pr,   x+hw );
		 vertmem.setFloat( pr+4, y-hw );
		 vertmem.setFloat( pr+8, z-hw );
		 vertmem.setFloat( pr+12, cast 63 );
		 vertmem.setFloat( pr+16, cast 127 );
		 pr += 20;
		
		 vertmem.setFloat( pr,     x-hw );
		 vertmem.setFloat( pr+4,   y+hw );
		 vertmem.setFloat( pr + 8, z-hw );
		 vertmem.setFloat( pr+12, cast 0 );
		 vertmem.setFloat( pr+16, cast 63 );
		 pr += 20;
		 subdivide_ptr += 60; }
		 
		 
		 
		//back face a
		{vertmem.setFloat( pr, x+hw );
		 vertmem.setFloat( pr+4, y-hw );
		 vertmem.setFloat( pr+8, z+hw );
		 vertmem.setFloat( pr+12, cast 128 );
		 vertmem.setFloat( pr+16, cast 128 );
		 pr += 20;
		
		 vertmem.setFloat( pr, x-hw );
		 vertmem.setFloat( pr+4, y-hw );
		 vertmem.setFloat( pr+8, z+hw );
		 vertmem.setFloat( pr+12, cast 191 );
		 vertmem.setFloat( pr+16, cast 128 );
		 pr += 20;
		
		 vertmem.setFloat( pr, x-hw );
		 vertmem.setFloat( pr+4, y+hw );
		 vertmem.setFloat( pr + 8, z+hw );
		 vertmem.setFloat( pr+12, cast 191 );
		 vertmem.setFloat( pr+16, cast 64 );
		 pr += 20;
	     subdivide_ptr += 60;}		 
		 
		//back face b
		{vertmem.setFloat( pr, x + hw );
		 vertmem.setFloat( pr+4, y+hw );
		 vertmem.setFloat( pr+8, z+hw );
		 vertmem.setFloat( pr+12, cast 128 );
		 vertmem.setFloat( pr+16, cast 64 );
		 pr += 20;
		
		 vertmem.setFloat( pr,   x+hw );
		 vertmem.setFloat( pr+4, y-hw );
		 vertmem.setFloat( pr+8, z+hw );
		 vertmem.setFloat( pr+12, cast 128 );
		 vertmem.setFloat( pr+16, cast 128 );
		 pr += 20;
		
		 vertmem.setFloat( pr,     x-hw );
		 vertmem.setFloat( pr+4,   y+hw );
		 vertmem.setFloat( pr + 8, z+hw );
		 vertmem.setFloat( pr+12, cast 191 );
		 vertmem.setFloat( pr+16, cast 64 );
		 pr += 20;
		 subdivide_ptr += 60; }
		 
		//left face a
		{vertmem.setFloat( pr,   x-hw );
		 vertmem.setFloat( pr+4, y-hw );
		 vertmem.setFloat( pr+8, z-hw );
		 vertmem.setFloat( pr+12, cast 255 );
		 vertmem.setFloat( pr+16, cast 127 );
		 pr += 20;
		
		 vertmem.setFloat( pr,   x-hw );
		 vertmem.setFloat( pr+4, y-hw );
		 vertmem.setFloat( pr+8, z+hw );
		 vertmem.setFloat( pr+12, cast 192 );
		 vertmem.setFloat( pr+16, cast 127 );
		 pr += 20;
		
		 vertmem.setFloat( pr,     x-hw );
		 vertmem.setFloat( pr+4,   y+hw );
		 vertmem.setFloat( pr + 8, z+hw );
		 vertmem.setFloat( pr+12, cast 192 );
		 vertmem.setFloat( pr+16, cast 64 );
		 pr += 20;
		 subdivide_ptr += 60; }
		 
		 //left face b
		{vertmem.setFloat( pr,   x-hw );
		 vertmem.setFloat( pr+4, y-hw );
		 vertmem.setFloat( pr+8, z-hw );
		 vertmem.setFloat( pr+12, cast 255 );
		 vertmem.setFloat( pr+16, cast 127 );
		 pr += 20;
		
		 vertmem.setFloat( pr,   x-hw );
		 vertmem.setFloat( pr+4, y+hw );
		 vertmem.setFloat( pr+8, z+hw );
		 vertmem.setFloat( pr+12, cast 192 );
		 vertmem.setFloat( pr+16, cast 64 );
		 pr += 20;
		
		 vertmem.setFloat( pr,     x-hw );
		 vertmem.setFloat( pr+4,   y+hw );
		 vertmem.setFloat( pr + 8, z-hw );
		 vertmem.setFloat( pr+12, cast 255 );
		 vertmem.setFloat( pr+16, cast 64 );
		 pr += 20;
		 subdivide_ptr += 60; }
		 
		
		 
		//right face a
		{vertmem.setFloat( pr,   x+hw );
		 vertmem.setFloat( pr+4, y-hw );
		 vertmem.setFloat( pr+8, z-hw );
		 vertmem.setFloat( pr+12, cast 64 );
		 vertmem.setFloat( pr+16, cast 127 );
		 pr += 20;
		
		 vertmem.setFloat( pr,   x+hw );
		 vertmem.setFloat( pr+4, y-hw );
		 vertmem.setFloat( pr+8, z+hw );
		 vertmem.setFloat( pr+12, cast 127 );
		 vertmem.setFloat( pr+16, cast 127 );
		 pr += 20;
		
		 vertmem.setFloat( pr,     x+hw );
		 vertmem.setFloat( pr+4,   y+hw );
		 vertmem.setFloat( pr + 8, z+hw );
		 vertmem.setFloat( pr+12, cast 127 );
		 vertmem.setFloat( pr+16, cast 64 );
		 pr += 20;
		 subdivide_ptr += 60; }
		 
		 //right face b
		{vertmem.setFloat( pr,   x+hw );
		 vertmem.setFloat( pr+4, y-hw );
		 vertmem.setFloat( pr+8, z-hw );
		 vertmem.setFloat( pr+12, cast 64 );
		 vertmem.setFloat( pr+16, cast 127 );
		 pr += 20;
		
		 vertmem.setFloat( pr,   x+hw );
		 vertmem.setFloat( pr+4, y+hw );
		 vertmem.setFloat( pr+8, z+hw );
		 vertmem.setFloat( pr+12, cast 127 );
		 vertmem.setFloat( pr+16, cast 64 );
		 pr += 20;
		
		 vertmem.setFloat( pr,     x+hw );
		 vertmem.setFloat( pr+4,   y+hw );
		 vertmem.setFloat( pr + 8, z-hw );
		 vertmem.setFloat( pr+12, cast 64 );
		 vertmem.setFloat( pr+16, cast 64 );
		 pr += 20;
		 subdivide_ptr += 60; }
		 
		
		 
		//top face a
		{vertmem.setFloat( pr,   x+hw );
		 vertmem.setFloat( pr+4, y-hw );
		 vertmem.setFloat( pr+8, z+hw );
		 vertmem.setFloat( pr+12, cast 127 );
		 vertmem.setFloat( pr+16, cast 191 );
		 pr += 20;
		
		 vertmem.setFloat( pr,   x-hw );
		 vertmem.setFloat( pr+4, y-hw );
		 vertmem.setFloat( pr+8, z+hw );
		 vertmem.setFloat( pr+12, cast 64 );
		 vertmem.setFloat( pr+16, cast 191 );
		 pr += 20;
		
		 vertmem.setFloat( pr,     x-hw );
		 vertmem.setFloat( pr+4,   y-hw );
		 vertmem.setFloat( pr + 8, z-hw );
		 vertmem.setFloat( pr+12, cast 64 );
		 vertmem.setFloat( pr+16, cast 128 );
		 pr += 20;
		 subdivide_ptr += 60; }
		 
		 //top face b
		{vertmem.setFloat( pr,   x+hw );
		 vertmem.setFloat( pr+4, y-hw );
		 vertmem.setFloat( pr+8, z+hw );
		 vertmem.setFloat( pr+12, cast 127 );
		 vertmem.setFloat( pr+16, cast 191 );
		 pr += 20;
		
		 vertmem.setFloat( pr,   x-hw );
		 vertmem.setFloat( pr+4, y-hw );
		 vertmem.setFloat( pr+8, z-hw );
		 vertmem.setFloat( pr+12, cast 64 );
		 vertmem.setFloat( pr+16, cast 128 );
		 pr += 20;
		
		 vertmem.setFloat( pr,     x+hw );
		 vertmem.setFloat( pr+4,   y-hw );
		 vertmem.setFloat( pr + 8, z-hw );
		 vertmem.setFloat( pr+12, cast 127 );
		 vertmem.setFloat( pr+16, cast 128 );
		 pr += 20;
		 subdivide_ptr += 60; }
		 
		 
		//bottom face a
		{vertmem.setFloat( pr,   x+hw );
		 vertmem.setFloat( pr+4, y+hw );
		 vertmem.setFloat( pr+8, z+hw );
		 vertmem.setFloat( pr+12, cast 127 );
		 vertmem.setFloat( pr+16, cast 0 );
		 pr += 20;
		
		 vertmem.setFloat( pr,   x-hw );
		 vertmem.setFloat( pr+4, y+hw );
		 vertmem.setFloat( pr+8, z+hw );
		 vertmem.setFloat( pr+12, cast 64 );
		 vertmem.setFloat( pr+16, cast 0 );
		 pr += 20;
		
		 vertmem.setFloat( pr,     x-hw );
		 vertmem.setFloat( pr+4,   y+hw );
		 vertmem.setFloat( pr + 8, z-hw );
		 vertmem.setFloat( pr+12, cast 64 );
		 vertmem.setFloat( pr+16, cast 63 );
		 pr += 20;
		 subdivide_ptr += 60; }
		 
		 
		 //bottom face b
		{vertmem.setFloat( pr,   x+hw );
		 vertmem.setFloat( pr+4, y+hw );
		 vertmem.setFloat( pr+8, z+hw );
		 vertmem.setFloat( pr+12, cast 127 );
		 vertmem.setFloat( pr+16, cast 0 );
		 pr += 20;
		
		 vertmem.setFloat( pr,   x-hw );
		 vertmem.setFloat( pr+4, y+hw );
		 vertmem.setFloat( pr+8, z-hw );
		 vertmem.setFloat( pr+12, cast 64 );
		 vertmem.setFloat( pr+16, cast 63 );
		 pr += 20;
		
		 vertmem.setFloat( pr,     x+hw );
		 vertmem.setFloat( pr+4,   y+hw );
		 vertmem.setFloat( pr + 8, z-hw );
		 vertmem.setFloat( pr+12, cast 127 );
		 vertmem.setFloat( pr+16, cast 63 );
		 pr += 20;
		 subdivide_ptr += 60;}	
	}
	
	function drawPlane( x:Float, y:Float, z:Float, size:Float, divisions:Int )
	{
		var hsize:Float = size * .5;
		var cells:Float = size / divisions;
		
		var startx:Float = x - hsize;
		var starty:Float = y - hsize;
		var endx:Float = x + hsize - cells*.5;
		var endy:Float = y + hsize - cells*.5;
		
		var ix:Float;
		var iy:Float;
		
		var pr:Int = subdivide_ptr;
		
		iy = starty;
		while ( iy < endy )
		{
			ix = startx;
			while ( ix < endx )
			{
			
				//bottom face a
				{vertmem.setFloat( pr,   ix );
				 vertmem.setFloat( pr+4, iy );
				 vertmem.setFloat( pr+8, 0 );
				 vertmem.setFloat( pr+12, cast Math.random()*0xFF );
				 vertmem.setFloat( pr+16,cast Math.random()*0xFF );
				 pr += 20;
				
				 vertmem.setFloat( pr,   ix );
				 vertmem.setFloat( pr+4, iy+cells );
				 vertmem.setFloat( pr+8, 0 );
				 vertmem.setFloat( pr+12, cast Math.random()*0xFF );
			     vertmem.setFloat( pr+16,cast Math.random()*0xFF );
				 pr += 20;
				
				 vertmem.setFloat( pr,     ix+cells );
				 vertmem.setFloat( pr+4,   iy );
				 vertmem.setFloat( pr + 8, 0 );
				 vertmem.setFloat( pr+12, cast Math.random()*0xFF );
			     vertmem.setFloat( pr+16,cast Math.random()*0xFF );
				 pr += 20;
				 subdivide_ptr += 60; }
				 
				 //bottom face b
				{vertmem.setFloat( pr,   ix+cells );
				 vertmem.setFloat( pr+4, iy );
				 vertmem.setFloat( pr+8, 0 );
				 vertmem.setFloat( pr+12, cast Math.random()*0xFF );
			     vertmem.setFloat( pr+16,cast Math.random()*0xFF );
				 pr += 20;
				
				 vertmem.setFloat( pr,   ix );
				 vertmem.setFloat( pr+4, iy+cells );
				 vertmem.setFloat( pr+8, 0 );
				 vertmem.setFloat( pr+12, cast Math.random()*0xFF );
			     vertmem.setFloat( pr+16,cast Math.random()*0xFF );
				 pr += 20;
				
				 vertmem.setFloat( pr,     ix+cells );
				 vertmem.setFloat( pr+4,   iy+cells );
				 vertmem.setFloat( pr + 8, 0 );
				 vertmem.setFloat( pr+12, cast Math.random()*0xFF );
			     vertmem.setFloat( pr+16,cast Math.random()*0xFF );
				 pr += 20;
				 subdivide_ptr += 60;}	
				
				
				ix += cells;
			}
			iy += cells;
		}
	}
	
	function init( shade:FloatRendererClassDef )
	{
		shader = shade;
		cur_shader = shade;
		canvas = new BitmapData( width, height, false );
		buffer = new BitmapData( width, height, false );
		bitmap = new Bitmap( canvas );
		Lib.current.addChild( bitmap );
		
		tf = new TextField( );
		tf.width = 1000;
		tf.height = 1000;
		tf.selectable = false;
		tf.textColor = 0xFF0000;
		Lib.current.addChild( tf );
		
		rebuild( );
		Lib.current.addEventListener( Event.ENTER_FRAME, onEnterFrame );
		Lib.current.stage.addEventListener( MouseEvent.MOUSE_WHEEL, onWheel );
		Lib.current.stage.addEventListener( MouseEvent.CLICK, onClick );
		Lib.current.stage.addEventListener( KeyboardEvent.KEY_DOWN, onKey );
	}
	
	static var mrot:Matrix4mem;
	static var mrot2:Matrix4mem;
	
	static var rotationY:Float = 0;
	static var level:Int = 2;
	static var demot:Int = 0;
	
	function onWheel( e )
	{
		if ( e.delta > 0 ) level++; else level--;
		
		rebuild( );
	}
	
	function onClick( e )
	{
		demot++;
		demot %= 4;
		rebuild( );
	}
	
	static var useBlurFilter:Int = 0;
	
	function onKey( e )
	{
		if ( e.keyCode == Keyboard.ENTER )
		{
			if ( cur_shader == shader )
				cur_shader = shader_debug;
			else
				cur_shader = shader;
				
				
			rotationY -= 1 * (Math.PI / 180);
			onEnterFrame( null );
		}
		if ( e.keyCode == Keyboard.RIGHT )
		{
			onEnterFrame( null );
		}
		
		if ( e.keyCode == Keyboard.LEFT )
		{
			pauseOnError = !pauseOnError;
			
			if( !pauseOnError )
				try {
					Lib.current.addEventListener( Event.ENTER_FRAME, onEnterFrame );
				}catch(e:Dynamic){}
		}
		
		/*
		if ( e.keyCode == Keyboard.DOWN )
		{
			useBlurFilter++;
			useBlurFilter %= 2;
			rotationY -= .5 * (Math.PI / 180);
			onEnterFrame( null );
		}
		*/
		
		if ( e.keyCode == Keyboard.HOME )
		{
			useBlurFilter++;
			useBlurFilter %= 2;
			rotationY -= 1 * (Math.PI / 180);
			onEnterFrame( null );
		}

		
		if ( e.keyCode == Keyboard.UP )
		{
			funkyMode = !funkyMode;
			
			rotationY -= 1 * (Math.PI / 180);
			onEnterFrame( null );
		}
		
		if ( e.keyCode == Keyboard.F1 )
		{
			level--;
			rebuild( );
		}
		
		if ( e.keyCode == Keyboard.F2 )
		{
			level++;
			rebuild( );
		}
	}
	
	var vertmem:RasterMem;
	var vertmem_t:RasterMem;
	function rebuild( )
	{
		
		subdivide_ptr = m_start;
		
		
		if ( vertmem != null )
		{
			vertmem.free( );
		}
		if (vertmem_t != null )
		{
			vertmem_t.free( );
		}
		
		subdivide_ptr = 0;		
		switch( demot )
		{
			case 0:
				level = (level > 10)?10:(level < 0)?0:level;
				vertmem = MemoryDispatcher.alloc( Std.int(Math.pow( 4, Std.int(level * .7)+1 )) * 3 * 20 );
				subDivide3D( 0, 0, 0, 1.5, cast(level*.7) );
			case 1:
				level = (level > 10)?10:(level < 1)?1:level;
				vertmem = MemoryDispatcher.alloc( Std.int(Math.pow( Std.int(level*1.5), 3 )) * 12 * 3 * 20 );
				subDivideCube3D( 0, 0, 0, 1.5, cast( level*1.5 ) );
			case 2:
				level = (level > 10)?10:(level < 1)?1:level;
				vertmem = MemoryDispatcher.alloc( level * 12 * 3 * 20 );
				for ( i in 0...cast(level) )
					drawCube( 0, 0, 0, 1.5 );
			case 3:
				level = (level > 10)?10:(level < 1)?1:level;
				vertmem = MemoryDispatcher.alloc( Std.int(Math.pow( level * level * 2, 2 )) * 2 * 3 * 20 );
				drawPlane( 0, 0, 0, 1.5, level*level*2 );
		}
		
		vertmem_t = MemoryDispatcher.alloc( vertmem.size );
		
		transform( );
		
		rotationY -= .5 * (Math.PI / 180);
		onEnterFrame( null );
		
		doInfos( );
	}
	
	static var polya:Int = 0;
	static var timea:Int = 0;
	static var pixelsa:Int = 0;
	
	static var ct:Int = 0;
	static var sectime:Int = 0;
	
	static var pauseOnError:Bool = false;
	static var funkyMode:Bool = false;
	private var bitmap:Bitmap;
	private var buffer:BitmapData;
	private var time:Int;
	private var time2:Int;
	
	inline function transform( )
	{
		
		rotationY += 1 * (Math.PI / 180);
		rotationY %= 360 * (Math.PI / 180);
		
		var r11 = Math.cos( rotationY );
		var r13 = Math.sin( rotationY );
		var r31 = -Math.sin( rotationY );
		var r33 = Math.cos( rotationY );
			
		mrot.fromArray([
			r11, 0.0, r31, 0,
			 0.0, 1.0, 0.0, 0,
			 r13, 0.0, r33, 0,
			 0.0, 0.0, 0.0, 1.0
		]);
		
		mrot2.fromArray([
			 1.0, 0.0, 0.0, 0,
			 0.0, Math.cos( rotationY ), Math.sin( rotationY ), 0,
			 0.0, -Math.sin( rotationY ), Math.cos( rotationY ), 0,
			 0.0, 0.0, 0.0, 1.0
		]);
		
		Matrix4mem.concat( mrot, mrot2, mrot );
		
		var mx:Float = CMath.clampf( -1.0, 1.0, Lib.current.stage.mouseX/(width*.5) - 1);
		var my:Float = CMath.clampf( -1.0, 1.0, Lib.current.stage.mouseY / (height * .5) - 1);
		
		var dx:Float;
		var dy:Float;
		var eye:Int = 1;
		var za:Float;
		
		var addr:Int = 0;
		while ( addr < vertmem.size )
		{
			Matrix4mem.concatVectorNoVP( mrot, vertmem.addr + addr, vertmem_t.addr + addr );
			
			var x = vertmem_t.getFloat( addr );
			var y = vertmem_t.getFloat( addr+4 );
			var z = vertmem_t.getFloat( addr+8 );	
			za = z + 3;
			
			vertmem_t.setFloat( addr + 12, vertmem.getFloat( addr + 12 ) );
			vertmem_t.setFloat( addr + 16, vertmem.getFloat( addr + 16 ) );
			
			if ( funkyMode )
			{
				dx =(x * x + mx * mx);
				dy  =(y * y + my * my);
				
				x += dx*((mx)*.5);
				y += dy*((my)*.5);
			
				x = (eye / za) * x;
				y = (eye / za) * y;
							
				x = x * width + (width*.5);
				y = y * height + (height*.5);
			
				x = CMath.clampf( 0.0, width, x );
				y = CMath.clampf( 0.0, height, y );
			}
			else
			{
				x = (eye / za) * x;
				y = (eye / za) * y;
							
				x = -x * width + (width*.5);
				y = y * height + (height*.5);
			}
			
			vertmem_t.setFloat( addr, x );
			vertmem_t.setFloat( addr + 4, y );
			
			vertmem_t.setFloat( addr + 8, za*100 );   //BUG Very low values of z do not interpolate correctly.
		
			addr += 20;
		}
	}
	
	function onEnterFrame( e )
	{	
		/*  double packing example
		rawMem.setFloat( 0, 100000 );
		rawMem.setFloat( 4, 100000 );
		var cval = rawMem.getDouble( 0 );
		//*/
		
		time2 = Lib.getTimer( );
		var addr:Int = 0;
		var end:Int = (width * height) * 4;
		while( addr < end )
		{
			frameBuffer.setDouble( addr, 0 );
			addr += 8;
			
			frameBuffer.setDouble( addr, 0 );
			addr += 8;
			
			frameBuffer.setDouble( addr, 0 );
			addr += 8;
			
			frameBuffer.setDouble( addr, 0 );
			addr += 8;			
		}
			
		
		
		transform( );
	
		
		time = Lib.getTimer( );
		var pixels:Int = cur_shader.shade( vertmem_t.addr, vertmem_t.addr + vertmem_t.size );
		time = Lib.getTimer( ) - time;
		
		tf.text = cast time;
		
		if ( pauseOnError )
			Lib.current.removeEventListener( Event.ENTER_FRAME, onEnterFrame );
		
			
		pixelsa += pixels;
		timea += time;
		polya = cast( polya + cast((vertmem_t.size) / 60) );
		ct++;
		
		
		
		
		if ( useBlurFilter == 1 )
		{
			MemoryDispatcher.ba.position = frameBuffer.addr;		
			buffer.setPixels( buffer.rect, MemoryDispatcher.ba );
			MemoryDispatcher.ba.position = 0;		
			canvas.applyFilter( buffer, buffer.rect, new Point( 0, 0 ), new BlurFilter( 1.75, 1.75, BitmapFilterQuality.LOW ) );
		}
		else
		{
			MemoryDispatcher.ba.position = frameBuffer.addr;			
			canvas.setPixels( buffer.rect, MemoryDispatcher.ba );
			MemoryDispatcher.ba.position = 0;							
		}
		//throw( pixels );
		//Lib.current.removeEventListener( Event.ENTER_FRAME, onEnterFrame );
		time2 = Lib.getTimer() - time2;
		doInfos( );
		
	}
	
	function doInfos( )
	{
		var polyCount:Int = cast(polya / ct);
		var pixelCount:Int = cast(pixelsa / ct);
		var timeCount:Int = cast(time );
		
		var polyspersec:Dynamic = Std.int(((1000 / timeCount) * polyCount));
		var pixelspersec:Dynamic = Std.int(((1000 / timeCount) * pixelCount));
		if ( timeCount == 0 )
		{
			polyspersec = "n/a";
			pixelspersec = "n/a";
		}
		
		var inUse:Float = Std.int(untyped MemoryDispatcher.inUse / (1000 * 10)) / 100;
		var inUseActual:Float = Std.int(untyped MemoryDispatcher.inUseActual / (1000 * 10)) / 100;
		var total:Float = Std.int(untyped MemoryDispatcher.max/(1000*10))/100;
		
		tf.text = 
			"FloatingRasterUV {zbuffer=true}\n" +
			"Change demo type by clicking\t\t [LEFT-MOUSE]\n" +
			"Change intensity level using \t\t\t [MOUSE-WHEEL]\n" +
			"Shader: overdraw/Depth \t\t\t [ENTER]\n" +
			"Next frame                         \t\t\t [RIGHT]\n" + 
			"Pause/play                  \t\t\t\t [LEFT]\n" +
			"Z-Buffer  				\t\t\t [DOWN]\n" +
			"Soften  				\t\t\t\t [HOME]\n" +
			"FunkyMode		    	  \t\t\t [UP]\n" +
			"\n\n[Rasterization details]\n" +
			"memory(V-Use/Use/TotalAvail): " + inUseActual + "/" + inUse + "/" + total + "mb\n" +
			"overall: " + time2 + "ms\n" +
			"rasterization: " + time + "ms\n" +
			"polys: " + polyCount + "\n" +
			"pixels: " + pixelCount + "\n" +
			"poly/sec: " + polyspersec + "\n" +
			"pixel/sec: " + pixelspersec + "\n" +
			"level: " + level;
		
		sectime = Lib.getTimer( );
		ct = 0;
		timea = 0;
		pixelsa = 0;
		polya = 0;
	}
	
}

import flash.display.BitmapData;
class CubeTex256x256 extends BitmapData { public function new() { super(0, 0);} }