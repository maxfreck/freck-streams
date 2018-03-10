/**
 * Easy-to-use I/O streams: generic exception
 *
 * License:   $(LINK2 http://www.boost.org/LICENSE_1_0.txt, Boost License 1.0)
 * Copyright: Maxim Freck, 2016–2017.
 * Authors:   Maxim Freck
 */
module freck.streams.exception;

string boundsError = "Attempt reading outside of the stream";
string appendNonreadableStream = "Each stream of AppendStream must be readable";
string cantOpenFile = "Cant't open file ";
string cantGetFilestat = "Cant't get filestat ";
string invalidMode = "Invalid mode specified during file open";
string nonSeekable = "This stream is not seekable";
string onlySetOrigin = "This stream can only seek with Seek.set";
string writeToNonwritable = "This stream is non-writable";
string readFromNoreadable = "This stream is non-readable";

class StreamsException : Exception {
	this(string s, string fn = __FILE__, size_t ln = __LINE__) @safe pure nothrow
	{
		super(s, fn, ln);
	}
}
