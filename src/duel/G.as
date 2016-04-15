package duel {
	public class G 
	{
		public static const SANDBOX:Object = 
		{
			HAND : 8,
			MANA : 8
		}
		
		public static const CARD_W:Number = 245;
		public static const CARD_H:Number = 342;
		public static const TABLE_Z:Number = .80;
		
		public static const FIELD_COLUMNS:Number = 4;
		
		public static const INIT_LP:Number = 20;		// 20 
		public static const INIT_HAND_SIZE:Number = CONFIG::sandbox?SANDBOX.HAND:2;	//  2
		public static const INIT_MANA:Number 	  = CONFIG::sandbox?SANDBOX.MANA:1; //  1
		public static const MAX_MANA:Number = 3; 		//  4
		public static const MAX_DECK_SIZE:Number = 48;	// 48
	}
}