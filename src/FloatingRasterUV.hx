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


class FloatingRasterUV
{

	var builder:BCBuild;
	var ctx:format.abc.Context;
	var frameBuffer:Int;
	var width:Int;
	var zBuffer:Int;
	
	public function new( call:Dynamic, frameBuffer:Int, width:Int, domain:ByteArray, ?debug:Bool, ?zBuffer:Int = -1 ) 
	{
		this.frameBuffer = frameBuffer;
		this.width = width;
		this.zBuffer = zBuffer;
		
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
	
	function scanline( x0:Dynamic, x1:Dynamic, y:Reg<Float> )
	{
		//scanline_flat( x0, x1, y );
		//scanline_debug( x0, x1, y );
		scanline_dinter( x0, x1, y );
	}
	
	function scanline_dinter( left:Dynamic, right:Dynamic, y:Reg<Float> )
	{
		var delta:Dynamic = { };
		var start:Dynamic = { };
		var xd = Reg.float();
		
		__abc__([
			OFloat( ctx.float( 1.0 ) ),
			OReg( right.x ),
			OToInt,
			OReg( left.x ),
			OToInt,
			OOp( OpSub ),
			ODup,
			OSetReg( xd ),
			OOp( OpDiv ),	
		]);	//{1/(x1-x0)
		
		for ( fld in CReflect.fieldsExcept( left, ["y", "x"] ) )
		{
			Reflect.setField( delta, fld, Reg.float() );
			Reflect.setField( start, fld, Reg.float() );
			
			__abc__([
				ODup,
				OReg( Reflect.field( left, fld ) ),
				OSetReg( Reflect.field( start, fld ) ),
				OReg( Reflect.field( right, fld ) ),
				OReg( Reflect.field( left, fld ) ),
				OOp( OpSub ),
				OOp( OpMul ),
				OSetReg( Reflect.field( delta, fld ) ),
			]);
		}
		__abc__([OPop]);
		
		
		//begin scanline routine
		
		var id:Int = Std.int( Math.random()*5000 ); //used to roll a different label id
		
		var end_address = Reg.int( );
		__abc__([
			OReg( y ),
			OToInt,
			OIntRef( ctx.int( cast width ) ),
			OOp( OpIMul ),
			OReg( left.x ),
			OToInt,
			OOp( OpIAdd ),
			OInt( 2 ),
			OOp( OpShl ),
			ODup,
			
			OReg( xd ),
			OToInt,
			ODup,
			
			//pixel counter
			OReg( ecode ),
			OOp( OpIAdd ),
			OSetReg( ecode ),
			
			OInt( 2 ),
			OOp( OpShl ),
			OOp( OpIAdd ),
			OSetReg( end_address ),
		]);
			
		//return;
		if ( zBuffer == -1 )
		{
			__abc__([
			
				OJump( JAlways, "scanline_flat_compat_jumpin" + id ),
				OLabel( "scanline_flat_WHILE1" + id ),
				ODup,
				OIntRef( ctx.int( cast frameBuffer ) ),
				OOp( OpIAdd ),
				//ODup,
				//OOp( OpMemGet32 ),
				//OIntRef( ctx.int( cast 0x000500CE ) ),
				//OOp( OpIAdd ),
				OReg( start.u ),
				OToInt,
				OSwap,
				OOp( OpMemSet32 ),
				
				OInt( 4 ),
				OOp( OpIAdd ),
			]);
		
			for ( fld in Reflect.fields( start ) )
			{
				__abc__([
					OReg( Reflect.field( start, fld ) ),
					OReg( Reflect.field( delta, fld ) ),
					OOp( OpAdd ),
					OSetReg( Reflect.field( start, fld ) ),
				]);
			}
			__abc__([	
				OLabel( "scanline_flat_compat_jumpin" + id ),
				ODup,
				OReg( end_address ),
				OJump( JLt, "scanline_flat_WHILE1" + id ),
				OPop,				//POP {address}
				
			]);
		}
		else
		{
			//@@@@ USE MAH ZBUFFER
			
			__abc__([
			
				OJump( JAlways, "scanline_flat_compat_jumpin" + id ),
				OLabel( "scanline_flat_WHILE1" + id ),
				
				ODup,
				OIntRef( ctx.int( cast zBuffer ) ),
				OOp( OpIAdd ),
				OOp( OpMemGetFloat ),
				OReg( Reflect.field( start, "z" ) ),
				OIf( JGt ),
					ODup,				//used in the color part
					OIntRef( ctx.int( cast zBuffer ) ),
					OOp( OpIAdd ),
					OReg( Reflect.field( start, "z" ) ),
					OSwap,
					OOp( OpMemSetFloat ),
					
					ODup,
					OReg( start.u ),
					OToInt,
					OInt( 8 ),
					OOp( OpShl ),
					OReg( start.v ),
					OToInt,
					OOp( OpOr ),
					
					OSwap,		
					OIntRef( ctx.int( cast frameBuffer ) ),
					OOp( OpIAdd ),			
					OOp( OpMemSet32 ),
				OFi,
				
				OInt( 4 ),
				OOp( OpIAdd ),
			]);
		
			for ( fld in Reflect.fields( start ) )
			{
				__abc__([
					OReg( Reflect.field( start, fld ) ),
					OReg( Reflect.field( delta, fld ) ),
					OOp( OpAdd ),
					OSetReg( Reflect.field( start, fld ) ),
				]);
			}
			__abc__([	
				OLabel( "scanline_flat_compat_jumpin" + id ),
				ODup,
				OReg( end_address ),
				OJump( JLt, "scanline_flat_WHILE1" + id ),
				OPop,				//POP {address}
				
			]);
		}
	}
	
	function scanline_debug( left:Dynamic, right:Dynamic, y:Reg<Float> )
	{
		
		__abc__([
		OReg( left.x ),
		OToInt,
		OReg( right.x ),
		OToInt,
		OIf( JGt ),
			OInt( 3038 ),
			OSetReg( ecode ),
		]);
			//*
			plotPointStar( left.x, y, 0xFFFF0000 );
			plotPointStar( right.x, y, 0xFFFF0000 );
			/*/
			plotPoint( x1, y, 0xFF333333 );
			plotPoint( x0, y, 0xFFFFFFFF );
			//*/
		__abc__([
		OElse,	
		]);
			plotPoint( left.x, y, 0xFF333333 );
			plotPoint( right.x, y, 0xFFFFFFFF );
		__abc__([
		OFi,	
		]);
	}
	
	//Requires pre-sorted vertices
	function scanPoly( poly:Dynamic )
	{
		sort_vertices( poly.v0, poly.v1, poly.v2 );
				
		var dx1 = findDeltas( poly.v0, poly.v1 );
		var dx3 = findDeltas( poly.v1, poly.v2 );
		var dx2 = findDeltas( poly.v0, poly.v2 );
		
		var left:Dynamic = { };
		var right:Dynamic = { };
		
		left.x = Reg.float( );
		right.x = Reg.float( );
		
		var Sy = Reg.float( );
		
		for ( fld in CReflect.fieldsExcept( dx1, ["y"] ) )
		{
			Reflect.setField( left, fld, Reg.float( ) );
			Reflect.setField( right, fld, Reg.float( ) );
			
			__abc__([
				OReg( Reflect.field( poly.v0, fld ) ),
				ODup,
				OSetReg( Reflect.field( left, fld ) ),
				OSetReg( Reflect.field( right, fld ) ),
			]);
		}
		
		
		__abc__([
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
				scanline( left, right, Sy );
		__abc__([				
				//replace with variable interpolation system
		]);
				for ( fld in Reflect.fields( left ) )
				{
					__abc__([
						OReg( Reflect.field( left, fld ) ),
						OReg( Reflect.field( dx2, fld ) ),
						OOp( OpAdd ),
						OSetReg( Reflect.field( left, fld ) ),
						
						OReg( Reflect.field( right, fld ) ),
						OReg( Reflect.field( dx1, fld ) ),
						OOp( OpAdd ),
						OSetReg( Reflect.field( right, fld ) ),
					]);
				}
				
		__abc__([				
				//y++
				OIncrReg( Sy ),
				OLabel( "scanPoly_WHILE1_JIN" ),
				OReg( Sy ),
				OReg( poly.v1.y ),
			OJump( JLt, "scanPoly_WHILE1" ),
			
		]);
			for ( fld in Reflect.fields( right ) )
			{
				__abc__([
					OReg( Reflect.field( poly.v1, fld ) ),
					OSetReg( Reflect.field( right, fld ) ),
				]);
			}
		__abc__([
			OReg( poly.v1.y ),			
			OSetReg( Sy ),
			
			OJump( JAlways, "scanPoly_WHILE2_JIN" ),
			OLabel( "scanPoly_WHILE2" ),
				//scanline algorithm here
		]);
				scanline( left, right, Sy );
		__abc__([				
				//replace with variable interpolation system
		]);
				for ( fld in Reflect.fields( left ) )
				{
					__abc__([
						OReg( Reflect.field( left, fld ) ),
						OReg( Reflect.field( dx2, fld ) ),
						OOp( OpAdd ),
						OSetReg( Reflect.field( left, fld ) ),
						
						OReg( Reflect.field( right, fld ) ),
						OReg( Reflect.field( dx3, fld ) ),
						OOp( OpAdd ),
						OSetReg( Reflect.field( right, fld ) ),
					]);
				}
				
		__abc__([	
				//y++
				OIncrReg( Sy ),
				OLabel( "scanPoly_WHILE2_JIN" ),
				OReg( Sy ),
				OReg( poly.v2.y ),
			OJump( JLt, "scanPoly_WHILE2" ),
			
		OElse,
			OJump( JAlways, "scanPoly_WHILE3_JIN" ),
			OLabel( "scanPoly_WHILE3" ),
				//scanline algorithm here
		]);
				scanline( left, right, Sy );
		__abc__([				
				//replace with variable interpolation system
		]);
				for ( fld in Reflect.fields( left ) )
				{
					__abc__([
						OReg( Reflect.field( left, fld ) ),
						OReg( Reflect.field( dx1, fld ) ),
						OOp( OpAdd ),
						OSetReg( Reflect.field( left, fld ) ),
						
						OReg( Reflect.field( right, fld ) ),
						OReg( Reflect.field( dx2, fld ) ),
						OOp( OpAdd ),
						OSetReg( Reflect.field( right, fld ) ),
					]);
				}
				
		__abc__([				
				//y++
				OIncrReg( Sy ),
				OLabel( "scanPoly_WHILE3_JIN" ),
				OReg( Sy ),
				OReg( poly.v1.y ),
			OJump( JLt, "scanPoly_WHILE3" ),
			
		]);
			for ( fld in Reflect.fields( left ) )
			{
				__abc__([
					OReg( Reflect.field( poly.v1, fld ) ),
					OSetReg( Reflect.field( left, fld ) ),
				]);
			}
			
		__abc__([
			OReg( poly.v1.y ),			
			OSetReg( Sy ),
			
			OJump( JAlways, "scanPoly_WHILE4_JIN" ),
			OLabel( "scanPoly_WHILE4" ),
				//scanline algorithm here
		]);
				scanline( left, right, Sy );
		__abc__([				
				//replace with variable interpolation system
		]);
				for ( fld in Reflect.fields( left ) )
				{
					__abc__([
						OReg( Reflect.field( left, fld ) ),
						OReg( Reflect.field( dx3, fld ) ),
						OOp( OpAdd ),
						OSetReg( Reflect.field( left, fld ) ),
						
						OReg( Reflect.field( right, fld ) ),
						OReg( Reflect.field( dx2, fld ) ),
						OOp( OpAdd ),
						OSetReg( Reflect.field( right, fld ) ),
					]);
				}
				
		__abc__([				
				//y++
				OIncrReg( Sy ),
				OLabel( "scanPoly_WHILE4_JIN" ),
				OReg( Sy ),
				OReg( poly.v2.y ),
			OJump( JLt, "scanPoly_WHILE4" ),
		OFi,
		]);
		
		/*
		plotPoint( poly.v0.x, poly.v0.y, 0xFF00FF00 );
		plotPoint( poly.v1.x, poly.v1.y, 0xFF0000FF );
		plotPoint( poly.v2.x, poly.v2.y, 0xFFFF0000 );
		*/
		
	}
	
	function findDeltas( v0, v1 )
	{
		var deltas:Dynamic = { };
		var deltasp1:Dynamic = { };
		for ( fld in CReflect.fieldsExcept( v0, ["y"] ) )
		{
			Reflect.setField( deltas, fld, Reg.float() );
			Reflect.setField( deltasp1, fld, Reg.float() );
		}
		
		//@@ Calculate deltas per y++;
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
		poly.v0 = read_vertex_xyzuv( );
		__abc__([
			OInt( 20 ),
			OOp( OpIAdd ),
		]);
		poly.v1 = read_vertex_xyzuv( );
		__abc__([
			OInt( 20 ),
			OOp( OpIAdd ),
		]);
		poly.v2 = read_vertex_xyzuv( );
		__abc__([
			OInt( 20 ),
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
			OToInt,
			OToNumber,
			OSetReg( regs.x = Reg.float() ),
			
			ODup,
			OInt( 4 ),
			OOp( OpIAdd ),
			OOp( OpMemGetFloat ),
			OToInt,
			OToNumber,
			OSetReg( regs.y = Reg.float() ),
			
			ODup,
			OInt( 8 ),
			OOp( OpIAdd ),
			OOp( OpMemGetFloat ),
			OToInt,
			OToNumber,
			OSetReg( regs.z = Reg.float() ),	
		]);
		
		return regs;
	}
	
	function read_vertex_xyzuv( ?v:Reg<Int> )
	{
		var regs:Dynamic = { }
		
		__abc__([
			ccom( (v == null), ODup, OReg(v) ),
			
			OOp( OpMemGetFloat ),
			OToInt,
			OToNumber,
			OSetReg( regs.x = Reg.float() ),
			
			ODup,
			OInt( 4 ),
			OOp( OpIAdd ),
			OOp( OpMemGetFloat ),
			OToInt,
			OToNumber,
			OSetReg( regs.y = Reg.float() ),
			
			ODup,
			OInt( 8 ),
			OOp( OpIAdd ),
			OOp( OpMemGetFloat ),
			OToInt,
			OToNumber,
			OSetReg( regs.z = Reg.float() ),	
			
			ODup,
			OInt( 12 ),
			OOp( OpIAdd ),
			OOp( OpMemGetFloat ),
			OToInt,
			OToNumber,
			OSetReg( regs.u = Reg.float() ),
			
			ODup,
			OInt( 16 ),
			OOp( OpIAdd ),
			OOp( OpMemGetFloat ),
			OToInt,
			OToNumber,
			OSetReg( regs.v = Reg.float() ),
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



























