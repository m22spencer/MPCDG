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

class MassRenderNoInline
{

	var ba:ByteArray;
	
	public function new() 
	{
		ba = new ByteArray( );
		ba.length = 10000000;
		ba.endian = Endian.LITTLE_ENDIAN;
		Memory.select( ba );
		
		new FloatingRaster( init, 0, 512, ba );
	}
	
	static var shader:Dynamic;
	private var canvas:BitmapData;
	private var tf:TextField;
	
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
		
		var ptr:Int = 5000000;
		var pr:Int = ptr;
		
		var sz:Float = 512;
		var dist:Float = 30;
		sz = 512 - dist * 2;
		
		var pixels:Int = 0;
		
		var num:Int = 12000;
		for ( i in 0...num )
		{
			var x:Float = Math.random()*sz+dist;
			var y:Float = Math.random() * sz + dist;
			
			var u:Float = (Math.random() > .5)?1: -1;
			var l:Float = (Math.random() > .5)?1: -1;
			
			Memory.setFloat( pr, x + Math.random()*dist*u );
			Memory.setFloat( pr+4, y + Math.random()*dist*l );
			pr += 12;
			
			Memory.setFloat( pr, x + Math.random()*dist*u);
			Memory.setFloat( pr+4, y + Math.random()*dist*l);
			pr += 12;
			
			Memory.setFloat( pr, x + Math.random()*dist*u);
			Memory.setFloat( pr+4, y + Math.random()*dist*l);
			pr += 12;
		}
		
		var time:Int = Lib.getTimer( );
		pixels += shader( ptr, ptr + num * 36 );
		time = Lib.getTimer( ) - time;
		
		tf.text = 
		"rasterization: " + time + "ms\n" +
		"pixels: " + pixels + "ms\n" +
		"polys: " + num;
		
		ba.position = 0;
		canvas.setPixels( canvas.rect, ba );
		ba.position = 0;	
		
		//throw( pixels );
		//Lib.current.removeEventListener( Event.ENTER_FRAME, onEnterFrame );
	}
	
}