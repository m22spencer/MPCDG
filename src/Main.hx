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
		//neash.Lib.SetFrameRate( 120 );
		neash.Lib.Run( );	
		
		//new GraphicsBufferTest( );
		
		//new apps.SerpenskiGen3DFloatingNewFormat( );
		
		
		
		//new apps.SerpenskiGen3DFloatingNewFormatRoutine( );
		//new apps.SerpenskiGen3DFloatingNewFormatRoutineMemoryManaged( );
		new apps.SerpenskiGen3DFloatingNewFormatRoutineMemoryManagedVertexShader( );
	}
	
	
}









