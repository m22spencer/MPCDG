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


class FixedRasterFull
{

	var builder:BCBuild;
	var ctx:format.abc.Context;
	var frameBuffer:Int;
	var width:Int;
	
	var dbg:Bool;
	
	public function new( call:Dynamic, frameBuffer:Int, width:Int, domain:ByteArray, ?debugMode:Bool = false ) 
	{
		this.frameBuffer = frameBuffer;
		this.width = width;
		
		dbg = debugMode;
		
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
		var m = ctx.beginMethod( "shade", [ctx.type("int"), ctx.type("int")], ctx.type("*") );
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
		//throw( untyped ctx.curFunction.f.nRegs );
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
		
		
		__abc__([ 
		OpCode.OReg( 1 ), 
		OLabel( "Mainloop" ),
		]);		
		var poly:Dynamic = read_vertices( );
		scanPoly( poly );
		__abc__([ 
		ODup,
		OpCode.OReg( 2 ), 
		OJump( JLt, "Mainloop" ),
		]);
		
		__abc__([
			OReg( ecode ),
			ORet,
		]);
	}
	
	static var ecode:Reg<Int> = Reg.int( );
	
	//x is 22.10, y is 28.4;
	function scanline( x0:Reg<Int>, x1:Reg<Int>, y:Reg<Int> )
	{
		if ( dbg )
			scanline_debug( x0, x1, y );
		else
			scanline_flat( x0, x1, y );
		
	}
	
	public static var triage_map:Int;
	
	function scanline_linear_triage( x0:Reg<Int>, x1:Reg<Int>, y:Reg<Int> )
	{
		
		var taddr = Reg.int( );
		var toffset = Reg.int( );
		var end_address = Reg.int( );
		
		__abc__([
			OReg( y ),
			OInt( FIXED_SHIFT ),
			OOp( OpShr ),
			OIntRef( ctx.int( cast width ) ),
			OOp( OpIMul ),
			OReg( x0 ),
			OInt( FIXED_SHIFT ),
			OOp( OpShr ),
			OOp( OpIAdd ),
			OInt( 2 ),
			OOp( OpShl ),
			OIntRef( ctx.int( cast frameBuffer ) ),
			OOp( OpIAdd ),
			ODup,
			
			OReg( x1 ),
			OReg( x0 ),
			OOp( OpISub ),
			OInt( FIXED_SHIFT ),
			OOp( OpShr ),
			
			//pixel counter
			OInt( 2 ),			
			OOp( OpShl ),
			OOp( OpIAdd ),
			OSetReg( end_address ),
			
			//find triage integer
			OReg( y ),
			OInt( FIXED_SHIFT + 5),
			OOp( OpShr ),
			OIntRef( ctx.int( cast (width/32) ) ),
			OOp( OpIMul ),
			OReg( x0 ),
			ODup,
			OToNumber,
			OFloat( ctx.float( 32 ) ),
			OOp( OpMod ),
			OToInt,
			OSetReg( toffset ),				//offset from start of intblock
			
			OInt( FIXED_SHIFT + 5),
			OOp( OpShr ),
			OOp( OpIAdd ),
			OInt( 2 ),
			OOp( OpShl ),
			OIntRef( ctx.int( cast triage_map ) ),
			OOp( OpIAdd ),
			OSetReg( taddr ),
		]);		
	}
	
	function scanline_flat_compat( x0:Reg<Int>, x1:Reg<Int>, y:Reg<Int> )
	{
		
		var id:Int = Std.int( Math.random()*5000 ); //used to roll a different label id
		
		var xc = Reg.int( );
		__abc__([
			OReg( x0 ),
			OInt( FIXED_SHIFT ),
			OOp( OpShr ),
			OInt( FIXED_SHIFT ),
			OOp( OpShl ),
			OJump( JAlways, "scanline_flat_compat_jumpin" + id ),
			OLabel( "scanline_flat_compat_loop" + id ),
			ODup,
			OSetReg( xc ),
		]);
		plotPointMul( xc, y, 0x000000FF );
		__abc__([		
			OInt( FIXED ),
			OOp( OpIAdd ),
			
			
			OLabel( "scanline_flat_compat_jumpin" + id ),
			ODup,
			OReg( x1 ),
			OInt( FIXED_SHIFT ),
			OOp( OpShr ),
			OInt( FIXED_SHIFT ),
			OOp( OpShl ),
			OJump( JLt, "scanline_flat_compat_loop" + id ),
			OPop,
		]);
		
	}
	
