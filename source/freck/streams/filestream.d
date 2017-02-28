/**
 * Primitive I/O streams library
 *
 * License:   $(LINK2 http://www.boost.org/LICENSE_1_0.txt, Boost License 1.0)
 * Copyright: Maxim Freck, 2016–2017.
 * Authors:   Maxim Freck
 */
module freck.streams.filestream;

import freck.streams.mixins;


///File i/o stream
class FileStream : from!"freck.streams.stream".Stream
{
	import std.stdio: File;
	import freck.streams.exception, freck.streams.stream, freck.streams.fileio;

protected:
	File f;

	@safe pure nothrow immutable(Endian) platformEndian()
	{
		union E {ushort s; ubyte[2] b; }
		E e = {s: 0x0102};
		return (e.b[0] == 0x02) ? Endian.little : Endian.big;
	}

public:

	this(string name, string mode = "rb", Endian e = Endian.little)
	{
		this.setEndian(e);
		this.f.open(name, mode);
	}

	override ubyte readUbyte()
	{
		if ((f.tell + ubyte.sizeof) > f.size()) {
			throw new StreamsException(boundsError);
		}

		ubyte[1] b;
		f.rawRead(b);

		return b[0];
	}

	override ubyte[] readUbyte(size_t n)
	{
		if ((f.tell + ubyte.sizeof*n) > f.size) {
			throw new StreamsException(boundsError);
		}

		auto buf = new ubyte[n];
		f.rawRead(buf);

		return buf;
	}

	override ushort readUshort()
	{
		if ((f.tell + ushort.sizeof) > f.size) {
			throw new StreamsException(boundsError);
		}

		if (endian == platformEndian) {
			return f.get!ushort;
		}

		ubyte[2] b;
		f.rawRead(b);

		if (endian == Endian.little) {
			return cast(uint)(b[0] | b[1] << 8);
		}
		
		return cast(uint)(b[0] << 8 | b[1]);
	}

	override uint readUint()
	{
		if ((f.tell() + uint.sizeof) > f.size()) {
			throw new StreamsException(boundsError);
		}

		if (endian == platformEndian) {
			return f.get!uint;
		}

		ubyte[4] b;
		f.rawRead(b);

		if (endian == Endian.little) {
			return cast(uint)(b[0] | b[1] << 8 | b[2] << 16 | b[3] << 24);
		}
		
		return cast(uint)(b[0] << 24 | b[1] << 16 | b[2] << 8 | b[3]);
	}

	override void write(ubyte b)
	{
		f.put(b);
	}

	override void write(ubyte[] b)
	{
		f.rawWrite(b);
	}

	override void write(ushort s)
	{
		if (endian == platformEndian) {
			f.put(s);
			return;
		}

		if (endian == Endian.little) {
			write([cast(ubyte)(s), cast(ubyte)(s >> 8)]);
			return;
		}
		write([cast(ubyte)(s >> 8), cast(ubyte)(s)]);
	}

	override void write(uint i)
	{
		if (endian == platformEndian) {
			f.put(i);
			return;
		}

		if (endian == Endian.little) {
			write([cast(ubyte)(i), cast(ubyte)(i >> 8), cast(ubyte)(i >> 16), cast(ubyte)(i >> 24)]);
			return;
		}

		write([cast(ubyte)(i >> 24), cast(ubyte)(i >> 16), cast(ubyte)(i >> 8), cast(ubyte)(i)]);
	}

	override ssize_t seek()
	{
		return f.tell();
	}

	override ssize_t seek(ssize_t pos)
	{
		f.seek(pos);
		return seek();
	}

	override @property ssize_t length()
	{
		return f.size();
	}

	override @property bool isEmpty()
	{
		return f.eof();
	}
}

unittest
{
	import std.file;
	import freck.streams.tests;

	auto createStream(string fileName, string mode)
	{
		return new FileStream(tempDir() ~ fileName, mode);
	}

	assertSimpleReads(createStream("/filestream-smple-reads", "w+b"));
	assertSimpleWrites(createStream("/filestream-smple-writes", "w+b"));

	assertRawWrite(createStream("/filestream-raw-write", "w+b"));
	assertRawRead(createStream("/filestream-raw-read", "w+b"));
}
