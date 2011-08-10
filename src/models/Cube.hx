/**
 * ...
 * @author Matthew Spencer
 */

package models;

class Cube extends AModel
{

	public function new() 
	{
		super( );
	}
	
	public override function vertices( )
	{
		return 
		[
			-1.0, -1, -1,
			 1, -1, -1,
			 1,  1, -1,
			-1,  1, -1,
			
			-1, -1, 1,
			 1, -1, 1,
			 1,  1, 1,
			-1,  1, 1,
		];
	}
	
	public override function indices( )
	{
		return 
		[
			//*front
			2, 0, 1,
			2, 3, 0,
			//*/
			
			//*right
			6, 1, 5,
			6, 2, 1,
			//*/
			
			//*left		
			3, 4, 0,
			3, 7, 4,
			//*/
			
			//*Top
			6, 3, 2,
			6, 7, 3,
			//*/
			
			//*Back
			7, 5, 4,
			7, 6, 5,
			//*/
			
			//*Bottom
			1, 4, 5,
			1, 0, 4,
			//*/
		];
	}
	
}