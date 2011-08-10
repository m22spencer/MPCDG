package ;
import apps.maps.vertex.XYZUVMap;
import apps.shaders.vertex.FlattenShader;
import byteapps.MatrixTest;
import byteapps.MemorySpeedTest;
import byteroutines.MemoryRoutines;
import byteroutines.RasterFloatRoutines;
import com.codex.c3dex.bcode.RasterizerFloat;
import com.codex.c3dex.GraphicsBuffer;
import com.codex.c3dex.mapping.VertexMapper2;
import com.codex.c3dex.memory.MemoryDispatcher;
import com.codex.c3dex.shader.VertexShader;
import flash.Lib;
import flash.Memory;
import flash.utils.ByteArray;

/**
 * ...
 * @author Matthew Spencer
 */

class Main 
{
	
	static var ba:ByteArray;
	
	static function main() 
	{
		flash.Lib.current.stage.scaleMode = flash.display.StageScaleMode.NO_SCALE;
		flash.Lib.current.stage.align = flash.display.StageAlign.TOP_LEFT;

		neash.Lib.Init( "MPCDG", 1024, 600 );
		neash.Lib.ShowFPS( true );
		neash.Lib.SetFrameRate( 30 );
		neash.Lib.Run( );	
		
		//new GraphicsBufferTest( );
		
		//new apps.SerpenskiGen3DFloatingNewFormat( );
		
		
		
		//new apps.SerpenskiGen3DFloatingNewFormatRoutine( );
		//new apps.SerpenskiGen3DFloatingNewFormatRoutineMemoryManaged( );
		
		MemoryDispatcher.init( 6, 18 );
		
		new MatrixTest( pfln, MemoryDispatcher.ba, untyped new VertexMapper2( 12, new Array( ) ), new FlattenShader( ) );
	}
	
	static function pfln( cls:MatrixTestDef )
	{
		var m1 = MemoryDispatcher.alloc( 64 );
		var m2 = MemoryDispatcher.alloc( 64 );
		var m3 = MemoryDispatcher.alloc( 64 );
		var vert_d = MemoryDispatcher.alloc( 24 );
		
		var l:Float = 1;
		loadMatrix( m1, [
			1.0, 0.0, 0.0, 0.0,
			0.0, 1.0, 0.0, 0.0,
			0.0, 0.0, 1.0, 0.0,
			0.0, 0.0, 5.0, 1.0,
		]);
		
		{m2.setFloat( 0, l++ );
		m2.setFloat( 4, l++ );
		m2.setFloat( 8, l++ );
		m2.setFloat( 12, l++ );
		
		m2.setFloat( 16, l++ );
		m2.setFloat( 20, l++ );
		m2.setFloat( 24, l++ );
		m2.setFloat( 28, l++ );
		
		m2.setFloat( 32, l++ );
		m2.setFloat( 36, l++ );
		m2.setFloat( 40, l++ );
		m2.setFloat( 44, l++ );
		
		m2.setFloat( 48, l++ );
		m2.setFloat( 52, l++ );
		m2.setFloat( 56, l++ );
		m2.setFloat( 60, l++ );}
		
		{m3.setFloat( 0, l++ );
		m3.setFloat( 4, l++ );
		m3.setFloat( 8, l++ );
		m3.setFloat( 12, l++ );
		
		m3.setFloat( 16, l++ );
		m3.setFloat( 20, l++ );
		m3.setFloat( 24, l++ );
		m3.setFloat( 28, l++ );
		
		m3.setFloat( 32, l++ );
		m3.setFloat( 36, l++ );
		m3.setFloat( 40, l++ );
		m3.setFloat( 44, l++ );
		
		m3.setFloat( 48, l++ );
		m3.setFloat( 52, l++ );
		m3.setFloat( 56, l++ );
		m3.setFloat( 60, l++ );}
		
		vert_d.setFloat( 0, 1.0 );
		vert_d.setFloat( 4, 1.0 );
		vert_d.setFloat( 8, 1.0 );
		vert_d.setFloat( 12, 10.0 );
		vert_d.setFloat( 16, 10.0 );
		vert_d.setFloat( 20, 10.0 );
		
		var gfxData:GraphicsBuffer = new GraphicsBuffer( 300, null );
		
		gfxData.pushMatrix( m1 );
		gfxData.pushVertexBuffer( vert_d );
		gfxData.finalize( );
		
		//trace( untyped gfxData.mem.getByte( 0 ) );
		
		var d_out = MemoryDispatcher.alloc( 1024 );
		
		trace( cls.transform( untyped gfxData.mem.addr, d_out.addr ) );
		
		trace( d_out.getFloat( 0 ) + ", " + d_out.getFloat( 4 ) + ", " + d_out.getFloat( 8 ) );
		trace( d_out.getFloat( 12 ) + ", " + d_out.getFloat( 16 ) + ", " + d_out.getFloat( 20 ) );

		
		
	}
	
	static function loadMatrix( m:RasterMem, data:Array<Float> )
	{
		if ( data.length != 16 )	throw( "Non 16 matrix data not supported" );
		
		for ( g in 0...16 )
		{
			m.setFloat( g * 4, data[g] );
		}
	}
}