	function scanline_flat( x0:Reg<Int>, x1:Reg<Int>, y:Reg<Int> )
	{		
		__abc__([
			OReg( x0 ),
			OReg( x1 ),
			OIf( JLt ),
		]);
		
		var id:Int = Std.int( Math.random()*5000 ); //used to roll a different label id
		
		var end_address = Reg.int( );
		__abc__([
			OReg( y ),
			OInt( f28_4s ),
			OOp( OpShr ),
			OIntRef( ctx.int( cast width ) ),
			OOp( OpIMul ),
			OReg( x0 ),
			OInt( f22_10s ),
			OOp( OpShr ),
			OOp( OpIAdd ),
			OInt( 2 ),
			OOp( OpShl ),
			OIntRef( ctx.int( cast frameBuffer ) ),
			OOp( OpIAdd ),
			ODup,
			
			OReg( x1 ),
			OInt( f22_10s ),
			OOp( OpShr ),
			OReg( x0 ),
			OInt( f22_10s ),
			OOp( OpShr ),
			OOp( OpISub ),
			ODup,
			
			//pixel counter
			OReg( ecode ),
			OOp( OpIAdd ),
			OSetReg( ecode ),
			OInt( 2 ),			
			OOp( OpShl ),
			OOp( OpIAdd ),
			OSetReg( end_address ),
	
			
			///@@@@ PER PIXEL
			OJump( JAlways, "scanline_flat_compat_jumpin" + id ),
			OLabel( "scanline_flat_WHILE2" + id ),
			ODup,
			ODup,
			OOp( OpMemGet32 ),
			OIntRef( ctx.int( cast 0x000500CE ) ),
			OOp( OpIAdd ),
			OSwap,
			OOp( OpMemSet32 ),
			
			OInt( 4 ),
			OOp( OpIAdd ),
			OLabel( "scanline_flat_compat_jumpin" + id ),
			ODup,
			OReg( end_address ),
			OJump( JLt, "scanline_flat_WHILE2" + id ),
			OPop,
		]);
		
		
		__abc__([
			OFi,
		]);
		
		
	}
	
