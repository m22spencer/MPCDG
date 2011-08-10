/**
 * ...
 * @author Matthew Spencer
 */

package models;

class AModel 
{

	public function new() 
	{
		
	}
	
	public dynamic function vertices():Array<Float>
	{
		throw( "Has no vertices" );
		return null;
	}
	
	public dynamic function indices():Array<Int>
	{
		throw( "Has no indices" );
		return null;
	}
	
}