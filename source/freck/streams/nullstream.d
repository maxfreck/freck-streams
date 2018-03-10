/**
 * Easy-to-use I/O streams: empty stream.
 *
 * License:   $(LINK2 http://www.boost.org/LICENSE_1_0.txt, Boost License 1.0)
 * Copyright: Maxim Freck, 2016–2017.
 * Authors:   Maxim Freck
 */
module freck.streams.nullstream;

import freck.streams.stream;

///Implementation of an empty stream.
class EmptyStream : Stream
{
	import freck.streams.exception;
public:
	this(string[string] metadata = null, Endian e = Endian.platform)
	{
		super(metadata, e);
	}

	override @property ssize_t length()
	{
		return 0;
	}

	override ssize_t tell()
	{
		return 0;
	}

	override @property bool isEmpty()
	{
		return true;
	}

	override bool isSeekable()
	{
		return false;
	}

	override ssize_t seek(in sdiff_t pos, in Seek origin = Seek.set)
	{
		throw new StreamsException(nonSeekable);
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
		return false;
	}

	override ubyte read()
	{
		throw new StreamsException(readFromNoreadable);
	}

	override ubyte[] read(in size_t n)
	{
		throw new StreamsException(readFromNoreadable);
	}

	override ubyte[] getContents()
	{
		return [];
	}
}
