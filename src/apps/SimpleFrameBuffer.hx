/**
 * ...
 * @author Matthew Spencer
 */

package apps;
import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.Lib;
import flash.Memory;
import flash.utils.ByteArray;
import flash.utils.Endian;

class SimpleFrameBuffer 
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
	
	function rop( x0, y0, x1, y1, x2, y2 )
	{
		var ptr = 5000000;
		var pr = ptr;
		Memory.setFloat( pr  , x0 );
		Memory.setFloat( pr+4, y0 );
		pr += 12;
		
		Memory.setFloat( pr  , x1 );
		Memory.setFloat( pr+4, y1 );
		pr += 12;
		
		Memory.setFloat( pr  , x2 );
		Memory.setFloat( pr+4, y2 );
		pr += 12;
		shader( ptr );
	}
	
	function init( shade:Dynamic )
	{
		shader = shade;
		var canvas:BitmapData = new BitmapData( 512, 512, false, 0x00000000 );
		Lib.current.addChild( new Bitmap( canvas ) );
		
		var x:Int = 25;
		var y:Int = 25;
		var step:Int = 25;
		var xinc:Int = 50;
		
		// | /
		// |/
		rop( 
			 x 
			,y
			,x+step
			,y
			,x
			,y+step
		);
		x += xinc;
		
		rop( 
			 x+step
			,y
			,x
			,y
			,x
			,y+step
		);
		x += xinc;
		
		rop( 
			 x 
			,y
			,x+step
			,y
			,x+step
			,y+step
		);
		x += xinc;
		
		rop( 
			 x+step 
			,y
			,x
			,y
			,x+step
			,y+step
		);
		x += xinc;
		
		ba.position = 0;
		canvas.setPixels( canvas.rect, ba );
		ba.position = 0;
		
		
		
	}
	
}