﻿/**
 * ...
 * @author Matthew Spencer
 */

package apps;
import com.abc.CMath;
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

class SerpenskiGen3D
{

	var ba:ByteArray;
	
	public function new() 
	{
		ba = new ByteArray( );
		ba.length = 100000000;
		ba.endian = Endian.LITTLE_ENDIAN;
		Memory.select( ba );
		
		new FixedRaster( preinit, 0, 512, ba, true );
	}
	
	function preinit( shade_debug:Dynamic )
	{
		shader_debug = shade_debug;
		new FixedRaster( init, 0, 512, ba );
	}
	
	static var cur_shader:Dynamic;
	static var shader:Dynamic;
	static var shader_debug:Dynamic;
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
			Memory.setFloat( pr, x );
			Memory.setFloat( pr+4, y-hsize );
			Memory.setFloat( pr+8, z );
			pr += 12;
			
			Memory.setFloat( pr, x+hsize );
			Memory.setFloat( pr+4, y + hsize );
			Memory.setFloat( pr+8, z-hsize );
			pr += 12;
			
			Memory.setFloat( pr, x-hsize );
			Memory.setFloat( pr+4, y + hsize );
			Memory.setFloat( pr + 8, z-hsize );
			pr += 12;
			subdivide_ptr += 36;
			
			//back-right face
			Memory.setFloat( pr, x );
			Memory.setFloat( pr+4, y-hsize );
			Memory.setFloat( pr+8, z );
			pr += 12;
			
			Memory.setFloat( pr, x+hsize );
			Memory.setFloat( pr+4, y + hsize );
			Memory.setFloat( pr+8, z-hsize );
			pr += 12;
			
			Memory.setFloat( pr, x );
			Memory.setFloat( pr+4, y + hsize );
			Memory.setFloat( pr + 8, z+hsize );
			pr += 12;
			subdivide_ptr += 36;
			
			//back-left face
			Memory.setFloat( pr, x );
			Memory.setFloat( pr+4, y-hsize );
			Memory.setFloat( pr+8, z );
			pr += 12;
			
			Memory.setFloat( pr, x-hsize );
			Memory.setFloat( pr+4, y + hsize );
			Memory.setFloat( pr+8, z-hsize );
			pr += 12;
			
			Memory.setFloat( pr, x );
			Memory.setFloat( pr+4, y + hsize );
			Memory.setFloat( pr + 8, z+hsize );
			pr += 12;
			subdivide_ptr += 36;
			
			//bottom face
			Memory.setFloat( pr, x+hsize );
			Memory.setFloat( pr+4, y+hsize );
			Memory.setFloat( pr+8, z-hsize );
			pr += 12;
			
			Memory.setFloat( pr, x-hsize );
			Memory.setFloat( pr+4, y + hsize );
			Memory.setFloat( pr+8, z-hsize );
			pr += 12;
			
			Memory.setFloat( pr, x );
			Memory.setFloat( pr+4, y + hsize );
			Memory.setFloat( pr + 8, z+hsize );
			pr += 12;
			subdivide_ptr += 36;
						
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
		{Memory.setFloat( pr, x+hw );
		 Memory.setFloat( pr+4, y-hw );
		 Memory.setFloat( pr+8, z-hw );
		 pr += 12;
		
		 Memory.setFloat( pr, x-hw );
		 Memory.setFloat( pr+4, y-hw );
		 Memory.setFloat( pr+8, z-hw );
		 pr += 12;
		
		 Memory.setFloat( pr, x-hw );
		 Memory.setFloat( pr+4, y+hw );
		 Memory.setFloat( pr + 8, z-hw );
		 pr += 12;
	     subdivide_ptr += 36;}
		
		//front face b
		{Memory.setFloat( pr, x+hw );
		 Memory.setFloat( pr+4, y+hw );
		 Memory.setFloat( pr+8, z-hw );
		 pr += 12;
		
		 Memory.setFloat( pr,   x+hw );
		 Memory.setFloat( pr+4, y-hw );
		 Memory.setFloat( pr+8, z-hw );
		 pr += 12;
		
		 Memory.setFloat( pr,     x-hw );
		 Memory.setFloat( pr+4,   y+hw );
		 Memory.setFloat( pr + 8, z-hw );
		 pr += 12;
		 subdivide_ptr += 36; }
		 
