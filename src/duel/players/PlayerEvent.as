package duel.players 
{
	import starling.events.Event;
	
	public class PlayerEvent extends Event 
	{
		static public const ACTION:String = "action";
		
		public function PlayerEvent(type:String, bubbles:Boolean=false, data:Object=null) 
		{
			super(type, bubbles, data);
		}
		
	}

}