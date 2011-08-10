/**
 * ...
 * @author Matthew Spencer
 */

package ;
import com.abc.BCBuild;
import com.abc.Reg;
import com.abc.Data;
import com.CReflect;
import flash.display.TriangleCulling;
import flash.utils.ByteArray;
import format.abc.Data;
using com.CReflect;


class FixedTransformation
{

	var builder:BCBuild;
	var ctx:format.abc.Context;
	var frameBuffer:Int;
	var width:Int;
	
	public function new( call:Dynamic, domain:ByteArray, ?debug:Bool ) 
	{
		
		builder = new BCBuild( );
		ctx = new format.abc.Context( );
		init( ctx );
		main( ctx );
		end( ctx );
		BCBuild.buildToFunctionAsync( call, ctx, "_FloatingTransformation", "transform", domain );
	}	
	
	function init( ctx:format.abc.Context )
	{
		ctx.beginClass( "_FloatingTransformation" );
		// ( matrix, vec_start, vec_end, vec_result )
		var m = ctx.beginMethod( "transform", [ctx.type("int"), ctx.type("int"), ctx.type("int"), ctx.type("int")], ctx.type("*") );
		m.maxStack = 20;
	}
	
	function main( ctx:format.abc.Context )
	{
		
		bytecode( ctx );
		
	}
	
	function end( ctx:format.abc.Context )
	{
		__abc__([ORet]);
		builder.buildToCtx( ctx );
		ctx.finalize( );
	}
	
	function __abc__( ops:Array<Dynamic> )
	{
		builder.__abc__( ops );		
	}
	
	static var FIXED:Int = 256;
	static var FIXED_SHIFT:Int = 8;
	
	function bytecode( ctx:format.abc.Context )
	{
		
		__abc__([ //load matrix address
			OpCode.OReg( 1 ),
		]);
		var mat = loadMatrixFloating( );		//push matrix into registers
		
		
		var result_address = Reg.int( );
		var end_address = Reg.int( );
		__abc__([
			OpCode.OReg( 4 ),
			OSetReg( result_address ),
			OpCode.OReg( 3 ),
			OSetReg( end_address ),
			
			OpCode.OReg( 2 ),		
		]);
		
		__abc__([
		OLabel( "transformation-loop" ),
		]);
			transformVector( mat, result_address );
		__abc__([
			ODup,
			OReg( result_address ),
			OInt( VEC_SIZE ),
			OOp( OpIAdd ),
			OSetReg( result_address ),
			OReg( end_address ),
		OJump( JLt, "transformation-loop" ),
		]);
	}
	
	// in: {vector_address}
	// out: {vector_address+size(vector)}
	function transformVector( mat:Dynamic , result_address:Reg<Int> )
	{
		__abc__([ ODup ]); //copy address and keep on the bottom of stack for return
		//read the vector onto the stack 3 times
		read_i( 0 );	__abc__([OSwap]);
		read_i( 4 );	__abc__([OSwap]);
		read_i( 8 );	__abc__([OSwap]);
		
		read_i( 0 );	__abc__([OSwap]);
		read_i( 4 );	__abc__([OSwap]);
		read_i( 8 );	__abc__([OSwap]);
		
		read_i( 0 );	__abc__([OSwap]);
		read_i( 4 );	__abc__([OSwap]);
		read_i( 8, false);				//dont dupe address this time, just consume it
		
		
		//{x, y, z, x, y, z, x, y, z, x, y, z} - 12
		
		//work backwards. Find result{x}
		
		
		for ( col in 1...4 )
		{
			__abc__([
				OInt( 8 ),
				OOp( OpShr ),
				OReg( cprop(mat, "n3" + col) ),					//{x, y, z, n3x}
				OInt( 8 ),
				OOp( OpShr ),
				OOp( OpIMul ),								//{x, y, z*n3x}
				OSwap,										//{x, z*n3x, y}
				
				OInt( 8 ),
				OOp( OpShr ),
				OReg( cprop(mat, "n2" + col) ),			
				OInt( 8 ),
				OOp( OpShr ),
				OOp( OpIMul ),								//{x, z*n3x, y*n2x}
				OOp( OpIAdd ),								//{x, z*n3x + y * n2x}
				OSwap,
				
				OInt( 8 ),
				OOp( OpShr ),
				OReg( cprop(mat, "n1" + col) ),
				OInt( 8 ),
				OOp( OpShr ),
				OOp( OpIMul ),
				OOp( OpIAdd ),								//{x*n1x + z*n3x + y * n2x}
				
				
				OReg( cprop(mat, "n4" + col ) ),
				OOp( OpIAdd ),
				
			
				OReg( result_address ),
			]);
			if ( col != 1 )
			{
				__abc__([
					OInt( (col - 1) * 4 ),
					OOp( OpIAdd ),
				]);
			}
			__abc__([
				OOp( OpMemSet32 ),
			]);
		}		
		__abc__([
			OInt( VEC_SIZE ),
			OOp( OpIAdd ),
		]);
	}
	
	public static var VEC_SIZE:Int = 12;
	
