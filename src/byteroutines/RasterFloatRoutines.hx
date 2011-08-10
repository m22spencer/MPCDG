/**
 * ...
 * @author Matthew Spencer
 */

package byteroutines;

import apps.FloatingTransformationTester;
import com.abc.Reg;
import com.codex.c3dex.bcode.app.ByteApplication;
import com.codex.c3dex.bcode.routines.ByteRoutine;
import com.codex.c3dex.mapping.VertexMapper2;
import com.CReflect;
import format.abc.Data.JumpStyle;
import com.codex.c3dex.memory.MemoryDispatcher;

class RasterFloatRoutines extends ByteRoutine
{
	private var fbuffer:Int;
	private var fwid:Int;

	public function new( app:ByteApplication, fb:Int, fwid:Int ) 
	{
		super( app );
		
		fbuffer = fb;
		this.fwid = fwid;
	}
	
	public function scanline_leftright( Sx:Reg<Dynamic>, Ex:Reg<Dynamic>, Sy:Reg<Float>, idata:Dynamic<Reg<Float>>, ixdata:Dynamic<Reg<Float>>, scanPixel:ScanpixelCall, ?zbuffer:RasterMem )
	{
		//plotPoint( Sx, Sy, 0xCCCC00, fbuffer, 512 );
		//plotPoint( Ex, Sy, 0x666600, fbuffer, 512 );
		//return;
		idata = clone_dynReg_float( idata, ["x", "y"] );
		
		//EDGE faddr
		
		var sl_loop = bLabel( );
		var sl_stepin = bLabel( );
		
		//find addr/eaddr
		var end_addr = Reg.int( );
		OpReg( Sy );
		OpToInt( );
		OpIntRef( bInt32( cast fwid ) );
		OpIMul( );
		OpReg( Sx );
		OpToInt( );
		OpIAdd( );
		OpInt( 2 );
		OpShl( );
		OpIntRef( bInt32( cast fbuffer ) );
		OpIAdd( );
		
		OpReg( Sy );
		OpToInt( );
		OpIntRef( bInt32( cast fwid ) );
		OpIMul( );
		OpReg( Ex );
		OpToInt( );
		OpIAdd( );
		OpInt( 2 );
		OpShl( );
		OpIntRef( bInt32( cast fbuffer ) );
		OpIAdd( );
		OpSetReg( end_addr );
		
		
		//Begin Scanline loop
		
		OpJump( JAlways, sl_stepin );
		OpLabel( sl_loop );
			
			if ( zbuffer != null )
			{
				//{addr}
				OpDup( );
				OpIntRef( bInt32( zbuffer.addr - fbuffer ) );
				OpIAdd( );	//{addr, zaddr}
				OpMemGetFloat( );	//{addr, zaddr, zdepth}
				OpReg( idata.z );	
				OpIf( JLt );	
					OpDup( );
					OpIntRef( bInt32( zbuffer.addr - fbuffer ) );
					OpIAdd( );	//{addr, zaddr}
					OpReg( idata.z );
					OpSwap( );
					OpMemSetFloat( );
			}
					scanPixel( idata );
			if ( zbuffer != null )
			{
				OpFi( );
			}
			
			interpolate_horiz( idata, ixdata, ["x", "y"] );			
			OpInt( 4 );
			OpIAdd( );
		OpLabel( sl_stepin );
		OpDup( );
		OpReg( end_addr );
		OpJump( JLt, sl_loop );
		OpPop( );
	}
	