	//function scanline_flat_unroll( x0:Reg<Int>, x1:Reg<Int>, y:Reg<Int> )
	//{
		//var leftover = Reg.int( );
		//var unroll:Int = 4 << 2;
		//var end_address_unroll = Reg.int( );
		//
		//__abc__([
			//OReg( x0 ),
			//OReg( x1 ),
			//OIf( JLt ),
		//]);
		//
		//var id:Int = Std.int( Math.random()*5000 ); //used to roll a different label id
		//
		//var end_address = Reg.int( );
		//__abc__([
			//OReg( y ),
			//OInt( FIXED_SHIFT ),
			//OOp( OpShr ),
			//OIntRef( ctx.int( cast width ) ),
			//OOp( OpIMul ),
			//OReg( x0 ),
			//OInt( FIXED_SHIFT ),
			//OOp( OpShr ),
			//OOp( OpIAdd ),
			//OInt( 2 ),
			//OOp( OpShl ),
			//OIntRef( ctx.int( cast frameBuffer ) ),
			//OOp( OpIAdd ),
			//ODup,
			//
			//OReg( x1 ),
			//OReg( x0 ),
			//OOp( OpISub ),
			//OInt( FIXED_SHIFT ),
			//OOp( OpShr ),
			//ODup,
			//
			//pixel counter
			//OReg( ecode ),
			//OOp( OpIAdd ),
			//OSetReg( ecode ),
			//
			//OInt( 2 ),
			//
			//find leftovers for unrolling
			//ODup,
			//OInt( unroll ),
			//OToNumber,
			//OOp( OpMod ),
			//OToInt,
			//OSetReg( leftover ),
			//
			//OOp( OpShl ),
			//OOp( OpIAdd ),
			//ODup,
			//OSetReg( end_address ),
			//
			//OReg( leftover ),
			//OOp( OpISub ),
			//OSetReg( end_address_unroll ),
		//]);
			//
		//return;
		//
		//__abc__([
			//OJump( JAlways, "scanline_flat_JumpIn" + id),
			//OLabel( "scanline_flat_WHILE1" + id ),
			//ODup,
			//OIntRef( ctx.int( cast 0xFFFF0000 ) ),
			//OSwap,
			//OOp( OpMemSet32 ),
			//
			//OInt( 4 ),
			//OOp( OpIAdd ),
			//ODup,
			//OIntRef( ctx.int( cast 0xFFFF0000 ) ),
			//OSwap,
			//OOp( OpMemSet32 ),
			//
			//OInt( 4 ),
			//OOp( OpIAdd ),
			//ODup,
			//OIntRef( ctx.int( cast 0xFFFF0000 ) ),
			//OSwap,
			//OOp( OpMemSet32 ),
			//
			//OInt( 4 ),
			//OOp( OpIAdd ),
			//ODup,
			//OIntRef( ctx.int( cast 0xFFFF0000 ) ),
			//OSwap,
			//OOp( OpMemSet32 ),
			//
			//OInt( 4 ),
			//OOp( OpIAdd ),
			//
			//OLabel( "scanline_flat_JumpIn" + id ),
			//ODup,
			//OInt( unroll ),
			//OOp( OpIAdd ),
			//OReg( end_address_unroll ),
			//OJump( JLt, "scanline_flat_WHILE1" + id ),
			//
			///@@@@ PER PIXEL
			//OJump( JAlways, "scanline_flat_JumpIn2" + id),
			//OLabel( "scanline_flat_WHILE2" + id ),
			//ODup,
			//OIntRef( ctx.int( cast 0xFFFF0000 ) ),
			//OSwap,
			//OOp( OpMemSet32 ),
			//
			//OInt( 4 ),
			//OOp( OpIAdd ),
			//
			//OLabel( "scanline_flat_JumpIn2" + id ),
			//ODup,
			//OReg( end_address ),
			//OJump( JLt, "scanline_flat_WHILE2" + id ),
			//OPop,
		//]);
		//
		//__abc__([
			//OFi,
		//]);
		//
	//}
	
	//x is 22.10, y is 28.4;
	function scanline_debug( x0:Reg<Int>, x1:Reg<Int>, y:Reg<Int> )
	{
		
		__abc__([
		OReg( x0 ),
		OReg( x1 ),
		OOp( OpISub ),
		OInt( 5*f22_10 ),
		OIf( JGt ),
			ODecrIReg( ecode ),
		]);
			//*
			plotPoint22_10_28_4( x0, y, 0xFFFF0000 );
			plotPoint22_10_28_4( x1, y, 0xFFFF0000 );
			/*/
			plotPoint( x1, y, 0xFF333333 );
			plotPoint( x0, y, 0xFFFFFFFF );
			//*/
		__abc__([
		OElse,	
		]);
			plotPoint22_10_28_4( x0, y, 0x000000FF );
			plotPoint22_10_28_4( x1, y, 0x000000FF );
		__abc__([
		OFi,	
		]);
	}
	
	function float_to_fixed( d:Dynamic )
	{
		var n:Dynamic = { };
		for ( fld in Reflect.fields( d ) )
		{
			Reflect.setField( n, fld, Reg.int() );
			__abc__([
				OReg( Reflect.field( d, fld ) ),
				OFloat( ctx.float( cast FIXED ) ),
				OOp( OpMul ),
				OToInt,
				OSetReg( Reflect.field( n, fld ) ),
			]);
		}
		return n;
	}
	
