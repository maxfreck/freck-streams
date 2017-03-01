/**
 * Easy-to-use I/O streams: abstract stream
 *
 * License:   $(LINK2 http://www.boost.org/LICENSE_1_0.txt, Boost License 1.0)
 * Copyright: Maxim Freck, 2016–2017.
 * Authors:   Maxim Freck
 */
module freck.streams.stream;

import freck.streams.mixins;

///Endiannes: big, little
enum Endian {
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
	abstract void write(const ubyte b);

	///operator "~" equivalent for write()
	typeof(this) opBinary(string op)(const ubyte b) if (op == "~")
	{
		write(b);
		return this;
	}

	/***********************************
	 * Writes an array of unsigned bytes to the stream
	 *
	 * Params:
	 *  b = The array of ubyte to write to the stream
	 */
	abstract void write(const ubyte[] b);

	///operator "~" equivalent for write()
	typeof(this) opBinary(string op)(const ubyte[] b) if (op == "~")
	{
		write(b);
		return this;
	}

	/***********************************
	 * Writes an unsigned short to the stream
	 *
	 * Params:
	 *  s = The ushort to write to the stream
	 */
	abstract void write(const ushort s);

	///operator "~" equivalent for write()
	typeof(this) opBinary(string op)(const ushort s) if (op == "~")
	{
		write(s);
		return this;
	}

	/***********************************
	 * Writes an unsigned int to the stream
	 *
	 * Params:
	 *  i = The uint to write to the stream
	 */
	abstract void write(const uint i);

	///operator "~" equivalent for write()
	typeof(this) opBinary(string op)(const uint i) if (op == "~")
	{
		write(i);
		return this;
	}

	///operator "~" equivalent for writeRaw()
	typeof(this) opBinary(string op, T)(const T var) if (op == "~")
	{
		import freck.streams.raw;
		this.writeRaw(var);
		return this;
	}

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
	 *  pos = The number of bytes to offset from origin
	 *  origin = Position used as reference for the offset. It is specified by one of the following constants:
	 *           Seek.set - beginning of the stream;
	 *           Seek.cur - current position of the pointer;
	 *           Seek.end - end of the stream.
	 */
	abstract ssize_t seek(const sdiff_t pos, const Seek origin = Seek.set);

	///operator "<<" equivalent for writeRaw(-pos, Seek.cur)
	typeof(this) opBinary(string op)(const sdiff_t pos) if (op == "<<")
	{
		seek(-pos, Seek.cur);
		return this;
	}

	///operator ">>" equivalent for writeRaw(pos, Seek.cur)
	typeof(this) opBinary(string op)(const sdiff_t pos) if (op == ">>")
	{
		seek(pos, Seek.cur);
		return this;
	}


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

	/***********************************
	 * Returns the platform endianness.
	 */
	@safe static pure nothrow immutable(Endian) platformEndian()
	{
		union E {ushort s; ubyte[2] b; }
		E e = {s: 0x0102};
		return (e.b[0] == 0x02) ? Endian.little : Endian.big;
	}
}
