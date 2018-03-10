/**
 * Easy-to-use I/O streams: utility functions
 *
 * License:   $(LINK2 http://www.boost.org/LICENSE_1_0.txt, Boost License 1.0)
 * Copyright: Maxim Freck, 2016–2017.
 * Authors:   Maxim Freck
 */
module freck.streams.util;

import freck.streams.mixins;

/***********************************
	* Dumps abstract stream into a file
	*
	* Params:
	*  src = The stream
	*  fileName = The destination file name
	*  chunkSize = The read chunk size
	*/
void dumpToFile(from!"freck.streams.stream".Stream src, string fileName, size_t chunkSize = 1024)
{
	import std.stdio: File;

	auto seekSave = src.seek();
	src.seek(0);
	auto f = File(fileName, "wb");

	scope(exit) {
		f.close();
		src.seek(seekSave);
	}

	while (!src.isEmpty) {
		f.rawWrite(src.readUbyte(chunkSize));
	}
}