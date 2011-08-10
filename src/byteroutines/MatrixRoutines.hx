/**
 * ...
 * @author Matthew Spencer
 */

package byteroutines;
import com.abc.Reg;
import com.codex.c3dex.bcode.app.ByteApplication;
import com.codex.c3dex.bcode.BVAR;
import com.codex.c3dex.bcode.routines.ByteRoutine;
import com.codex.c3dex.memory.MemoryDispatcher;

class MatrixRoutines extends ByteRoutine
{

	public function new( app:ByteApplication ) 
	{
		super( app );
	}
	
	public function loadVector( addr:BVAR<Int> ):_Vector
	{
		var v:_Vector = cast { };
		var m = new MemoryRoutines( _app );
		
		addr.get( );
		m.readFloat( bv.stack, null, bv.reg( v.x = Reg.float( ) ) );
		m.readFloat( bv.stack, bv.int( 4 ), bv.reg( v.y = Reg.float( ) ) );
		m.readFloat( bv.stackEat, bv.int( 8 ), bv.reg( v.z = Reg.float( ) ) );
	
		return v;
	}
	
	//confirmed working
	public function loadMatrix( addr:BVAR<Int> ):_MatrixFloat
	{
		var m = new MemoryRoutines( _app );
		var o = new _MatrixOffsetRow( );
		var r:_MatrixFloat = cast { };
		
		addr.get( );		
		m.readFloat( bv.stack.int(), bv.int( o.m11 ), bv.reg( r.n11 = Reg.float( ) ) );
		m.readFloat( bv.stack.int(), bv.int( o.m12 ), bv.reg( r.n12 = Reg.float( ) ) );
		m.readFloat( bv.stack.int(), bv.int( o.m13 ), bv.reg( r.n13 = Reg.float( ) ) );
		m.readFloat( bv.stack.int(), bv.int( o.m14 ), bv.reg( r.n14 = Reg.float( ) ) );
		
		m.readFloat( bv.stack.int(), bv.int( o.m21 ), bv.reg( r.n21 = Reg.float( ) ) );
		m.readFloat( bv.stack.int(), bv.int( o.m22 ), bv.reg( r.n22 = Reg.float( ) ) );
		m.readFloat( bv.stack.int(), bv.int( o.m23 ), bv.reg( r.n23 = Reg.float( ) ) );
		m.readFloat( bv.stack.int(), bv.int( o.m24 ), bv.reg( r.n24 = Reg.float( ) ) );
		
		m.readFloat( bv.stack.int(), bv.int( o.m31 ), bv.reg( r.n31 = Reg.float( ) ) );
		m.readFloat( bv.stack.int(), bv.int( o.m32 ), bv.reg( r.n32 = Reg.float( ) ) );
		m.readFloat( bv.stack.int(), bv.int( o.m33 ), bv.reg( r.n33 = Reg.float( ) ) );
		m.readFloat( bv.stack.int(), bv.int( o.m34 ), bv.reg( r.n34 = Reg.float( ) ) );
		
		m.readFloat( bv.stack.int(), bv.int( o.m41 ), bv.reg( r.n41 = Reg.float( ) ) );
		m.readFloat( bv.stack.int(), bv.int( o.m42 ), bv.reg( r.n42 = Reg.float( ) ) );
		m.readFloat( bv.stack.int(), bv.int( o.m43 ), bv.reg( r.n43 = Reg.float( ) ) );
		m.readFloat( bv.stackEat.int(), bv.int( o.m44 ), bv.reg( r.n44 = Reg.float( ) ) );
		
		return r;
	}
	
	public function copyMatrix( from:_MatrixFloat, to:_MatrixFloat )
	{
		OpReg( from.n11 ); OpSetReg( to.n11 );
		OpReg( from.n12 ); OpSetReg( to.n12 );
		OpReg( from.n13 ); OpSetReg( to.n13 );
		OpReg( from.n14 ); OpSetReg( to.n14 );
		
		OpReg( from.n21 ); OpSetReg( to.n21 );
		OpReg( from.n22 ); OpSetReg( to.n22 );
		OpReg( from.n23 ); OpSetReg( to.n23 );
		OpReg( from.n24 ); OpSetReg( to.n24 );
		
		OpReg( from.n31 ); OpSetReg( to.n31 );
		OpReg( from.n32 ); OpSetReg( to.n32 );
		OpReg( from.n33 ); OpSetReg( to.n33 );
		OpReg( from.n34 ); OpSetReg( to.n34 );
		
		OpReg( from.n41 ); OpSetReg( to.n41 );
		OpReg( from.n42 ); OpSetReg( to.n42 );
		OpReg( from.n43 ); OpSetReg( to.n43 );
		OpReg( from.n44 ); OpSetReg( to.n44 );
	}
	