		//back face a
		{Memory.setFloat( pr, x+hw );
		 Memory.setFloat( pr+4, y-hw );
		 Memory.setFloat( pr+8, z+hw );
		 pr += 12;
		
		 Memory.setFloat( pr, x-hw );
		 Memory.setFloat( pr+4, y-hw );
		 Memory.setFloat( pr+8, z+hw );
		 pr += 12;
		
		 Memory.setFloat( pr, x-hw );
		 Memory.setFloat( pr+4, y+hw );
		 Memory.setFloat( pr + 8, z+hw );
		 pr += 12;
	     subdivide_ptr += 36;}		 
		 
		//back face b
		{Memory.setFloat( pr, x + hw );
		 Memory.setFloat( pr+4, y+hw );
		 Memory.setFloat( pr+8, z+hw );
		 pr += 12;
		
		 Memory.setFloat( pr,   x+hw );
		 Memory.setFloat( pr+4, y-hw );
		 Memory.setFloat( pr+8, z+hw );
		 pr += 12;
		
		 Memory.setFloat( pr,     x-hw );
		 Memory.setFloat( pr+4,   y+hw );
		 Memory.setFloat( pr + 8, z+hw );
		 pr += 12;
		 subdivide_ptr += 36; }
		 
		
		 
		//left face a
		{Memory.setFloat( pr,   x-hw );
		 Memory.setFloat( pr+4, y-hw );
		 Memory.setFloat( pr+8, z-hw );
		 pr += 12;
		
		 Memory.setFloat( pr,   x-hw );
		 Memory.setFloat( pr+4, y-hw );
		 Memory.setFloat( pr+8, z+hw );
		 pr += 12;
		
		 Memory.setFloat( pr,     x-hw );
		 Memory.setFloat( pr+4,   y+hw );
		 Memory.setFloat( pr + 8, z+hw );
		 pr += 12;
		 subdivide_ptr += 36; }
		 
		 //left face b
		{Memory.setFloat( pr,   x-hw );
		 Memory.setFloat( pr+4, y-hw );
		 Memory.setFloat( pr+8, z-hw );
		 pr += 12;
		
		 Memory.setFloat( pr,   x-hw );
		 Memory.setFloat( pr+4, y+hw );
		 Memory.setFloat( pr+8, z+hw );
		 pr += 12;
		
		 Memory.setFloat( pr,     x-hw );
		 Memory.setFloat( pr+4,   y+hw );
		 Memory.setFloat( pr + 8, z-hw );
		 pr += 12;
		 subdivide_ptr += 36; }
		 
		 
		//right face a
		{Memory.setFloat( pr,   x+hw );
		 Memory.setFloat( pr+4, y-hw );
		 Memory.setFloat( pr+8, z-hw );
		 pr += 12;
		
		 Memory.setFloat( pr,   x+hw );
		 Memory.setFloat( pr+4, y-hw );
		 Memory.setFloat( pr+8, z+hw );
		 pr += 12;
		
		 Memory.setFloat( pr,     x+hw );
		 Memory.setFloat( pr+4,   y+hw );
		 Memory.setFloat( pr + 8, z+hw );
		 pr += 12;
		 subdivide_ptr += 36; }
		 
		 //right face b
		{Memory.setFloat( pr,   x+hw );
		 Memory.setFloat( pr+4, y-hw );
		 Memory.setFloat( pr+8, z-hw );
		 pr += 12;
		
		 Memory.setFloat( pr,   x+hw );
		 Memory.setFloat( pr+4, y+hw );
		 Memory.setFloat( pr+8, z+hw );
		 pr += 12;
		
		 Memory.setFloat( pr,     x+hw );
		 Memory.setFloat( pr+4,   y+hw );
		 Memory.setFloat( pr + 8, z-hw );
		 pr += 12;
		 subdivide_ptr += 36; }
		 

		 
		//top face a
		{Memory.setFloat( pr,   x+hw );
		 Memory.setFloat( pr+4, y-hw );
		 Memory.setFloat( pr+8, z+hw );
		 pr += 12;
		
		 Memory.setFloat( pr,   x-hw );
		 Memory.setFloat( pr+4, y-hw );
		 Memory.setFloat( pr+8, z+hw );
		 pr += 12;
		
		 Memory.setFloat( pr,     x-hw );
		 Memory.setFloat( pr+4,   y-hw );
		 Memory.setFloat( pr + 8, z-hw );
		 pr += 12;
		 subdivide_ptr += 36; }
		 
		 //top face b
		{Memory.setFloat( pr,   x+hw );
		 Memory.setFloat( pr+4, y-hw );
		 Memory.setFloat( pr+8, z+hw );
		 pr += 12;
		
		 Memory.setFloat( pr,   x-hw );
		 Memory.setFloat( pr+4, y-hw );
		 Memory.setFloat( pr+8, z-hw );
		 pr += 12;
		
		 Memory.setFloat( pr,     x+hw );
		 Memory.setFloat( pr+4,   y-hw );
		 Memory.setFloat( pr + 8, z-hw );
		 pr += 12;
		 subdivide_ptr += 36;}		 
		 
