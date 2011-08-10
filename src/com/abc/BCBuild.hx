/**
 * ...
 * @author Matthew Spencer
 */

package com.abc;

import com.abc.Data;
import flash.utils.ByteArray;
import format.abc.Data;
import format.swf.Data;

private typedef RegData = { cls:Class<Dynamic>, id:Int };

class BCBuild
{

	var ops:Array<Dynamic>;
	
	public function new() 
	{
		ops = new Array( );
	}
	
	public function __abc__( a:Array<Dynamic> )
	{
		ops = ops.concat( a );
	}
	
	public function compile( )
	{
		
	}
	
	public static function buildToFunctionAsync( call:Dynamic->Void, ctx:format.abc.Context, classDefinition:String, functionName:String, ?domainMem:ByteArray )
	{
		
		//***** GENERATE SWF
		// compile ActionScript bytecode
        var abcOutput = new haxe.io.BytesOutput();
        format.abc.Writer.write(abcOutput, ctx.getData( ) );
        var abcBytes:haxe.io.Bytes = abcOutput.getBytes();
        
        // create a new SWF
        var swfOutput:haxe.io.BytesOutput = new haxe.io.BytesOutput();
        var swfFile:format.swf.SWF = {
            header: {
                version : 9,
                compressed : true,
                width : 400,
                height : 300,
                fps : 30,
                nframes : 1
            },
            tags: [
                TSandBox(25),            // Flash9 Sandbox
                TActionScript3(abcBytes),    // ActionScript block
                TShowFrame            // Show frame
            ]
            
        }
        // write SWF
        var writer:format.swf.Writer = new format.swf.Writer(swfOutput);
        writer.write(swfFile);
        var swfBytes:haxe.io.Bytes = swfOutput.getBytes();

		var loader = new flash.display.Loader();
		
		var cb_load = function(e) {
			
			if( domainMem != null )
				loader.contentLoaderInfo.applicationDomain.domainMemory = domainMem;
			
			var m = loader.contentLoaderInfo.applicationDomain.getDefinition(classDefinition);
				
			// create an instance of it
			var inst:Dynamic = Type.createInstance(m, []);
			
			call( Reflect.field( inst, functionName ) );		
		}
		
        // load locally
       
        loader.contentLoaderInfo.addEventListener(flash.events.Event.COMPLETE, cb_load);
        loader.loadBytes(swfBytes.getData());
	}
	
	public function buildToCtx( ctx:format.abc.Context )
	{
		var opsbak:Array<Dynamic> = ops.copy( );
		
		proccessConditions( );
		proccessRegisters( ctx );
		
		var labels:Dynamic = { };
		var jumps:Dynamic = { };
		
		var op:Dynamic;
		for ( op in ops )
		{
			if ( op == null )
			{
				throw( "Null ops cannot be accepted" );
			}
			else if ( Std.is( op, OpCode ) )
			{
				ctx.op( op );
			}
			else if ( Std.is( op, OpCodeE ) ) switch( cast op )
			{
				
				case OJump( j, l ):
					var a:Array<Dynamic>;
					if ( !Reflect.hasField( jumps, l ) )
					{
						a = new Array( );
						Reflect.setField( jumps, l, a );
					}
					a = Reflect.field( jumps, l );
					
					ctx.op( OpCode.OJump( j, 0 ) );	
					a.push( { pos:untyped ctx.bytepos.n, apos:untyped ctx.curFunction.ops.length-1, j:j } );
									
					
				case OLabel( l ):
					if ( Reflect.hasField( labels, l ) )
						throw( "Duplicate labels are not allowed" );
						Reflect.setField( labels, l, {pos:untyped ctx.bytepos.n, apos:untyped ctx.curFunction.ops.length} );
					ctx.op( OpCode.OLabel );
				
				case OReg( r ):
				case OSetReg( r ):
				case ORegKill( r ):
				case ONext( r1, r2 ):
				case OIncrReg( r ):
				case ODecrReg( r ):
				case OIncrIReg( r ):
				case ODecrIReg( r ):
				case ODebugReg( name, r, line ):
					
					
				default:
					throw( op + " must be preprocessed" );
			}
			
		}
		
		//post process ctx jump positions
		var cops:Array<Dynamic> = untyped ctx.curFunction.ops;
		for ( fld in Reflect.fields( jumps ) )
		{
			var lbl:Dynamic = Reflect.field( labels, fld );
			var jarray:Array<Dynamic> = Reflect.field( jumps, fld );
			
			var jmp:Dynamic;
			for ( jmp in jarray )
			{
				//forward jump
				cops[jmp.apos] = OpCode.OJump( jmp.j, cast lbl.pos - jmp.pos );
			}			
		}
		
		ops = opsbak;
	}
	
