package duel.processes 
{
	import duel.cards.Card;
	import duel.Player;
	import duel.table.CreatureField;
	import duel.table.IndexedField;
	/**
	 * ...
	 * @author choephix
	 */
	public class GameplayProcess extends Process 
	{
		
		public function getIndex():int
		{
			if ( this.callbackArgs[ 0 ] is Card ) 
			{
				if ( Card( this.callbackArgs[ 0 ] ).isInPlay )
					return Card( this.callbackArgs[ 0 ] ).indexedField.index;
				else
					return -1;
			}
			if ( this.callbackArgs[ 0 ] is IndexedField ) 
				return IndexedField( this.callbackArgs[ 0 ] ).index;
			throw new ArgumentError( "What to do... ..." );
		}
		
		public function getController():Player
		{
			if ( this.callbackArgs[ 0 ] is Card ) 
				return Card( this.callbackArgs[ 0 ] ).controller;
			throw new ArgumentError( "What to do... ..." );
		}
		
		public function getPlayer():Player
		{
			if ( this.callbackArgs[ 0 ] is Player ) 
				return Player( this.callbackArgs[ 0 ] );
			throw new ArgumentError( "What to do... ..." );
		}
		
		public function getSourceCard():Card
		{
			if ( this.callbackArgs[ 0 ] is Card ) 
				return Card( this.callbackArgs[ 0 ] );
			throw new ArgumentError( "What to do... ..." );
		}
		
		public function getAttacker():Card
		{
			if ( this.callbackArgs[ 0 ] is Card && Card( this.callbackArgs[ 0 ] ).type.isCreature ) 
				return Card( this.callbackArgs[ 0 ] );
			throw new ArgumentError( "What to do... ..." );
		}
		
		public function getSummoned():Card
		{
			if ( this.callbackArgs[ 0 ] is Card && Card( this.callbackArgs[ 0 ] ).type.isCreature ) 
				return Card( this.callbackArgs[ 0 ] );
			throw new ArgumentError( "What to do... ..." );
		}
		
		public function getSummonedField():CreatureField
		{
			if ( this.callbackArgs[ 1 ] is CreatureField ) 
				return CreatureField( this.callbackArgs[ 1 ] );
			throw new ArgumentError( "What to do... ..." );
		}
		
	}

}