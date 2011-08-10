/**
 * ...
 * @author Matthew Spencer
 * 
 * This class is a data holder for the rasterizer. Using it allows for
 * Geometry Instancing, Pushable matrices, etc...
 * 
 * I am not convinced that it is a good method to use. Please review.
 */

package com.codex.c3dex;
import com.codex.c3dex.mapping.VertexMapper2;
import com.codex.c3dex.memory.MemoryDispatcher;

class GraphicsBuffer 
{
	
	var mem:RasterMem;
	var ptr:Int;
	var vmap:VertexMapper2;

	public function new( bytes:Int, vmapper:VertexMapper2 ) 
	{
		mem = MemoryDispatcher.alloc( bytes );
		ptr = 0;
		vmap = vmapper;
	}
	
	public function pushMatrix( mat:RasterMem )
	{
		#if debug
		if ( mat.size != 64 )	throw( "invalid matrix" );
		#end
		
		mem.setByte( ptr, GBE.MATRIX_PUSH );	ptr++;
		mem.setI32( ptr, mat.addr );			ptr+=4;
		
	}
	
	public function pushPerspectiveMatrix( mat:RasterMem )
	{
		#if debug
		if ( mat.size != 64 )	throw( "invalid matrix" );
		#end
		
		mem.setByte( ptr, GBE.PERSPECTIVE_PUSH );	ptr++;
		mem.setI32( ptr, mat.addr );				ptr+=4;
		
	}
	
	public function popMatrix( )
	{
		throw( "Not yet implemented" );
		mem.setByte( ptr, GBE.MATRIX_POP );	ptr++;
	}
	
	public function pushVertexBuffer( vbuffer:RasterMem )
	{
		mem.setByte( ptr, GBE.VERTEX_BUFFER_POINTER );      ptr++;
		mem.setI32( ptr, vbuffer.addr );    				ptr += 4;
		mem.setI32( ptr, vbuffer.addr + vbuffer.size );		ptr += 4;
	}
	
	public function finalize( )
	{
		mem.setByte( ptr, GBE.FINAL );
	}
	
}

class GBE
{
	public static inline var MATRIX_PUSH:Int = 0x01;
	public static inline var MATRIX_POP:Int = 0x02;
	public static inline var VERTEX_BUFFER_POINTER:Int = 0x03;
	public static inline var FINAL:Int = 0x04;
	public static inline var PERSPECTIVE_PUSH:Int = 0x05;
}