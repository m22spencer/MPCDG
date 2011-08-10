/**
 * ...
 * @author Matthew Spencer
 */

package com;
import flash.Memory;
//import engine.Memory.Memory;
//import engine.EngineMemory.MEM_ADDRESS;

private typedef MEM_ADDRESS = Int;

class Matrix4mem
{

	public var addr:Int;
	
	public function new( addr:Int, ?vals:Array<Float>  ) 
	{
		this.addr = addr;
		if ( vals != null )
			fromArray( vals );
	}
	
	public function get( pos:Int ):Float
	{
		
		return Memory.getFloat( addr + (pos << 2) );
	}
	
	public function set( pos:Int, val:Float ):Void
	{
		
		Memory.setFloat( addr + (pos << 2), val );
	}
	
	public function fromArray( values:Array<Float> )
	{
		
		var itr_addr:MEM_ADDRESS = addr;
		
		for ( i in 0...16 )
		{
			Memory.setFloat( itr_addr, values[i] );			
			itr_addr += 4;
		}
		
	}
	
	public function toArray( )
	{
		var itr_addr:MEM_ADDRESS = addr;
		var values:Array<Float> = new Array( );
		
		for ( i in 0...16 )
		{
			values.push( Memory.getFloat( itr_addr ) );			
			itr_addr += 4;
		}
		return values;
	}
	
	//Memory offsets
	public static inline var n11:Int = 0;
	public static inline var n12:Int = 4;
	public static inline var n13:Int = 8;
	public static inline var n14:Int = 12;
	
	public static inline var n21:Int = 16;
	public static inline var n22:Int = 20;
	public static inline var n23:Int = 24;
	public static inline var n24:Int = 28;
	
	public static inline var n31:Int = 32;
	public static inline var n32:Int = 36;
	public static inline var n33:Int = 40;
	public static inline var n34:Int = 44;
	
	public static inline var n41:Int = 48;
	public static inline var n42:Int = 52;
	public static inline var n43:Int = 56;
	public static inline var n44:Int = 60;
	
