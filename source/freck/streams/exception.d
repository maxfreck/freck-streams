/**
 * Easy-to-use I/O streams: generic exception
 *
 * License:   $(LINK2 http://www.boost.org/LICENSE_1_0.txt, Boost License 1.0)
 * Copyright: Maxim Freck, 2016–2017.
 * Authors:   Maxim Freck
 */
module freck.streams.exception;

string boundsError = "Attempt reading outside of the stream";
//string readonlyError = "Attempt writing to readonly stream";
string cantOpenFile = "Cant't open file ";
string cantGetFilestat = "Cant't get filestat ";
string invalidMode = "Invalid mode specified during file open";

class StreamsException : Exception {
	@safe pure nothrow this(string s, string fn = __FILE__, size_t ln = __LINE__) {
		super(s, fn, ln);
	}
}
