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


class FixedRaster
{

	var builder:BCBuild;
	var ctx:format.abc.Context;
	var frameBuffer:Int;
	var width:Int;
	
	public function new( call:Dynamic, frameBuffer:Int, width:Int, domain:ByteArray ) 
	{
		this.frameBuffer = frameBuffer;
		this.width = width;
		
		builder = new BCBuild( );
		ctx = new format.abc.Context( );
		init( ctx );
		main( ctx );
		end( ctx );
		BCBuild.buildToFunctionAsync( call, ctx, "_FIXEDRASTER", "shade", domain );
	}	
	
	function init( ctx:format.abc.Context )
	{
		ctx.beginClass( "_FIXEDRASTER" );
		var m = ctx.beginMethod( "shade", [ctx.type("int")], ctx.type("*") );
		m.maxStack = 8;
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
		__abc__([
			OInt( 0 ),
			OSetReg( ecode ),
		]);
		
		var poly:Dynamic = read_vertices( );
				
		scanPoly( poly );
		
		
		__abc__([
			OReg( ecode ),
			ORet,
		]);
	}
	
	static var ecode:Reg<Int> = Reg.int( );
	
	function scanline( x0:Reg<Float>, x1:Reg<Float>, y:Reg<Float> )
	{
		__abc__([
		OReg( x0 ),
		OReg( x1 ),
		OIf( JGt ),
			OInt( 3038 ),
			OSetReg( ecode ),
		]);
			plotPointStar( x0, y, 0xFFFF0000 );
			plotPointStar( x1, y, 0xFFFF0000 );
		__abc__([
		OElse,	
		]);
			plotPoint( x0, y, 0xFF666666 );
			plotPoint( x1, y, 0xFFCCCCCC );
		__abc__([
		OFi,	
		]);
	}
	
	//Requires pre-sorted vertices
	function scanPoly( poly:Dynamic )
	{
		sort_vertices( poly.v0, poly.v1, poly.v2 );
		
		//@@@@@ FIX FOR DIVIDE BY ZERO FIX
		// Divide by zero fix causes polys with v0.y == v1.y to render right to left
		// This is a fix in conjunction with @@REF_A032
		__abc__([
		OReg( poly.v0.y ),
		OReg( poly.v1.y ),
		OIf( JEq ),
			OReg( poly.v0.x ),
			OReg( poly.v1.x ),
			OIf( JGt ),
		]);
				swapEach( poly.v0, poly.v1 );
		__abc__([
			OFi,
		OFi,
		]);
		//@@@@@@@@@@@@@@@@@@@@@@@@@@@@
		
		var dx1 = findDeltas( poly.v0, poly.v1 );
		var dx3 = findDeltas( poly.v1, poly.v2 );
		var dx2 = findDeltas( poly.v0, poly.v2 );
		
		var Sx = Reg.float( );
		var Ex = Reg.float( );
		var Sy = Reg.float( );
		
		__abc__([
		OReg( poly.v0.x ),
		ODup,
		OSetReg( Sx ),
		OSetReg( Ex ),
		
		OReg( poly.v0.y ),
		OSetReg( Sy ),
	
		
		//@@@REF_A032 FIX FOR DIVIDE BY ZERO FIX (continued..)
		// Divide by zero fix causes polys with v0.y == v1.y to render right to left
		// This is a fix in conjunction with 
		OReg( poly.v0.y ),
		OReg( poly.v1.y ),
		OIf( JEq ),
			OReg( dx1.x ),
			OReg( dx2.x ),
			OJump( JLte, "scanPoly_WHILE1" ),		//jump straight in.
			OJump( JAlways, "scanPoly_WHILE3" ),	//jump straight in.
		OFi,
		
		OReg( dx1.x ),
		OReg( dx2.x ),
		OIf( JGt ),
			OLabel( "scanPoly_WHILE1" ),
				//scanline algorithm here
		]);
				scanline( Sx, Ex, Sy );
		__abc__([				
				//replace with variable interpolation system
				OReg( Sx ),
				OReg( dx2.x ),
				OOp( OpAdd ),
				OSetReg( Sx ),
				
				OReg( Ex ),
				OReg( dx1.x ),
				OOp( OpAdd ),
				OSetReg( Ex ),
				
				//y++
				OIncrReg( Sy ),
				OReg( Sy ),
				OReg( poly.v1.y ),
			OJump( JLt, "scanPoly_WHILE1" ),
			
			OReg( poly.v1.x ),
			OSetReg( Ex ),
			
			OLabel( "scanPoly_WHILE2" ),
				//scanline algorithm here
		]);
				scanline( Sx, Ex, Sy );
		__abc__([				
				//replace with variable interpolation system
				OReg( Sx ),
				OReg( dx2.x ),
				OOp( OpAdd ),
				OSetReg( Sx ),
				
				OReg( Ex ),
				OReg( dx3.x ),
				OOp( OpAdd ),
				OSetReg( Ex ),
				
				//y++
				OIncrReg( Sy ),
				OReg( Sy ),
				OReg( poly.v2.y ),
			OJump( JLt, "scanPoly_WHILE2" ),
			
		OElse,
			OLabel( "scanPoly_WHILE3" ),
				//scanline algorithm here
		]);
				scanline( Sx, Ex, Sy );
		__abc__([				
				//replace with variable interpolation system
				OReg( Sx ),
				OReg( dx1.x ),
				OOp( OpAdd ),
				OSetReg( Sx ),
				
				OReg( Ex ),
				OReg( dx2.x ),
				OOp( OpAdd ),
				OSetReg( Ex ),
				
				//y++
				OIncrReg( Sy ),
				OReg( Sy ),
				OReg( poly.v1.y ),
			OJump( JLt, "scanPoly_WHILE3" ),
			
			OReg( poly.v1.x ),
			OSetReg( Sx ),
			
			OLabel( "scanPoly_WHILE4" ),
				//scanline algorithm here
		]);
				scanline( Sx, Ex, Sy );
		__abc__([				
				//replace with variable interpolation system
				OReg( Sx ),
				OReg( dx3.x ),
				OOp( OpAdd ),
				OSetReg( Sx ),
				
				OReg( Ex ),
				OReg( dx2.x ),
				OOp( OpAdd ),
				OSetReg( Ex ),
				
				//y++
				OIncrReg( Sy ),
				OReg( Sy ),
				OReg( poly.v2.y ),
			OJump( JLt, "scanPoly_WHILE4" ),
		OFi,
		]);
		
		
		plotPoint( poly.v0.x, poly.v0.y, 0xFF00FF00 );
		plotPoint( poly.v1.x, poly.v1.y, 0xFF0000FF );
		plotPoint( poly.v2.x, poly.v2.y, 0xFFFF0000 );
		
	}
	
