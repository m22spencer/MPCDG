/**
 * ...
 * @author Matthew Spencer
 */

package com.codex.c3dex.memory;
import flash.Memory;
import flash.utils.ByteArray;
import flash.utils.Endian;

class MemoryDispatcher
{
	private static var btree:MTree;
	public static var ba:ByteArray;
	private static var inUse:Int;
	private static var inUseActual:Int;
	static private var min:Int;
	static private var max:Int;
	
	public static function init( min_power:Int, max_power:Int )
	{
		min = cast Math.pow(2, min_power);
		max = cast Math.pow(2, max_power);
		
		btree = new MTree( min, max, 0 );
		ba = new ByteArray( );
		ba.endian = Endian.LITTLE_ENDIAN;
		ba.length = max + 1024;
		
		inUse = 0;
		
		Memory.select( ba );
	}
	
	public static function alloc( b:Int )
	{
		var n = btree.store( b );
		inUse += n.size;
		inUseActual += b;
		return new RasterMem( n.addr, b, n );		
	}
	
	public static function free( rmem:RasterMem )
	{
		inUseActual -= rmem.size;
		inUse -= rmem.node.size;
		
		btree.free( rmem.node );
		untyped rmem.size = 0;	//will force errors to be thrown if in debug mode and a write is attempted
	}
	
}

//TODO write this to always fill perfect blocks in the branch with the least free space.
class MTree
{
	var _head:MNode;
	private var minsize:Int;
	private var maxsize:Int;
	private var addr:Int;
	
	public function new( minsize:Int, maxsize:Int, addr:Int )
	{
		this.minsize = minsize;
		this.maxsize = maxsize;
		this.addr = addr;
	}
	
	//store b bytes in memory
	public function store( b:Int )
	{
		var mask = findMask( b );
		var addr:Int = 0;
		
		//trace( "Insert " + b + "b [" + untyped findMask(b).toString(2) + "]" );
		
		//find our base target node
		if ( _head == null )
		{
			//we need to have a non-null node as our base
			_head = new MNode( );
			_head.mask = findMask( maxsize );
			_head.size_mask = findMask( maxsize );
			_head.addr = addr;
			_head.size = maxsize;
		}
		
		var node = _head;
		while ( node != null )
		{
			if ( node.mask >= mask )
			{
				if ( node.left != null )
				{
					if ( node.left.mask >= mask )
					{
						//perfect descend
						//trace( "Descend left" );
						node = node.left;
						continue;
					} 
				}
				if ( node.right != null )
				{
					if ( node.right.mask >= mask )
					{
						//perfect descend
						//trace( "Descend right" );
						node = node.right;
						continue;
					}
				}
				if ( node.mask & mask == mask && node.left == null && node.right == null )
				{
					//perfect node
					//trace( "Perfect node" );
					zero_and_build( node );
					break;
				}
				
				{
					if ( node.left == null )
					{
						node.left = new MNode( );
						node.left.parent = node;
						node.left.size_mask = node.size_mask >>> 1;
						node.left.mask = node.left.size_mask;
						node.left.size = node.size >> 1;
						node.left.addr = node.addr;
						//trace( "Created new node on left: " + node.left.addr );
						node = node.left;
						continue;
					}
					if( node.right == null )
					{
						
						node.right = new MNode( );
						node.right.parent = node;
						node.right.size_mask = node.size_mask >>> 1;
						node.right.mask = node.right.size_mask;
						node.right.size = node.size >> 1;
						node.right.addr = node.addr + node.right.size;
						//trace( "Created new node on right: " + node.right.addr );
						node = node.right;
						continue;
					} else throw( "WHOA, one of the nodes should be null, what happened" );
				}
				
				
				
				break;
			} else
			{
				throw( "Out of memory: "+ node.mask + ":" + mask);
				break;
			}
			
		}
		
		
		return node;
	}
	
	public function free( node:MNode )
	{
		if ( node.parent == null )
			throw( "This node belongs to nothing" );
			
		while ( node != null )
		{
			if ( node.left == null && node.right == null )
			{
				//remove from parent, and continue
				var tnode = node;
				node = node.parent;
				remove_node( tnode );
				continue;
			}
			else
			{
				var mask:Int = 0x00;
				if ( node.left != null ) mask |= node.left.mask; else mask |= node.size_mask >>> 1;
				if ( node.right != null ) mask |= node.right.mask; else mask |= node.size_mask >>> 1;
				node.mask = mask;
				node = node.parent;
				continue;
			}
		}
	}
	
	function remove_node( n:MNode )
	{
		if ( n.parent == null )
			_head = null;
		else
		{
			if ( n.parent.left == n )
				n.parent.left = null;
			else
				n.parent.right = null;
		}
	}
	
	function zero_and_build( node:MNode )
	{
		node.mask = 0x00;
		node = node.parent;
		while ( node != null )
		{
			var mask:Int = 0;
			if ( node.left != null ) mask |= node.left.mask; else mask |= node.size_mask >>> 1;
			if ( node.right != null ) mask |= node.right.mask; else mask |= node.size_mask >>> 1;
			node.mask = mask;
			//trace( "setting node mask to " + untyped mask.toString(2) );
			
			node = node.parent;
		}
	}
	