	function proccessRegisters( ctx:format.abc.Context )
	{
		//make a pass, storing an alloc command in the first reg found
		//also, store regs in a table, and place a dealloc after the last use.
		
		var registerTable:IntHash<Int> = new IntHash( );
		var registerLinker:IntHash<Reg<Dynamic>> = new IntHash( );
		
		
		
		var i:Int = 0;
		while ( i < ops.length )
		{
			var oplinker = ops;
			var pr = function( r:Reg<Dynamic> )
			{
				if ( !registerTable.exists( r.id ) )
				{
					oplinker.insert( i++, OAlloc( r ) );
					registerLinker.set( r.id, r );
				}
				registerTable.set( r.id, i+1 );
			}
			
			if ( Std.is( ops[i], OpCodeE ) )
			{
				switch( cast ops[i] )
				{
					case OReg( r ):
						pr( r );
					case OSetReg( r ):
						pr( r );
					case ORegKill( r ):
						pr( r );
					case ONext( r1, r2 ):
						pr( r1 );
						pr( r2 );
					case OIncrReg( r ):
						pr( r );
					case ODecrReg( r ):
						pr( r );
					case OIncrIReg( r ):
						pr( r );
					case ODecrIReg( r ):
						pr( r );
					case ODebugReg( name, r, line ):
						pr( r );
					default:
				}
			}
			
			i++;
		}
		
		var offset:Int = 0;
		for ( reg in registerTable.keys( ) )
		{
			var line:Int = registerTable.get( reg ) + (offset++);
			
			ops.insert( line, ODealloc( registerLinker.get( reg ) ) );
		}
		
		var avail:Array<RegData> = new Array( );
		
		var getReg = function ( cls:Class<Dynamic> )
		{
			for ( r in avail )
			{
				if ( r.cls == cls )
				{
					var ret = r;
					avail.remove( r );
					return ret;
				}
			}
			return { cls:cls, id:ctx.allocRegister( ) };
		}
		
		var i:Int = 0;
		while ( i < ops.length )
		{
			var op = ops[i];
			if ( Std.is( op, POps ) )
			{
				switch( cast op )
				{
					case OAlloc( r ):
						r.m0 = getReg( r.cls );
						
						
					case ODealloc( r ):
						avail.push( r.m0 );
						r.m0 = null;
				}
			}else if ( Std.is( op, OpCodeE ) )
			{	
				switch( cast ops[i] )
				{
					case OReg( r ):
						ops[i] = OpCode.OReg( r.m0.id );
					case OSetReg( r ):
						ops[i] = OpCode.OSetReg( r.m0.id );
					case ORegKill( r ):
						ops[i] = OpCode.ORegKill( r.m0.id );
					case ONext( r1, r2 ):
						ops[i] = OpCode.ONext( r1.m0.id, r2.m0.id );
					case OIncrReg( r ):
						ops[i] = OpCode.OIncrReg( r.m0.id );
					case ODecrReg( r ):
						ops[i] = OpCode.ODecrReg( r.m0.id );
					case OIncrIReg( r ):
						ops[i] = OpCode.OIncrIReg( r.m0.id );
					case ODecrIReg( r ):
						ops[i] = OpCode.ODecrIReg( r.m0.id );
					case ODebugReg( name, r, line ):
						ops[i] = OpCode.ODebugReg( name, r.m0.id, line );
					default:
				}
			}
			i++;
		}
		
		var pinit:Array<Dynamic> = new Array( );
		for ( rg in avail )
		{
			switch( rg.cls )
			{
				case Int:
					pinit.push( OInt( 0 ) );
				case Float:
					pinit.push( OInt( 0 ) );
					pinit.push( OToNumber );	//uneccesary, @FIXME
				default:
					throw( "Unsupported type" );
			}
			pinit.push( OpCode.OSetReg( rg.id ) );
		}
		ops = pinit.concat( ops );
	}
	
	static var label_id:Int = 0;
	public static function label( )
	{
		return "__LABEL__" + label_id++;
	}
	
	//Allows easier to read conditionals
	//OIf( j:JumpStyle )		//these are inverted, if true, they will execute the adjacent block
	//
	//OElse
	//
	//OFi
	function proccessConditions( )
	{
		var ifcounter:Array<{id:Int,c:Int}> = new Array( );
		var ifinc:Int = 0;
		
		var i:Int = 0;
		while ( i < ops.length )
		{
			if( Std.is( ops[i], OpCodeE ) )
				switch( ops[i] )
				{
					case OIf( j ):
						ifcounter.push( {id:ifinc++, c:0} );
						ops[i] = OJump( oppositeJump(j), "_IFELSE"+ ifcounter.length + "ID"+ifcounter[ifcounter.length - 1].id );
						
					case OElse:
						if ( ifcounter.length == 0 )
							throw( "No matching If statement" );
						if ( ifcounter[ifcounter.length - 1].c > 1 )
							throw( "cannot add OElse" );
						ifcounter[ifcounter.length - 1].c++;
						ops[i] = OJump( JAlways, "_IFEND" + ifcounter.length + "ID"+ifcounter[ifcounter.length - 1].id );
						ops.insert( i + 1, OLabel( "_IFELSE" + ifcounter.length + "ID"+ifcounter[ifcounter.length - 1].id ) );
					case OFi:
						if ( ifcounter.length == 0 )
							throw( "No matching If statement" );
						if ( ifcounter[ifcounter.length - 1].c == 0 )
							ops[i] = OLabel( "_IFELSE" + ifcounter.length + "ID"+ifcounter[ifcounter.length - 1].id );
						else
							ops[i] = OLabel( "_IFEND" + ifcounter.length + "ID"+ifcounter[ifcounter.length - 1].id );
						ifcounter.pop( );
					default:				
				}
				
			i++;
		}
		
		if ( ifcounter.length != 0 )
			throw( "You have an unclosed if statement" );
		
	}
	
	function oppositeJump( o:JumpStyle )
	{
		switch( o )
		{
			case JNotLt:
				return JLt;
			case JNotLte:
				return JLte;
			case JNotGt:
				return JGt;
			case JNotGte:
				return JGte;
			case JAlways:
				throw( "cannot use JAlways in an if statement" );
			case JTrue:
				return JFalse;
			case JFalse:
				return JTrue;
			case JEq:
				return JNeq;
			case JNeq:
				return JEq;
			case JLt:
				return JGte;
			case JLte:
				return JGt;
			case JGt:
				return JLte;
			case JGte:
				return JLt;
			case JPhysEq:
				return JPhysNeq;
			case JPhysNeq:
				return JPhysEq;
		}
	}
	
}

private enum POps {
	OAlloc( r:Reg<Dynamic> );
	ODealloc( r:Reg<Dynamic> );
}