	function findDeltas( v0, v1 )
	{
		var deltas:Dynamic = { };
		for ( fld in CReflect.fieldsExcept( v0, ["y"] ) )
			Reflect.setField( deltas, fld, Reg.float() );
		
		__abc__([
		OReg( v1.y ),
		OReg( v0.y ),
		OOp( OpSub ),
		ODup,
		OInt( 0 ),
		OIf( JGt ),
			OFloat( ctx.float( 1 ) ),
			OSwap,
			OOp( OpDiv ),		//{1/ABstep}
		]);			
			for ( fld in CReflect.fieldsExcept( v0, ["y"] ) )
			{
				__abc__([
				ODup,
				OReg( Reflect.field( v1, fld ) ),
				OReg( Reflect.field( v0, fld ) ),
				OOp( OpSub ),
				OOp( OpMul ),
				OSetReg( Reflect.field( deltas, fld ) ),
				]);
				
			}
		__abc__([
			OPop,
		OElse,
		]);
			for ( fld in CReflect.fieldsExcept( v0, ["y"] ) )
			{
				__abc__([
				OFloat( ctx.float( 0.0 ) ),
				OSetReg( Reflect.field( deltas, fld ) ),
				]);
			}
		__abc__([
			OPop,
		OFi,
		]);
		return deltas;
	}
	
	function read_vertices( )
	{
		var poly:Dynamic = { };
		__abc__([ OpCode.OReg( 1 ) ]);
		poly.v0 = read_vertex_xyz( );
		__abc__([
			OInt( 12 ),
			OOp( OpIAdd ),
		]);
		poly.v1 = read_vertex_xyz( );
		__abc__([
			OInt( 12 ),
			OOp( OpIAdd ),
		]);
		poly.v2 = read_vertex_xyz( );
		
		return poly;
	}
	
	function sort_vertices( v0:Dynamic, v1:Dynamic, v2:Dynamic )
	{
		
		//test_and_swap( v0_data, v1_data );
		//test_and_swap( v0_data, v2_data );
		//test_and_swap( v1_data, v2_data );
		
		__abc__([
			//if v0.y > v1.y
			OReg( v0.y ),
			OReg( v1.y ),
			OIf( JGt ),
		]);
				swapEach( v0, v1 );
		__abc__([
			OFi,
			
			//if v0.y > v2.y
			OReg( v0.y ),
			OReg( v2.y ),
			OIf( JGt ),
		]);
				swapEach( v0, v2 );
		__abc__([
			OFi,
			
			//if v1.y > v2.y
			OReg( v1.y ),
			OReg( v2.y ),
			OIf( JGt ),
		]);
				swapEach( v1, v2 );
		__abc__([
			OFi,
		]);
		
	}
	
