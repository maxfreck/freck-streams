/**
 * Easy-to-use I/O streams: stream that wraps several streams one after the other.
 *
 * License:   $(LINK2 http://www.boost.org/LICENSE_1_0.txt, Boost License 1.0)
 * Copyright: Maxim Freck, 2016–2017.
 * Authors:   Maxim Freck
 */
module freck.streams.appendstream;

import freck.streams.stream;

///Implementation of stream that wraps several streams one after the other.
class AppendStream : Stream
{
	import freck.streams.exception;
	import freck.streams.util: writeRaw;

protected:
	StreamInterface[] streams;
	size_t current = 0;
	size_t pos = 0;

	bool seekable = true;

public:
	this(StreamInterface[] streams, string[string] metadata = null, Endian e = Endian.platform)
	{
		super(metadata, e);

		foreach (stream; streams) addStream(stream);
	}

	void addStream(StreamInterface stream)
	{
		if (!stream.isReadable) throw new StreamsException(appendNonreadableStream);
		if (!stream.isSeekable) this.seekable = false;
		this.streams ~= stream;
	}

	override @property ssize_t length()
	{
		size_t len = 0;
		foreach(stream; this.streams) {
			len+= stream.length;
		}
		return len;
	}

	override ssize_t tell()
	{
		return this.pos;
	}

	override @property bool isEmpty()
	{
		return
			this.streams.length == 0 ||
			this.current >= this.streams.length ||
			(this.current == this.streams.length - 1 && this.streams[this.current].isEmpty);
	}

	override bool isSeekable()
	{
		return this.seekable;
	}

	override ssize_t seek(in sdiff_t pos, in Seek origin = Seek.set)
	{
		if (!this.seekable) throw new StreamsException(nonSeekable);
		if (origin != Seek.set) throw new StreamsException(onlySetOrigin);

		this.pos = 0;
		this.current = 0;

		foreach (stream; streams) {
			stream.seek(0);
		}

		while (this.pos < pos && !this.isEmpty) {
			auto ret = this.read(8096);
			if (ret.length == 0) break;
		}

		return this.tell;
	}

	override bool isWritable()
	{
		return false;
	}

	override void write(in ubyte b)
	{
		throw new StreamsException(writeToNonwritable);
	}

	override void write(in ubyte[] b)
	{
		throw new StreamsException(writeToNonwritable);
	}

	override bool isReadable()
	{
		return true;
	}

	override ubyte read()
	{
		if (this.streams[this.current].isEmpty) {
			if (this.current >= this.streams.length - 1) throw new StreamsException(boundsError);
			this.current++;
		}

		if (this.streams[this.current].isEmpty) throw new StreamsException(boundsError);

		this.pos++;
		return this.streams[this.current].read();
	}

	override ubyte[] read(in size_t n)
	{
		import std.array: appender;

		auto buffer = appender!(ubyte[]);
		size_t remaining = n;
		bool progressToNext = false;

		while (remaining > 0) {
			if (progressToNext || this.streams[this.current].isEmpty) {
				progressToNext = false;
				if (this.current == (this.streams.length - 1)) break;
				this.current++;
			}

			auto result = this.streams[this.current].read(remaining);
			if (result.length == 0) {
					progressToNext = true;
					continue;
			}

			buffer.put(result);
			remaining = n - buffer.data.length;
		}

		this.pos+= buffer.data.length;

		return buffer.data;
	}

	override ubyte[] getContents()
	{
		import std.array: appender;

		auto buffer = appender!(ubyte[]);

		foreach (stream; streams) {
			auto save = stream.tell;
			stream.seek(0);
			buffer.put(stream.getContents());
			stream.seek(save);
		}

		return buffer.data;
	}
}

unittest
{
	import std.stdio: stdout, write, writeln;
	import freck.streams.memorystream: MemoryStream;

	write("Running AppendStrem tests:"); stdout.flush;

	auto m1 = MemoryStream.fromBytes(cast(ubyte[])[1, 2, 3]);
	auto m2 = MemoryStream.fromBytes(cast(ubyte[])[4, 5, 6]);

	auto a1 = new AppendStream([m1, m2]);

	assert(a1.read(2) == cast(ubyte[])[1, 2]);
	assert(a1.read(2) == cast(ubyte[])[3, 4]);
	assert(a1.read == 5);
	assert(a1.read == 6);

	a1.seek(0);
	assert(a1.getContents == cast(ubyte[])[1, 2, 3, 4, 5, 6]);

	assert(a1.read(480) == cast(ubyte[])[1, 2, 3, 4, 5, 6]);

	writeln(" OK");
}