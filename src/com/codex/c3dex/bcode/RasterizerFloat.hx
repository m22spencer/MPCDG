/**
 * ...
 * @author Matthew Spencer
 */

package com.codex.c3dex.bcode;

import apps.FloatingTransformationTester;
import com.abc.BCBuild;
import com.abc.Data;
import com.abc.Reg;
import com.codex.c3dex.mapping.VertexMapper;
import format.abc.Data;
import com.CReflect;

class RasterizerFloat extends BytecodeGroup
{
	private var fbuffer:Int;

	public function new( abcfunc:Array<Dynamic>->Void, ctx:format.abc.Context, fb:Int ) 
	{
		super( abcfunc, ctx );
		
		fbuffer = fb;
	}
	
	public function scanline_leftright( Sx:Reg<Float>, Ex:Reg<Float>, Sy:Reg<Float>, idata:Dynamic<Reg<Float>>, ixdata:Dynamic<Reg<Float>> )
	{
		//plotPoint( Sx, Sy, 0xCCCC00, fbuffer, 512 );
		//plotPoint( Ex, Sy, 0x666600, fbuffer, 512 );
		//return;
		
		idata = clone_dynReg_float( idata, ["x", "y"] );
		
		//EDGE faddr
		
		var sl_loop = BCBuild.label( );
		var sl_stepin = BCBuild.label( );
		
		//find addr/eaddr
		var end_addr = Reg.int( );
		{__abc__([
			OReg( Sy ),
			OToInt,
			OIntRef( ctx.int( cast 512 ) ),
			OOp( OpIMul ),
			OReg( Sx ),
			OToInt,
			OOp( OpIAdd ),
			OInt( 2 ),
			OOp( OpShl ),
			OIntRef( ctx.int( cast fbuffer ) ),
			OOp( OpIAdd ),
			
			OReg( Sy ),
			OToInt,
			OIntRef( ctx.int( cast 512 ) ),
			OOp( OpIMul ),
			OReg( Ex ),
			OToInt,
			OOp( OpIAdd ),
			OInt( 2 ),
			OOp( OpShl ),
			OIntRef( ctx.int( cast fbuffer ) ),
			OOp( OpIAdd ),
			OSetReg( end_addr ),
		]);}
		
		__abc__([
			OJump( JAlways, sl_stepin ),
			OLabel( sl_loop ),
				
				ODup,
				
				/*overwrite shader
				ODup,
				OOp( OpMemGet32 ),
				OIntRef( ctx.int( cast 0x000010 ) ),
				OOp( OpIAdd ),
				/*/
				OReg( idata.v ),
				OToInt,
				OInt( 256 ),
				OOp( OpIMul ),
				OReg( idata.u ),
				OOp( OpIAdd ),
				OInt( 2 ),
				OOp( OpShl ),
				OUIntRef( ctx.uint( cast 199000000 ) ),
				OOp( OpIAdd ),
				OOp( OpMemGet32 ),				
				//*/
				
				OSwap,
				OOp( OpMemSet32 ),
		]);
			
				interpolate_horiz( idata, ixdata, ["x", "y"] );
		__abc__([
				OInt( 4 ),
				OOp( OpIAdd ),
			OLabel( sl_stepin ),
			ODup,
			OReg( end_addr ),
			OJump( JLt, sl_loop ),
			OPop,
		]);
	}
	
