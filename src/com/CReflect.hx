/**
 * ...
 * @author Matthew Spencer
 */

package com;

class CReflect 
{

	public static function fieldsExcept( o : Dynamic, e:Array<String> ) : Array<String>
	{
		var fld = Reflect.fields( o );
		
		for ( f in fld )
		{
			for ( l in e )
			{
				if ( f == l )
					fld.remove( f );
			}
		}
		
		return fld;		
	}
	
	public static function field( o:Dynamic, fld:String )
	{
		Reflect.field( o, fld );
	}
	
	public static function setField( o:Dynamic, fld:String, val:Dynamic )
	{
		Reflect.setField( o, fld, val );
	}
	
}