	//find mask from b bytes
	function findMask( b:Int )
	{
		var msize:Int = minsize;
		var mask:Int = 1;
		
		while ( msize <= maxsize )
		{
			if ( b <= msize )
			break;
			
			mask <<= 1;
			msize += msize;	//msize*2
		}
		return mask;
	}
	
}

class MNode
{
	public function new( ) { }
	public var left:MNode;			
	public var right:MNode;
	public var parent:MNode;	
	
	public var mask:Int;
	public var size_mask:Int;
	public var size:Int;
	public var addr:Int;
}

class RasterMem 
{
	public var addr(default, null):Int;
	public var size(default, null):Int;
	public var node(default, null):MNode;
	public function new( addr:Int, size:Int, node:MNode ) 
	{
		this.addr = addr;
		this.size = size;
		this.node = node;
	}
	
	public function free( )
	{
		MemoryDispatcher.free( this );
	}
	
	public inline function setI32( a:Int, v:Int )
	{
		a += addr;
		#if debug
		if ( a < addr ) throw( 'RasterMem::setI32() @OOB addr['+Std.int( a )+'](val '+v+') is OOB for block ['+addr+'->'+(addr+size)+']');
		if ( a+4 > addr + size ) throw( 'RasterMem::setI32() @OOB addr['+Std.int( a )+'](val '+v+') is OOB for block ['+addr+'->'+(addr+size)+']');
		#end		
		Memory.setI32( a, v );
	}
	
	public inline function getI32( a:Int )
	{
		a += addr;
		#if debug
		if ( a < addr ) throw( 'RasterMem::getI32() @OOB addr['+Std.int( a )+'] is OOB for block ['+addr+'->'+(addr+size)+']');
		if ( a+4 > addr + size ) throw( 'RasterMem::getI32() @OOB addr['+Std.int( a )+'] is OOB for block ['+addr+'->'+(addr+size)+']');
		#end		
		return Memory.getI32( a );
	}
	
	public inline function setFloat( a:Int, v:Float )
	{
		a += addr;
		#if debug
		if ( a < addr ) throw( 'RasterMem::setFloat() @OOB addr['+Std.int( a )+'](val '+v+') is OOB for block ['+addr+'->'+(addr+size)+']');
		if ( a+4 > addr + size ) throw( 'RasterMem::setFloat() @OOB addr['+Std.int( a )+'](val '+v+') is OOB for block ['+addr+'->'+(addr+size)+']');
		#end		
		Memory.setFloat( a, v );
	}
	
	public inline function getFloat( a:Int )
	{
		a += addr;
		#if debug
		if ( a < addr ) throw( 'RasterMem::getFloat() @OOB addr['+Std.int( a )+'] is OOB for block ['+addr+'->'+(addr+size)+']');
		if ( a+4 > addr + size ) throw( 'RasterMem::getFloat() @OOB addr['+Std.int( a )+'] is OOB for block ['+addr+'->'+(addr+size)+']');
		#end		
		return Memory.getFloat( a );
	}
	
	public inline function setDouble( a:Int, v:Float )
	{
		a += addr;
		#if debug
		if ( a < addr ) throw( 'RasterMem::getFloat() @OOB addr['+Std.int( a )+'] is OOB for block ['+addr+'->'+(addr+size)+']');
		if ( a+8 > addr + size ) throw( 'RasterMem::getFloat() @OOB addr['+Std.int( a )+'] is OOB for block ['+addr+'->'+(addr+size)+']');
		#end		
		Memory.setDouble( a, v );
	}
	
	public inline function getDouble( a:Int )
	{
		a += addr;
		#if debug
		if ( a < addr ) throw( 'RasterMem::getFloat() @OOB addr['+Std.int( a )+'] is OOB for block ['+addr+'->'+(addr+size)+']');
		if ( a+8 > addr + size ) throw( 'RasterMem::getFloat() @OOB addr['+Std.int( a )+'] is OOB for block ['+addr+'->'+(addr+size)+']');
		#end		
		return Memory.getDouble( a );
	}
	
	public inline function setByte( a:Int, v:Int )
	{
		a += addr;
		#if debug
		if ( a < addr ) throw( 'RasterMem::setFloat() @OOB addr['+Std.int( a )+'](val '+v+') is OOB for block ['+addr+'->'+(addr+size)+']');
		if ( a+1 > addr + size ) throw( 'RasterMem::setFloat() @OOB addr['+Std.int( a )+'](val '+v+') is OOB for block ['+addr+'->'+(addr+size)+']');
		#end		
		Memory.setByte( a, v );
	}
	
	public inline function getByte( a:Int )
	{
		a += addr;
		#if debug
		if ( a < addr ) throw( 'RasterMem::getFloat() @OOB addr['+Std.int( a )+'] is OOB for block ['+addr+'->'+(addr+size)+']');
		if ( a+1 > addr + size ) throw( 'RasterMem::getFloat() @OOB addr['+Std.int( a )+'] is OOB for block ['+addr+'->'+(addr+size)+']');
		#end		
		return Memory.getByte( a );
	}
	
}