	//Requires pre-sorted vertices
	function scanPoly( poly:Dynamic )
	{
		//if it's a micro-row, skip the raster routine
		/*
		__abc__([
		OReg( poly.v0.y ),
		OToInt,
		OReg( poly.v1.y ),
		OToInt,
		OIf( JEq ),				//if( y0 == y1 )
			OReg( poly.v1.y ),
			OToInt,
			OReg( poly.v2.y ),
			OToInt,
			OIf( JEq ),				//if( y1 == y2 )
		]);
		__abc__([
				OJump( JAlways, "scanPoly_skip" ),
			OFi,
		OFi,
		]);
		*/
		
		sort_vertices( poly.v0, poly.v1, poly.v2 );
		
		var dx1 = findDeltas( poly.v0, poly.v1 );
		var dx3 = findDeltas( poly.v1, poly.v2 );
		var dx2 = findDeltas( poly.v0, poly.v2 );
		
		var Sx = Reg.int( );
		var Ex = Reg.int( );
		var Sy = Reg.int( );
		
		__abc__([
		OReg( poly.v0.x ),
		OInt( f22_10s - f28_4s ),
		OOp( OpShl ),
		ODup,
		OSetReg( Sx ),
		OSetReg( Ex ),
		
		OReg( poly.v0.y ),
		OSetReg( Sy ),
	
		
		//@@@REF_A032 FIX FOR DIVIDE BY ZERO FIX (continued..)
		// Divide by zero fix causes polys with v0.y == v1.y to render right to left
		// This is the necessary fix.
		OReg( poly.v0.y ),
		OReg( poly.v1.y ),
		OIf( JEq ),
			//OJump( JAlways, "scanPoly_skip" ),
			OReg( poly.v0.x ),
			OReg( poly.v1.x ),
			OJump( JLte, "scanPoly_WHILE1_JIN" ),
			OJump( JAlways, "scanPoly_WHILE3_JIN" ),
		OFi,
		
		//@@@@@ END FIX
		
		OReg( dx1.x ),
		OReg( dx2.x ),
		OIf( JGt ),
			OJump( JAlways, "scanPoly_WHILE1_JIN" ),
			OLabel( "scanPoly_WHILE1" ),
				//scanline algorithm here
		]);
				scanline( Sx, Ex, Sy );
		__abc__([				
				//replace with variable interpolation system
				OReg( Sx ),
				OReg( dx2.x ),
				OOp( OpIAdd ),
				OSetReg( Sx ),
				
				OReg( Ex ),
				OReg( dx1.x ),
				OOp( OpIAdd ),
				OSetReg( Ex ),
				
				//y++
				OReg( Sy ),
				OIntRef( ctx.int( cast f28_4 ) ),
				OOp( OpIAdd ),
				OSetReg( Sy ),
				
				OLabel( "scanPoly_WHILE1_JIN" ),
				OReg( Sy ),
				OReg( poly.v1.y ),
			OJump( JLt, "scanPoly_WHILE1" ),
			
			OReg( poly.v1.x ),		
			OInt( f22_10s - f28_4s ),
			OOp( OpShl ),	
			OSetReg( Ex ),
			OReg( poly.v1.y ),			
			OSetReg( Sy ),
			
			OJump( JAlways, "scanPoly_WHILE2_JIN" ),
			OLabel( "scanPoly_WHILE2" ),
				//scanline algorithm here
		]);
				scanline( Sx, Ex, Sy );
		__abc__([				
				//replace with variable interpolation system
				OReg( Sx ),
				OReg( dx2.x ),
				OOp( OpIAdd ),
				OSetReg( Sx ),
				
				OReg( Ex ),
				OReg( dx3.x ),
				OOp( OpIAdd ),
				OSetReg( Ex ),
				
				//y++
				OReg( Sy ),
				OIntRef( ctx.int( cast f28_4 ) ),
				OOp( OpIAdd ),
				OSetReg( Sy ),
				
				OLabel( "scanPoly_WHILE2_JIN" ),
				OReg( Sy ),
				OReg( poly.v2.y ),
			OJump( JLt, "scanPoly_WHILE2" ),
			
		OElse,
			OJump( JAlways, "scanPoly_WHILE3_JIN" ),
			OLabel( "scanPoly_WHILE3" ),
				//scanline algorithm here
		]);
				scanline( Sx, Ex, Sy );
		__abc__([				
				//replace with variable interpolation system
				OReg( Sx ),
				OReg( dx1.x ),
				OOp( OpIAdd ),
				OSetReg( Sx ),
				
				OReg( Ex ),
				OReg( dx2.x ),
				OOp( OpIAdd ),
				OSetReg( Ex ),
				
				//y++
				OReg( Sy ),
				OIntRef( ctx.int( cast f28_4 ) ),
				OOp( OpIAdd ),
				OSetReg( Sy ),
				
				OLabel( "scanPoly_WHILE3_JIN" ),
				OReg( Sy ),
				OReg( poly.v1.y ),
			OJump( JLt, "scanPoly_WHILE3" ),
			
			OReg( poly.v1.x ),
			OInt( f22_10s - f28_4s ),
			OOp( OpShl ),
			OSetReg( Sx ),
			OReg( poly.v1.y ),			
			OSetReg( Sy ),
			
			OJump( JAlways, "scanPoly_WHILE4_JIN" ),
			OLabel( "scanPoly_WHILE4" ),
				//scanline algorithm here
		]);
				scanline( Sx, Ex, Sy );
		__abc__([				
				//replace with variable interpolation system
				OReg( Sx ),
				OReg( dx3.x ),
				OOp( OpIAdd ),
				OSetReg( Sx ),
				
				OReg( Ex ),
				OReg( dx2.x ),
				OOp( OpIAdd ),
				OSetReg( Ex ),
				
				//y++
				OReg( Sy ),
				OIntRef( ctx.int( cast f28_4 ) ),
				OOp( OpIAdd ),
				OSetReg( Sy ),
				
				OLabel( "scanPoly_WHILE4_JIN" ),
				OReg( Sy ),
				OReg( poly.v2.y ),
			OJump( JLt, "scanPoly_WHILE4" ),
		OFi,
		
		OLabel( "scanPoly_skip" ),
		]);
		
	}
	
