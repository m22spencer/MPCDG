/**
 * ...
 * @author Matthew Spencer
 */

package com.abc;

class Reg #if !FD <T> #end
{
	public var id:Int;
	public static var _ID:Int = 0;
	
	public var m0:Dynamic;
	
	public var isParameter(default,null):Bool;
	
	public var cls:Class<T>;
	
	public function new( t:Class<T> ) 
	{
		id = _ID++;
		cls = t;
		isParameter = false;
	}
	
	public function toString( )
	{
		return "r" + id;
	}
	
	public static function int( )
	{
		return new Reg<Int>(Int);
	}
	
	public static function float( )
	{
		return new Reg<Float>(Float);
	}
	
	public static function param<T>( x:Int, type:Class<T> )
	{
		var r = new Reg<T>(type);
		r.isParameter = true;
		r.m0 = { id:x };
		return r;
	}
}