	public function scanline_rightleft( Sx:Reg<Float>, Ex:Reg<Float>, Sy:Reg<Float>, idata:Dynamic<Reg<Float>>, ixdata:Dynamic<Reg<Float>> )
	{
		//plotPoint( Sx, Sy, 0x00CCCC, fbuffer, 512 );
		//plotPoint( Ex, Sy, 0x006666, fbuffer, 512 );
		//return
		
		idata = clone_dynReg_float( idata, ["x", "y"] );
		
		var sl_loop = BCBuild.label( );
		var sl_stepin = BCBuild.label( );
		
		//find addr/eaddr
		var end_addr = Reg.int( );
		{__abc__([
			OReg( Sy ),
			OToInt,
			OIntRef( ctx.int( cast 512 ) ),
			OOp( OpIMul ),
			OReg( Sx ),
			OToInt,
			OOp( OpIAdd ),
			OInt( 2 ),
			OOp( OpShl ),
			OIntRef( ctx.int( cast fbuffer ) ),
			OOp( OpIAdd ),
			
			OReg( Sy ),
			OToInt,
			OIntRef( ctx.int( cast 512 ) ),
			OOp( OpIMul ),
			OReg( Ex ),
			OToInt,
			OOp( OpIAdd ),
			OInt( 2 ),
			OOp( OpShl ),
			OIntRef( ctx.int( cast fbuffer ) ),
			OOp( OpIAdd ),
			OSetReg( end_addr ),
		]); }
		
		//since we're working backwards we need to step in one to adhere to 
		//top/left primary rules.
		interpolate_horiz( idata, ixdata, ["x", "y"] );
		__abc__([OInt( -4 ), OOp( OpIAdd )]);
		
		__abc__([
			OJump( JAlways, sl_stepin ),
			OLabel( sl_loop ),
				
				ODup,
				
				/*overwrite shader
				ODup,
				OOp( OpMemGet32 ),
				OIntRef( ctx.int( cast 0x000010 ) ),
				OOp( OpIAdd ),
				/*/
				OReg( idata.v ),
				OToInt,
				OInt( 256 ),
				OOp( OpIMul ),
				OReg( idata.u ),
				OOp( OpIAdd ),
				OInt( 2 ),
				OOp( OpShl ),
				OUIntRef( ctx.uint( cast 199000000 ) ),
				OOp( OpIAdd ),
				OOp( OpMemGet32 ),				
				//*/
				
				OSwap,
				OOp( OpMemSet32 ),
		]);
			
				interpolate_horiz( idata, ixdata, ["x", "y"] );
		__abc__([
				OInt( -4 ),
				OOp( OpIAdd ),
			OLabel( sl_stepin ),
			ODup,
			OReg( end_addr ),
			OJump( JGte, sl_loop ),
			OPop,
		]);
	}
	
	public function interpolate_horiz( data:Dynamic, hdata:Dynamic, exclude:Array<String> )
	{
		for ( fld in CReflect.fieldsExcept( data, exclude ) )
		{
			__abc__([
				OReg( Reflect.field( data, fld ) ),
				OReg( Reflect.field( hdata, fld ) ),
				OOp( OpAdd ),
				OSetReg( Reflect.field( data, fld ) ),			
			]);
		}
	}
	
	public function clone_dynReg_float( data:Dynamic, exclude:Array<String> )
	{
		var newdata:Dynamic = { };
		for ( fld in CReflect.fieldsExcept( data, exclude ) )
		{
			Reflect.setField( newdata, fld, Reg.float( ) );
			__abc__([
				OReg( Reflect.field( data, fld ) ),
				OSetReg( Reflect.field( newdata, fld ) ),			
			]);
		}
		return newdata;
	}
	
