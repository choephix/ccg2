package duel.controllers 
{
	
	public class SelectionContext 
	{
		public var name:String = "unnamed";
		
		///// Must accept NO arguments and return Boolean
		//public var condition:Function = TRUTH;
		
		/// Must accept ONE argument of type * and return Boolean
		public var isSelectable:Function = TRUTH;
		//public var isSelectable:Vector.<Function> = new Vector.<Function>();
		
		/// Must accept ONE argument of type *
		public var onSelected:Function = ERROR;
		
		//
		public function toString():String 
		{ return "[SelectionContext=" + name + "]" }
		
		//
		private static function TRUTH( o:* ):Boolean 
		{ return true }
		private static function ERROR( o:* ):void
		{ CONFIG::development{ throw new UninitializedError("Undefined Function Called") } }
	}

}