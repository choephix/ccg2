package editor 
{
	/**
	 * ...
	 * @author choephix
	 */
	public class SortFunctions 
	{
		
		public static function byType( a:Card, b:Card ):int
		{
			return a.color - b.color;
		}
		
	}

}