	//confirmed working
	public function concatMatrix( a:_MatrixFloat, b:_MatrixFloat )
	{
		var r:_MatrixFloat = cast { };
		
		//Row 1
		{//find n11
		OpReg( a.n11 );		OpReg( b.n11 );		OpMul( );
		OpReg( a.n12 );		OpReg( b.n21 );		OpMul( );		OpAdd( );
		OpReg( a.n13 );		OpReg( b.n31 );		OpMul( );		OpAdd( );
		OpReg( a.n14 );		OpReg( b.n41 );		OpMul( );		OpAdd( );	OpSetReg( r.n11 = Reg.float( ) );
		
		//find n12
		OpReg( a.n11 );		OpReg( b.n12 );		OpMul( );
		OpReg( a.n12 );		OpReg( b.n22 );		OpMul( );		OpAdd( );
		OpReg( a.n13 );		OpReg( b.n32 );		OpMul( );		OpAdd( );
		OpReg( a.n14 );		OpReg( b.n42 );		OpMul( );		OpAdd( );	OpSetReg( r.n12 = Reg.float( ) );
		
		//find n13
		OpReg( a.n11 );		OpReg( b.n13 );		OpMul( );
		OpReg( a.n12 );		OpReg( b.n23 );		OpMul( );		OpAdd( );
		OpReg( a.n13 );		OpReg( b.n33 );		OpMul( );		OpAdd( );
		OpReg( a.n14 );		OpReg( b.n43 );		OpMul( );		OpAdd( );	OpSetReg( r.n13 = Reg.float( ) );
		
		//find n14
		OpReg( a.n11 );		OpReg( b.n14 );		OpMul( );
		OpReg( a.n12 );		OpReg( b.n24 );		OpMul( );		OpAdd( );
		OpReg( a.n13 );		OpReg( b.n34 );		OpMul( );		OpAdd( );
		OpReg( a.n14 );		OpReg( b.n44 );		OpMul( );		OpAdd( );	OpSetReg( r.n14 = Reg.float( ) );}
		
		
		//Row 2
		{//find n21
		OpReg( a.n21 );		OpReg( b.n11 );		OpMul( );
		OpReg( a.n22 );		OpReg( b.n21 );		OpMul( );		OpAdd( );
		OpReg( a.n23 );		OpReg( b.n31 );		OpMul( );		OpAdd( );
		OpReg( a.n24 );		OpReg( b.n41 );		OpMul( );		OpAdd( );	OpSetReg( r.n21 = Reg.float( ) );
		
		//find n222
		OpReg( a.n21 );		OpReg( b.n12 );		OpMul( );
		OpReg( a.n22 );		OpReg( b.n22 );		OpMul( );		OpAdd( );
		OpReg( a.n23 );		OpReg( b.n32 );		OpMul( );		OpAdd( );
		OpReg( a.n24 );		OpReg( b.n42 );		OpMul( );		OpAdd( );	OpSetReg( r.n22 = Reg.float( ) );
		
		//find n23
		OpReg( a.n21 );		OpReg( b.n13 );		OpMul( );
		OpReg( a.n22 );		OpReg( b.n23 );		OpMul( );		OpAdd( );
		OpReg( a.n23 );		OpReg( b.n33 );		OpMul( );		OpAdd( );
		OpReg( a.n24 );		OpReg( b.n43 );		OpMul( );		OpAdd( );	OpSetReg( r.n23 = Reg.float( ) );
		
		//find n24
		OpReg( a.n21 );		OpReg( b.n14 );		OpMul( );
		OpReg( a.n22 );		OpReg( b.n24 );		OpMul( );		OpAdd( );
		OpReg( a.n23 );		OpReg( b.n34 );		OpMul( );		OpAdd( );
		OpReg( a.n24 );		OpReg( b.n44 );		OpMul( );		OpAdd( );	OpSetReg( r.n24 = Reg.float( ) );}
		
		//Row 3
		{//find n31
		OpReg( a.n31 );		OpReg( b.n11 );		OpMul( );
		OpReg( a.n32 );		OpReg( b.n21 );		OpMul( );		OpAdd( );
		OpReg( a.n33 );		OpReg( b.n31 );		OpMul( );		OpAdd( );
		OpReg( a.n34 );		OpReg( b.n41 );		OpMul( );		OpAdd( );	OpSetReg( r.n31 = Reg.float( ) );
		
		//find n32
		OpReg( a.n31 );		OpReg( b.n12 );		OpMul( );
		OpReg( a.n32 );		OpReg( b.n22 );		OpMul( );		OpAdd( );
		OpReg( a.n33 );		OpReg( b.n32 );		OpMul( );		OpAdd( );
		OpReg( a.n34 );		OpReg( b.n42 );		OpMul( );		OpAdd( );	OpSetReg( r.n32 = Reg.float( ) );
		
		//find n33
		OpReg( a.n31 );		OpReg( b.n13 );		OpMul( );
		OpReg( a.n32 );		OpReg( b.n23 );		OpMul( );		OpAdd( );
		OpReg( a.n33 );		OpReg( b.n33 );		OpMul( );		OpAdd( );
		OpReg( a.n34 );		OpReg( b.n43 );		OpMul( );		OpAdd( );	OpSetReg( r.n33 = Reg.float( ) );
		
		//find n34
		OpReg( a.n31 );		OpReg( b.n14 );		OpMul( );
		OpReg( a.n32 );		OpReg( b.n24 );		OpMul( );		OpAdd( );
		OpReg( a.n33 );		OpReg( b.n34 );		OpMul( );		OpAdd( );
		OpReg( a.n34 );		OpReg( b.n44 );		OpMul( );		OpAdd( );	OpSetReg( r.n34 = Reg.float( ) );}
		
		//Row 4
		{//find n41
		OpReg( a.n41 );		OpReg( b.n11 );		OpMul( );
		OpReg( a.n42 );		OpReg( b.n21 );		OpMul( );		OpAdd( );
		OpReg( a.n43 );		OpReg( b.n31 );		OpMul( );		OpAdd( );
		OpReg( a.n44 );		OpReg( b.n41 );		OpMul( );		OpAdd( );	OpSetReg( r.n41 = Reg.float( ) );
		
		//find n42
		OpReg( a.n41 );		OpReg( b.n12 );		OpMul( );
		OpReg( a.n42 );		OpReg( b.n22 );		OpMul( );		OpAdd( );
		OpReg( a.n43 );		OpReg( b.n32 );		OpMul( );		OpAdd( );
		OpReg( a.n44 );		OpReg( b.n42 );		OpMul( );		OpAdd( );	OpSetReg( r.n42 = Reg.float( ) );
		
		//find n43
		OpReg( a.n41 );		OpReg( b.n13 );		OpMul( );
		OpReg( a.n42 );		OpReg( b.n23 );		OpMul( );		OpAdd( );
		OpReg( a.n43 );		OpReg( b.n33 );		OpMul( );		OpAdd( );
		OpReg( a.n44 );		OpReg( b.n43 );		OpMul( );		OpAdd( );	OpSetReg( r.n43 = Reg.float( ) );
		
		//find n44
		OpReg( a.n41 );		OpReg( b.n14 );		OpMul( );
		OpReg( a.n42 );		OpReg( b.n24 );		OpMul( );		OpAdd( );
		OpReg( a.n43 );		OpReg( b.n34 );		OpMul( );		OpAdd( );
		OpReg( a.n44 );		OpReg( b.n44 );		OpMul( );		OpAdd( );	OpSetReg( r.n44 = Reg.float( ) );}
			
		return r;
	}
	
