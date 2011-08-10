/**
 * ...
 * @author Matthew Spencer
 */

package com.abc;
import com.abc.Data;
import com.abc.Reg;
import format.abc.Data;

class FixedReg 
{

	var reg:Reg<Int>;
	var format:FixedFormat;
	
	public function new( format:FixedFormat, ?reg:Reg<Int> ) 
	{
		if ( reg == null ) reg = Reg.int( );
		this.reg = reg;
		this.format = format;
	}
	static var overflowChecking:Bool = false;
	
	static function t( ft:FixedReg )
	{
		switch( ft.format )
		{
			case F22_10:
				return 10;
			case F28_4:
				return 4;
		}
	}
	public static function mul( f0:FixedReg, f1:FixedReg, r:FixedReg )
	{
		var bcode:Array<Dynamic>;
		
		if ( !overflowChecking )
		{
			var align_shift:Int = t(f0) + t(f1) - t(r);
			//speedy, fast, dangerous
			bcode = 
			[
				OReg( f0.r ),
				OReg( f1.r ),
				OOp( OpIMul ),
				OInt( align_shift ),
				OOp( OpShr ),
				OSetReg( r ),				
			]
		}
		else
		{
			//make our values not go "poof"
			
		}
	}
	
}

enum FixedFormat {
	F22_10;
	F28_4;
}