	/**
	 * Interpolates via ~AC only. Utilizes horizontal deltas and dx2.
	 * If dx2(~AC) is on the left side, scanlines are rendered left to right
	 * If dx2(~AC) is on the right side, scanlines are rendered right to left
	 * @param	poly {v0, v1, v2}
	 */
	public function scanRows( poly:Dynamic<Dynamic<Reg<Float>>> )
	{
		
		sort_vertices( poly.v0, poly.v1, poly.v2 );   //we need top->bottom order
		
		//plotPoint( poly.v0.x, poly.v0.y, 0xFFFFFFFF, 0, 512 );
		
		//!! We still need to find x deltas for each side.
		var dx1 = Reg.float( );
		var dx2 = Reg.float( );
		
		//@XXX This can result in a divide by zero, however flash treats this as +/- infinity
		//no divide by zero check is needed due to the native clamping.
		__abc__([
			OReg( poly.v1.x ),
			OReg( poly.v0.x ),
			OOp( OpSub ),			//x1-x0
			OReg( poly.v1.y ),
			OReg( poly.v0.y ),
			OOp( OpSub ),			//y1-y0
			OOp( OpDiv ),			//(x1-x0)/(y1-y0)
			OSetReg( dx1 ),
			
			OReg( poly.v2.x ),
			OReg( poly.v0.x ),
			OOp( OpSub ),			//x2-x0
			OReg( poly.v2.y ),
			OReg( poly.v0.y ),
			OOp( OpSub ),			//y2-y0
			OOp( OpDiv ),			//(x2-x0)/(y2-y0)
			OSetReg( dx2 ),
		]);
		
		//temporary variables
		var Sy = Reg.float( );
		var Sx = Reg.float( );
		var Ex = Reg.float( );
		
		__abc__([
			OReg( poly.v0.y ),
			OSetReg( Sy ),
			
			OReg( poly.v0.x ),
			ODup,
			OSetReg( Sx ),
			OSetReg( Ex ),
		
		]);
		
		__abc__([
			OReg( dx1 ),
			OReg( dx2 ),
			OIf( JGt ),
				//######################
				//short right
				//  |\
				//  |/
				
		]);
				//Find deltas for AC
				var delta_AC = findDelta_nocheck( poly.v0, poly.v2, ["x", "y"] );
				
				//Find horiontal delta/pixel
				var delta_horiz = findDelta_horizontal( poly.v0, poly.v1, delta_AC, dx2, ["x", "y"] );
				
				scanrow_walk( delta_AC, delta_horiz, poly.v0, poly.v1.y, Sx, Ex, Sy, dx2, dx1, scanline_leftright );
				var dx3 = findSingleDelta( poly.v1.x, poly.v2.x, poly.v1.y, poly.v2.y );
				
				__abc__([
					OReg( poly.v1.x ),
					OSetReg( Ex ),				
				]);
				
				scanrow_walk( delta_AC, delta_horiz, poly.v0, poly.v2.y, Sx, Ex, Sy, dx2, dx3, scanline_leftright );
				
			__abc__([
			
		
			OElse,
				//######################
				//short left
				//  /|
				//  \|
				
				]);
				//Find deltas for AC
				var delta_AC = findDelta_nocheck( poly.v0, poly.v2, ["x", "y"] );
				
				//Find horiontal delta/pixel
				var delta_horiz = findDelta_horizontal_opp( poly.v0, poly.v1, delta_AC, dx2, ["x", "y"] );
				
				scanrow_walk( delta_AC, delta_horiz, poly.v0, poly.v1.y, Sx, Ex, Sy, dx2, dx1, scanline_rightleft );
				var dx3 = findSingleDelta( poly.v1.x, poly.v2.x, poly.v1.y, poly.v2.y );
				
				__abc__([
					OReg( poly.v1.x ),
					OSetReg( Ex ),				
				]);
				
				scanrow_walk( delta_AC, delta_horiz, poly.v0, poly.v2.y, Sx, Ex, Sy, dx2, dx3, scanline_rightleft );
				
		__abc__([
			OFi,
		]);
	}

	public function findSingleDelta( x0:Reg<Float>, x1:Reg<Float>, y0:Reg<Float>, y1:Reg<Float> )
	{
		var r = Reg.float( );
		__abc__([
			OReg( x1 ),
			OReg( x0 ),
			OOp( OpSub ),
			
			OReg( y1 ),
			OReg( y0 ),
			OOp( OpSub ),
			OOp( OpDiv ),
			OSetReg( r ),
		]);
		return r;
	}
	
	public function scanrow_walk( delta_AC:Dynamic, delta_horiz:Dynamic, v:Dynamic, y_end:Reg<Float>, Sx:Reg<Float>, Ex:Reg<Float>, Sy:Reg<Float>, SxD:Reg<Float>, ExD:Reg<Float>, scan_call:Reg<Float>->Reg<Float>->Reg<Float>->Dynamic<Reg<Float>>->Dynamic<Reg<Float>>->Void )
	{
		var scanPoly_while = BCBuild.label( );
		var scanPoly_while_jumpin = BCBuild.label( );
		__abc__([
				OJump( JAlways, scanPoly_while_jumpin ),
				OLabel( scanPoly_while ),
		]);
					//scanline algo here
					//scanline( Sx, Ex, Sy );
					
					scan_call( Sx, Ex, Sy, v, delta_horiz );
			
					//interpolate AC
					for ( fld in Reflect.fields( delta_AC ) )
					{
						__abc__([
							OReg( Reflect.field( delta_AC, fld ) ),
							OReg( Reflect.field( v, fld ) ),
							OOp( OpAdd ),
							OSetReg( Reflect.field( v, fld ) ),
						]);
					}
			
					//Interpolated dx1/dx2
		__abc__([				
					//replace with variable interpolation system
					OReg( Sx ),
					OReg( SxD ),
					OOp( OpAdd ),
					OSetReg( Sx ),
					
					OReg( Ex ),
					OReg( ExD ),
					OOp( OpAdd ),
					OSetReg( Ex ),
					
					//y++
					OIncrReg( Sy ),
					OLabel( scanPoly_while_jumpin ),
					OReg( Sy ),
					OReg( y_end ),
				OJump( JLt, scanPoly_while ),
				
		]);	
	}
	
