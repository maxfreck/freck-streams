/**
 * Easy-to-use I/O streams: testing stuff for internal use only
 *
 * License:   $(LINK2 http://www.boost.org/LICENSE_1_0.txt, Boost License 1.0)
 * Copyright: Maxim Freck, 2016–2017.
 * Authors:   Maxim Freck
 */
module freck.streams.tests;

version(unittest)
{
	import freck.streams.stream, freck.streams.raw;

	void assertSimpleReads(Stream stream)
	{
		stream.setEndian(Endian.little);

		stream.write(cast(ubyte[])([0x01, 0x02, 0x03, 0x04]));

		stream.seek(0);
		auto read1 = stream.readUshort();
		assert(read1 == 0x0201);
		auto read2 = stream.readUshort();
		assert(read2 == 0x0403);

		stream.seek(0);
		stream.setEndian(Endian.big);
		auto read3 = stream.readUshort();
		assert(read3 == 0x0102);
		auto read4 = stream.readUshort();
		assert(read4 == 0x0304);

		stream.seek(0);
		auto read5 = stream.readUint();
		assert(read5 == 0x01020304);

		stream.seek(0);
		stream.setEndian(Endian.little);
		auto read6 = stream.readUint();
		assert(read6 == 0x04030201);

		stream.seek(0);
	}

	void assertSimpleWrites(Stream stream)
	{
		stream.setEndian(Endian.little);

		stream.write(cast(ushort)(0x0201));
		stream.seek(0);
		auto read1 = stream.readUbyte(2);
		assert(read1 == cast(ubyte[])([0x01, 0x02]));

		stream.seek(0);
		stream.setEndian(Endian.big);
		stream.write(cast(ushort)(0x0201));
		stream.seek(0);
		auto read2 = stream.readUbyte(2);
		assert(read2 == cast(ubyte[])([0x02, 0x01]));

		stream.seek(0);
		stream.setEndian(Endian.little);
		stream.write(cast(uint)(0x04030201));
		stream.seek(0);
		auto read3 = stream.readUbyte(4);
		assert(read3 == cast(ubyte[])([0x01, 0x02, 0x03, 0x04]));

		stream.seek(0);
		stream.setEndian(Endian.big);
		stream.write(cast(uint)(0x04030201));
		stream.seek(0);
		auto read4 = stream.readUbyte(4);
		assert(read4 == cast(ubyte[])([0x04, 0x03, 0x02, 0x01]));
	}


	align(1) struct test
	{
		align(1):
	
		ubyte t = 0x54;
		uint est = 0x21747365;
	}

	void assertRawWrite(Stream stream)
	{
		stream.seek(0);
		stream.setEndian(Endian.little);

		test t;
		stream.writeRaw(t);

		stream.seek(0);
		auto read = cast(string)(stream.readUbyte(5));
		assert(read == "Test!");
	}

	void assertRawRead(Stream stream)
	{
		stream.seek(0);
		stream.setEndian(Endian.little);
		stream.write(cast(ubyte[])("Test!"));

		stream.seek(0);
		auto read = stream.readRaw!test;
		assert(read.t == 0x54);
		assert(read.est == 0x21747365);
	}
}