	//No mediator variables, requires three unique matrices.
	public static inline function concat_unique( matrix1:Matrix4mem, matrix2:Matrix4mem, result:Matrix4mem )
	{
		
		var m1_addr:MEM_ADDRESS = matrix1.addr;
		var m2_addr:MEM_ADDRESS = matrix2.addr;
		
		var res_addr:MEM_ADDRESS = result.addr;
		
		//r11 = m11*c11 + m12*c21 + m13*c31 + m14*c41
		Memory.setFloat( res_addr, 
			Memory.getFloat(m1_addr) * Memory.getFloat(m2_addr) + 
			Memory.getFloat(m1_addr+n12) * Memory.getFloat(m2_addr+n21) + 
			Memory.getFloat(m1_addr+n13) * Memory.getFloat(m2_addr+n31) + 
			Memory.getFloat(m1_addr + n14) * Memory.getFloat(m2_addr + n41) );
		//r12 = m11*c12 + m12*c22 + m13*c32 + m14*c42
		Memory.setFloat( res_addr+n12, 
			Memory.getFloat(m1_addr) * Memory.getFloat(m2_addr+n12) + 
			Memory.getFloat(m1_addr+n12) * Memory.getFloat(m2_addr+n22) + 
			Memory.getFloat(m1_addr+n13) * Memory.getFloat(m2_addr+n32) + 
			Memory.getFloat(m1_addr+n14) * Memory.getFloat(m2_addr+n42) );
		//r13 = m11*c13 + m12*c23 + m13*c33 + m14*c43
		Memory.setFloat( res_addr+n13, 
			Memory.getFloat(m1_addr) * Memory.getFloat(m2_addr+n13) + 
			Memory.getFloat(m1_addr+n12) * Memory.getFloat(m2_addr+n23) + 
			Memory.getFloat(m1_addr+n13) * Memory.getFloat(m2_addr+n33) + 
			Memory.getFloat(m1_addr+n14) * Memory.getFloat(m2_addr+n43) );
		//r14 = m11*c14 + m12*c24 + m13*c34 + m14*c44
		Memory.setFloat( res_addr+n14, 
			Memory.getFloat(m1_addr) * Memory.getFloat(m2_addr+n14) + 
			Memory.getFloat(m1_addr+n12) * Memory.getFloat(m2_addr+n24) + 
			Memory.getFloat(m1_addr+n13) * Memory.getFloat(m2_addr+n34) + 
			Memory.getFloat(m1_addr + n14) * Memory.getFloat(m2_addr + n44) );
			
			
		//r21 = m21*c11 + m22*c21 + m23*c31 + m24*c41
		Memory.setFloat( res_addr+n21, 
			Memory.getFloat(m1_addr+n21) * Memory.getFloat(m2_addr) + 
			Memory.getFloat(m1_addr+n22) * Memory.getFloat(m2_addr+n21) + 
			Memory.getFloat(m1_addr+n23) * Memory.getFloat(m2_addr+n31) + 
			Memory.getFloat(m1_addr+n24) * Memory.getFloat(m2_addr+n41) );
		//r22 = m11*c12 + m12*c22 + m13*c32 + m14*c42
		Memory.setFloat( res_addr+n22, 
			Memory.getFloat(m1_addr+n21) * Memory.getFloat(m2_addr+n12) + 
			Memory.getFloat(m1_addr+n22) * Memory.getFloat(m2_addr+n22) + 
			Memory.getFloat(m1_addr+n23) * Memory.getFloat(m2_addr+n32) + 
			Memory.getFloat(m1_addr+n24) * Memory.getFloat(m2_addr+n42) );
		//r23 = m11*c13 + m12*c23 + m13*c33 + m14*c43
		Memory.setFloat( res_addr+n23, 
			Memory.getFloat(m1_addr+n21) * Memory.getFloat(m2_addr+n13) + 
			Memory.getFloat(m1_addr+n22) * Memory.getFloat(m2_addr+n23) + 
			Memory.getFloat(m1_addr+n23) * Memory.getFloat(m2_addr+n33) + 
			Memory.getFloat(m1_addr+n24) * Memory.getFloat(m2_addr+n43) );
		//r24 = m11*c14 + m12*c24 + m13*c34 + m14*c44
		Memory.setFloat( res_addr+n24, 
			Memory.getFloat(m1_addr+n21) * Memory.getFloat(m2_addr+n14) + 
			Memory.getFloat(m1_addr+n22) * Memory.getFloat(m2_addr+n24) + 
			Memory.getFloat(m1_addr+n23) * Memory.getFloat(m2_addr+n34) + 
			Memory.getFloat(m1_addr+n24) * Memory.getFloat(m2_addr+n44) );
	
		//r21 = m21*c11 + m22*c21 + m23*c31 + m24*c41
		Memory.setFloat( res_addr+n31, 
			Memory.getFloat(m1_addr+n31) * Memory.getFloat(m2_addr) + 
			Memory.getFloat(m1_addr+n32) * Memory.getFloat(m2_addr+n21) + 
			Memory.getFloat(m1_addr+n33) * Memory.getFloat(m2_addr+n31) + 
			Memory.getFloat(m1_addr+n34) * Memory.getFloat(m2_addr+n41) );
		//r22 = m11*c12 + m12*c22 + m13*c32 + m14*c42
		Memory.setFloat( res_addr+n32, 
			Memory.getFloat(m1_addr+n31) * Memory.getFloat(m2_addr+n12) + 
			Memory.getFloat(m1_addr+n32) * Memory.getFloat(m2_addr+n22) + 
			Memory.getFloat(m1_addr+n33) * Memory.getFloat(m2_addr+n32) + 
			Memory.getFloat(m1_addr+n34) * Memory.getFloat(m2_addr+n42) );
		//r23 = m11*c13 + m12*c23 + m13*c33 + m14*c43
		Memory.setFloat( res_addr+n33, 
			Memory.getFloat(m1_addr+n31) * Memory.getFloat(m2_addr+n13) + 
			Memory.getFloat(m1_addr+n32) * Memory.getFloat(m2_addr+n23) + 
			Memory.getFloat(m1_addr+n33) * Memory.getFloat(m2_addr+n33) + 
			Memory.getFloat(m1_addr+n34) * Memory.getFloat(m2_addr+n43) );
		//r24 = m11*c14 + m12*c24 + m13*c34 + m14*c44
		Memory.setFloat( res_addr+n34, 
			Memory.getFloat(m1_addr+n31) * Memory.getFloat(m2_addr+n14) + 
			Memory.getFloat(m1_addr+n32) * Memory.getFloat(m2_addr+n24) + 
			Memory.getFloat(m1_addr+n33) * Memory.getFloat(m2_addr+n34) + 
			Memory.getFloat(m1_addr+n34) * Memory.getFloat(m2_addr+n44) );
			
		//r21 = m21*c11 + m22*c21 + m23*c31 + m24*c41
		Memory.setFloat( res_addr+n41, 
			Memory.getFloat(m1_addr+n41) * Memory.getFloat(m2_addr) + 
			Memory.getFloat(m1_addr+n42) * Memory.getFloat(m2_addr+n21) + 
			Memory.getFloat(m1_addr+n43) * Memory.getFloat(m2_addr+n31) + 
			Memory.getFloat(m1_addr+n44) * Memory.getFloat(m2_addr+n41) );
		//r22 = m11*c12 + m12*c22 + m13*c32 + m14*c42
		Memory.setFloat( res_addr+n42, 
			Memory.getFloat(m1_addr+n41) * Memory.getFloat(m2_addr+n12) + 
			Memory.getFloat(m1_addr+n42) * Memory.getFloat(m2_addr+n22) + 
			Memory.getFloat(m1_addr+n43) * Memory.getFloat(m2_addr+n32) + 
			Memory.getFloat(m1_addr+n44) * Memory.getFloat(m2_addr+n42) );
		//r23 = m11*c13 + m12*c23 + m13*c33 + m14*c43
		Memory.setFloat( res_addr+n43, 
			Memory.getFloat(m1_addr+n41) * Memory.getFloat(m2_addr+n13) + 
			Memory.getFloat(m1_addr+n42) * Memory.getFloat(m2_addr+n23) + 
			Memory.getFloat(m1_addr+n43) * Memory.getFloat(m2_addr+n33) + 
			Memory.getFloat(m1_addr+n44) * Memory.getFloat(m2_addr+n43) );
		//r24 = m11*c14 + m12*c24 + m13*c34 + m14*c44
		Memory.setFloat( res_addr+n44, 
			Memory.getFloat(m1_addr+n41) * Memory.getFloat(m2_addr+n14) + 
			Memory.getFloat(m1_addr+n42) * Memory.getFloat(m2_addr+n24) + 
			Memory.getFloat(m1_addr+n43) * Memory.getFloat(m2_addr+n34) + 
			Memory.getFloat(m1_addr+n44) * Memory.getFloat(m2_addr+n44) );
			
	}
	
//No mediator variables, requires three unique matrices.
	public static inline function concat( matrix1:Matrix4mem, matrix2:Matrix4mem, result:Matrix4mem )
	{
		
		var m1_addr:MEM_ADDRESS = matrix1.addr;
		var m2_addr:MEM_ADDRESS = matrix2.addr;
		
		var res_addr:MEM_ADDRESS = result.addr;
		
		//r11 = m11*c11 + m12*c21 + m13*c31 + m14*c41
		var m11:Float =  
			Memory.getFloat(m1_addr) * Memory.getFloat(m2_addr) + 
			Memory.getFloat(m1_addr+n12) * Memory.getFloat(m2_addr+n21) + 
			Memory.getFloat(m1_addr+n13) * Memory.getFloat(m2_addr+n31) + 
			Memory.getFloat(m1_addr + n14) * Memory.getFloat(m2_addr + n41);
		//r12 = m11*c12 + m12*c22 + m13*c32 + m14*c42
		var m12:Float =  
			Memory.getFloat(m1_addr) * Memory.getFloat(m2_addr+n12) + 
			Memory.getFloat(m1_addr+n12) * Memory.getFloat(m2_addr+n22) + 
			Memory.getFloat(m1_addr+n13) * Memory.getFloat(m2_addr+n32) + 
			Memory.getFloat(m1_addr+n14) * Memory.getFloat(m2_addr+n42) ;
		//r13 = m11*c13 + m12*c23 + m13*c33 + m14*c43
		var m13:Float =  
			Memory.getFloat(m1_addr) * Memory.getFloat(m2_addr+n13) + 
			Memory.getFloat(m1_addr+n12) * Memory.getFloat(m2_addr+n23) + 
			Memory.getFloat(m1_addr+n13) * Memory.getFloat(m2_addr+n33) + 
			Memory.getFloat(m1_addr+n14) * Memory.getFloat(m2_addr+n43) ;
		//r14 = m11*c14 + m12*c24 + m13*c34 + m14*c44
		var m14:Float =  
			Memory.getFloat(m1_addr) * Memory.getFloat(m2_addr+n14) + 
			Memory.getFloat(m1_addr+n12) * Memory.getFloat(m2_addr+n24) + 
			Memory.getFloat(m1_addr+n13) * Memory.getFloat(m2_addr+n34) + 
			Memory.getFloat(m1_addr + n14) * Memory.getFloat(m2_addr + n44) ;
			
			
		//r21 = m21*c11 + m22*c21 + m23*c31 + m24*c41
		var m21:Float =  
			Memory.getFloat(m1_addr+n21) * Memory.getFloat(m2_addr) + 
			Memory.getFloat(m1_addr+n22) * Memory.getFloat(m2_addr+n21) + 
			Memory.getFloat(m1_addr+n23) * Memory.getFloat(m2_addr+n31) + 
			Memory.getFloat(m1_addr+n24) * Memory.getFloat(m2_addr+n41) ;
		//r22 = m11*c12 + m12*c22 + m13*c32 + m14*c42
		var m22:Float =   
			Memory.getFloat(m1_addr+n21) * Memory.getFloat(m2_addr+n12) + 
			Memory.getFloat(m1_addr+n22) * Memory.getFloat(m2_addr+n22) + 
			Memory.getFloat(m1_addr+n23) * Memory.getFloat(m2_addr+n32) + 
			Memory.getFloat(m1_addr+n24) * Memory.getFloat(m2_addr+n42) ;
		//r23 = m11*c13 + m12*c23 + m13*c33 + m14*c43
		var m23:Float =  
			Memory.getFloat(m1_addr+n21) * Memory.getFloat(m2_addr+n13) + 
			Memory.getFloat(m1_addr+n22) * Memory.getFloat(m2_addr+n23) + 
			Memory.getFloat(m1_addr+n23) * Memory.getFloat(m2_addr+n33) + 
			Memory.getFloat(m1_addr+n24) * Memory.getFloat(m2_addr+n43) ;
		//r24 = m11*c14 + m12*c24 + m13*c34 + m14*c44
		var m24:Float =  
			Memory.getFloat(m1_addr+n21) * Memory.getFloat(m2_addr+n14) + 
			Memory.getFloat(m1_addr+n22) * Memory.getFloat(m2_addr+n24) + 
			Memory.getFloat(m1_addr+n23) * Memory.getFloat(m2_addr+n34) + 
			Memory.getFloat(m1_addr+n24) * Memory.getFloat(m2_addr+n44) ;
	
		//r21 = m21*c11 + m22*c21 + m23*c31 + m24*c41
		var m31:Float =  
			Memory.getFloat(m1_addr+n31) * Memory.getFloat(m2_addr) + 
			Memory.getFloat(m1_addr+n32) * Memory.getFloat(m2_addr+n21) + 
			Memory.getFloat(m1_addr+n33) * Memory.getFloat(m2_addr+n31) + 
			Memory.getFloat(m1_addr+n34) * Memory.getFloat(m2_addr+n41) ;
		//r22 = m11*c12 + m12*c22 + m13*c32 + m14*c42
		var m32:Float =   
			Memory.getFloat(m1_addr+n31) * Memory.getFloat(m2_addr+n12) + 
			Memory.getFloat(m1_addr+n32) * Memory.getFloat(m2_addr+n22) + 
			Memory.getFloat(m1_addr+n33) * Memory.getFloat(m2_addr+n32) + 
			Memory.getFloat(m1_addr+n34) * Memory.getFloat(m2_addr+n42) ;
		//r23 = m11*c13 + m12*c23 + m13*c33 + m14*c43
		var m33:Float =  
			Memory.getFloat(m1_addr+n31) * Memory.getFloat(m2_addr+n13) + 
			Memory.getFloat(m1_addr+n32) * Memory.getFloat(m2_addr+n23) + 
			Memory.getFloat(m1_addr+n33) * Memory.getFloat(m2_addr+n33) + 
			Memory.getFloat(m1_addr+n34) * Memory.getFloat(m2_addr+n43) ;
		//r24 = m11*c14 + m12*c24 + m13*c34 + m14*c44
		var m34:Float =  
			Memory.getFloat(m1_addr+n31) * Memory.getFloat(m2_addr+n14) + 
			Memory.getFloat(m1_addr+n32) * Memory.getFloat(m2_addr+n24) + 
			Memory.getFloat(m1_addr+n33) * Memory.getFloat(m2_addr+n34) + 
			Memory.getFloat(m1_addr+n34) * Memory.getFloat(m2_addr+n44) ;
			
		//r21 = m21*c11 + m22*c21 + m23*c31 + m24*c41
		var m41:Float =   
			Memory.getFloat(m1_addr+n41) * Memory.getFloat(m2_addr) + 
			Memory.getFloat(m1_addr+n42) * Memory.getFloat(m2_addr+n21) + 
			Memory.getFloat(m1_addr+n43) * Memory.getFloat(m2_addr+n31) + 
			Memory.getFloat(m1_addr+n44) * Memory.getFloat(m2_addr+n41) ;
		//r22 = m11*c12 + m12*c22 + m13*c32 + m14*c42
		var m42:Float =   
			Memory.getFloat(m1_addr+n41) * Memory.getFloat(m2_addr+n12) + 
			Memory.getFloat(m1_addr+n42) * Memory.getFloat(m2_addr+n22) + 
			Memory.getFloat(m1_addr+n43) * Memory.getFloat(m2_addr+n32) + 
			Memory.getFloat(m1_addr+n44) * Memory.getFloat(m2_addr+n42) ;
		//r23 = m11*c13 + m12*c23 + m13*c33 + m14*c43
		var m43:Float =  
			Memory.getFloat(m1_addr+n41) * Memory.getFloat(m2_addr+n13) + 
			Memory.getFloat(m1_addr+n42) * Memory.getFloat(m2_addr+n23) + 
			Memory.getFloat(m1_addr+n43) * Memory.getFloat(m2_addr+n33) + 
			Memory.getFloat(m1_addr+n44) * Memory.getFloat(m2_addr+n43) ;
		//r24 = m11*c14 + m12*c24 + m13*c34 + m14*c44
		var m44:Float =   
			Memory.getFloat(m1_addr+n41) * Memory.getFloat(m2_addr+n14) + 
			Memory.getFloat(m1_addr+n42) * Memory.getFloat(m2_addr+n24) + 
			Memory.getFloat(m1_addr+n43) * Memory.getFloat(m2_addr+n34) + 
			Memory.getFloat(m1_addr + n44) * Memory.getFloat(m2_addr + n44) ;
			
		Memory.setFloat( res_addr, m11 );
		Memory.setFloat( res_addr + n12, m12 );
		Memory.setFloat( res_addr + n13, m13 );
		Memory.setFloat( res_addr + n14, m14 );
		
		Memory.setFloat( res_addr + n21, m21 );
		Memory.setFloat( res_addr + n22, m22 );
		Memory.setFloat( res_addr + n23, m23 );
		Memory.setFloat( res_addr + n24, m24 );
		
		Memory.setFloat( res_addr + n31, m31 );
		Memory.setFloat( res_addr + n32, m32 );
		Memory.setFloat( res_addr + n33, m33 );
		Memory.setFloat( res_addr + n34, m34 );
	
		Memory.setFloat( res_addr + n41, m41 );
		Memory.setFloat( res_addr + n42, m42 );
		Memory.setFloat( res_addr + n43, m43 );
		Memory.setFloat( res_addr + n44, m44 );
			
	}
	