	function findDeltas( v0, v1 )
	{
		var deltas:Dynamic = { };
		var deltasp1:Dynamic = { };
		for ( fld in CReflect.fieldsExcept( v0, ["y"] ) )
		{
			Reflect.setField( deltas, fld, Reg.int() );
			Reflect.setField( deltasp1, fld, Reg.int() );
		}
		
		//@@ Calculate deltas per y++;
		__abc__([
		OReg( v1.y ),
		OReg( v0.y ),
		OOp( OpISub ),
		ODup,
		OInt( 0 ),
		OIf( JGt ),
			OToNumber,
			OFloat( ctx.float( 1 ) ),
			OSwap,
			OOp( OpDiv ),		//{1/ABstep}
			OFloat( ctx.float( f28_4 * f22_10 ) ),
			OOp( OpMul ),
			OToInt,				//(1/[f28_4]) << (f28_4s + f22_10s)
		]);			
			for ( fld in CReflect.fieldsExcept( v0, ["y"] ) )
			{
				__abc__([
				ODup,
				OReg( Reflect.field( v1, fld ) ),		//[f28_4]
				OReg( Reflect.field( v0, fld ) ),		//[f28_4]
				OOp( OpISub ),
				OOp( OpIMul ),							//[f28_4]*[f22_10]
				OInt( f28_4s ),
				OOp( OpShr ),
				OSetReg( Reflect.field( deltas, fld ) ),	//[f22_10]
				]);
			}
		__abc__([
			OPop,
		OElse,
		]);
			for ( fld in CReflect.fieldsExcept( v0, ["y"] ) )
			{
				__abc__([
				OInt( 0 ),
				OSetReg( Reflect.field( deltas, fld ) ),
				]);
			}
		__abc__([
			OPop,
		OFi,
		]);
		
		//@@ Calculate deltas per x++
		/*
		__abc__([
			OReg( v0.y ),
			OReg( v1.y ),
			OIf( JEq ),
				OReg( v1.x ),
				OReg( v0.x ),
				
		
		
		
		]);
		*/
		
		return deltas;
	}
	