	public function concatVector( v:_Vector, m:_MatrixFloat ):_Vector
	{
		var o:_Vector = cast { };
		
		OpReg( v.x );		OpReg( m.n11 );		OpMul( );
		OpReg( v.y );		OpReg( m.n21 );		OpMul( );		OpAdd( );
		OpReg( v.z );		OpReg( m.n31 );		OpMul( );		OpAdd( );
		OpReg( m.n41 );		OpAdd( );	OpSetReg( o.x = Reg.float( ) );
		
		//find n42
		OpReg( v.x );		OpReg( m.n12 );		OpMul( );
		OpReg( v.y );		OpReg( m.n22 );		OpMul( );		OpAdd( );
		OpReg( v.z );		OpReg( m.n32 );		OpMul( );		OpAdd( );
		OpReg( m.n42 );		OpAdd( );	OpSetReg( o.y = Reg.float( ) );
		
		//find n43
		OpReg( v.x );		OpReg( m.n13 );		OpMul( );
		OpReg( v.y );		OpReg( m.n23 );		OpMul( );		OpAdd( );
		OpReg( v.z );		OpReg( m.n33 );		OpMul( );		OpAdd( );
		OpReg( m.n43 );		OpAdd( );	OpSetReg( o.z = Reg.float( ) );
		
		return o;
	}
	
