class JSSocket {
  static var socket:flash.net.Socket;
  static var id:String;
  static dynamic var state:String;
 
  private static function invokeExternalCallback(type, data:Dynamic) {
    flash.external.ExternalInterface.call('JSSocket.callback', id, type, data);
  }
  
  #if debugEnabled
  private static function debug(data:Dynamic) {
    flash.external.ExternalInterface.call('JSSocket.debug', ("Flash: " + data.toString()));
  }
  #end
 
  static function main() {
    // Allow the domain
    flash.system.Security.allowDomain("*");
    state = "created";
    id = flash.Lib.current.loaderInfo.parameters.id;
    #if debugEnabled
    // Expose the socket wrappers to JS.
    debug("Adding external callbacks - id is " + id);
    // Expose stateName.
    debug("ExternalInterface.available // " + flash.external.ExternalInterface.available);
    #end
    flash.external.ExternalInterface.addCallback("state", currentState);
    flash.external.ExternalInterface.addCallback("open",  open);
    flash.external.ExternalInterface.addCallback("send",  send);
    flash.external.ExternalInterface.addCallback("close", close);
    #if debugEnabled
    debug("Exposed, ready to go! - About to call load.");
    #end
    state = "loading";
    invokeExternalCallback('load', true);
    state = "loaded";
  }
  
  static function currentState() {
    return state;
  }
 
  static function open(host, port) {
    state = "preconnect";
    #if debugEnabled
    debug("connect(" + host + ", " + port + "); called. Preparing to connect.");
    debug("Loading policy file.");
    #end
    flash.system.Security.loadPolicyFile('xmlsocket://' + host + ':' + port);
    #if debugEnabled
    debug("Creating socket and adding event listeners");
    #end
    socket = new flash.net.Socket();
    socket.addEventListener(flash.events.Event.CONNECT, function(s){
      invokeExternalCallback('open', true);
      state = "opened";
    });
    socket.addEventListener(flash.events.Event.CLOSE, function(e){
      invokeExternalCallback('close', null);
      state = "closed-stopped";
    });
    socket.addEventListener(flash.events.IOErrorEvent.IO_ERROR, function(e){
      invokeExternalCallback('close', e.text);
      state = "closed-error";
    });
    socket.addEventListener(flash.events.SecurityErrorEvent.SECURITY_ERROR, function(e){
      invokeExternalCallback('close', e.text);
      state = "closed-error";
    });
    socket.addEventListener(flash.events.ProgressEvent.SOCKET_DATA, function(d){
      var size = socket.bytesAvailable;
      var data = new flash.utils.ByteArray();
      socket.readBytes(data);
      var realData = data.toString();
      #if debugEnabled
      debug("Got " + size + " bytes of data, = " + data);
      #end
      invokeExternalCallback('data', realData);
    });
    state = "opening";
    #if debugEnabled
    debug("Connecting with socket to " + host + ":" + port);
    #end
    socket.connect(host, Std.parseInt(port));
    return true;
  }
 
  static function send(data:String) {
    #if debugEnabled
    debug("Preparing to write data: " + data);
    #end
    if (socket.connected && data.length > 0) {
      var t = new flash.utils.Timer(0, 1);
      t.addEventListener(flash.events.TimerEvent.TIMER, function(d){
        #if debugEnabled
        debug("Writing data: " + data);
        #end
        socket.writeUTFBytes(data);
        socket.flush();
      });
      t.start();
      return true;
    } else return false;
  }
 
  static function close() {
    #if debugEnabled
    debug("Called close()");
    #end
    if (socket.connected) socket.close();
    state = "disconnected";
  }
}