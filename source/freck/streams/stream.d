/**
 * Primitive I/O streams library
 *
 * License:   $(LINK2 http://www.boost.org/LICENSE_1_0.txt, Boost License 1.0)
 * Copyright: Maxim Freck, 2016–2017.
 * Authors:   Maxim Freck
 */
module freck.streams.stream;


///Endiannes: big, little
enum Endian {
	big,
	little
}

///
alias ssize_t = ulong;

///Abstract i/o stream interface
class Stream {
protected:
	Endian endian = Endian.little;

public:
	/***********************************
	 * Reads an unsigned byte from the stream
	 * Returns: The unsigned byte read from the stream
	 */
	abstract ubyte readUbyte();

	/***********************************
	 * Reads an array of ubytes from the stream
	 * Returns: The array of unsigned bytes read from the stream
	 *
	 * Params:
	 *  n = The number of bytes to read from the stream
	 */
	abstract ubyte[] readUbyte(size_t n);

	/***********************************
	 * Reads an unsigned short from the stream
	 * Returns: The unsigned short read from the stream
	 */
	abstract ushort readUshort();

	/***********************************
	 * Reads an unsigned int from the stream
	 * Returns: The unsigned int read from the stream
	 */
	abstract uint readUint();

	/***********************************
	 * Writes an unsigned byte to the stream
	 *
	 * Params:
	 *  b = The ubyte to write to the stream
	 */
	abstract void write(ubyte b);

	/***********************************
	 * Writes an array of unsigned bytes to the stream
	 *
	 * Params:
	 *  b = The array of ubyte to write to the stream
	 */
	abstract void write(ubyte[] b);

	/***********************************
	 * Writes an unsigned short to the stream
	 *
	 * Params:
	 *  s = The ushort to write to the stream
	 */
	abstract void write(ushort s);

	/***********************************
	 * Writes an unsigned int to the stream
	 *
	 * Params:
	 *  i = The uint to write to the stream
	 */
	abstract void write(uint i);

	/***********************************
	 * Returns the current positon in the stream
	 * Returns: The current positon in the stream
	 */
	abstract ssize_t seek();

	/***********************************
	 * Sets the current position in the stream
	 * Returns: The current positon in the stream
	 *
	 * Params:
	 *  pos = The number of bytes to offset from the stream start
	 */
	abstract ssize_t seek(ssize_t pos);

	/***********************************
	 * Returns: The lenght of the stream in bytes
	 */
	abstract @property ssize_t length();

	/***********************************
	 * Returns: True if the stream is empty (seek position == stream lenght)
	 */
	abstract @property bool isEmpty();

	/***********************************
	 * Sets the stream endianness. Affects on the byte order during read and write units and ulongs.
	 */
	void setEndian(Endian e) {
		this.endian = e;
	}
}
