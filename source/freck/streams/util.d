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

/***********************************
 * Writes a raw byte sequence of a variable type T to the stream
 *
 * Params:
 *  s = The stream
 *  var = The variable to write
 */
void writeRaw(T)(from!"freck.streams.stream".Stream s, const T var)
{
	union Buffer {ubyte[T.sizeof] b; T var;}
	Buffer buf;
	buf.var = var;
	s.write(buf.b);
}

/***********************************
 * Reads a raw byte sequence of type T from the stream
 * Returns: The variable of type T
 *
 * Params:
 *  s = The stream
 */
T readRaw(T)(from!"freck.streams.stream".Stream s) {
	union Buffer {ubyte[T.sizeof] b; T var;}
	Buffer buf;
	buf.b = s.readUbyte(T.sizeof);
	return buf.var;
}