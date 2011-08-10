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
import flash.utils.ByteArray;
import flash.utils.Endian;

class UnitTestLeftRight
{

	var ba:ByteArray;
	
	public function new() 
	{
		ba = new ByteArray( );
		ba.length = 10000000;
		ba.endian = Endian.LITTLE_ENDIAN;
		Memory.select( ba );
		
		new FixedRaster( init, 0, 512, ba );
	}
	
	static var shader:Dynamic;
	private var canvas:BitmapData;
	
	function init( shade:Dynamic )
	{
		shader = shade;
		canvas = new BitmapData( 512, 512, false );
		Lib.current.addChild( new Bitmap( canvas ) );
		
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
		
		var sz:Int = 512;
		
		Memory.setFloat( pr, Math.random() * sz );
		Memory.setFloat( pr+4, Math.random() * sz );
		pr += 12;
		
		Memory.setFloat( pr, Math.random() * sz );
		Memory.setFloat( pr+4, Math.random() * sz );
		pr += 12;
		
		Memory.setFloat( pr, Math.random() * sz );
		Memory.setFloat( pr+4, Math.random() * sz );
		pr += 12;
		
		var res = shader( ptr );
		
		ba.position = 0;
		canvas.setPixels( canvas.rect, ba );
		ba.position = 0;	
		
		if ( res == 3038 )
			Lib.current.removeEventListener( Event.ENTER_FRAME, onEnterFrame );
	}
	
}