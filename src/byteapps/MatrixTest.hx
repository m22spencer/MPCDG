/**
 * ...
 * @author Matthew Spencer
 */

package byteapps;
import byteroutines.MatrixRoutines;
import com.codex.c3dex.bcode.app.ByteApplication;
import com.codex.c3dex.bcode.BVAR;
import com.abc.Reg;
import com.codex.c3dex.mapping.VertexMapper2;
import com.codex.c3dex.memory.MemoryDispatcher;
import com.codex.c3dex.shader.VertexShader;
import flash.utils.ByteArray;
import format.abc.Data;
import com.codex.c3dex.GraphicsBuffer;

typedef MatrixTestDef =
{
	function transform( a:Int, b:Int, c:Int ):Array<Float>;
	var vmap:VertexMapper2;
}

class MatrixTest extends ByteApplication
{
	private var gb_temp_address:Reg<Int>;
	private var varying_offset:Int;
	private var varying_infos:Array<Dynamic>;
	private var _call:MatrixTestDef->Void;

	public function new( call:MatrixTestDef->Void, ba:ByteArray, vmap:VertexMapper2, vertex_shader:VertexShader, width:Int, height:Int ) 
	{
		super( );
		_call = call;
		varying_offset = 12;
		varying_infos = new Array( );
		
		var c = bBeginClass( "_TransformationFloat" );
		var m = bBeginMethod( "transform", [_ctx.type("int"), _ctx.type("int"), _ctx.type("int")], tAny );
		m.maxStack = 20;
		
		var gb_address = Reg.param( 1, Int );
		gb_temp_address = Reg.param( 2, Int );
		var quitFast = Reg.param( 3, Int );
		
		OpReg( quitFast );
		OpInt( 1 );
		OpIf( JEq );
			OpRetVoid( );
		OpFi( );
			
		var main_loop = bLabel( );
		var CASE_END = bLabel( );
		var matRoutines = new MatrixRoutines( this );
		
		
		//build varying data for x/y/z
		varying_infos.push( { offset:0, type:Float, name:"x" } );
		varying_infos.push( { offset:4, type:Float, name:"y" } );
		varying_infos.push( { offset:8, type:Float, name:"z" } );
		
		//Load identity matrix to stack
		var currentMatrix = matRoutines.loadIdentity( );
		var perspectiveMatrix = matRoutines.loadIdentity( );					
		
		OpReg( gb_address );
		OpLabel( main_loop );
			
			//{addr}
			OpDup( );
			//{addr,addr}
			OpMemGet8( );											//read our function code from graphics data: switch( op )
			//{addr,op}
			
			
			OpDup( );	//{addr,op,op}
			OpInt( GBE.MATRIX_PUSH );
			OpIf( JEq );											//case GBE.MATRIX_PUSH
				//{addr}
				OpPop( );		//{addr}
				OpInt( 1 );
				OpIAdd( );		//{addr+1}
				OpDup( );		//{addr,addr}
				OpMemGet32( );	//{addr,ptr}
				var nm = matRoutines.loadMatrix( bv.stackEat.int() );
				var xm = matRoutines.concatMatrix( currentMatrix, nm );
				matRoutines.copyMatrix( xm, currentMatrix );					//TODO Analyze this bytecode. We can't just set currentMatrix = concatMatrix.. this causes the registers to distort, hence the "copy" function is there a better alternative?
				OpInt( 4 );
				OpIAdd( );
				OpJump( JAlways, main_loop );
			OpFi( );
			
			OpDup( );
			OpInt( GBE.PERSPECTIVE_PUSH );
			OpIf( JEq );
				OpPop( );		//{addr}
				OpInt( 1 );
				OpIAdd( );		//{addr+1}
				OpDup( );		//{addr,addr}
				OpMemGet32( );	//{addr,ptr}
				var npm = matRoutines.loadMatrix( bv.stackEat.int() );
				matRoutines.copyMatrix( npm, perspectiveMatrix );					//TODO Analyze this bytecode. We can't just set perspectiveMatrix = npm.. this causes the registers to distort, hence the "copy" function is there a better alternative?
				OpInt( 4 );
				OpIAdd( );
				OpJump( JAlways, main_loop );			
			OpFi( );
			
			OpDup( );
			OpInt( GBE.VERTEX_BUFFER_POINTER );
			OpIf( JEq );
				OpPop( );
				
				
				OpInt( 1 );
				OpIAdd( );			//jump our opcode to get to the data
				OpDup( );
				
				OpInt( 4 );			//jump to the second int to read our terminating address
				OpIAdd( );
				var vertex_end = Reg.int( );
				OpMemGet32( );	//vertex_pointer_end
				OpSetReg( vertex_end );
				
				OpDup( );
				OpMemGet32( );	//vertex_pointer
					//{addr, ptr}
					//do our vertex loop here.
						//
						// This is where culling and vertex shader will be run
						// For a PPOLYGON_CULL mode the following should happen
						// 1. Calculate matrix inverse
						// 2. Camera.position -> Object space
						// 3. Deallocate inverse matrix
						// 4. Generate surface norm for poly
						// 5. Cull based on v0->Camera
						// 6. If not culled write our poly pointer into our render data
						//
					
					//TODO calculate inverse matrix
					
					//TODO calculate camera position in object space
					
					//TODO force deallocation of our inverse matrix
						
					var tmatrix = matRoutines.concatMatrix( currentMatrix, perspectiveMatrix );
					
					var VERTEX_LOOP = bLabel( );
					OpLabel( VERTEX_LOOP );		//{addr, ptr}			
						
						var vec = vmap.genByteCodeXYZ( this );									//get current vector position	
						vertex_shader.setTarget( this, varying );
						var out_vec = vertex_shader.main( cast vec, tmatrix );			//pass through vertex shader
						
						//*
						out_vec = matRoutines.concatVectorPerspective( out_vec, tmatrix, width, height );
						/*/
						out_vec = matRoutines.concatVector( out_vec, tmatrix );
						//*/
						
						//write data to our gb_output address
						OpReg( gb_temp_address );	
						OpDup( );
						OpReg( out_vec.x );
						OpSwap( );
						OpMemSetFloat( );
						OpDup( );
						OpInt( 4 );
						OpIAdd( );						
						OpReg( out_vec.y );
						OpSwap( );
						OpMemSetFloat( );
						OpDup( );
						OpInt( 8 );
						OpIAdd( );
						OpReg( out_vec.z );
						OpSwap( );
						OpMemSetFloat( );
						
						OpInt( varying_offset );
						OpIAdd( );
						OpSetReg( gb_temp_address );
						
					
					OpInt( vmap.vertex_size_bytes );
					OpIAdd( );
					OpDup( );
					OpReg( vertex_end );					
					OpJump( JLt, VERTEX_LOOP );
					
					OpPop( );	//pop pointer addr
					
				OpInt( 8 );				//skip 8 bytes (pointer_start/pointer_end)
				OpIAdd( );		
				OpJump( JAlways, main_loop );
			OpFi( );
			
			OpInt( GBE.FINAL );
			OpIf( JEq );					//case GBE.FINAL			
				var c = currentMatrix;
				OpReg( c.n11 );	OpReg( c.n12 );	OpReg( c.n13 );	OpReg( c.n14 );
				OpReg( c.n21 );	OpReg( c.n22 );	OpReg( c.n23 );	OpReg( c.n24 );
				OpReg( c.n31 );	OpReg( c.n32 );	OpReg( c.n33 );	OpReg( c.n34 );
				OpReg( c.n41 );	OpReg( c.n42 );	OpReg( c.n43 );	OpReg( c.n44 );
				
				OpArray( 16 );
				OpRet( );
				OpJump( JAlways, main_loop );
			OpFi( );
			
		
		OpJump( JAlways, main_loop );
		
		
		/*
		ByteApplication.buildToCtx( this );
		
		var s:String = untyped _ctx.curFunction.ops;
		s = StringTools.replace( s, ",O", "\nO" );
		
		throw( s );
		*/
		
		bEndMethod( );
		
		bFinalize( );
		
		ByteApplication.buildToAsync( middle_call, this, "_TransformationFloat", ba );
	}
	
	function middle_call( d:Dynamic ):Void
	{		
		d.vmap = new VShader_Mapper( varying_offset, varying_infos );
		_call( d );
	}
	
	function varying( a:BVAR<Dynamic>, name:String ):Void
	{
		//mod our vertex structure information
		varying_infos.push( { offset:varying_offset, type:a.type, name:name } );
		
		a.get( );
		OpReg( gb_temp_address );
		OpInt( varying_offset );					//TODO change this to intref if necessary
		OpIAdd( );
		switch( a.type )
		{
			case Int:
				OpMemSet32( );
			case Float:
				OpMemSetFloat( );				
		}
		varying_offset += 4;
	}
	
}

import com.codex.c3dex.mapping.VertexMapper2;
class VShader_Mapper extends VertexMapper2
{
	var dynInfos:Array<Dynamic>;
	
	public function new( size:Int, a:Array<Dynamic> )
	{
		dynInfos = a;
		super( size, [mapDyn] );
	}
	
	function mapDyn( )
	{
		for ( item in dynInfos )
		{
			switch( item.type )
			{
				case Int:
					readi( item.offset, item.name );
				case Float:
					readf( item.offset, item.name );
			}
		}
	}
	
}