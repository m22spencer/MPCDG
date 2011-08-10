/**
 * ...
 * @author Matthew Spencer
 */

package byteapps;
import byteroutines.MatrixRoutines;
import com.abc.Reg;
import com.codex.c3dex.bcode.app.ByteApplication;
import com.codex.c3dex.GraphicsBuffer;
import format.abc.Data.JumpStyle;

class Transformation extends ByteApplication
{

	public function new() 
	{
		super( );
	}
	
	function bytecode( )
	{
		
		//accept input of "GraphicsBuffer address"
		//read through GraphicsBuffer switching each possible operation (push/pop matrix... etc)
		//composite matrix information
		//when reaching a vertex array, pass vertex data to vertex shader based on "culling parameter"
		
		
		var c = bBeginClass( "_TransformationFloat" );
		var m = bBeginMethod( "transform", [tAny, tAny], null );
		m.maxStack = 5;
		
		var gb_address = Reg.param( 1, Int );
		var gb_temp_address = Reg.param( 2, Int );
			
		var main_loop = bLabel( );
		var CASE_END = bLabel( );
		var matRoutines = new MatrixRoutines( this );
		
		//Load identity matrix to stack
		var currentMatrix = matRoutines.loadIdentity( );
		
		OpReg( gb_address );
		OpLabel( main_loop );
			
			OpDup( );
			OpMemGet8( );											//read our function code from graphics data: switch( op )
			
			OpDup( );
			OpInt( GBE.MATRIX_PUSH );
			OpIf( JEq );											//case GBE.MATRIX_PUSH
				OpDup( );
				OpInt( 1 );											//grab pointer at next byte
				OpMemGet32( );
				currentMatrix = matRoutines.loadMatrix( bv.stack );		
				//currentMatrix = matRoutines.concatMatrix( currentMatrix, nm );		//concat matrices.. obviously
				OpInt( 5 );
				OpIAdd( );											//update our reader
				OpJump( JAlways, CASE_END );
			OpFi( );
			
			OpDup( );
			OpInt( GBE.MATRIX_POP );
			OpIf( JEq );					//case GBE.MATRIX_POP
			
			
			OpFi( );
			
			OpDup( );
			OpInt( GBE.VERTEX_BUFFER_POINTER );
			OpIf( JEq );					//case GBE.VERTEX_BUFFER_POINTER
			
			
			OpFi( );
			
			
			OpDup( );
			OpInt( GBE.FINAL );
			OpIf( JEq );					//case GBE.FINAL			
				var c = currentMatrix;
				OpReg( c.n11 );	OpReg( c.n12 );	OpReg( c.n13 );	OpReg( c.n14 );
				OpReg( c.n21 );	OpReg( c.n22 );	OpReg( c.n23 );	OpReg( c.n24 );
				OpReg( c.n31 );	OpReg( c.n32 );	OpReg( c.n33 );	OpReg( c.n34 );
				OpReg( c.n41 );	OpReg( c.n42 );	OpReg( c.n43 );	OpReg( c.n44 );
				
				OpArray( 16 );
				OpRet( );
			
			OpFi( );
			OpLabel( CASE_END );
		
	}
	
}



















