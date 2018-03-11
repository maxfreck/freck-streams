/**
 * Easy-to-use I/O streams: file stream implementation
 *
 * License:   $(LINK2 http://www.boost.org/LICENSE_1_0.txt, Boost License 1.0)
 * Copyright: Maxim Freck, 2016–2017.
 * Authors:   Maxim Freck
 */
module freck.streams.filestream;

import freck.streams.stream;


///File i/o stream
class FileStream : Stream
{
	import std.stdio: File;
	import freck.streams.exception;

protected:
	enum READABLE = [
		"r", "w+", "r+", "x+", "c+","rb", "w+b", "r+b", "x+b","c+b", "rt", "w+t", "r+t","x+t", "c+t", "a+"
	];

	enum WRITABLE = [
		"w", "w+", "rw", "r+", "x+","c+", "wb", "w+b", "r+b","x+b", "c+b", "w+t", "r+t","x+t", "c+t", "a", "a+"
	];

	File f;
	string mode;

	this(File f, string[string] metadata = null, Endian e = Endian.platform)
	{
		super(metadata, e);
		this.mode = "wb+";
		this.f = f;
	}

public:
	static FileStream tmpfile(string[string] metadata = null, Endian e = Endian.platform)
	{
		return new FileStream(File.tmpfile, metadata, e);
	}

	this(string name, string mode = "rb", string[string] metadata = null, Endian e = Endian.platform)
	{
		super(metadata, e);
		this.mode = mode;
		this.f.open(name, mode);
	}

	~this()
	{
		f.close();
	}

	override ssize_t length()
	{
		return f.size();
	}

	override ssize_t tell()
	{
		return f.tell();
	}

	override bool isEmpty()
	{
		return (f.size - f.tell) <= 0;
	}

	override bool isSeekable()
	{
		return true;
	}

	override ssize_t seek(in sdiff_t pos, in Seek origin = Seek.set)
	{
		import std.stdio: SEEK_SET, SEEK_CUR, SEEK_END;

		int orig = 0;
		with (Seek) final switch (origin) {
			case set:
				orig = SEEK_SET;
				break;
			case cur:
				orig = SEEK_CUR;
				break;
			case end:
				orig = SEEK_END;
				break;
		}

		f.seek(pos, orig);
		return tell();
	}

	override bool isWritable()
	{
		import std.algorithm: canFind;
		return WRITABLE.canFind(this.mode);
	}

	override void write(in ubyte b)
	{
		f.rawWrite([b]);
	}

	override void write(in ubyte[] b)
	{
		f.rawWrite(b);
	}

	override bool isReadable()
	{
		import std.algorithm: canFind;
		return READABLE.canFind(this.mode);
	}

	override ubyte read()
	{
		if ((f.tell + ubyte.sizeof) > f.size()) {
			throw new StreamsException(boundsError);
		}

		ubyte[1] b;
		f.rawRead(b);

		return b[0];
	}

	override ubyte[] read(in size_t n)
	{
		auto buf = new ubyte[(f.tell + n > f.size) ? f.size - f.tell : n];
		f.rawRead(buf);

		return buf;
	}

	override ubyte[] getContents()
	{
		auto ret = new ubyte[f.size];
		f.rawRead(ret);
		return ret;
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

	assertSimpleReads(FileStream.tmpfile());
	assertSimpleWrites(FileStream.tmpfile());

	assertRawWrite(FileStream.tmpfile());
	assertRawRead(FileStream.tmpfile());
}