		//bottom face a
		{Memory.setFloat( pr,   x+hw );
		 Memory.setFloat( pr+4, y+hw );
		 Memory.setFloat( pr+8, z+hw );
		 pr += 12;
		
		 Memory.setFloat( pr,   x-hw );
		 Memory.setFloat( pr+4, y+hw );
		 Memory.setFloat( pr+8, z+hw );
		 pr += 12;
		
		 Memory.setFloat( pr,     x-hw );
		 Memory.setFloat( pr+4,   y+hw );
		 Memory.setFloat( pr + 8, z-hw );
		 pr += 12;
		 subdivide_ptr += 36; }
		 
		 //bottom face b
		{Memory.setFloat( pr,   x+hw );
		 Memory.setFloat( pr+4, y+hw );
		 Memory.setFloat( pr+8, z+hw );
		 pr += 12;
		
		 Memory.setFloat( pr,   x-hw );
		 Memory.setFloat( pr+4, y+hw );
		 Memory.setFloat( pr+8, z-hw );
		 pr += 12;
		
		 Memory.setFloat( pr,     x+hw );
		 Memory.setFloat( pr+4,   y+hw );
		 Memory.setFloat( pr + 8, z-hw );
		 pr += 12;
		 subdivide_ptr += 36;}	
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
				{Memory.setFloat( pr,   ix );
				 Memory.setFloat( pr+4, iy );
				 Memory.setFloat( pr+8, 0 );
				 pr += 12;
				
				 Memory.setFloat( pr,   ix );
				 Memory.setFloat( pr+4, iy+cells );
				 Memory.setFloat( pr+8, 0 );
				 pr += 12;
				
				 Memory.setFloat( pr,     ix+cells );
				 Memory.setFloat( pr+4,   iy );
				 Memory.setFloat( pr + 8, 0 );
				 pr += 12;
				 subdivide_ptr += 36; }
				 
