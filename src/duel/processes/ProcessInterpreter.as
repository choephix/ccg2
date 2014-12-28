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
	public class ProcessInterpreter 
	{
		public static function getIndex( p:Process ):int
		{
			if ( p.callbackArgs[ 0 ] is Card ) 
			{
				if ( Card( p.callbackArgs[ 0 ] ).isInPlay )
					return Card( p.callbackArgs[ 0 ] ).indexedField.index;
				else
					return -1;
			}
			if ( p.callbackArgs[ 0 ] is IndexedField ) 
				return IndexedField( p.callbackArgs[ 0 ] ).index;
			throw new ArgumentError( "What to do... ..." );
		}
		
		public static function getController( p:Process ):Player
		{
			if ( p.callbackArgs[ 0 ] is Card ) 
				return Card( p.callbackArgs[ 0 ] ).controller;
			throw new ArgumentError( "What to do... ..." );
		}
		
		public static function getSourceCard( p:Process ):Card
		{
			if ( p.callbackArgs[ 0 ] is Card ) 
				return Card( p.callbackArgs[ 0 ] );
			throw new ArgumentError( "What to do... ..." );
		}
		
		public static function getAttacker( p:Process ):Card
		{
			if ( p.callbackArgs[ 0 ] is Card && Card( p.callbackArgs[ 0 ] ).type.isCreature ) 
				return Card( p.callbackArgs[ 0 ] );
			throw new ArgumentError( "What to do... ..." );
		}
		
		public static function getSummoned( p:Process ):Card
		{
			if ( p.callbackArgs[ 0 ] is Card && Card( p.callbackArgs[ 0 ] ).type.isCreature ) 
				return Card( p.callbackArgs[ 0 ] );
			throw new ArgumentError( "What to do... ..." );
		}
		
		public static function getSummonedField( p:Process ):CreatureField
		{
			if ( p.callbackArgs[ 1 ] is CreatureField ) 
				return CreatureField( p.callbackArgs[ 1 ] );
			throw new ArgumentError( "What to do... ..." );
		}
		
	}

}