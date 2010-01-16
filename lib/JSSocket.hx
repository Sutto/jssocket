class JSSocket {
  static var socket:flash.net.Socket;
  static var id:String;
 
  private static function invokeExternalCallback(type, data:Dynamic) {
    flash.external.ExternalInterface.call('JSSocket.callback', id, type, data);
  }
 
  private static function debug(data:Dynamic) {
    flash.external.ExternalInterface.call('JSSocket.debug', ("Flash: " + data.toString()));
  }
 
  static function main() {
    id = flash.Lib.current.loaderInfo.parameters.id;
    // Expose the socket wrappers to JS.
    debug("Adding external callbacks - id is " + id);
    flash.external.ExternalInterface.addCallback("open",  open);
    flash.external.ExternalInterface.addCallback("send",  send);
    flash.external.ExternalInterface.addCallback("close", close);
    debug("Exposed, ready to go!");
    invokeExternalCallback('load', true);
  }
 
  static function open(host, port) {
    debug("Loading policy file.");
    flash.system.Security.loadPolicyFile('xmlsocket://' + host + ':' + port);
    debug("Creating socket and adding event listeners");
    socket = new flash.net.Socket();
    socket.addEventListener(flash.events.Event.CONNECT, function(s){
      invokeExternalCallback('open', true);
    });
    socket.addEventListener(flash.events.Event.CLOSE, function(e){
      invokeExternalCallback('close', null);
    });
    socket.addEventListener(flash.events.IOErrorEvent.IO_ERROR, function(e){
      invokeExternalCallback('close', e.text);
    });
    socket.addEventListener(flash.events.SecurityErrorEvent.SECURITY_ERROR, function(e){
      invokeExternalCallback('close', e.text);
    });
    socket.addEventListener(flash.events.ProgressEvent.SOCKET_DATA, function(d){
      var size = socket.bytesAvailable;
      var data = new flash.utils.ByteArray();
      socket.readBytes(data);
      var realData = data.toString();
      debug("Got " + size + " bytes of data, = " + data);
      invokeExternalCallback('data', realData);
    });
    
    debug("Connecting with socket to " + host + ":" + port);
    return socket.connect(host, Std.parseInt(port));
  }
 
  static function send(data:String) {
    debug("Preparing to write data: " + data);
    if (socket.connected && data.length > 0) {
      var t = new flash.utils.Timer(0, 1);
      t.addEventListener(flash.events.TimerEvent.TIMER, function(d){
        debug("Writing data: " + data);
        socket.writeUTFBytes(data);
        socket.flush();
      });
      t.start();
      return true;
    } else return false;
  }
 
  static function close() {
    if (socket.connected) socket.close();
  }
}