	//BUG right->left render causes 1px artifacts, cause unknown
	//UPDATE Hacked in a quickfix, interpolated values are now shifted 1px left. This is incorrect
	public function scanline_rightleft( Sx:Reg<Dynamic>, Ex:Reg<Dynamic>, Sy:Reg<Float>, idata:Dynamic<Reg<Float>>, ixdata:Dynamic<Reg<Float>>, scanPixel:ScanpixelCall, ?zbuffer:RasterMem )
	{
		//plotPoint( Sx, Sy, 0x00CCCC, fbuffer, 512 );
		//plotPoint( Ex, Sy, 0x006666, fbuffer, 512 );
		
		idata = clone_dynReg_float( idata, ["x", "y"] );
		
		var sl_loop = bLabel( );
		var sl_stepin = bLabel( );
		
		//find addr/eaddr
		var end_addr = Reg.int( );
		
		OpReg( Sy );
		OpToInt( );
		OpIntRef( bInt32( cast fwid ) );
		OpIMul( );
		OpReg( Sx );
		OpToInt( );
		OpIAdd( );
		OpInt( 2 );
		OpShl( );
		OpIntRef( bInt32( cast fbuffer ) );
		OpIAdd( );
		
		OpReg( Sy );
		OpToInt( );
		OpIntRef( bInt32( cast fwid ) );
		OpIMul( );
		OpReg( Ex );
		OpToInt( );
		OpIAdd( );
		OpInt( 2 );
		OpShl( );
		OpIntRef( bInt32( cast fbuffer ) );
		OpIAdd( );
		OpSetReg( end_addr );
		
		//since we're working backwards we need to step in one to adhere to 
		//top/left primary rules.
		interpolate_horiz( idata, ixdata, ["x", "y"] );
		OpInt( -4 );
		OpIAdd( );
		
		
		//Begin pixelwrite loop
		OpJump( JAlways, sl_stepin );
		OpLabel( sl_loop );
			
			if ( zbuffer != null )
			{
				//{addr}
				OpDup( );
				OpIntRef( bInt32( zbuffer.addr - fbuffer ) );
				OpIAdd( );	//{addr, zaddr}
				OpMemGetFloat( );	//{addr, zaddr, zdepth}
				OpReg( idata.z );	
				OpIf( JLt );	
					OpDup( );
					OpIntRef( bInt32( zbuffer.addr - fbuffer ) );
					OpIAdd( );	//{addr, zaddr}
					OpReg( idata.z );
					OpSwap( );
					OpMemSetFloat( );
			}
					scanPixel( idata );
			if ( zbuffer != null )
			{
				OpFi( );
			}
			
			//update pixel data
			interpolate_horiz( idata, ixdata, ["x", "y"] );	
			OpInt( -4 );
			OpIAdd( );
		OpLabel( sl_stepin );
		OpDup( );
		OpReg( end_addr );
		OpJump( JGte, sl_loop );
		OpPop( );
		
	}
	
	public function interpolate_horiz( data:Dynamic, hdata:Dynamic, exclude:Array<String> )
	{
		for ( fld in CReflect.fieldsExcept( data, exclude ) )
		{
			OpReg( Reflect.field( data, fld ) );
			OpReg( Reflect.field( hdata, fld ) );
			OpAdd( );
			OpSetReg( Reflect.field( data, fld ) );		
		}
	}
	
	public function clone_dynReg_float( data:Dynamic, exclude:Array<String> )
	{
		var newdata:Dynamic = { };
		for ( fld in CReflect.fieldsExcept( data, exclude ) )
		{
			Reflect.setField( newdata, fld, Reg.float( ) );
			OpReg( Reflect.field( data, fld ) );
			OpSetReg( Reflect.field( newdata, fld ) );
		}
		return newdata;
	}
	
