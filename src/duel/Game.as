package duel
{
	import chimichanga.common.assets.AdvancedAssetManager;
	import chimichanga.common.display.Sprite;
	import dev.ProcessManagementInspector;
	import duel.cards.Card;
	import duel.cards.CardFactory;
	import duel.cards.CommonCardQuestions;
	import duel.cards.temp_database.TempCardsDatabase;
	import duel.display.cardlots.HandSprite;
	import duel.display.TableSide;
	import duel.gui.Gui;
	import duel.gui.GuiJuggler;
	import duel.processes.GameplayProcess;
	import duel.processes.GameplayProcessManager;
	import duel.processes.gameprocessing;
	import duel.processes.ProcessEvent;
	import duel.table.CreatureField;
	import duel.table.Field;
	import duel.table.Hand;
	import duel.table.IndexedField;
	import duel.table.TrapField;
	import flash.geom.Point;
	import starling.animation.IAnimatable;
	import starling.core.Starling;
	import starling.display.DisplayObjectContainer;
	import starling.display.Image;
	import starling.display.Quad;
	import starling.text.TextField;
	
	use namespace gameprocessing;
	
	[Event( name="turnStart",type="duel.GameEvents" )]
	[Event( name="turnEnd",type="duel.GameEvents" )]
	[Event( name="select",type="duel.GameEvents" )]
	[Event( name="deselect",type="duel.GameEvents" )]
	[Event( name="hover",type="duel.GameEvents" )]
	[Event( name="unhover",type="duel.GameEvents" )]
	[Event( name="destroy",type="duel.GameEvents" )]
	
	/**
	 * ...
	 * @author choephix
	 */
	public class Game extends DisplayObjectContainer implements IAnimatable
	{
		public static var current:Game;
		public static var frameNum:int = 0;
		
		//CONFIG::development
		public static var GODMODE:Boolean;
		
		public var currentPlayer:Player;
		public var processes:GameplayProcessManager;
		
		//
		public var jugglerStrict:GuiJuggler;
		public var jugglerGui:GuiJuggler;
		public var juggler:GuiJuggler;
		
		public var gui:Gui;
		public var selection:Selection;
		
		public var p1:Player;
		public var p2:Player;
		
		public var bg:Background;
		
		//
		public function Game()
		{
			current = this;
			initialize();
		}
		
		private function initialize():void
		{
			Starling.juggler.add( this );
			
			jugglerStrict = new GuiJuggler();
			jugglerGui = new GuiJuggler();
			juggler = new GuiJuggler();
			
			processes = new GameplayProcessManager();
			processes.addEventListener( ProcessEvent.CURRENT_PROCESS, onProcessAdvance );
			
			//
			p1 = generatePlayer( "player1" );
			p2 = generatePlayer( "player2" );
			p1.opponent = p2;
			p2.opponent = p1;
			
			// VISUALS
			bg = new Background( assets.getTexture( "bg" ) );
			bg.onClickedCallback = onBgClicked;
			addChild( bg );
			
			const CHAR_SCALE:Number = 0.5;
			const CHAR_MARGIN_Y:Number = 40;
			
			var char1:Image = assets.generateImage( "char1" );
			char1.alignPivot( "right", "bottom" );
			char1.x = App.W;
			char1.y = App.H - CHAR_MARGIN_Y;
			char1.scaleX = CHAR_SCALE;
			char1.scaleY = CHAR_SCALE;
			addChild( char1 );
			
			var char2:Image = assets.generateImage( "char2" );
			char2.alignPivot( "right", "top" );
			char2.x = 0;
			char2.y = CHAR_MARGIN_Y;
			char2.scaleX = -CHAR_SCALE;
			char2.scaleY = CHAR_SCALE;
			addChild( char2 );
			
			p2.tableSide = new TableSide( p2, true );
			p2.tableSide.x = App.W * 0.50;
			p2.tableSide.y = App.H * 0.30;
			addChild( p2.tableSide );
			
			p1.tableSide = new TableSide( p1, false );
			p1.tableSide.x = App.W * 0.50;
			p1.tableSide.y = App.H * 0.70;
			addChild( p1.tableSide );
			
			// GUI AND STUFF
			gui = new Gui();
			addChild( gui );
			
			selection = new Selection();
			
			p1.handSprite = new HandSprite( p1.hand );
			p1.handSprite.maxWidth = 1000;
			p1.handSprite.x = -450 + ( App.W - p1.handSprite.maxWidth ) * 0.5;
			p1.handSprite.y = -p1.tableSide.y + App.H;
			
			p2.handSprite = new HandSprite( p2.hand );
			p2.handSprite.maxWidth = 950;
			p2.handSprite.x = -300 + ( App.W - p2.handSprite.maxWidth ) * 0.5;
			p2.handSprite.y = -p2.tableSide.y;
			p2.handSprite.flipped = true;
			
			// START GAME
			currentPlayer = p1;
			currentPlayer.opponent = p2;
			
			CONFIG::development
			{
				var pmi:ProcessManagementInspector = new ProcessManagementInspector( processes );
				addChild( pmi );
				pmi.x = 200;
				pmi.y = 400;
			/** / ProcessTester.initTest1( processes ); return /**/
			}
			
			//
			
			// PREPARE DECKS
			const DECK1:Array = [];
			const DECK2:Array = [];
			
			var i:int;
			
			i = 0;
			
			do
			{
				DECK1.push( i );
			} while ( TempCardsDatabase.F[ ++i ] != null )
			
			++i
			
			do
			{
				DECK2.push( i );
			} while ( TempCardsDatabase.F[ ++i ] != null )
			
			++i
			
			do
			{
				DECK1.push( i );
				DECK2.push( i );
			} while ( TempCardsDatabase.F[ ++i ] != null )
			
			// PREPARE GAMEPLAY
			const DECK1_SIZE:uint = Math.min( DECK1.length, G.MAX_DECK_SIZE );
			const DECK2_SIZE:uint = Math.min( DECK2.length, G.MAX_DECK_SIZE );
			
			var time:Number = 0.7;
			var c:Card;
			for ( i = 0; i < DECK1_SIZE; i++ )
			{
				time += .010;
				c = CardFactory.produceCard( DECK1[ i ] );
				c.owner = p1;
				c.faceDown = true;
				jugglerStrict.delayCall( p1.deck.addCard, time, c, true );
			}
			
			for ( i = 0; i < DECK2_SIZE; i++ )
			{
				time += .010;
				c = CardFactory.produceCard( DECK2[ i ] );
				c.owner = p2;
				c.faceDown = true;
				jugglerStrict.delayCall( p2.deck.addCard, time, c, true );
			}
			
			jugglerStrict.delayCall( drawCards, time + .360 );
			function drawCards():void
			{
				processes.prepend_Draw( p1, G.INIT_HAND_SIZE );
				processes.prepend_Draw( p2, G.INIT_HAND_SIZE );
			}
			
		}
		
		public function destroy():void
		{
			dispatchEventWith( GameEvents.DESTROY );
			Starling.juggler.remove( this );
			removeFromParent( true );
		}
		
		public function advanceTime( time:Number ):void
		{
			frameNum++;
			
			jugglerStrict.advanceTime( time );
			jugglerGui.advanceTime( time );
			juggler.advanceTime( time );
			
			gui.advanceTime( time );
			p1.handSprite.advanceTime( time );
			p2.handSprite.advanceTime( time );
			
			if ( jugglerStrict.isIdle )
				processes.advanceTime( time );
			
			if ( selectedCard != null && !canSelect( selectedCard ) )
				selectCard( null );
			
			//bg.visible = interactable;
			this.touchable = interactable;
			
			updateSelectables();
		}
		
		// PROCESSES
		
		private function onProcessAdvance( e:ProcessEvent ):void
		{
			var p:GameplayProcess = e.process as GameplayProcess;
			
			if ( p == null )
				return;
			
			gameInspectProcess( p );
			playerInspectProcess( currentPlayer.opponent, p );
			playerInspectProcess( currentPlayer, p );
		}
		
		private function gameInspectProcess( p:GameplayProcess ):void
		{
			if ( p.name == GameplayProcess.TURN_END )
				dispatchEventWith( GameEvents.TURN_END );
			if ( p.name == GameplayProcess.TURN_START )
				dispatchEventWith( GameEvents.TURN_START );
		}
		
		private function playerInspectProcess( player:Player, p:GameplayProcess ):void
		{
			var i:int;
			
			if ( p.isInterrupted )
				return;
			
			for ( i = 0; i < player.fieldsT.count; i++ )
			{
				if ( player.fieldsT.getAt( i ).isEmpty )
					continue;
				
				player.fieldsT.getAt( i ).topCard.onGameProcess( p );
				
				if ( p.isInterrupted )
					return;
			}
			
			for ( i = 0; i < player.fieldsC.count; i++ )
			{
				if ( player.fieldsC.getAt( i ).isEmpty )
					continue;
				
				player.fieldsC.getAt( i ).topCard.onGameProcess( p );
				
				if ( p.isInterrupted )
					return;
			}
			
			for ( i = 0; i < player.hand.cardsCount; i++ )
			{
				player.hand.getCardAt( i ).onGameProcess( p );
				
				if ( p.isInterrupted )
					return;
			}
			
			for ( i = 0; i < player.grave.cardsCount; i++ )
			{
				player.grave.getCardAt( i ).onGameProcess( p );
				
				if ( p.isInterrupted )
					return;
			}
		}
		
		// INTERACTION
		public function onFieldClicked( field:Field ):void
		{
			if ( selectedCard )
			{
				var c:Card = selectedCard;
				var p:Player = c.controller;
				
				if ( c.isInHand )
				{
					if ( canSummon() )
					{
						performCardSummon( c, field as CreatureField );
						return;
					}
					if ( canSetTrap() )
					{
						performTrapSet( c, field as TrapField );
						return;
					}
				}
				
				selectCard( null );
				
				if ( canRelocate() )
				{
					performRelocation( c, field as CreatureField );
					return;
				}
				
				if ( c.isInPlay && field.owner == currentPlayer.opponent )
				{
					performCardAttack( c );
					return;
				}
				
				// DEV SHIT
				CONFIG::development
				{
					if ( GODMODE && field.type.isGraveyard && field.owner == p )
						processes.prepend_AddToGrave( c );
				}
			}
			else if ( field is IndexedField && !field.isEmpty )
			{
				onCardClicked( IndexedField( field ).topCard );
			}
			else
			{
				// DEV SHIT
				CONFIG::development
				{
					if ( GODMODE && field.type.isDeck )
					{
						processes.prepend_Draw( field.owner, 5 );
						return;
					}
					if ( GODMODE && field.type.isGraveyard )
					{
						processes.prepend_AddToHand( field.topCard, currentPlayer );
						return;
					}
				}
				
				if ( field.type.isDeck && field.owner == currentPlayer )
				{
					processes.prepend_Draw( field.owner, 1 );
					return;
				}
			}
			
			function canSummon():Boolean
			{
				if ( !canPerformAction() )
					return false;
				if ( !c.type.isCreature )
					return false;
				if ( field as CreatureField == null )
					return false;
				return CommonCardQuestions.canSummonHere( c, field as CreatureField );
			}
			function canSetTrap():Boolean
			{
				if ( !canPerformAction() )
					return false;
				if ( !c.type.isTrap )
					return false;
				if ( field as TrapField == null )
					return false;
				return CommonCardQuestions.canPlaceTrapHere( c, field as TrapField );
			}
			function canRelocate():Boolean
			{
				if ( !c.type.isCreature )
					return false;
				if ( field as CreatureField == null )
					return false;
				return CommonCardQuestions.canRelocateHere( c, field as CreatureField );
			}
		}
		
		public function onCardClicked( card:Card ):void
		{
			if ( selectedCard == null )
			{
				if ( card.controller == currentPlayer )
				{
					if ( card.lot is Hand )
					{
						if ( canSelect( card ) )
							selectCard( selectedCard == card ? null : card );
						return;
					}
					else if ( canSelect( card ) )
					{
						selectCard( card );
					}
				}
			}
			else
			{
				var c:Card = selectedCard;
				
				if ( c != card && card.lot is Hand )
				{
					selectCard( card );
					return;
				}
				
				selectCard( null );
				
				if ( c != card && canSelect( card ) )
				{
					selectCard( card );
					return;
				}
				
				/// DEV SHIT
				
				CONFIG::development
				{
				/** /
				   // MANUALLY ADD TO GRAVE
				   if ( currentPlayer.grave.containsCard( card ) )
				   {
				   processes.enterGrave( c );
				   return;
				   }
				   /** /
				   // STACK CARDS LIKE IT'S NOTHING
				   if ( c.lot != card.lot && card.controller == c.controller )
				   {
				   if ( !card.lot.isEmpty )
				   c.faceDown = card.lot.getFirstCard().faceDown;
				   card.lot.addCard( c );
				   }
				 /**/
				}
			}
		}
		
		public function onCardRollOver( card:Card ):void
		{
			if ( !interactable )
				return;
			if ( card.controller.controllable )
				card.sprite.peekIn();
			dispatchEventWith( GameEvents.HOVER, false, card );
		}
		
		public function onCardRollOut( card:Card ):void
		{
			if ( !interactable )
				return;
			if ( card.controller.controllable )
				card.sprite.peekOut();
			dispatchEventWith( GameEvents.UNHOVER, false, card );
		}
		
		private function onBgClicked():void
		{
			selectCard( null );
		}
		
		// GAMEPLAY
		
		public function endTurn():void
		{
			selectCard( null );
			processes.append_TurnEnd( currentPlayer );
		}
		
		public function canPerformAction():Boolean
		{
			CONFIG::sandbox { return true }
			return currentPlayer.mana.current > 0;
		}
		
		public function performCardSummon( c:Card, field:CreatureField ):void
		{
			selectCard( null );
			processes.append_SummonHere( c, field, true );
		}
		
		public function performTrapSet( c:Card, field:TrapField ):void
		{
			selectCard( null );
			processes.append_TrapSet( c, field, true );
		}
		
		public function performCardAttack( c:Card ):void
		{
			selectCard( null );
			processes.append_Attack( c, false );
		}
		
		public function performRelocation( c:Card, field:CreatureField ):void
		{
			selectCard( null );
			processes.append_Relocation( c, field, false );
		}
		
		public function performSafeFlip( c:Card ):void
		{
			selectCard( null );
			processes.prepend_SafeFlip( c );
		}
		
		//
		public function endGame():void
		{
			var q:Quad = new Quad( App.W, App.H, 0x0 );
			q.alpha = 0;
			addChild( q );
			touchable = false;
			
			Starling.juggler.remove( this );
			Starling.juggler.tween( q, .440, { alpha: 1.0, onComplete: destroy } );
		}
		
		//
		public function selectCard( card:Card ):void
		{
			if ( selectedCard != null )
				dispatchEventWith( GameEvents.DESELECT, false, selectedCard );
			
			selection.selectedCard = card;
			
			if ( selectedCard != null )
				dispatchEventWith( GameEvents.SELECT, false, selectedCard );
			
			updateSelectables();
		}
		
		public function updateSelectables():void
		{
			var card:Card = selectedCard;
				
			/// HAND
			
			var i:int = 0;
			for ( 0; i < currentPlayer.hand.cardsCount; i++ )
				currentPlayer.hand.getCardAt( i ).sprite.isSelectable = 
					card == null ? canPlayAtAll( currentPlayer.hand.getCardAt( i ) ) : false;
			for ( 0; i < currentPlayer.opponent.hand.cardsCount; i++ )
				currentPlayer.opponent.hand.getCardAt( i ).sprite.isSelectable = false;
			
			/// COMBAT FIELDS
			var clr:uint;
			var cond:Function;
			
			clr = 0; cond = null;
			p1.fieldsC.forEachField( setFieldAuraColor );
			p1.fieldsT.forEachField( setFieldAuraColor );
			p2.fieldsC.forEachField( setFieldAuraColor );
			p2.fieldsT.forEachField( setFieldAuraColor );
			
			if ( card == null )
			{
				clr = 0xFFFFFF; cond = isSelectable;
				currentPlayer.fieldsC.forEachField( setFieldAuraColor );
			}
			else
			{
				if ( card.lot is Hand )
				{
					if ( card.type.isTrap )
					{
						clr = 0xB062FF; cond = canSetTrapTo;
						currentPlayer.fieldsT.forEachField( setFieldAuraColor );
					}
					if ( card.type.isCreature )
					{
						clr = 0xCC530B; cond = canSummonTo;
						currentPlayer.fieldsC.forEachField( setFieldAuraColor );
					}
				}
				else
				if ( card.isInPlay )
				{
					if ( card.type.isCreature && !card.exhausted )
					{
						if ( CommonCardQuestions.canPerformAttack( card ) )
						{
							clr = 0xD71500; //cond = canAttack;
							card.indexedField.opposingCreatureField.sprite.setSelectableness( clr )
							if ( card.indexedField.opposingCreatureField.isEmpty )
								card.indexedField.opposingTrapField.sprite.setSelectableness( clr )
						}
						clr = 0x1050AF; cond = canRelocateTo;
						currentPlayer.fieldsC.forEachField( setFieldAuraColor );
					}
				}
			}
			
			/// SLECTED, IN HAND
			function canSetTrapTo( f:TrapField ):Boolean
			{ return CommonCardQuestions.canPlaceTrapHere( card, f ) }
			function canSummonTo( f:CreatureField ):Boolean
			{ return CommonCardQuestions.canSummonHere( card, f ) }
			
			/// SELECTED, ON FIELD
			//function canAttack( f:CreatureField ):Boolean
			//{ return CommonCardQuestions.canPerformAttack( card ) ) }
			function canRelocateTo( f:CreatureField ):Boolean
			{ return CommonCardQuestions.canRelocateHere( card, f ) }
			
			/// NOTHING SELECTED
			function isSelectable( f:Field ):Boolean
			{ return f.topCard != null && canSelect( f.topCard ) }
			
			function setFieldAuraColor( f:Field ):void
			{
				f.sprite.setSelectableness( cond == null || cond( f ) ? clr : 0 );
			}
		}
		
		public function get selectedCard():Card
		{
			return selection.selectedCard
		}
		
		//
		private function generatePlayer( name:String ):Player
		{
			return new Player( name, G.INIT_LP );
		}
		
		//
		public function get interactable():Boolean
		{
			return jugglerStrict.isIdle && jugglerGui.isIdle && processes.isIdle;
		}
		
		// FX
		
		public function showFloatyText( p:Point, text:String, color:uint ):void
		{
			var o:Sprite = new Sprite();
			addChild( o );
			
			var t:TextField = new TextField( 500, 100, text, "Impact", 36, color, false );
			t.alignPivot();
			
			var q:Quad = new Quad( t.textBounds.width, t.textBounds.height, 0x0 );
			q.alignPivot();
			q.alpha = .6;
			
			o.addChild( q );
			o.addChild( t );
			o.x = p.x;
			o.y = p.y;
			juggler.tween( o, 2.5,
				{
					delay : .500,
					alpha : .0,
					onComplete : o.removeFromParent,
					onCompleteArgs : [true]
				} );
		}
		
		// QUESTIONS
		
		public function canSelect( card:Card ):Boolean
		{
			if ( card.controller != currentPlayer )
				return false;
			if ( card.type.isTrap && card.isInPlay )
				return false;
			if ( card.type.isCreature && card.exhausted )
				return false;
			if ( card.field && card.field.type.isGraveyard )
				return false;
			if ( card.field && card.field.type.isDeck )
				return false;
			return true;
		}
		
		public function canPlayAtAll( c:Card ):Boolean
		{
			if ( c.type.isCreature )
				return currentPlayer.fieldsC.hasAnyFieldThat( canSummonTo );
			if ( c.type.isTrap )
				return currentPlayer.fieldsT.hasAnyFieldThat( canSetTrapTo );
			
			function canSummonTo( f:CreatureField ):Boolean
			{ return CommonCardQuestions.canSummonHere( c, f ); }
			function canSetTrapTo( f:TrapField ):Boolean
			{ return CommonCardQuestions.canPlaceTrapHere( c, f as TrapField ) }
			
			return false;
		}
		
		//
		protected function get assets():AdvancedAssetManager
		{
			return App.assets
		}
	}
}