	function read_vertices( )
	{
		var poly:Dynamic = { };
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
		__abc__([
			OInt( 12 ),
			OOp( OpIAdd ),
		]);
		
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
	
	function plotPointFloat( x:Reg<Float>, y:Reg<Float>, color:Int )
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
	
	function plotPoint( x:Reg<Int>, y:Reg<Int>, color:Int )
	{
		__abc__([
			//find pixel address
			OReg( y ),
			OInt( f28_4s ),
			OOp( OpShr ),
			OIntRef( ctx.int( cast width ) ),
			OOp( OpIMul ),
			OReg( x ),
			OInt( f28_4s ),
			OOp( OpShr ),
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
	
	function plotPoint22_10_28_4( x:Reg<Int>, y:Reg<Int>, color:Int )
	{
		__abc__([
			//find pixel address
			OReg( y ),
			OInt( f28_4s ),
			OOp( OpShr ),
			OIntRef( ctx.int( cast width ) ),
			OOp( OpIMul ),
			OReg( x ),
			OInt( f22_10s ),
			OOp( OpShr ),
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
	
	function plotPointMul( x:Reg<Int>, y:Reg<Int>, color:Int )
	{
		__abc__([
			//find pixel address
			OReg( y ),
			OInt( FIXED_SHIFT ),
			OOp( OpShr ),
			OIntRef( ctx.int( cast width ) ),
			OOp( OpIMul ),
			OReg( x ),
			OInt( FIXED_SHIFT ),
			OOp( OpShr ),
			OOp( OpIAdd ),
			OInt( 2 ),
			OOp( OpShl ),								//(y*width+x) >> (FIXED_SHIFT-2)
			OIntRef( ctx.int( cast frameBuffer ) ),
			OOp( OpIAdd ),
		
			ODup,
			OOp( OpMemGet32 ),
			OIntRef( ctx.int( cast color ) ),
			OOp( OpIMul ),			
			OSwap,
			OOp( OpMemSet32 ),		
		]);		
	}
	
	function plotPointStar( x:Reg<Int>, y:Reg<Int>, color:Int )
	{
		__abc__([
			//find pixel address
			OReg( y ),
			OInt( FIXED_SHIFT ),
			OOp( OpShr ),
			OIntRef( ctx.int( cast width ) ),
			OOp( OpIMul ),
			OReg( x ),
			OInt( FIXED_SHIFT ),
			OOp( OpShr ),
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
	
	//returns vertices utilizing 28_4 fixed point.
	function read_vertex_xyz( ?v:Reg<Int> )
	{
		var vdata:Dynamic = { }
		
		__abc__([
			ccom( (v == null), ODup, OReg(v) ),
			
			OOp( OpMemGetFloat ),
			OToInt,
			OInt( f28_4s ),
			OOp( OpShl ),
			OSetReg( vdata.x = Reg.int() ),
			
			ODup,
			OInt( 4 ),
			OOp( OpIAdd ),
			OOp( OpMemGetFloat ),
			OToInt,
			OInt( f28_4s ),
			OOp( OpShl ),
			OSetReg( vdata.y = Reg.int() ),
			
			ODup,
			OInt( 8 ),
			OOp( OpIAdd ),
			OOp( OpMemGetFloat ),
			OToInt,
			OInt( f28_4s ),
			OOp( OpShl ),
			OSetReg( vdata.z = Reg.int() ),	
		]);
		
		return vdata;
	}
	
	function ccom( cond, a, b ):Dynamic
	{
		if ( cond )
			return a;
		return b;
	}
	
	static inline var f28_4:Int  = 256;
	static inline var f28_4s:Int = 8;
	
	static inline var f22_10:Int  = 65536;
	static inline var f22_10s:Int = 16;
	
	
}



























