package duel.display.fx 
{
	import duel.display.cards.CardSprite;
	import duel.GameEntity;
	import flash.utils.Dictionary;
	
	/**
	 * ...
	 * @author ...
	 */
	public class CardAuraManager extends GameEntity 
	{
		protected var _selectable:Vector.<CardAura>;
		protected var _selectedInHand:CardAura;
		protected var _selectedOnField:CardAura;
		
		protected var _book:Dictionary;
		
		public function initialize():void 
		{
			_selectable = new Vector.<CardAura>();
			_book = new Dictionary()
		}
		
		//
		
		public function setToNone( card:CardSprite ):CardAura
		{
			if ( _book[ card ] == undefined ) return _book[ card ];
			removeAuraFrom( _book[ card ], card );
			return null;
		}
		
		public function setToSelectedInHand( card:CardSprite ):CardAura
		{
			if ( _book[ card ] == _selectedInHand ) return _book[ card ];
			if ( _selectedInHand == null ) _selectedInHand = new CardFlames();
			return addAuraTo( _selectedInHand, card );
		}
		
		public function setToSelectedOnField( card:CardSprite ):CardAura
		{
			if ( _book[ card ] == _selectedOnField ) return _book[ card ];
			if ( _selectedOnField == null ) _selectedOnField = new CardFlames();
			return addAuraTo( _selectedOnField, card );
		}
		
		public function setToSelectable( card:CardSprite ):CardAura
		{
			if ( _selectable.indexOf( _book[ card ] ) > -1 ) return _book[ card ];
			var aura:CardAura;
			for ( var i:int = 0; i < _selectable.length; i++ ) 
				if ( _selectable[ i ].parent == null )
				{
					aura = _selectable[ i ];
					break;
				}
			if ( aura == null )
			{
				aura = new CardAura0();
				_selectable.push( aura );
			}
			return addAuraTo( aura, card );
		}
		
		//
		
		protected function addAuraTo( aura:CardAura, card:CardSprite ):CardAura
		{
			if ( _book[ card ] != undefined )
				removeAuraFrom( _book[ card ], card );
				
			card.auraContainer.addChild( aura );
			_book[ card ] = aura;
			
			return aura;
		}
		
		protected function removeAuraFrom( aura:CardAura, card:CardSprite ):void
		{
			card.auraContainer.removeChild( aura );
			delete _book[ card ];
		}
		
	}

}