				 //bottom face b
				{Memory.setFloat( pr,   ix+cells );
				 Memory.setFloat( pr+4, iy );
				 Memory.setFloat( pr+8, 0 );
				 pr += 12;
				
				 Memory.setFloat( pr,   ix );
				 Memory.setFloat( pr+4, iy+cells );
				 Memory.setFloat( pr+8, 0 );
				 pr += 12;
				
				 Memory.setFloat( pr,     ix+cells );
				 Memory.setFloat( pr+4,   iy+cells );
				 Memory.setFloat( pr + 8, 0 );
				 pr += 12;
				 subdivide_ptr += 36;}	
				
				
				ix += cells;
			}
			iy += cells;
		}
	}
	
	function init( shade:Dynamic )
	{
		shader = shade;
		cur_shader = shade;
		canvas = new BitmapData( 512, 512, false );
		buffer = new BitmapData( 512, 512, false );
		bitmap = new Bitmap( canvas );
		Lib.current.addChild( bitmap );
		
		tf = new TextField( );
		tf.width = 1000;
		tf.x = 520;
		tf.height = 1000;
		tf.selectable = false;
		tf.textColor = 0x000000;
		Lib.current.addChild( tf );
		
		rebuild( );
		Lib.current.addEventListener( Event.ENTER_FRAME, onEnterFrame );
		Lib.current.stage.addEventListener( MouseEvent.MOUSE_WHEEL, onWheel );
		Lib.current.stage.addEventListener( MouseEvent.CLICK, onClick );
		Lib.current.stage.addEventListener( KeyboardEvent.KEY_DOWN, onKey );
	}
	
	static var mrot:Matrix4mem = new Matrix4mem( 4000000 );
	static var mrot2:Matrix4mem = new Matrix4mem( 4005000 );
	
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
				
				
			rotationY -= .5 * (Math.PI / 180);
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
		
		if ( e.keyCode == Keyboard.DOWN )
		{
			useBlurFilter++;
			useBlurFilter %= 2;
			rotationY -= .5 * (Math.PI / 180);
			onEnterFrame( null );
		}
		
		if ( e.keyCode == Keyboard.UP )
		{
			funkyMode = !funkyMode;
			
			rotationY -= .5 * (Math.PI / 180);
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
	
	function rebuild( )
	{
		
		subdivide_ptr = m_start;
		
		switch( demot )
		{
			case 0:
				level = (level > 10)?10:(level < 0)?0:level;
				subDivide3D( 0, 0, 0, 1.5, cast(level*.7) );
			case 1:
				level = (level > 10)?10:(level < 1)?1:level;
				subDivideCube3D( 0, 0, 0, 1.5, cast( level*1.5 ) );
			case 2:
				level = (level > 10)?10:(level < 1)?1:level;
				for ( i in 0...cast(level*2) )
					drawCube( 0, 0, 0, 1.5 );
			case 3:
				level = (level > 10)?10:(level < 1)?1:level;
				drawPlane( 0, 0, 0, 1.5, level*level*2 );
		}
		
		
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
	
	function onEnterFrame( e )
	{		
		for ( i in 0...(512 * 512) )
			Memory.setI32( i << 2, 0x01 );
			
		rotationY += .5 * (Math.PI / 180);
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
		
		var mx:Float = CMath.clampf( -1.0, 1.0, Lib.current.stage.mouseX/256 - 1);
		var my:Float = CMath.clampf( -1.0, 1.0, Lib.current.stage.mouseY / 256 - 1);
		
		var dx:Float;
		var dy:Float;
		var eye:Int = 1;
		var za:Float;
		
		var addr:Int = m_start;
		var addr2:Int = m_start + (subdivide_ptr - m_start);
		while ( addr < subdivide_ptr )
		{
			Matrix4mem.concatVectorNoVP( mrot, addr, addr2 );
			
			var x = Memory.getFloat( addr2 );
			var y = Memory.getFloat( addr2+4 );
			var z = Memory.getFloat( addr2 + 8 );	
			za = z + 3;
			
			
			
			if ( funkyMode )
			{
				dx =(x * x + mx * mx);
				dy  =(y * y + my * my);
				
				x += dx*((mx)*.5);
				y += dy*((my)*.5);
			
				x = (eye / za) * x;
				y = (eye / za) * y;
							
				x = x * 512 + 256;
				y = y * 512 + 256;
			
				x = CMath.clampf( 0.0, 512.0, x );
				y = CMath.clampf( 0.0, 512.0, y );
			}
			else
			{
				x = (eye / za) * x;
				y = (eye / za) * y;
							
				x = x * 512 + 256;
				y = y * 512 + 256;
			}
			
			Memory.setFloat( addr2, x );
			Memory.setFloat( addr2 + 4, y );
		
			addr += 12;
			addr2 += 12;
		}
		
		var offset:Int = (subdivide_ptr - m_start);
		var time:Int = Lib.getTimer( );
		var pixels:Int = cur_shader( m_start+offset, m_start+offset+offset );
		time = Lib.getTimer( ) - time;
		
		if ( pauseOnError )
			Lib.current.removeEventListener( Event.ENTER_FRAME, onEnterFrame );
		
		pixelsa += pixels;
		timea += time;
		polya = cast( polya + cast((subdivide_ptr - m_start) / 36) );
		ct++;
		
		if ( Lib.getTimer() - sectime > 500 )
		{
			doInfos( );
		}
		
		if ( useBlurFilter == 1 )
		{
			ba.position = 0;
			buffer.setPixels( buffer.rect, ba );
			ba.position = 0;	
			canvas.applyFilter( buffer, buffer.rect, new Point( 0, 0 ), new BlurFilter( 1.25, 1.25, BitmapFilterQuality.LOW ) );
		}
		else
		{
			ba.position = 0;
			canvas.setPixels( buffer.rect, ba );
			ba.position = 0;	
		}
		//throw( pixels );
		//Lib.current.removeEventListener( Event.ENTER_FRAME, onEnterFrame );
	}
	
	function doInfos( )
	{
		var polyCount:Int = cast(polya / ct);
		var pixelCount:Int = cast(pixelsa / ct);
		var timeCount:Int = cast(timea / ct);
		
		var polyspersec:Dynamic = Std.int(((1000 / timeCount) * polyCount));
		var pixelspersec:Dynamic = Std.int(((1000 / timeCount) * pixelCount));
		if ( timeCount == 0 )
		{
			polyspersec = "n/a";
			pixelspersec = "n/a";
		}
		
		tf.text = 
			"Change demo type by clicking\t\t [left-mouse]\n" +
			"Change intensity level using \t\t\t [mouse-wheel]\n" +
			"Change debug/normal mode using\t [Any key]\n" +
			"Next frame                         \t\t\t [Right]\n" + 
			"Pause/play                  \t\t\t\t [Left]\n" +
			"Soften  					  \t\t\t [Down]\n" +
			"FunkyMode		    	  \t\t\t [Up]\n" +
			"\n\n[Rasterization details]\n" +
			"rasterization: " + timeCount + "ms\n" +
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