	/**
	 * Interpolates via ~AC only. Utilizes horizontal deltas and dx2.
	 * If dx2(~AC) is on the left side, scanlines are rendered left to right
	 * If dx2(~AC) is on the right side, scanlines are rendered right to left
	 * @param	poly {v0, v1, v2}
	 */
	public function scanRows( poly:Dynamic<Dynamic<Reg<Float>>>, scanPixel:ScanpixelCall, ?zbuffer:RasterMem )
	{
		
		//HACK Floor y values to fix a rasterization bug		
		OpReg( poly.v0.y );
		OpToInt( );
		OpToNumber( );
		OpSetReg( poly.v0.y );
		OpReg( poly.v1.y );
		OpToInt( );
		OpToNumber( );
		OpSetReg( poly.v1.y );
		OpReg( poly.v2.y );
		OpToInt( );
		OpToNumber( );
		OpSetReg( poly.v2.y );		
		//END HACK
		
		
		
		sort_vertices( poly.v0, poly.v1, poly.v2 );   //we need top->bottom order
		
		//plotPoint( poly.v0.x, poly.v0.y, 0xFFFFFFFF, 0, 512 );
		
		//!! We still need to find x deltas for each side.
		var dx1 = Reg.float( );
		var dx2 = Reg.float( );
		
		//@XXX This can result in a divide by zero, however flash treats this as +/- infinity
		//no divide by zero check is needed due to the native clamping.
			OpReg( poly.v1.x );
			OpReg( poly.v0.x );
			OpSub( );			//x1-x0
			OpReg( poly.v1.y );
			OpReg( poly.v0.y );
			OpSub( );			//y1-y0
			OpDiv( );			//(x1-x0)/(y1-y0)
			OpSetReg( dx1 );
			
			OpReg( poly.v2.x );
			OpReg( poly.v0.x );
			OpSub( );			//x2-x0
			OpReg( poly.v2.y );
			OpReg( poly.v0.y );
			OpSub( );			//y2-y0
			OpDiv( );			//(x2-x0)/(y2-y0)
			OpSetReg( dx2 );
			
		//temporary variables
		var Sy = Reg.float( );
		var Sx = Reg.float( );
		var Ex = Reg.float( );
		
		OpReg( poly.v0.y );
		OpSetReg( Sy );
		
		OpReg( poly.v0.x );
		OpDup( );
		OpSetReg( Sx );
		OpSetReg( Ex );
		
		OpReg( dx1 );
		OpReg( dx2 );
		OpIf( JGt );
			//######################
			//short right
			//  |\
			//  |/
				
			//Find deltas for AC
			var delta_AC = findDelta_nocheck( poly.v0, poly.v2, ["x", "y"] );
			
			//Find horiontal delta/pixel
			var delta_horiz = findDelta_horizontal( poly.v0, poly.v1, delta_AC, dx2, ["x", "y"] );
			
			scanrow_walk( delta_AC, delta_horiz, poly.v0, poly.v1.y, Sx, Ex, Sy, dx2, dx1, scanline_leftright, scanPixel, zbuffer );
			var dx3 = findSingleDelta( poly.v1.x, poly.v2.x, poly.v1.y, poly.v2.y );
			
			OpReg( poly.v1.x );
			OpSetReg( Ex );		
			
			scanrow_walk( delta_AC, delta_horiz, poly.v0, poly.v2.y, Sx, Ex, Sy, dx2, dx3, scanline_leftright, scanPixel, zbuffer );
				
		OpElse( );
			//######################
			//short left
			//  /|
			//  \|
			
			
			//Find deltas for AC
			var delta_AC = findDelta_nocheck( poly.v0, poly.v2, ["x", "y"] );
			
			//Find horiontal delta/pixel
			var delta_horiz = findDelta_horizontal_opp( poly.v0, poly.v1, delta_AC, dx2, ["x", "y"] );
			
			scanrow_walk( delta_AC, delta_horiz, poly.v0, poly.v1.y, Sx, Ex, Sy, dx2, dx1, scanline_rightleft, scanPixel, zbuffer );
			var dx3 = findSingleDelta( poly.v1.x, poly.v2.x, poly.v1.y, poly.v2.y );
			
			OpReg( poly.v1.x );
			OpSetReg( Ex );
			
			scanrow_walk( delta_AC, delta_horiz, poly.v0, poly.v2.y, Sx, Ex, Sy, dx2, dx3, scanline_rightleft, scanPixel, zbuffer );
				
		OpFi( );
	}

	public function findSingleDelta( x0:Reg<Float>, x1:Reg<Float>, y0:Reg<Float>, y1:Reg<Float> )
	{
		var r = Reg.float( );
			OpReg( x1 );
			OpReg( x0 );
			OpSub( );
			
			OpReg( y1 );
			OpReg( y0 );
			OpSub( );
			OpDiv( );
			OpSetReg( r );
		return r;
	}
	
