/**
 * Easy-to-use I/O streams: CRC32 calculation
 *
 * License:   $(LINK2 http://www.boost.org/LICENSE_1_0.txt, Boost License 1.0)
 * Copyright: Maxim Freck, 2016.
 * Authors:   Maxim Freck
 */
module freck.streams.crc32;

import freck.streams.mixins;

private static immutable uint[256] crcTable = () {
	uint[256] ret;
	foreach (uint n; 0 .. 256) {
		uint c = n;
		foreach (uint k; 0 .. 8) {
			if (c & 1) {
				c = 0xedb88320L ^ (c >> 1);
			} else {
				c = c >> 1;
			}
		}
		ret[n] = c;
	}
	return ret;
}();

/***********************************
 * Returns: The CRC32 hash computed from a stream
 *
 * Params:
 *  s = The stream
 */
uint crc32(from!"freck.streams.stream".Stream s)
{
	import freck.streams.stream;

	uint crc = 0xffffffff;

	immutable auto seekSave = s.tell();
	s.seek(0);

	foreach (_; 0 .. s.length) {
		crc = crcTable[(crc ^ s.read) & 0xFF] ^ (crc >> 8);
	}

	s.seek(seekSave);

	return crc ^ 0xffffffff;
}

///
unittest
{
	import freck.streams.memorystream;

	foreach (str, result; [
		"Hello, teenage America": 0x11fa4292,
		"The quick brown fox jumps over the lazy dog": 0x414fa339,
		"hash me!": 0xdbc71824
	]) {
		auto stream = MemoryStream.fromBytes(cast(ubyte[])(str));
		assert(stream.crc32 == result);
	}
}