	public static inline function concatVector( matrix:Matrix4mem, vector_address:MEM_ADDRESS, result_address:MEM_ADDRESS )
	{
		var maddr:MEM_ADDRESS = matrix.addr;
		
		Memory.setFloat( result_address,
			Memory.getFloat(maddr + n11) * Memory.getFloat(vector_address) + 
			Memory.getFloat(maddr + n12) * Memory.getFloat(vector_address+4) + 
			Memory.getFloat(maddr + n13) * Memory.getFloat(vector_address+8) + 
			Memory.getFloat(maddr + n14) );
			
		Memory.setFloat( result_address+4,
			Memory.getFloat(maddr + n21) * Memory.getFloat(vector_address) + 
			Memory.getFloat(maddr + n22) * Memory.getFloat(vector_address+4) + 
			Memory.getFloat(maddr + n23) * Memory.getFloat(vector_address+8) + 
			Memory.getFloat(maddr + n24) );
			
		Memory.setFloat( result_address+8,
			Memory.getFloat(maddr + n31) * Memory.getFloat(vector_address) + 
			Memory.getFloat(maddr + n32) * Memory.getFloat(vector_address+4) + 
			Memory.getFloat(maddr + n33) * Memory.getFloat(vector_address+8) + 
			Memory.getFloat(maddr + n34) );
			
	}
	
