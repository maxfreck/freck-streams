/**
 * Easy-to-use I/O streams: extinsion to standard File I/O
 *
 * License:   $(LINK2 http://www.boost.org/LICENSE_1_0.txt, Boost License 1.0)
 * Copyright: Maxim Freck, 2016–2017.
 * Authors:   Maxim Freck
 */
module freck.streams.fileio;

import freck.streams.mixins;

enum fileincl = "std.stdio";

T[] get(T)(from!fileincl.File f, size_t size)
{
	import std.stdio: File;
	if (size < 1) return [];
	auto buf = new T[size];
	f.rawRead(buf);
	return buf;
}

auto get(T)(from!fileincl.File f)
{
	import std.stdio: File;

	static if (T.sizeof == 1) {
		T b;
		f.rawRead(b);
		return b;
	} else {
		union buffer {ubyte[T.sizeof] b; T v;}
		buffer buf;
		f.rawRead(buf.b);
		return buf.v;
	}
}


void put(T)(from!fileincl.File f, T v)
{
	import std.stdio: File;

	union buffer {ubyte[T.sizeof] b; T v;}
	buffer buf = {v: v};
	f.rawWrite(buf.b);
}

unittest
{
	import std.stdio;
	import std.file;
	import freck.streams.tests;

	string fileName = tempDir() ~ "/fileio-test";
	auto f = File(fileName, "w+b");

	//---
	f.put(cast(ubyte)(0x33));
	f.put(cast(ubyte)(0x34));
	f.put(cast(ubyte)(0x35));
	f.put(cast(ubyte)(0x36));

	f.seek(0);
	auto ret1 = f.get!uint;
	assert(ret1 == 0x36353433);

	//---
	f.seek(0);
	f.put(cast(ulong)(0x4344454653545556));
	f.put(cast(ubyte)(0x31));

	f.seek(0);
	auto ret2 = cast(string)(f.get!ubyte(8));
	assert(ret2 == "VUTSFEDC");

	//---
	f.seek(0);
	test t;
	f.put(t);

	f.seek(0);
	auto ret3 = cast(string)(f.get!ubyte(4));
	assert(ret3 == "Test");

	f.seek(0);
	f.rawWrite("Rest! Not test.");

	f.seek(0);
	auto ret4 = f.get!test;
	assert(ret4.t == 0x52);
	assert(ret4.est == 0x21747365);
}