package screens.lobby 
{
	import chimichanga.common.display.Sprite;
	import chimichanga.debug.logging.error;
	import chimichanga.debug.logging.log;
	import com.reyco1.multiuser.data.UserObject;
	import com.reyco1.multiuser.MultiUserSession;
	import duel.Game;
	import flash.system.Capabilities;
	import starling.animation.Juggler;
	import starling.display.Button;
	import starling.display.Quad;
	import starling.events.Event;
	
	CONFIG::air
	{
	import flash.filesystem.File;
	}
	
	/**
	 * ...
	 * @author choephix
	 */
	public class Lobby extends Sprite 
	{
		private const SERVER_ADDRESS:String	= "rtmfp://p2p.rtmfp.net/dd445b2af11141d2f0638908-3a1ceb27480a";
		private var connection:MultiUserSession;
		public var myUser:UserObject;
		
		/// Must expect tweo args: roomName:String, opponentName:String
		public var readyCallback:Function;
		
		///
		public var buttons:Sprite;
		
		public function Lobby() 
		{
			super();
			initialize();
		}
		
		public function initialize():void
		{
			connection = new MultiUserSession( SERVER_ADDRESS, "ccg2/lobby" );
			connection.onConnect 		= onConnected;
			connection.onUserAdded 		= onUserAdded;
			connection.onUserRemoved 	= onUserRemoved;
			connection.onUserExpired 	= onUserExpired;
			connection.onObjectRecieve 	= onUserObjectRecieved;
			
			var myEnterTime:Number = new Date().time;
			var myName:String = "User_" + myEnterTime.toString( 36 ).toUpperCase();
			var myColor:uint = Math.random() * 0xFFFFFF;
			
			trace ( myEnterTime );
			
			CONFIG::air
			{ myName = File.userDirectory.name }
			
			CONFIG::mobile
			{ myName = Capabilities.cpuArchitecture+"_"+ myEnterTime.toString( 36 ) }
			
			connection.connect( myName, new UserDetails( myColor, myEnterTime ) );
			////
			
			var q:Quad = new Quad( App.STAGE_W, App.STAGE_H, 0x110044 );
			addChild( q );
			
			buttons = new Sprite();
			addChild( buttons );
			buttons.y = 50;
			buttons.x = .5 * q.width;
		}
		
		override public function dispose():void 
		{
			connection.close();
			connection = null;
			
			myUser = null;
			readyCallback = null;
			
			buttons.removeFromParent( true );
			buttons = null;
			
			super.dispose();
		}
		
		private function addButton( name:String, call:Function, clr:uint ):Button 
		{
			var b:Button = new Button( App.assets.getTexture('btn'), name );
			b.fontColor = clr;
			//b.scaleX = 2.0;
			//b.scaleY = 1.5;
			b.x = -.5 * b.width;
			b.y = buttons.height;
			buttons.addChild( b );
			b.addEventListener( Event.TRIGGERED, call );
			return b;
		}
		
		public function destroy():void
		{
			connection.close();
			connection = null;
			myUser = null;
		}
		
		protected function onConnected(user:UserObject):void					
		{
			log( "I'm connected"
				+ "\n" + "username: " + user.name
				+ "\n" + "userid: " + user.id.substr(0,16) + "..."
				+ "\n" + "totalusers: " + connection.userCount
				+ "\n"
				);
			
			myUser = user;
			var details:UserDetails = myUser.details as UserDetails;
			details.button = addButton( "HOST AS "+user.name, becomeHost, details.color );
		}
		
		protected function onUserAdded( user:UserObject ):void
		{
			log( "User added"
				+ "\n" + "username: " + user.name
				+ "\n" + "userid: " + user.id.substr(0,16) + "..."
				+ "\n" + "totalusers: " + connection.userCount
				+ "\n"
				); 
			
			var details:UserDetails = user.details as UserDetails;
			
			if ( details == null )
				user.details = details = UserDetails.fromObject( user.details );
			
			if ( details.isHost )
				onUserBecameHost( user, user.details.room );
		}
		
		protected function onUserRemoved(user:UserObject):void				
		{
			log( "User disconnected"
				+ "\n" + "username: " + user.name
				+ "\n" + "userid: " + user.id.substr(0,16) + "..."
				+ "\n" + "totalusers: " + connection.userCount
				+ "\n"
				);
				
			if ( user.details.button )
				Button( user.details.button ).removeFromParent( true );
		}
		
		protected function onUserExpired(user:UserObject):void				
		{
			log( "User expired"
				+ "\n" + "username: " + user.name
				+ "\n" + "userid: " + user.id.substr(0,16) + "..."
				+ "\n" + "totalusers: " + connection.userCount
				+ "\n"
				); 
		}
		
		public function sendMyUserObject( data:Object ):void			
		{
			log("sendMyUserObject: " + data ); 
			connection.sendObject( data );			
		}
		
		protected function onUserObjectRecieved( userID:String, data:Object ):void
		{
			var user:UserObject = connection.userList[userID];
			
			log( "onUserObjectRecieved[" + user.name + "]: " + data.type );
			
			if ( data == null )
			{
				error( "Unrecognized EventObject" );
				return;
			}
				
			switch ( data.type )
			{
				case E.BECOME_HOST:
					onUserBecameHost( user, data.detail as String );
					break;
				case E.JOIN:
					if ( data.detail == myUser.id )
						onUserJoinMe( user );
					break;
				case E.UNDEFINED:
					error( "received message of type UNDEFINED" );
					break;
			}
		}
		
		private function onUserBecameHost( user:UserObject, room:String ):void 
		{
			( room == null ? error : trace )( user.name + " became host of " + room );
			
			var details:UserDetails = user.details as UserDetails;
			
			details.isHost = true;
			details.room = room;
				
			if ( details.button )
				error( "User already had button" );
			else
				details.button = addButton( "JOIN " + user.name, joinUser, details.color );
				
			function joinUser():void
			{
				myUser.details.room = room;
				sendMyUserObject( { type : E.JOIN, detail : user.id } );
				trace( "I want to join " + user.name + " in " + room );
				
				onReady( user.details.room, user.name );
			}
		}
		
		private function onUserJoinMe(user:UserObject):void 
		{
			trace( user.name + " wants joined me in " + myUser.details.room );
			
			onReady( myUser.details.room, user.name );
		}
		
		private function becomeHost():void 
		{
			
			myUser.details.isHost = true;
			UserDetails( myUser.details ).button.enabled = false;
			
			var room:String = myUser.name + "_" + Number(myUser.details.logtime).toString(36);
			
			myUser.details.room = room;
			
			sendMyUserObject( { type : E.BECOME_HOST, detail : room } );
			
			trace( "BECAME HOST OF ROOM " + room );
		}
		
		private function onReady( room:String, enemy:String ):void
		{
			trace ( "ready to head to room '" + room + "' to play against " + enemy );
			
			readyCallback( room, enemy );
			removeFromParent( true );
		}
		
	}
}

class E {
	static public const BECOME_HOST:String = "becomeHost";
	static public const JOIN:String = "join";
	static public const UNDEFINED:String = "undefined";
}

import starling.display.Button;

class UserDetails {
	public var color:uint = 0xFFFFFF;
	public var logtime:Number = 0.0;
	
	public var isHost:Boolean = false;
	public var room:String = null;
	
	public var button:Button = null;
	
	public function UserDetails( color:uint, logtime:Number )
	{
		this.color = color;
		this.logtime = logtime;
	}
	
	public function updateFromObject( data:Object ):UserDetails
	{
		if ( data.color != undefined )
			color = data.color;
		if ( data.logtime != undefined )
			logtime = data.logtime;
			
		if ( data.isHost != undefined )
			isHost = data.isHost;
		if ( data.room != undefined )
			room = data.room;
			
		return this;
	}
	
	public function toString():String 
	{ return "[UserDetails color=" + color + " logtime=" + logtime + " isHost=" + isHost + "]" }
	
	public static function fromObject( o:Object ):UserDetails
	{ return new UserDetails( 0, 0 ).updateFromObject( o ) }
}

