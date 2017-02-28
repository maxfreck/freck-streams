/**
 * Primitive I/O streams library
 *
 * License:   $(LINK2 http://www.boost.org/LICENSE_1_0.txt, Boost License 1.0)
 * Copyright: Maxim Freck, 2016–2017.
 * Authors:   Maxim Freck
 */
module freck.streams.raw;

import freck.streams.mixins;

/***********************************
 * Writes a raw byte sequence of a variable type T to the stream
 *
 * Params:
 *  s = The stream
 *  var = The variable to write
 */
void writeRaw(T)(from!"freck.streams.stream".Stream s, T var) {
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
