/**
 * ...
 * @author Matthew Spencer
 */

package apps;
import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.Lib;
import flash.Memory;
import flash.text.TextField;
import flash.utils.ByteArray;
import flash.utils.Endian;

class SerpenskiGen
{

	var ba:ByteArray;
	
	public function new() 
	{
		ba = new ByteArray( );
		ba.length = 50000000;
		ba.endian = Endian.LITTLE_ENDIAN;
		Memory.select( ba );
		
		new FloatingRaster( init, 0, 512, ba );
	}
	
	static var shader:Dynamic;
	private var canvas:BitmapData;
	private var tf:TextField;
	
	var subdivide_ptr:Int;
	
	function subDivide( x:Float, y:Float, size:Float, drawLevel:Int, ?level:Int = 0  )
	{
		var hsize:Float = size * .5;
		var qsize:Float = size * .25;
		var esize:Float = size * .8;
		if ( level == drawLevel )
		{
			//draw me!
			var pr:Int = subdivide_ptr;
			
			Memory.setFloat( pr, x );
			Memory.setFloat( pr+4, y-hsize );
			pr += 12;
			
			Memory.setFloat( pr, x+hsize );
			Memory.setFloat( pr+4, y+hsize );
			pr += 12;
			
			Memory.setFloat( pr, x-hsize );
			Memory.setFloat( pr + 4, y+hsize );
			
			subdivide_ptr += 36;			
		}
		else
		{
			//gots to descened. Lets see if I can code this right the first fucking time...
			
			//triangle 1 (top)
			subDivide( x, y-qsize, hsize, drawLevel, level+1 );
			
			//triangle 2 (bottom left)
			subDivide( x - qsize, y + qsize, hsize, drawLevel, level+1 );
			
			//triangle 2 (bottom right)
			subDivide( x + qsize, y + qsize, hsize, drawLevel, level+1 );
		}
	}
	
	function init( shade:Dynamic )
	{
		shader = shade;
		canvas = new BitmapData( 512, 512, false );
		Lib.current.addChild( new Bitmap( canvas ) );
		
		tf = new TextField( );
		tf.width = 1000;
		tf.textColor = 0xFFFFFFFF;
		Lib.current.addChild( tf );
		
		Lib.current.addEventListener( Event.ENTER_FRAME, onEnterFrame );
		Lib.current.stage.addEventListener( MouseEvent.CLICK, onClick );
	}
	
	function onClick( e )
	{
		Lib.current.addEventListener( Event.ENTER_FRAME, onEnterFrame );
	}
	
	function onEnterFrame( e )
	{		
		for ( i in 0...(512 * 512) )
			Memory.setI32( i << 2, 0x0 );
		
		var m_start:Int = 5000000;
		subdivide_ptr = m_start;
		
		subDivide( 256, 256, 500, 8 );
		
		var time:Int = Lib.getTimer( );
		var pixels:Int = shader( m_start, subdivide_ptr );
		time = Lib.getTimer( ) - time;
		
		tf.text = 
		"rasterization: " + time + "ms\n" +
		"pixels: " + pixels + "ms\n" +
		"polys: " + ((subdivide_ptr-m_start) / 36);
		
		ba.position = 0;
		canvas.setPixels( canvas.rect, ba );
		ba.position = 0;	
		
		//throw( pixels );
		//Lib.current.removeEventListener( Event.ENTER_FRAME, onEnterFrame );
	}
	
}