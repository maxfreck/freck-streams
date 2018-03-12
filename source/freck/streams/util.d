/**
 * Easy-to-use I/O streams: utility functions
 *
 * License:   $(LINK2 http://www.boost.org/LICENSE_1_0.txt, Boost License 1.0)
 * Copyright: Maxim Freck, 2016–2017.
 * Authors:   Maxim Freck
 */
module freck.streams.util;

import std.traits: isScalarType;
import freck.streams.streaminterface;

/***********************************
	* Dumps abstract stream into a file
	*
	* Params:
	*  src = The stream
	*  fileName = The destination file name
	*  chunkSize = The read chunk size
	*/
void dumpToFile(StreamInterface src, string fileName, size_t chunkSize = 1024) @trusted
{
	import std.stdio: File;

	auto seekSave = src.tell();
	src.seek(0);
	auto f = File(fileName, "wb");

	scope(exit) {
		f.close();
		src.seek(seekSave);
	}

	while (!src.isEmpty) {
		f.rawWrite(src.read(chunkSize));
	}
}

/***********************************
 * Writes a raw byte sequence of a variable type T to the stream
 *
 * Params:
 *  s = The stream
 *  var = The variable to write
 */
void writeRaw(T)(StreamInterface s, in T var) @trusted
{
	import std.traits: isArray;
	static if (isArray!T) {
		foreach(v; var) writeRaw(s, v);
	} else {
		union Buffer {ubyte[T.sizeof] b; T var;}
		Buffer buf;
		buf.var = var;
		s.write(buf.b);
	}
}

/***********************************
 * Reads a raw byte sequence of type T from the stream
 * Returns: The variable of type T
 *
 * Params:
 *  s = The stream
 */
T readRaw(T)(StreamInterface s) @trusted
{
	union Buffer {ubyte[T.sizeof] b; T var;}
	Buffer buf;

	auto ret = s.read(T.sizeof);

	foreach (size_t i, ref v; buf.b) {
		v = (i < ret.length) ? ret[i] : 0;
	}

	return buf.var;
}

/*******
 * Swaps endianness of a given value
 * Params:
 *  stc = the source value
 * Returns: converted value
 */
immutable(T) swapEndianness(T)(T src) @trusted @nogc pure nothrow if (isScalarType!(T))
{
	static if (T.sizeof == 1) {
		return src;
	} else static if (T.sizeof == 2) {
		return cast(T)(src >> 8 | src << 8);
	} else {
		union buffer {ubyte[T.sizeof] b; T v;}
		buffer buf = {v: src};
		reverse(buf.b);
		return buf.v;
	}
}

/*******
 * Performes inplace reverse of an array
 */
void reverse(T, size_t n)(ref T[n] a) @trusted @nogc pure nothrow
{
	foreach (i; 0 .. n/2) {
		immutable T temp = a[i];
		a[i] = a[n - 1 - i];
		a[n - 1 - i] = temp;
	}
}

immutable(Endian) platformEndian() @trusted @nogc pure nothrow
{
	union E {ushort s; ubyte[2] b;}
	E e = {s: 0x0102};
	return (e.b[0] == 0x02) ? Endian.little : Endian.big;
}

/*******
 * Converts the given value from the native endianness to big endian
 * Params:
 *  stc = the source value
 * Returns: big endian value
 */
pure nothrow immutable(T) nativeToBigEndian(T)(T src) @trusted @nogc if (isScalarType!(T))
{
	version (BigEndian) {
		return src;
	} else {
		return swapEndianness(src);
	}
}

/*******
 * Converts the given value from the native endianness to little endian
 * Params:
 *  stc = the source value
 * Returns: little endian value
 */
pure nothrow immutable(T) nativeToLittleEndian(T)(T src) @trusted @nogc if (isScalarType!(T))
{
	version (LittleEndian) {
		return src;
	} else {
		return swapEndianness(src);
	}
}

/***********************************
 * Writes a scalar variable to the stream preserving the stream endianness
 *
 * Params:
 *  s = The stream
 *  var = The variable to write
 */
void writeScalar(T)(StreamInterface s, in T var) @trusted if (isScalarType!(T))
{
	union Buffer {ubyte[T.sizeof] b; T v;}
	Buffer buf;
	buf.v = (s.getEndian == Endian.little) ? nativeToLittleEndian(var) : nativeToBigEndian(var);

	s.write(buf.b);
}

/***********************************
 * Reads a scalar variable from the stream preserving the stream endianness
 * Returns: The variable of type T
 *
 * Params:
 *  s = The stream
 */
T readScalar(T)(StreamInterface s) if (isScalarType!(T))
{
	union Buffer {ubyte[T.sizeof] b; T v;}
	Buffer buf;

	auto ret = s.read(T.sizeof);

	foreach (size_t i, ref v; buf.b) {
		v = (i < ret.length) ? ret[i] : 0;
	}

	return (s.getEndian == Endian.little) ? nativeToLittleEndian(buf.v) : nativeToBigEndian(buf.v);
}

