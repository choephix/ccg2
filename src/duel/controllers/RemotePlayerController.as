package duel.controllers 
{
	import chimichanga.debug.logging.error;
	import duel.cards.Card;
	import duel.Game;
	import duel.players.Player;
	import flash.events.Event;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.net.URLRequestHeader;
	
	/**
	 * ...
	 * @author choephix
	 */
	public class RemotePlayerController extends PlayerController 
	{
		private static const COOLDOWN:Number =  .100; // 1.0 .1
		private static const PINGTIME:Number = 1.500; // 1.0 .1
		
		private var url:String;
		private var urlLoader:URLLoader;
		private var urlRequest:URLRequest;
		
		private var isBusy:Boolean;
		
		private var actionQueue:Array = [];
		private var cooldown:Number = COOLDOWN;
		private var pingTimeout:Number = PINGTIME;
		
		public function RemotePlayerController( p:Player ) { super( p ) }
		
		override public function initialize():void 
		{
			url = "http://localhost/ccg2f/read.php?p=" + player.name;
			urlLoader = new URLLoader();
			urlLoader.addEventListener( Event.COMPLETE, onPingComplete );
			urlRequest = new URLRequest( url );
			urlRequest.requestHeaders.push( new URLRequestHeader("pragma", "no-cache") );
		}
		
		override public function advanceTime( time:Number ):void
		{
			if ( !active ) return;
			if ( !jugglerStrict.isIdle ) return;
			if ( !game.processes.isIdle ) return;
			if ( isBusy ) return;
			
			if ( actionQueue.length == 0 )
			{
				if ( pingTimeout > .0 )
					pingTimeout -= time;
				else
				{
					ping();
					pingTimeout = PINGTIME;
				}
				
				cooldown = COOLDOWN;
				return;
			}
			
			if ( cooldown > .0 )
				cooldown -= time;
			else
			{
				doNextAction();
				cooldown = COOLDOWN;
			}
		}
		
		public function ping():void
		{
			isBusy = true;
			
			urlRequest.url = url + "&shit=" + Math.random();
			urlLoader.load( urlRequest );
			
			Game.log( "4:marco ("+urlRequest.url+")" );
		}
		
		private function onPingComplete( e:Event ):void 
		{
			Game.log( "4:polo - " + urlLoader.data );
			isBusy = false;
			
			processReceivedData( urlLoader.data );
		}
		
		private function processReceivedData( data:String ):void 
		{
			actionQueue = data.split("|");
			
			while ( actionQueue[0] == "" )
				actionQueue.shift();
			
			if ( actionQueue.length > 0 )
				trace ( actionQueue );
		}
		
		private function doNextAction():void 
		{
			var action:Array = String( actionQueue.shift() ).split( ":" );
			var c:Card;
			
			trace( "Will do action " + action );
			
			switch( action[0] )
			{
				case "attack" :
					c = player.fieldsC.getAt( action[1] ).topCard;
					if ( c == null || ( faq.canCreatureAttack( c, true ) != null ) )
					{
						error( "Card " + c + " cannot attack" );
						return;
					}
					performActionAttack( c );
					break;
				case "summon" :
					if ( player.hand.findByUid( action[1] ) == null )
					{
						error( "Card#" + action[1] + " not in " + player + "'s hand - " + player.hand );
						return;
					}
					performActionSummon( player.hand.findByUid( action[1] ), player.fieldsC.getAt( action[2] ) );
					break;
				case "trapset" :
					if ( player.hand.findByUid( action[1] ) == null )
					{
						error( "Card#" + action[1] + " not in " + player + "'s hand - " + player.hand );
						return;
					}
					performActionTrapSet( player.hand.findByUid( action[1] ), player.fieldsT.getAt( action[2] ) );
					break;
				case "draw":
					performActionDraw();
					break;
				case "turnend":
					performActionTurnEnd();
					break;
			}
		}
		
		public function populateActionQueue():void
		{
			actionQueue.length = 0;
			
			var mana:int = player.mana.current;
			var i:int = 0;
			var j:int = 0;
			var c:Card;
			
			var blacklistC:Array = [];
			var blacklistT:Array = [];
			
			for ( i = 0; i < player.hand.cardsCount && mana > 0; i++ ) 
			{
				c = player.hand.getCardAt( i );
				
				if ( c.type.isCreature )
				{
					for ( j = 0; j < player.fieldsC.count; j++ ) 
						if ( faq.canSummonCreatureOn( c, player.fieldsC.getAt( j ), true ) == null )
						{
							if ( blacklistC.indexOf( j ) > -1 ) continue;
							actionQueue.push( "summon" + ":" + c.uid + ":" + j );
							blacklistC.push( j );
							mana -= c.cost;
							break;
						}
				}
				else
				if ( c.type.isTrap )
				{
					for ( j = 0; j < player.fieldsT.count; j++ ) 
						if ( faq.canSetTrapOn( c, player.fieldsT.getAt( j ), true ) == null )
						{
							if ( blacklistT.indexOf( j ) > -1 ) continue;
							actionQueue.push( "trapset" + ":" + c.uid + ":" + j );
							blacklistT.push( j );
							mana -= c.cost;
							break;
						}
				}
			}
			
			while ( mana > 0 )
			{
				actionQueue.push( "draw" );
				mana--;
			}
			
			for ( j = 0; j < player.fieldsC.count; j++ ) 
			{
				c = player.fieldsC.getAt( j ).topCard;
				if ( c == null ) continue;
				if ( faq.canCreatureAttack( c, true ) != null ) continue;
				actionQueue.push( "attack" + ":" + j );
			}
						
			actionQueue.push( "turnend" );
			
			trace ( "\n\nNEW ACTION QUEUE FOR " + player + "\n" + actionQueue.join("\n") );
		}
		
		override public function onTurnStart():void
		{ }
		
	}

}