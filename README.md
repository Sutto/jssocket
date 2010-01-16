# JSSocket - Flash + Javascript for sweet, sockety love.

Fork of [Aman Gupta's jsSocket](http://github.com/tmm1/jssocket) with a rewritten
javascript library and simplified flash / haxe socket implementation. As such,
lib/JSSocket.hx is (c) Aman Gupta (tmm1) 2008.

It's like WebSockets but simpler. Use it as you would basic async sockets available
in most different programming languages.

## Requirements

* Flash 9 or higher on the client side (widely available)
* Super simple async api
* You must escape html / binary data

## Usage

    JSSocket.connect("host", port, function(socket) {
      
      socket.onOpen(function() {
        socket.send("Hello there!");
        console.log("Connected!");
      });
      
      socket.onData(function(data) {
        console.log("Got Data:", data);
      });
      
      socket.onClose(function(reason) {
        console.log("Lost connection, reason:", reason);
      });
      
    });

## License

Licensed under the [Ruby License](http://www.ruby-lang.org/en/LICENSE.txt)