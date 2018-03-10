/**
 * Easy-to-use I/O streams: abstract stream
 *
 * License:   $(LINK2 http://www.boost.org/LICENSE_1_0.txt, Boost License 1.0)
 * Copyright: Maxim Freck, 2016–2017.
 * Authors:   Maxim Freck
 */
module freck.streams.stream;

public import freck.streams.streaminterface;

///Abstract i/o stream interface
class Stream: StreamInterface
{
protected:
	Endian endian = Endian.little;
	string[string] metadata;

public:

	this(string[string] metadata = null, Endian e = Endian.platform)
	{
		this.metadata = metadata;
		setEndian(e);
	}

	/***********************************
	 * Sets the stream endianness. Affects on the byte order during read and write units and ulongs.
	 */
	void setEndian(Endian e)
	{
		import freck.streams.util: platformEndian;
		this.endian = (e == Endian.platform) ? platformEndian : e;
	}

	/***********************************
	 * Returns: the current srream endiannes
	 */
	Endian getEndian()
	{
		return this.endian;
	}

	/***********************************
	 * Returns: The lenght of the stream in bytes
	 */
	abstract ssize_t length();

	/***********************************
	 * Returns the current positon in the stream
	 * Returns: The current positon in the stream
	 */
	abstract ssize_t tell();

	/***********************************
	 * Returns: True if the stream is empty (seek position == stream lenght)
	 */
	abstract bool isEmpty();

	/***********************************
	 * Returns: True if the stream is seekable, false otherwise
	 */
	abstract bool isSeekable();

	/***********************************
	 * Sets the current position in the stream
	 * Returns: The current positon in the stream
	 *
	 * Params:
	 *  pos = The number of bytes to offset from origin
	 *  origin = Position used as reference for the offset. It is specified by one of the following constants:
	 *           Seek.set - beginning of the stream;
	 *           Seek.cur - current position of the pointer;
	 *           Seek.end - end of the stream.
	 */
	abstract ssize_t seek(in sdiff_t pos, in Seek origin = Seek.set);

	/***********************************
	 * Returns: True if the stream is writeble, false otherwise
	 */
	abstract bool isWritable();

	/***********************************
	 * Writes an unsigned byte to the stream
	 *
	 * Params:
	 *  b = The ubyte to write to the stream
	 */
	abstract void write(in ubyte b);

	/***********************************
	 * Writes an array of unsigned bytes to the stream
	 *
	 * Params:
	 *  b = The array of ubyte to write to the stream
	 */
	abstract void write(in ubyte[] b);

	/***********************************
	 * Returns: True if the stream is readable, false otherwise
	 */
	abstract bool isReadable();

	/***********************************
	 * Reads an unsigned byte from the stream
	 * Returns: The unsigned byte read from the stream
	 */
	abstract ubyte read();

	/***********************************
	 * Reads an array of ubytes from the stream
	 * Returns: The array of unsigned bytes read from the stream
	 *
	 * Params:
	 *  n = The number of bytes to read from the stream
	 */
	abstract ubyte[] read(in size_t n);

	/***********************************
	 * Reads entire stream as ubyte[] array
	 * Returns: The array of unsigned bytes read from the stream
	 */
	abstract ubyte[] getContents();

	/***********************************
	* Returns: stream metadata by a specified key
	*
	* Params:
	*  key = The metadata key
	*/
	string getMetadata(string key)
	{
		auto val = (key in metadata);
		if (null != val) return *val;
		return "";
	}
}
