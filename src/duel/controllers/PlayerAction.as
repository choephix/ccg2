package duel.controllers 
{
	/**
	 * ...
	 * @author choephix
	 */
	public class PlayerAction 
	{
		private var _type:String;
		private var _args:Array;
		
		public function setTo( type:String, ...args ):PlayerAction
		{
			_type = type;
			_args = args;
			return this;
		}
		
		public function get type():String 
		{ return _type }
		
		public function get args():Array 
		{ return _args }
	}
}