	public static inline function concatVectorDivW( matrix:Matrix4mem, vector_address:MEM_ADDRESS, result_address:MEM_ADDRESS )
	{
		var maddr:MEM_ADDRESS = matrix.addr;
		
		var w:Float = 
			Memory.getFloat(maddr + n41) +
			Memory.getFloat(maddr + n42) +
			Memory.getFloat(maddr + n43) +
			Memory.getFloat(maddr + n44);
		
		Memory.setFloat( result_address,
			(Memory.getFloat(maddr + n11) * Memory.getFloat(vector_address) + 
			Memory.getFloat(maddr + n12) * Memory.getFloat(vector_address+4) + 
			Memory.getFloat(maddr + n13) * Memory.getFloat(vector_address+8) + 
			Memory.getFloat(maddr + n14))/w );
			
		Memory.setFloat( result_address+4,
			(Memory.getFloat(maddr + n21) * Memory.getFloat(vector_address) + 
			Memory.getFloat(maddr + n22) * Memory.getFloat(vector_address+4) + 
			Memory.getFloat(maddr + n23) * Memory.getFloat(vector_address+8) + 
			Memory.getFloat(maddr + n24))/w );
			
		Memory.setFloat( result_address+8,
			(Memory.getFloat(maddr + n31) * Memory.getFloat(vector_address) + 
			Memory.getFloat(maddr + n32) * Memory.getFloat(vector_address+4) + 
			Memory.getFloat(maddr + n33) * Memory.getFloat(vector_address+8) + 
			Memory.getFloat(maddr + n34))/w );
			
	}
	
