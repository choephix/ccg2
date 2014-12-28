package duel.cards.behaviour 
{
	/**
	 * ...
	 * @author choephix
	 */
	public class CreatureCardBehaviour extends CardBehaviour 
	{
		public var attack:int = 0;
		
		public var haste:Boolean = false; 		// CAN ATTACK OR MOVE FIRST TURN
		public var noattack:Boolean = false; 	// CANNOT ATTACK
		public var nomove:Boolean = false; 		// CANNOT MOVE
		public var swift:Boolean = false; 		// CAN ATTACK AND MOVE SAME TURN
		public var berserk:Boolean = false;		// ATTACKS AUTOMATICALLY
		
		public var onCombatFlipFunc:Function;
		public var onSafeFlipFunc:Function;
		public var onMagicFlipFunc:Function;
		
		public function get hasCombatFlipEffect():Boolean
		{
			return onCombatFlipFunc != null;
		}
		
		public function get hasSafeFlipEffect():Boolean
		{
			return onSafeFlipFunc != null;
		}
		
		public function get hasMagicFlipEffect():Boolean
		{
			return onMagicFlipFunc != null;
		}
		
		public function onCombatFlip():void
		{
			if ( onCombatFlipFunc != null )
				onCombatFlipFunc();
		}
		
		public function onSafeFlip():void
		{
			if ( onSafeFlipFunc != null )
				onSafeFlipFunc();
		}
		
		public function onMagicFlip():void
		{
			if ( onMagicFlipFunc != null )
				onMagicFlipFunc();
		}
		
		public function toString():String 
		{
			var a:Array = [];
			if ( haste )	a.push( "haste" );
			if ( noattack )	a.push( "no attack" );
			if ( nomove )	a.push( "no move" );
			if ( swift )	a.push( "swift" );
			if ( berserk )	a.push( "berserk" );
			return a.join( "\n" );
		}
	}
}