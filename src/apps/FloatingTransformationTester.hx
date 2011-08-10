/**
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

class FloatingTransformationTester
{

	var ba:ByteArray;
	
	public function new() 
	{
		ba = new ByteArray( );
		ba.length = 100000000;
		ba.endian = Endian.LITTLE_ENDIAN;
		Memory.select( ba );
		
		new FixedTransformation( init, ba );
	}
	
	private var canvas:BitmapData;
	private var tf:TextField;
	
	var subdivide_ptr:Int;
	public static inline var m_start:Int = 5000000;
		
	function init( transform:Dynamic )
	{
		transformer = transform;
		
		tf = new TextField( );
		tf.width = 1000;
		tf.x = 0;
		tf.height = 1000;
		//tf.selectable = false;
		tf.textColor = 0x000000;
		Lib.current.addChild( tf );
		
		Memory.setFloat(  0, 1.1 );
		Memory.setFloat(  4, 1.2 );
		Memory.setFloat(  8, 1.3 );
		Memory.setFloat( 12, 1.4 );
		
		Memory.setFloat( 16, 1.5 );
		Memory.setFloat( 20, 1.6 );
		Memory.setFloat( 24, 1.7 );
		Memory.setFloat( 28, 1.8 );
		
		Memory.setFloat( 32, 1.9 );
		Memory.setFloat( 36, 2.0 );
		Memory.setFloat( 40, 2.1 );
		Memory.setFloat( 44, 2.2 );
		
		Memory.setFloat( 48, 2.3 );
		Memory.setFloat( 52, 2.4 );
		Memory.setFloat( 56, 2.5 );
		Memory.setFloat( 60, 2.6 );
		
		var nverts:Int = 1000000;
		
		o_addr = 100;
		s_addr = o_addr;
		e_addr = o_addr + (nverts * 12);
		for ( i in 0...nverts )
		{
			Memory.setFloat( s_addr,   Math.random( ) );
			Memory.setFloat( s_addr+4, Math.random( ) );
			Memory.setFloat( s_addr+8, Math.random( ) );
			
			s_addr += 12;
		}
		
		Lib.current.addEventListener( Event.ENTER_FRAME, onEnterFrame );
	}
	
	static var mrot:Matrix4mem = new Matrix4mem( 4000000 );
	static var mrot2:Matrix4mem = new Matrix4mem( 4005000 );
	
	static var rotationY:Float = 0;
	private var transformer:Dynamic;
	private var o_addr:Int;
	private var s_addr:Int;
	private var e_addr:Int;
	
	function onEnterFrame( e )
	{		
		
		
		var time:Int = Lib.getTimer( );
		var out = transformer( 0, o_addr, e_addr, e_addr );
		time = Lib.getTimer( ) - time;
		
		tf.text = time+"ms";
	}
	
	function doInfos( )
	{
		
		//tf.text = 0;
	}
	
}