	public static inline function cvCorrect( matrix:Matrix4mem, _x:Float, _y:Float, _z:Float )
	{
		var maddr:MEM_ADDRESS = matrix.addr;
		
		var w:Float = 
			Memory.getFloat(maddr + n14) * _x + 
			Memory.getFloat(maddr + n24) * _y + 
			Memory.getFloat(maddr + n34) * _z + 
			Memory.getFloat(maddr + n44);
		
		var x:Float = 
			Memory.getFloat(maddr + n11) * _x + 
			Memory.getFloat(maddr + n21) * _y + 
			Memory.getFloat(maddr + n31) * _z + 
			Memory.getFloat(maddr + n41);
			
		var y:Float = 
			Memory.getFloat(maddr + n12) * _x + 
			Memory.getFloat(maddr + n22) * _y + 
			Memory.getFloat(maddr + n32) * _z + 
			Memory.getFloat(maddr + n42) ;
			
		var z:Float = 
			Memory.getFloat(maddr + n13) * _x + 
			Memory.getFloat(maddr + n23) * _y + 
			Memory.getFloat(maddr + n33) * _z + 
			Memory.getFloat(maddr + n43);
			
		x /= w;
		y /= w;
		z /= w;
		w /= w;
			
		trace( "( " + Std.int(x * 10000) / 10000 + ", " + Std.int(y * 10000) / 10000 + ", " + Std.int(z * 10000) / 10000 + ", " + Std.int(w * 1000) / 1000 + " )" );
		trace( "( " + Std.int((x/z)*10000)/10000 + ", " + Std.int((y/z)*10000)/10000 + ", " + Std.int(z*10000)/10000 + ", " + Std.int(w*1000)/1000 + " )" );
			
	}
	
