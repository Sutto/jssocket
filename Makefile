default: flash/jssocket.swf

flash/jssocket.swf: lib/JSSocket.hx
	haxe -swf9 flash/jssocket.swf -cp lib -main JSSocket -swf-header 1:1:1
