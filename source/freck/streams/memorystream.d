/**
 * Primitive I/O streams library
 *
 * License:   $(LINK2 http://www.boost.org/LICENSE_1_0.txt, Boost License 1.0)
 * Copyright: Maxim Freck, 2016–2017.
 * Authors:   Maxim Freck
 */
module freck.streams.memorystream;

import freck.streams.mixins;

///Memory i/o stream
class MemoryStream : from!"freck.streams.stream".Stream {
	import freck.streams.exception, freck.streams.stream;

protected:
	ubyte[] buf;
	size_t ptr;

	this(ubyte[] buf, Endian e) {
		this.setEndian(e);
		this.buf = buf;
		this.ptr = 0;
	}

public:

	/***********************************
	 * Creates an empty memory stream
	 *
	 * Params:
	 *  e = Endianness (default: little)
	 */
	static MemoryStream fromScratch(Endian e = Endian.little)
	{
		return new MemoryStream([], e);
	}

	/***********************************
	 * Creates a memory stream initialized with an array of unsigned bytes
	 *
	 * Params:
	 *  buf = Initial array
	 *  e = Endianness (default: little)
	 */
	static MemoryStream fromBytes(ubyte[] buf, Endian e = Endian.little)
	{
		return new MemoryStream(buf, e);
	}

	/***********************************
	 * Creates a memory stream initialized with content of a file
	 *
	 * Params:
	 *  fileName = File name
	 *  e = Endianness (default: little)
	 */
	static MemoryStream fromFile(const string fileName, Endian e = Endian.little)
	{
		import std.stdio: File;

		auto f = File(fileName, "rb");
		auto buffer = new ubyte[cast(uint)(f.size())];
		f.rawRead(buffer);

		return new MemoryStream(buffer, e);
	}

	/***********************************
	 * Saves stream content into a file
	 *
	 * Params:
	 *  fileName = File name
	 */
	void saveAsFile(const string fileName)
	{
		import std.stdio: File;

		auto f = File(fileName, "wb");
		f.rawWrite(this.buf);
	}

	override ubyte readUbyte()
	{
		if ((this.ptr + ubyte.sizeof) > this.length()) {
			throw new StreamsException(boundsError);
		}

		return this.buf[this.ptr++];
	}

	override ubyte[] readUbyte(size_t n)
	{
		if ((this.ptr + n) > this.length()) {
			throw new StreamsException(boundsError);
		}

		auto a = this.ptr;
		this.ptr += n;
		return this.buf[a .. this.ptr];
	}

	ubyte[] readAllUbyte()
	{
		this.ptr = this.buf.length;
		return this.buf;
	}

	override ushort readUshort()
	{
		if ((this.ptr + ushort.sizeof) > this.length()) {
			throw new StreamsException(boundsError);
		}

		if (endian == Endian.little) {
			return cast(uint)(this.buf[this.ptr++] | this.buf[this.ptr++] << 8);
		}
		return cast(uint)(this.buf[this.ptr++] << 8 | this.buf[this.ptr++]);
	}

	override uint readUint()
	{
		if ((this.ptr + uint.sizeof) > this.length()) {
			throw new StreamsException(boundsError);
		}

		if (endian == Endian.little) {
			return cast(uint)(this.buf[this.ptr++] | this.buf[this.ptr++] << 8
				| this.buf[this.ptr++] << 16 | this.buf[this.ptr++] << 24);
		}
		return cast(uint)(this.buf[this.ptr++] << 24 | this.buf[this.ptr++] << 16
			| this.buf[this.ptr++] << 8 | this.buf[this.ptr++]);
	}

	override void write(ubyte b)
	{
		if (this.ptr == this.buf.length) {
			this.buf ~= b;
			this.ptr++;
		} else {
			this.buf[this.ptr++] = b;
		}
	}

	override void write(ubyte[] b)
	{
		if (this.ptr == this.buf.length) {
			this.buf ~= b;
			this.ptr = this.buf.length;
		} else if (this.ptr+b.length < this.buf.length) {
			this.buf[this.ptr .. (this.ptr + b.length)] = b;
		} else {
			this.buf.length = this.ptr;
			this.buf ~= b;
			this.ptr = this.buf.length;
		}
	}

	override void write(ushort s)
	{
		if (endian == Endian.little) {
			write([cast(ubyte)(s), cast(ubyte)(s >> 8)]);
			return;
		}
		write([cast(ubyte)(s >> 8), cast(ubyte)(s)]);
	}

	override void write(uint i)
	{
		if (endian == Endian.little) {
			write([cast(ubyte)(i), cast(ubyte)(i >> 8), cast(ubyte)(i >> 16), cast(ubyte)(i >> 24)]);
			return;
		}
		write([cast(ubyte)(i >> 24), cast(ubyte)(i >> 16), cast(ubyte)(i >> 8), cast(ubyte)(i)]);
	}

	override ssize_t seek()
	{
		return this.ptr;
	}

	override ssize_t seek(ssize_t pos)
	{
		this.ptr = (pos > this.buf.length) ? this.buf.length : cast(size_t)(pos);
		return this.ptr;
	}

	override @property ssize_t length()
	{
		return this.buf.length;
	}

	override @property bool isEmpty()
	{
		return (this.ptr == (this.length));
	}
}

unittest
{
	import freck.streams.tests;

	assertSimpleReads(MemoryStream.fromScratch());
	assertSimpleWrites(MemoryStream.fromScratch());

	assertRawWrite(MemoryStream.fromScratch());
	assertRawRead(MemoryStream.fromScratch());
}