	public static inline function concatVectorToVP( matrix:Matrix4mem, vector_address:MEM_ADDRESS, result_address:MEM_ADDRESS, width:Int, height:Int )
	{
		var maddr:MEM_ADDRESS = matrix.addr;
		
		var w:Float = 
			Memory.getFloat(maddr + n14) * Memory.getFloat(vector_address) + 
			Memory.getFloat(maddr + n24) * Memory.getFloat(vector_address+4) + 
			Memory.getFloat(maddr + n34) * Memory.getFloat(vector_address+8) + 
			Memory.getFloat(maddr + n44);
		
		var x:Float = 
			Memory.getFloat(maddr + n11) * Memory.getFloat(vector_address) + 
			Memory.getFloat(maddr + n21) * Memory.getFloat(vector_address+4) + 
			Memory.getFloat(maddr + n31) * Memory.getFloat(vector_address+8) + 
			Memory.getFloat(maddr + n41);
			
		var y:Float = 
			Memory.getFloat(maddr + n12) * Memory.getFloat(vector_address) + 
			Memory.getFloat(maddr + n22) * Memory.getFloat(vector_address+4) + 
			Memory.getFloat(maddr + n32) * Memory.getFloat(vector_address+8) + 
			Memory.getFloat(maddr + n42) ;
			
		var z:Float = 
			Memory.getFloat(maddr + n13) * Memory.getFloat(vector_address) + 
			Memory.getFloat(maddr + n23) * Memory.getFloat(vector_address+4) + 
			Memory.getFloat(maddr + n33) * Memory.getFloat(vector_address+8) + 
			Memory.getFloat(maddr + n43);
			
		w = 1 / w;	
		x /= w;
		y /= w;
		z /= w;
		
			
		x = (x / z) * (width*.5) + (width * .5);
		y = ( -y / z) * (height * .5) + (height * .5);
		
		Memory.setFloat( result_address, x );
		Memory.setFloat( result_address+4, y );
		Memory.setFloat( result_address+8, z );
			
	}
	
