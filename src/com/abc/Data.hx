/**
 * ...
 * @author Matthew Spencer
 */

package com.abc;
import format.abc.Data;

enum OpCodeE
{
	OReg( r:Reg<Dynamic> );
	OSetReg( r:Reg<Dynamic> );
	ORegKill( r:Reg<Dynamic> );
	ONext( r1:Reg<Dynamic>, r2:Reg<Dynamic> );
	OIncrReg( r:Reg<Dynamic> );
	ODecrReg( r:Reg<Dynamic> );
	OIncrIReg( r:Reg<Dynamic> );
	ODecrIReg( r:Reg<Dynamic> );
	ODebugReg( name : Index<String>, r:Reg<Dynamic>, line : Int );
	
	OJump( j:JumpStyle, l:String );
	OLabel( l:String );	
	
	OIf( j:JumpStyle );
	OElse;
	OFi;
}