	public static var useFixed:Bool = false;
	
	public function scanrow_walk( delta_AC:Dynamic, delta_horiz:Dynamic, v:Dynamic, y_end:Reg<Float>, Sx:Reg<Float>, Ex:Reg<Float>, Sy:Reg<Float>, SxD:Reg<Float>, ExD:Reg<Float>, scan_call:ScanlineCall, scan_pixel:ScanpixelCall, ?zbuffer:RasterMem )
	{
		var scanPoly_while = bLabel( );
		var scanPoly_while_jumpin = bLabel( );
		
		
		var Sx_F = Reg.int( );
		var Ex_F = Reg.int( );
		var SxD_F = Reg.int( );
		var ExD_F = Reg.int( );
		if ( useFixed )
		{
			OpReg( Sx );
			OpFloat( bFloat( 256.0 ) );
			OpMul( );
			OpToInt( );
			OpSetReg( Sx_F );
			
			OpReg( Ex );
			OpFloat( bFloat( 256.0 ) );
			OpMul( );
			OpToInt( );
			OpSetReg( Ex_F );
			
			OpReg( SxD_F );
			OpFloat( bFloat( 256.0 ) );
			OpMul( );
			OpToInt( );
			OpSetReg( SxD_F );
			
			OpReg( ExD_F );
			OpFloat( bFloat( 256.0 ) );
			OpMul( );
			OpToInt( );
			OpSetReg( ExD_F );
		}
		
		
		OpJump( JAlways, scanPoly_while_jumpin );
		OpLabel( scanPoly_while );
			//scanline algo here
			//scanline( Sx, Ex, Sy );
			
			if ( useFixed )
				scan_call( Sx_F, Ex_F, Sy, v, delta_horiz, scan_pixel, zbuffer );
			else
				scan_call( Sx, Ex, Sy, v, delta_horiz, scan_pixel, zbuffer );
	
			//interpolate AC
			
			for ( fld in Reflect.fields( delta_AC ) )
			{
				OpReg( Reflect.field( delta_AC, fld ) );
				OpReg( Reflect.field( v, fld ) );
				OpAdd( );
				OpSetReg( Reflect.field( v, fld ) );
			}
			
			//Interpolated dx1/dx2			
			//replace with variable interpolation system
			if ( useFixed )
			{
				OpReg( Sx_F );
				OpReg( SxD_F );
				OpIAdd( );
				OpSetReg( Sx_F );
				
				OpReg( Ex_F );
				OpReg( ExD_F );
				OpIAdd( );
				OpSetReg( Ex_F );
			}
			else
			{
				OpReg( Sx );
				OpReg( SxD );
				OpAdd( );
				OpSetReg( Sx );
				
				OpReg( Ex );
				OpReg( ExD );
				OpAdd( );
				OpSetReg( Ex );				
			}
			
			//y++
			OpIncrReg( Sy );
			OpLabel( scanPoly_while_jumpin );
			OpReg( Sy );
			OpReg( y_end );
		OpJump( JLt, scanPoly_while );
	}
	