	public function concatVectorPerspective( v:_Vector, m:_MatrixFloat, width:Int, height:Int ):_Vector
	{
		var o:_Vector = cast { };
		
		OpFloat( bFloat( 1.0 ) );
		//find w
		OpReg( v.x );		OpReg( m.n14 );		OpMul( );
		OpReg( v.y );		OpReg( m.n24 );		OpMul( );		OpAdd( );
		OpReg( v.z );		OpReg( m.n34 );		OpMul( );		OpAdd( );
		OpReg( m.n44 );		OpAdd( ); 		OpDiv( ); 		//find 1/w
		
		OpDup( );
		OpDup( );
		//find x
		OpReg( v.x );		OpReg( m.n11 );		OpMul( );
		OpReg( v.y );		OpReg( m.n21 );		OpMul( );		OpAdd( );
		OpReg( v.z );		OpReg( m.n31 );		OpMul( );		OpAdd( );
		OpReg( m.n41 );		OpAdd( );	
		OpMul( );			//x/w
		OpFloat( bFloat( width * .5 ) );
		OpMul( );
		OpFloat( bFloat( width * .5) );
		OpAdd( );
		OpSetReg( o.x = Reg.float( ) );
		
		//find y
		OpReg( v.x );		OpReg( m.n12 );		OpMul( );
		OpReg( v.y );		OpReg( m.n22 );		OpMul( );		OpAdd( );
		OpReg( v.z );		OpReg( m.n32 );		OpMul( );		OpAdd( );
		OpReg( m.n42 );		OpAdd( );	
		OpMul( );			//x/w
		OpFloat( bFloat( height * .5 ) );
		OpMul( );
		OpFloat( bFloat( height * .5) );
		OpAdd( );
		OpSetReg( o.y = Reg.float( ) );
		
		//find z
		OpReg( v.x );		OpReg( m.n13 );		OpMul( );
		OpReg( v.y );		OpReg( m.n23 );		OpMul( );		OpAdd( );
		OpReg( v.z );		OpReg( m.n33 );		OpMul( );		OpAdd( );
		OpReg( m.n43 );		OpAdd( );	
		OpMul( );			//x/w
		//OpFloat( bFloat( 1.0 ) );
		//OpSwap( );
		//OpDiv( );
		OpSetReg( o.z = Reg.float( ) );
		
		return o;
	}
	
	public static function arrayToMem( m:RasterMem, data:Array<Float> )
	{
		if ( data.length != 16 )	throw( "Non 16 matrix data not supported" );
		
		for ( g in 0...16 )
		{
			m.setFloat( g * 4, data[g] );
		}
	}
	
	public function writeMatrixToMemory( addr:BVAR<Int>, m:_MatrixFloat )
	{
		addr.get( );
		
		OpDup( ); OpReg( m.n11 ); OpSwap( ); OpMemSetFloat( );
		OpDup( ); OpReg( m.n12 ); OpSwap( ); OpMemSetFloat( );
		OpDup( ); OpReg( m.n13 ); OpSwap( ); OpMemSetFloat( );
		OpDup( ); OpReg( m.n14 ); OpSwap( ); OpMemSetFloat( );
		
		OpDup( ); OpReg( m.n21 ); OpSwap( ); OpMemSetFloat( );
		OpDup( ); OpReg( m.n22 ); OpSwap( ); OpMemSetFloat( );
		OpDup( ); OpReg( m.n23 ); OpSwap( ); OpMemSetFloat( );
		OpDup( ); OpReg( m.n24 ); OpSwap( ); OpMemSetFloat( );
		
		OpDup( ); OpReg( m.n31 ); OpSwap( ); OpMemSetFloat( );
		OpDup( ); OpReg( m.n32 ); OpSwap( ); OpMemSetFloat( );
		OpDup( ); OpReg( m.n33 ); OpSwap( ); OpMemSetFloat( );
		OpDup( ); OpReg( m.n34 ); OpSwap( ); OpMemSetFloat( );
		
		OpDup( ); OpReg( m.n41 ); OpSwap( ); OpMemSetFloat( );
		OpDup( ); OpReg( m.n42 ); OpSwap( ); OpMemSetFloat( );
		OpDup( ); OpReg( m.n43 ); OpSwap( ); OpMemSetFloat( );
				  OpReg( m.n44 ); OpSwap( ); OpMemSetFloat( );
		
	}
	