	public static inline function concatVectorNoVP( matrix:Matrix4mem, vector_address:MEM_ADDRESS, result_address:MEM_ADDRESS )
	{
		var maddr:MEM_ADDRESS = matrix.addr;
		
		var w:Float = 
			Memory.getFloat(maddr + n14) * Memory.getFloat(vector_address) + 
			Memory.getFloat(maddr + n24) * Memory.getFloat(vector_address+4) + 
			Memory.getFloat(maddr + n34) * Memory.getFloat(vector_address+8) + 
			Memory.getFloat(maddr + n44);
		
		var x:Float = 
			Memory.getFloat(maddr + n11) * Memory.getFloat(vector_address) + 
			Memory.getFloat(maddr + n21) * Memory.getFloat(vector_address+4) + 
			Memory.getFloat(maddr + n31) * Memory.getFloat(vector_address+8) + 
			Memory.getFloat(maddr + n41);
			
		var y:Float = 
			Memory.getFloat(maddr + n12) * Memory.getFloat(vector_address) + 
			Memory.getFloat(maddr + n22) * Memory.getFloat(vector_address+4) + 
			Memory.getFloat(maddr + n32) * Memory.getFloat(vector_address+8) + 
			Memory.getFloat(maddr + n42) ;
			
		var z:Float = 
			Memory.getFloat(maddr + n13) * Memory.getFloat(vector_address) + 
			Memory.getFloat(maddr + n23) * Memory.getFloat(vector_address+4) + 
			Memory.getFloat(maddr + n33) * Memory.getFloat(vector_address+8) + 
			Memory.getFloat(maddr + n43);
		
		Memory.setFloat( result_address, x );
		Memory.setFloat( result_address+4, y );
		Memory.setFloat( result_address+8, z );
			
	}
	