	public function findDelta_horizontal_opp( v0:Dynamic<Reg<Float>>, v1:Dynamic<Reg<Float>>, deltas:Dynamic, deltax:Reg<Float>, except:Array<String> )
	{
		var hdeltas:Dynamic = { };
		for ( fld in CReflect.fieldsExcept( v0, except ) )
		{
			Reflect.setField( hdeltas, fld, Reg.float() );
		}
		
		var ystep = Reg.float( );
		__abc__([
			OReg( v1.y ),
			OReg( v0.y ),
			OOp( OpSub ),
			OSetReg( ystep ),
		]);
		
		for ( fld in CReflect.fieldsExcept( v0, except ) )
		{
			__abc__([
				OReg( Reflect.field( v1, fld ) ),
				
				OReg( ystep ),
				OReg( Reflect.field( deltas, fld ) ),
				OOp( OpMul ),
				OReg( Reflect.field( v0, fld ) ),
				OOp( OpAdd ),			//v0.fld + deltas.fld*ystep
				
				OOp( OpSub ),				//v1.fld - res
				
				OReg( v1.x ),
				
				OReg( ystep ),
				OReg( deltax ),
				OOp( OpMul ),
				OReg( v0.x ),
				OOp( OpAdd ),			//v0.fld + deltas.fld*ystep
				
				OOp( OpSub ),//v1.x - res
				
				OOp( OpDiv ),
				
				OOp( OpNeg ),
				
				OSetReg( Reflect.field( hdeltas, fld ) ),			
			]);			
		}
		return hdeltas;
	}
	
	public function findDelta_horizontal( v0:Dynamic<Reg<Float>>, v1:Dynamic<Reg<Float>>, deltas:Dynamic, deltax:Reg<Float>, except:Array<String> )
	{
		var hdeltas:Dynamic = { };
		for ( fld in CReflect.fieldsExcept( v0, except ) )
		{
			Reflect.setField( hdeltas, fld, Reg.float() );
		}
		
		var ystep = Reg.float( );
		__abc__([
			OReg( v1.y ),
			OReg( v0.y ),
			OOp( OpSub ),
			OSetReg( ystep ),
		]);
		
		for ( fld in CReflect.fieldsExcept( v0, except ) )
		{
			__abc__([
				OReg( Reflect.field( v1, fld ) ),
				
				OReg( ystep ),
				OReg( Reflect.field( deltas, fld ) ),
				OOp( OpMul ),
				OReg( Reflect.field( v0, fld ) ),
				OOp( OpAdd ),			//v0.fld + deltas.fld*ystep
				
				OOp( OpSub ),				//v1.fld - res
				
				OReg( v1.x ),
				
				OReg( ystep ),
				OReg( deltax ),
				OOp( OpMul ),
				OReg( v0.x ),
				OOp( OpAdd ),			//v0.fld + deltas.fld*ystep
				
				OOp( OpSub ),//v1.x - res
				
				OOp( OpDiv ),
				
				OSetReg( Reflect.field( hdeltas, fld ) ),			
			]);			
		}
		return hdeltas;
	}
	