	public function loadIdentity( )
	{
		var r:_MatrixFloat = cast { };
		
		OpFloat( bFloat( 1.0 ) );	OpSetReg( r.n11 = Reg.float( ) );
		OpFloat( bFloat( 0.0 ) );	OpSetReg( r.n12 = Reg.float( ) );
		OpFloat( bFloat( 0.0 ) );	OpSetReg( r.n13 = Reg.float( ) );
		OpFloat( bFloat( 0.0 ) );	OpSetReg( r.n14 = Reg.float( ) );
		
		OpFloat( bFloat( 0.0 ) );	OpSetReg( r.n21 = Reg.float( ) );
		OpFloat( bFloat( 1.0 ) );	OpSetReg( r.n22 = Reg.float( ) );
		OpFloat( bFloat( 0.0 ) );	OpSetReg( r.n23 = Reg.float( ) );
		OpFloat( bFloat( 0.0 ) );	OpSetReg( r.n24 = Reg.float( ) );
		
		OpFloat( bFloat( 0.0 ) );	OpSetReg( r.n31 = Reg.float( ) );
		OpFloat( bFloat( 0.0 ) );	OpSetReg( r.n32 = Reg.float( ) );
		OpFloat( bFloat( 1.0 ) );	OpSetReg( r.n33 = Reg.float( ) );
		OpFloat( bFloat( 0.0 ) );	OpSetReg( r.n34 = Reg.float( ) );
		
		OpFloat( bFloat( 0.0 ) );	OpSetReg( r.n41 = Reg.float( ) );
		OpFloat( bFloat( 0.0 ) );	OpSetReg( r.n42 = Reg.float( ) );
		OpFloat( bFloat( 0.0 ) );	OpSetReg( r.n43 = Reg.float( ) );
		OpFloat( bFloat( 1.0 ) );	OpSetReg( r.n44 = Reg.float( ) );
		
		return r;
	}
	
}

class _MatrixOffsetRow extends _MatrixOffset
{
	public function new( )
	{
		super( );
		m11 = 0;	m12 = 4;	m13 = 8;	m14 = 12;
		m21 = 16;	m22 = 20;	m23 = 24;	m24 = 28;
		m31 = 32;	m32 = 36;	m33 = 40;	m34 = 44;
		m41 = 48;	m42 = 52;	m43 = 56;	m44 = 60;
	}
	
}

class _MatrixOffset
{
	public var m11:Int; public var m12:Int; public var m13:Int; public var m14:Int; 
	public var m21:Int; public var m22:Int; public var m23:Int; public var m24:Int; 
	public var m31:Int; public var m32:Int; public var m33:Int; public var m34:Int; 
	public var m41:Int; public var m42:Int; public var m43:Int; public var m44:Int; 
	
	public function new( ){}
}


//  [row][column]
typedef _MatrixFloat = 
{
	var n11:Reg<Float>; var n12:Reg<Float>; var n13:Reg<Float>; var n14:Reg<Float>;
	var n21:Reg<Float>; var n22:Reg<Float>; var n23:Reg<Float>; var n24:Reg<Float>;
	var n31:Reg<Float>; var n32:Reg<Float>; var n33:Reg<Float>; var n34:Reg<Float>;
	var n41:Reg<Float>; var n42:Reg<Float>; var n43:Reg<Float>; var n44:Reg<Float>;	
}

typedef _Vector = 
{
	var x:Reg<Float>; var y:Reg<Float>; var z:Reg<Float>;
}