/**
 * Easy-to-use I/O streams: utility functions
 *
 * License:   $(LINK2 http://www.boost.org/LICENSE_1_0.txt, Boost License 1.0)
 * Copyright: Maxim Freck, 2016–2017.
 * Authors:   Maxim Freck
 */
module freck.streams.streaminterface;


///Endiannes: big, little
enum Endian {
	platform,
	big,
	little
}

///
alias ssize_t = ulong;

///
alias sdiff_t = long;

///
enum Seek {
	set,
	cur,
	end
}

interface StreamInterface
{
	/***********************************
	 * Sets the stream endianness. Affects on the byte order during read and write units and ulongs.
	 */
	void setEndian(Endian e);

	/***********************************
	 * Returns: the current srream endiannes
	 */
	Endian getEndian();

	/***********************************
	 * Returns: The lenght of the stream in bytes
	 */
	ssize_t length();

	/***********************************
	 * Returns the current positon in the stream
	 * Returns: The current positon in the stream
	 */
	ssize_t tell();

	/***********************************
	 * Returns: True if the stream is empty (seek position == stream lenght)
	 */
	bool isEmpty();

	/***********************************
	 * Returns: True if the stream is seekable, false otherwise
	 */
	bool isSeekable();

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
	ssize_t seek(in sdiff_t pos, in Seek origin = Seek.set);

	/***********************************
	 * Returns: True if the stream is writeble, false otherwise
	 */
	bool isWritable();

	/***********************************
	 * Writes an unsigned byte to the stream
	 *
	 * Params:
	 *  b = The ubyte to write to the stream
	 */
	void write(in ubyte b);

	/***********************************
	 * Writes an array of unsigned bytes to the stream
	 *
	 * Params:
	 *  b = The array of ubyte to write to the stream
	 */
	void write(in ubyte[] b);


	/***********************************
	 * Returns: True if the stream is readable, false otherwise
	 */
	bool isReadable();

	/***********************************
	 * Reads an unsigned byte from the stream
	 * Returns: The unsigned byte read from the stream
	 */
	ubyte read();

	/***********************************
	 * Reads an array of ubytes from the stream
	 * Returns: The array of unsigned bytes read from the stream
	 *
	 * Params:
	 *  n = The number of bytes to read from the stream
	 */
	ubyte[] read(in size_t n);

	/***********************************
	* Returns: stream metadata by a specified key
	*
	* Params:
	*  key = The metadata key
	*/
	string getMetadata(string key);
}