	public function findDelta_nocheck( v0:Dynamic<Reg<Float>>, v1:Dynamic<Reg<Float>>, except:Array<String>)
	{
		var deltas:Dynamic = { };
		for ( fld in CReflect.fieldsExcept( v0, except ) )
		{
			Reflect.setField( deltas, fld, Reg.float() );
		}
		
		//@@ Calculate deltas per y++;
		__abc__([
		OFloat( ctx.float( 1 ) ),
		OReg( v1.y ),
		OReg( v0.y ),
		OOp( OpSub ),
		OOp( OpDiv ),		//{1/ABstep}
		]);			
		for ( fld in CReflect.fieldsExcept( v0, except ) )
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
		]);
		
		return deltas;	
	}
	
	/**
	 * 
	 * @param	v0 Top vert
	 * @param	v1 Mid vert
	 * @param	v2 Bottom vert
	 */
	public function findDelta( v0:Dynamic<Reg<Float>>, v1:Dynamic<Reg<Float>>, except:Array<String>)
	{
		var deltas:Dynamic = { };
		for ( fld in CReflect.fieldsExcept( v0, except ) )
		{
			Reflect.setField( deltas, fld, Reg.float() );
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
		
		return deltas;	
	}
	
	public function offsetAddressSmall( o:Int, ?dupe:Bool = false )
	{
		if ( dupe ) __abc__([ ODup ]);
		__abc__([
			OInt( o ),
			OOp( OpIAdd ),	
		]);
	}

	public function sort_vertices( v0:Dynamic<Reg<Dynamic>>, v1:Dynamic<Reg<Dynamic>>, v2:Dynamic<Reg<Dynamic>> )
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
	
	public function plotPoint( x:Reg<Float>, y:Reg<Float>, color:Int, frameBuffer:Int, screenWidth:Int )
	{
		__abc__([
			//find pixel address
			OReg( y ),
			OToInt,
			OIntRef( ctx.int( cast screenWidth ) ),
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
	
	public function swapEach( a:Dynamic<Reg<Dynamic>>, b:Dynamic<Reg<Dynamic>> )
	{
		for ( fld in Reflect.fields( a ) )
		{
			swap( Reflect.field( a, fld ), Reflect.field( b, fld ) );
		}
	}
	
	public function swap<T>( a:Reg<T>, b:Reg<T> )
	{
		__abc__([
			OReg( a ),
			OReg( b ),
			OSetReg( a ),
			OSetReg( b ),		
		]);		
	}
	
	public function read_vertices_map( map:VertexMapper )
	{
		var poly:Dynamic = { };
		poly.v0 = read_vertex_map( map );
		__abc__([
			OInt( map.vertex_size_bytes ),
			OOp( OpIAdd ),
		]);
		poly.v1 = read_vertex_map( map );
		__abc__([
			OInt( map.vertex_size_bytes ),
			OOp( OpIAdd ),
		]);
		poly.v2 = read_vertex_map( map );
		__abc__([
			OInt( map.vertex_size_bytes ),
			OOp( OpIAdd ),
		]);
		
		return poly;
	}
	
	public function read_vertex_map( map:VertexMapper )
	{
		
		var res = map.genByteCode( );
		
		//throw( res.regs );
		
		var s:String = "";
		
		for ( fld in Reflect.fields( res.regs ) )
			s += "\n" + fld + ":" + Reflect.field( res.regs, fld );
			
		//throw( s );
		
		__abc__(res.ops);
		
		return res.regs;		
	}
			
			
	public function read_vertex_xyzuv( ?v:Reg<Int> )
	{
		var regs:Dynamic = { }
		
		__abc__([
			regOrStack( (v == null), ODup, OReg(v) ),
			
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
	
	public function read_vertex( ?v:Reg<Int> ):Dynamic<Reg<Dynamic>>
	{
		var vdata:Dynamic = { }
		
		__abc__([
			regOrStack( (v == null), ODup, OReg(v) ),
			
			//x
			OOp( OpMemGetFloat ),
			OToInt,
			OToNumber,
			OSetReg( vdata.x = Reg.float() ),
			
			//y
			ODup,
			OInt( 4 ),
			OOp( OpIAdd ),
			OOp( OpMemGetFloat ),
			OToInt,
			OToNumber,
			OSetReg( vdata.y = Reg.float() ),
			
			//z
			ODup,
			OInt( 8 ),
			OOp( OpIAdd ),
			OOp( OpMemGetFloat ),
			OToInt,
			OToNumber,
			OSetReg( vdata.z = Reg.float() ),
		]);
		
		return vdata;
	}
	
	public function regOrStack( cond, a, b ):Dynamic
	{
		if ( cond )
			return a;
		return b;
	}
}