	function loadMatrixFloating( ?m_addr:Reg<Int>, ?rowMajor:Bool = true )
	{
		if ( rowMajor == false )
			throw( "Column major is not yet supported" );
		var mat:Dynamic<Reg<Int>> = cast { } //OSetReg( regs.x = Reg.float() ),
	
		var offset:MatrixOffset = new MatrixOffsetRow( );
		
		//@@@@ ROW 1
		{__abc__([
			ccom( (m_addr == null), ODup, OReg(m_addr) ),
			OOp( OpMemGet32 ),
			OSetReg( mat.n11 = Reg.int() ),
			
			ODup,
			OInt( offset.n12 ),
			OOp( OpIAdd ),
			OOp( OpMemGet32 ),
			OSetReg( mat.n12 = Reg.int() ),
			
			ODup,
			OInt( offset.n13 ),
			OOp( OpIAdd ),
			OOp( OpMemGet32 ),
			OSetReg( mat.n13 = Reg.int() ),
			
			ODup,
			OInt( offset.n14 ),
			OOp( OpIAdd ),
			OOp( OpMemGet32 ),
			OSetReg( mat.n14 = Reg.int() ),
		]);}
		
		//@@@@ ROW 2
		{__abc__([
			ODup,
			OInt( offset.n21 ),
			OOp( OpIAdd ),
			OOp( OpMemGet32 ),
			OSetReg( mat.n21 = Reg.int() ),
			
			ODup,
			OInt( offset.n22 ),
			OOp( OpIAdd ),
			OOp( OpMemGet32 ),
			OSetReg( mat.n22 = Reg.int() ),
			
			ODup,
			OInt( offset.n23 ),
			OOp( OpIAdd ),
			OOp( OpMemGet32 ),
			OSetReg( mat.n23 = Reg.int() ),
			
			ODup,
			OInt( offset.n24 ),
			OOp( OpIAdd ),
			OOp( OpMemGet32 ),
			OSetReg( mat.n24 = Reg.int() ),
		]); }
		
		//@@@@ ROW 3
		{__abc__([
			ODup,
			OInt( offset.n31 ),
			OOp( OpIAdd ),
			OOp( OpMemGet32 ),
			OSetReg( mat.n31 = Reg.int() ),
			
			ODup,
			OInt( offset.n32 ),
			OOp( OpIAdd ),
			OOp( OpMemGet32 ),
			OSetReg( mat.n32 = Reg.int() ),
			
			ODup,
			OInt( offset.n33 ),
			OOp( OpIAdd ),
			OOp( OpMemGet32 ),
			OSetReg( mat.n33 = Reg.int() ),
			
			ODup,
			OInt( offset.n34 ),
			OOp( OpIAdd ),
			OOp( OpMemGet32 ),
			OSetReg( mat.n34 = Reg.int() ),
		]);}
	
		//@@@@ ROW 4
		{__abc__([
			ODup,
			OInt( offset.n41 ),
			OOp( OpIAdd ),
			OOp( OpMemGet32 ),
			OSetReg( mat.n41 = Reg.int() ),
			
			ODup,
			OInt( offset.n42 ),
			OOp( OpIAdd ),
			OOp( OpMemGet32 ),
			OSetReg( mat.n42 = Reg.int() ),
			
			ODup,
			OInt( offset.n43 ),
			OOp( OpIAdd ),
			OOp( OpMemGet32 ),
			OSetReg( mat.n43 = Reg.int() ),
			
			ODup,
			OInt( offset.n44 ),
			OOp( OpIAdd ),
			OOp( OpMemGet32 ),
			OSetReg( mat.n44 = Reg.int() ),
		]);}	
		
		return mat;
	}
	
	function ccom( cond, a, b ):Dynamic
	{
		if ( cond )
			return a;
		return b;
	}
	
	function read_f( offset:Int, ?dup:Bool = true, ?reg:Reg<Float> )
	{
		if ( offset > 0xFF ) throw( "Offset must be less than 0xFF" );
		
		if ( dup ) __abc__([ODup]);
		
		if ( offset != 0 )
		{
			__abc__([
			OInt( offset ),
			OOp( OpIAdd ),
			]);
		}
		__abc__([
			OOp( OpMemGetFloat ),
		]);
		if ( reg != null )	__abc__([OSetReg( reg )]);
	}
	
	function read_i( offset:Int, ?dup:Bool = true, ?reg:Reg<Int> )
	{
		if ( offset > 0xFF ) throw( "Offset must be less than 0xFF" );
		
		if ( dup ) __abc__([ODup]);
		
		if ( offset != 0 )
		{
			__abc__([
			OInt( offset ),
			OOp( OpIAdd ),
			]);
		}
		__abc__([
			OOp( OpMemGet32 ),
		]);
		if ( reg != null )	__abc__([OSetReg( reg )]);
	}
	
	function cprop( o:Dynamic, s:String )
	{
		return Reflect.field( o, s );
	}
	
}

class MatrixOffset
{
	function new( ) { }
	public var n11:Int;
	public var n12:Int;
	public var n13:Int;
	public var n14:Int;
	
	public var n21:Int;
	public var n22:Int;
	public var n23:Int;
	public var n24:Int;
	
	public var n31:Int;
	public var n32:Int;
	public var n33:Int;
	public var n34:Int;
	
	public var n41:Int;
	public var n42:Int;
	public var n43:Int;
	public var n44:Int;	
}

class MatrixOffsetRow extends MatrixOffset
{
	public function new( ) 
	{
		super( );
		n11 = 0;
		n12 = 4;
		n13 = 8;
		n14 = 12;
		n21 = 16;
		n22 = 20;
		n23 = 24;
		n24 = 28;
		n31 = 32;
		n32 = 36;
		n33 = 40;
		n34 = 44;
		n41 = 48;
		n42 = 52;
		n43 = 56;
		n44 = 60;
	}
	
}






