	function plot_vertices( v0:Dynamic, v1:Dynamic, v2:Dynamic )
	{
		//plotVertex( v0, 0xFF00FF00 );
		//plotVertex( v0, 0xFF0000FF );
		//plotVertex( v0, 0xFFFF0000 );
	}
	
	/*
	function plotVertex( v:Dynamic, color:Int )
	{
		__abc__([
			//find pixel address
			OReg( v.y ),
			OIntRef( ctx.int( cast width ) ),
			OOp( OpIMul ),
			OReg( v.x ),
			OOp( OpIAdd ),
			OInt( FIXED_SHIFT-2 ),
			OOp( OpShr ),								//(y*width+x) >> (FIXED_SHIFT-2)
			OIntRef( ctx.int( cast frameBuffer ) ),
			OOp( OpIAdd ),
		
			OIntRef( ctx.int( cast color ) ),
			OSwap,
			OOp( OpMemSet32 ),		
		]);
	}
	*/
	
	function plotPoint( x:Reg<Float>, y:Reg<Float>, color:Int )
	{
		__abc__([
			//find pixel address
			OReg( y ),
			OToInt,
			OIntRef( ctx.int( cast width ) ),
			OOp( OpIMul ),
			OReg( x ),
			OToInt,
			OOp( OpIAdd ),
			OInt( 2 ),
			OOp( OpShl ),								//(y*width+x) >> (FIXED_SHIFT-2)
			OIntRef( ctx.int( cast frameBuffer ) ),
			OOp( OpIAdd ),
		
			OIntRef( ctx.int( cast color ) ),
			OSwap,
			OOp( OpMemSet32 ),		
		]);		
	}
	
	function plotPointStar( x:Reg<Float>, y:Reg<Float>, color:Int )
	{
		__abc__([
			//find pixel address
			OReg( y ),
			OToInt,
			OIntRef( ctx.int( cast width ) ),
			OOp( OpIMul ),
			OReg( x ),
			OToInt,
			OOp( OpIAdd ),
			OInt( 2 ),
			OOp( OpShl ),								//(y*width+x) >> (FIXED_SHIFT-2)
			OIntRef( ctx.int( cast frameBuffer ) ),
			OOp( OpIAdd ),
			
			ODup,
			OIntRef( ctx.int( cast width*4 ) ),
			OOp( OpIAdd ),
			OSwap,
			
			ODup,
			OIntRef( ctx.int( cast width*4 ) ),
			OOp( OpISub ),
			OSwap,
			
			ODup,
			OInt( 4 ),
			OOp( OpIAdd ),
			OSwap,		
			
			ODup,
			OInt( 4 ),
			OOp( OpISub ),
			
			OIntRef( ctx.int( cast color ) ),
			OSwap,
			OOp( OpMemSet32 ),		
			
			OIntRef( ctx.int( cast color ) ),
			OSwap,
			OOp( OpMemSet32 ),
			
			OIntRef( ctx.int( cast color ) ),
			OSwap,
			OOp( OpMemSet32 ),
			
			OIntRef( ctx.int( cast color ) ),
			OSwap,
			OOp( OpMemSet32 ),
			
			OIntRef( ctx.int( cast color ) ),
			OSwap,
			OOp( OpMemSet32 ),
		]);		
	}
	
	function swapEach( a:Dynamic, b:Dynamic )
	{
		for ( fld in Reflect.fields( a ) )
		{
			swap( Reflect.field( a, fld ), Reflect.field( b, fld ) );
		}
	}
	
	function swap<T>( a:Reg<T>, b:Reg<T> )
	{
		__abc__([
			OReg( a ),
			OReg( b ),
			OSetReg( a ),
			OSetReg( b ),		
		]);		
	}
	
	function read_vertex_xyz( ?v:Reg<Int> )
	{
		var regs:Dynamic = { }
		
		__abc__([
			ccom( (v == null), ODup, OReg(v) ),
			
			OOp( OpMemGetFloat ),
			OSetReg( regs.x = Reg.float() ),
			
			ODup,
			OInt( 4 ),
			OOp( OpIAdd ),
			OOp( OpMemGetFloat ),
			OSetReg( regs.y = Reg.float() ),
			
			ODup,
			OInt( 8 ),
			OOp( OpIAdd ),
			OOp( OpMemGetFloat ),
			OSetReg( regs.z = Reg.float() ),	
		]);
		
		return regs;
	}
	
	function ccom( cond, a, b ):Dynamic
	{
		if ( cond )
			return a;
		return b;
	}
	
}



























