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
	static immutable READABLE = [
		"r", "w+", "r+", "x+", "c+","rb", "w+b", "r+b", "x+b","c+b", "rt", "w+t", "r+t","x+t", "c+t", "a+"
	];

	static immutable WRITABLE = [
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

	/***********************************
	 * Creates a temporary file stream
	 * Returns: created FileStream
	 *
	 * Params:
	 *  metadata = Stream metadata
	 *  e = Endianness (default: platform)
	 */
	static FileStream tmpfile(string[string] metadata = null, Endian e = Endian.platform)
	{
		return new FileStream(File.tmpfile, metadata, e);
	}

	/***********************************
	 * Class constructor
	 *
	 * Params:
	 *  name = File name
	 *  mode = File access mode
	 *  metadata = Stream metadata
	 *  e = Endianness (default: platform)
	 */
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

		int orig;
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
		auto buf = new ubyte[ cast(size_t)((f.tell + n > f.size) ? f.size - f.tell : n) ];
		f.rawRead(buf);

		return buf;
	}

	override ubyte[] getContents()
	{
		auto ret = new ubyte[cast(size_t)(f.size)];
		f.rawRead(ret);
		return ret;
	}
}

unittest
{
	import std.stdio: stdout, write, writeln;
	import std.file: tempDir;
	import freck.streams.tests;

	auto createStream(string fileName, string mode)
	{
		return new FileStream(tempDir() ~ fileName, mode);
	}

	write("Running FileStream simple tests:"); stdout.flush;
	assertSimpleReads(createStream("/filestream-smple-reads", "w+b"));
	assertSimpleWrites(createStream("/filestream-smple-writes", "w+b"));
	writeln(" OK");

	write("Running FileStream raw i/o tests:"); stdout.flush;
	assertRawWrite(createStream("/filestream-raw-write", "w+b"));
	assertRawRead(createStream("/filestream-raw-read", "w+b"));
	writeln(" OK");

	write("Running FileStream.tmpfile simple tests:"); stdout.flush;
	assertSimpleReads(FileStream.tmpfile());
	assertSimpleWrites(FileStream.tmpfile());
	writeln(" OK");

	write("Running FileStream.tmpfile raw i/o tests:"); stdout.flush;
	assertRawWrite(FileStream.tmpfile());
	assertRawRead(FileStream.tmpfile());
	writeln(" OK");
}
