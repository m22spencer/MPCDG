/**
 * ...
 * @author Matthew Spencer
 */

package apps;
import apps.maps.vertex.XZYMap;
import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.Lib;
import flash.Memory;
import flash.utils.ByteArray;
import flash.utils.Endian;

class UnitTestLeftRight2
{

	var ba:ByteArray;
	
	public function new() 
	{
		ba = new ByteArray( );
		ba.length = 10000000;
		ba.endian = Endian.LITTLE_ENDIAN;
		Memory.select( ba );
		
		new FloatingRasterNewFormat( init, 0, 512, ba, new XZYMap( ) );
		
		bmdToTex( new TestTexture( ), 2000000 );
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
	
	function bmdToTex( bmd:BitmapData, addr:Int )
	{
		for ( y in 0...Std.int(bmd.height) )
		{
			for ( x in 0...Std.int(bmd.width) )
			{
				Memory.setI32( addr + ((y * Std.int(bmd.height)) + x) * 4, bmd.getPixel32( x, y ) );			
			}			
		}
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
		
		Memory.setFloat( pr, 400 );
		Memory.setFloat( pr+4, 400 );
		Memory.setFloat( pr+8, 262144 + 512 );
		pr += 12;
		
		Memory.setFloat( pr, 400 );
		Memory.setFloat( pr+4, 100 );
		Memory.setFloat( pr+8, 512 );
		pr += 12;
		
		Memory.setFloat( pr, 100 );
		Memory.setFloat( pr+4, 400 );
		Memory.setFloat( pr+8, 262144 + 0 );
		pr += 12;
		
		Memory.setFloat( pr, 120+100 );
		Memory.setFloat( pr+4, 150 );
		Memory.setFloat( pr+8, 0 );
		pr += 12;
		
		Memory.setFloat( pr, 120+150 );
		Memory.setFloat( pr+4, 100 );
		Memory.setFloat( pr+8, 10 );
		pr += 12;
		
		Memory.setFloat( pr, 120+130 );
		Memory.setFloat( pr+4, 300 );
		Memory.setFloat( pr+8, 20 );
		pr += 12;
		
		shader( ptr, ptr + 1 );
		
		
		
		ba.position = 0;
		canvas.setPixels( canvas.rect, ba );
		ba.position = 0;	
		
		//if ( res == 3038 )
		//	Lib.current.removeEventListener( Event.ENTER_FRAME, onEnterFrame );
	}
	
}

class TestTexture extends BitmapData { public function new() { super(0, 0); }}