	public function findDelta_horizontal_opp( v0:Dynamic<Reg<Float>>, v1:Dynamic<Reg<Float>>, deltas:Dynamic, deltax:Reg<Float>, except:Array<String> )
	{
		var hdeltas:Dynamic = { };
		for ( fld in CReflect.fieldsExcept( v0, except ) )
		{
			Reflect.setField( hdeltas, fld, Reg.float() );
		}
		
		var ystep = Reg.float( );
		OpReg( v1.y );
		OpReg( v0.y );
		OpSub( );
		OpSetReg( ystep );
		
		for ( fld in CReflect.fieldsExcept( v0, except ) )
		{
			
			OpReg( Reflect.field( v1, fld ) );
			
			OpReg( ystep );
			OpReg( Reflect.field( deltas, fld ) );
			OpMul( );
			OpReg( Reflect.field( v0, fld ) );
			OpAdd( );			//v0.fld + deltas.fld*ystep
			
			OpSub( );				//v1.fld - res
			
			OpReg( v1.x );
			
			OpReg( ystep );
			OpReg( deltax );
			OpMul( );
			OpReg( v0.x );
			OpAdd( );			//v0.fld + deltas.fld*ystep
			
			OpSub( );			//v1.x - res
			
			OpDiv( );
			
			OpNeg( );
			
			OpSetReg( Reflect.field( hdeltas, fld ) );	
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
		OpReg( v1.y );
		OpReg( v0.y );
		OpSub( );
		OpSetReg( ystep );
		
		for ( fld in CReflect.fieldsExcept( v0, except ) )
		{
			
			OpReg( Reflect.field( v1, fld ) );
			
			OpReg( ystep );
			OpReg( Reflect.field( deltas, fld ) );
			OpMul( );
			OpReg( Reflect.field( v0, fld ) );
			OpAdd( );			//v0.fld + deltas.fld*ystep
			
			OpSub( );				//v1.fld - res
			
			OpReg( v1.x );
			
			OpReg( ystep );
			OpReg( deltax );
			OpMul( );
			OpReg( v0.x );
			OpAdd( );			//v0.fld + deltas.fld*ystep
			
			OpSub( );			//v1.x - res
			
			OpDiv( );
			
			OpSetReg( Reflect.field( hdeltas, fld ) );				
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
		OpFloat( bFloat( 1 ) );
		OpReg( v1.y );
		OpReg( v0.y );
		OpSub( );
		OpDiv( );		//{1/ABstep}
		
		for ( fld in CReflect.fieldsExcept( v0, except ) )
		{
			OpDup( );
			OpReg( Reflect.field( v1, fld ) );
			OpReg( Reflect.field( v0, fld ) );
			OpSub( );
			OpMul( );
			OpSetReg( Reflect.field( deltas, fld ) );
		}
		OpPop( );
		
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
		OpReg( v1.y );
		OpReg( v0.y );
		OpSub( );
		OpDup( );
		OpInt( 0 );
		OpIf( JGt );
			OpFloat( bFloat( 1 ) );
			OpSwap( );
			OpDiv( );		//{1/ABstep}
			
			for ( fld in CReflect.fieldsExcept( v0, ["y"] ) )
			{
				OpDup( );
				OpReg( Reflect.field( v1, fld ) );
				OpReg( Reflect.field( v0, fld ) );
				OpSub( );
				OpMul( );
				OpSetReg( Reflect.field( deltas, fld ) );
			}
			OpPop( );
		OpElse( );
			for ( fld in CReflect.fieldsExcept( v0, ["y"] ) )
			{
				OpFloat( bFloat( 0.0 ) );
				OpSetReg( Reflect.field( deltas, fld ) );
			}
			OpPop( );
		OpFi( );
		
		return deltas;	
	}
	
	public function offsetAddressSmall( o:Int, ?dupe:Bool = false )
	{
		if ( dupe ) OpDup( );
		OpInt( o );
		OpIAdd( );
	}

	public function sort_vertices( v0:Dynamic<Reg<Dynamic>>, v1:Dynamic<Reg<Dynamic>>, v2:Dynamic<Reg<Dynamic>> )
	{
		
		//test_and_swap( v0_data, v1_data );
		//test_and_swap( v0_data, v2_data );
		//test_and_swap( v1_data, v2_data );
		
		//if v0.y > v1.y
		OpReg( v0.y );
		OpReg( v1.y );
		OpIf( JGt );
			swapEach( v0, v1 );
	
		OpFi( );
		
		//if v0.y > v2.y
		OpReg( v0.y );
		OpReg( v2.y );
		OpIf( JGt );
			swapEach( v0, v2 );
		OpFi( );
		
		//if v1.y > v2.y
		OpReg( v1.y );
		OpReg( v2.y );
		OpIf( JGt );
			swapEach( v1, v2 );
		OpFi( );
	
	}
	
	public function plotPoint( x:Reg<Float>, y:Reg<Float>, color:Int, frameBuffer:Int, screenWidth:Int )
	{
		//find pixel address
		OpReg( y );
		OpToInt( );
		OpIntRef( bInt32( cast screenWidth ) );
		OpIMul( );
		OpReg( x );
		OpToInt( );
		OpIAdd( );
		OpInt( 2 );
		OpShl( );								//(y*width+x) >> (FIXED_SHIFT-2)
		OpIntRef( bInt32( cast frameBuffer ) );
		OpIAdd( );
	
		OpIntRef( bInt32( cast color ) );
		OpSwap( );
		OpMemSet32( );	
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
			OpReg( a );
			OpReg( b );
			OpSetReg( a );
			OpSetReg( b );	
	}
	
	public function read_vertices_map( map:VertexMapper2 )
	{
		var poly:Dynamic = { };
		poly.v0 = read_vertex_map( map );
			OpInt( map.vertex_size_bytes );
			OpIAdd( );
		poly.v1 = read_vertex_map( map );
			OpInt( map.vertex_size_bytes );
			OpIAdd( );
		poly.v2 = read_vertex_map( map );
			OpInt( map.vertex_size_bytes );
			OpIAdd( );
		
		return poly;
	}
	
	public function read_vertices( )
	{
		var poly:Dynamic = { };
		poly.v0 = read_vertex( );
			OpInt( 12 );
			OpIAdd( );
		poly.v1 = read_vertex( );
			OpInt( 12 );
			OpIAdd( );
		poly.v2 = read_vertex( );
			OpInt( 12 );
			OpIAdd( );
		
		return poly;
	}
	
	public function read_vertex_map( map:VertexMapper2 )
	{
		var regs = map.genByteCode( _app );
		
		return regs;		
	}
			
			
	public function read_vertex_xyzuv( ?v:Reg<Int> )
	{
		var regs:Dynamic = { }
		
		
		if (v == null) OpDup( ); else OpReg(v);
		
		OpMemGetFloat( );
		OpToInt( );
		OpToNumber( );
		OpSetReg( regs.x = Reg.float() );
		
		OpDup( );
		OpInt( 4 );
		OpIAdd( );
		OpMemGetFloat( );
		OpToInt( );
		OpToNumber( );
		OpSetReg( regs.y = Reg.float() );
		
		OpDup( );
		OpInt( 8 );
		OpIAdd( );
		OpMemGetFloat( );
		OpToInt( );
		OpToNumber( );
		OpSetReg( regs.z = Reg.float() );	
		
		OpDup( );
		OpInt( 12 );
		OpIAdd( );
		OpMemGetFloat( );
		OpToInt( );
		OpToNumber( );
		OpSetReg( regs.u = Reg.float() );
		
		OpDup( );
		OpInt( 16 );
		OpIAdd( );
		OpMemGetFloat( );
		OpToInt( );
		OpToNumber( );
		OpSetReg( regs.v = Reg.float() );
		
		return regs;
	}
	
	public function read_vertex( ?v:Reg<Int> ):Dynamic<Reg<Dynamic>>
	{
		var vdata:Dynamic = { }
		
		if (v == null) OpDup( ); else OpReg(v);
		
		//x
		OpMemGetFloat( );
		OpToInt( );
		OpToNumber( );
		OpSetReg( vdata.x = Reg.float() );
		
		//y
		OpDup( );
		OpInt( 4 );
		OpIAdd( );
		OpMemGetFloat( );
		OpToInt( );
		OpToNumber( );
		OpSetReg( vdata.y = Reg.float() );
		
		//z
		OpDup( );
		OpInt( 8 );
		OpIAdd( );
		OpMemGetFloat( );
		OpToInt( );
		OpToNumber( );
		OpSetReg( vdata.z = Reg.float() );
		
		return vdata;
	}
}

typedef ScanlineCall = Reg<Dynamic>->Reg<Dynamic>->Reg<Float>->Dynamic<Reg<Float>>->Dynamic<Reg<Float>>->ScanpixelCall->RasterMem->Void;

typedef ScanpixelCall = Dynamic<Reg<Float>>->Void;