	public static inline function concatVector2( matrix:Matrix4mem, vector_address:MEM_ADDRESS, result_address:MEM_ADDRESS )
	{
		var maddr:MEM_ADDRESS = matrix.addr;
		
		var w:Float = 
			Memory.getFloat(maddr + n14) * Memory.getFloat(vector_address) + 
			Memory.getFloat(maddr + n24) * Memory.getFloat(vector_address+4) + 
			Memory.getFloat(maddr + n34) * Memory.getFloat(vector_address+8) + 
			Memory.getFloat(maddr + n44);
		
		var x:Float = 
			Memory.getFloat(maddr + n11) * Memory.getFloat(vector_address) + 
			Memory.getFloat(maddr + n21) * Memory.getFloat(vector_address+4) + 
			Memory.getFloat(maddr + n31) * Memory.getFloat(vector_address+8) + 
			Memory.getFloat(maddr + n41);
			
		var y:Float = 
			Memory.getFloat(maddr + n12) * Memory.getFloat(vector_address) + 
			Memory.getFloat(maddr + n22) * Memory.getFloat(vector_address+4) + 
			Memory.getFloat(maddr + n32) * Memory.getFloat(vector_address+8) + 
			Memory.getFloat(maddr + n42) ;
			
		var z:Float = 
			Memory.getFloat(maddr + n13) * Memory.getFloat(vector_address) + 
			Memory.getFloat(maddr + n23) * Memory.getFloat(vector_address+4) + 
			Memory.getFloat(maddr + n33) * Memory.getFloat(vector_address+8) + 
			Memory.getFloat(maddr + n43);
		
		Memory.setFloat( result_address, x );
		Memory.setFloat( result_address+4, y );
		Memory.setFloat( result_address+8, z );
			
	}
	
	public static function calculatePerspectiveFovLH( m:Matrix4mem, fov:Float, aspect:Float, zNear:Float, zFar:Float )
	{
		
		var h:Float = 1 / Math.tan( fov * .5 );
		var w:Float = h / aspect;
		
		var neg_depth:Float = zFar - zNear;
		
		m.fromArray(
		[w, 0,              0, 0,
		 0, h,              0, 0,
		 0, 0, zFar/neg_depth, 1,
		 0, 0, -(zFar*zNear)/neg_depth, 0]);
		 
		
	}
	
	public inline function to4D( val:Float )
	{
		return Math.floor(val * 10000) / 10000;
	}
	
	public function toString( )
	{
		var s:String = 
		"\n[" + to4D(Memory.getFloat(addr + n11)) + ", " + to4D(Memory.getFloat(addr + n12)) + ", " + to4D(Memory.getFloat(addr + n13)) + ", " + to4D(Memory.getFloat(addr + n14)) + "\n " +
		to4D(Memory.getFloat(addr + n21)) + ", " + to4D(Memory.getFloat(addr + n22)) + ", " + to4D(Memory.getFloat(addr + n23)) + ", " + to4D(Memory.getFloat(addr + n24)) + "\n " +
		to4D(Memory.getFloat(addr + n31)) + ", " + to4D(Memory.getFloat(addr + n32)) + ", " + to4D(Memory.getFloat(addr + n33)) + ", " + to4D(Memory.getFloat(addr + n34)) + "\n " +
		to4D(Memory.getFloat(addr + n41)) + ", " + to4D(Memory.getFloat(addr + n42)) + ", " + to4D(Memory.getFloat(addr + n43)) + ", " + to4D(Memory.getFloat(addr + n44)) + "]";
		return s;
	}
	
}