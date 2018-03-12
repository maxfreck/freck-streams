/**
 * Easy-to-use I/O streams: generic exception
 *
 * License:   $(LINK2 http://www.boost.org/LICENSE_1_0.txt, Boost License 1.0)
 * Copyright: Maxim Freck, 2016–2017.
 * Authors:   Maxim Freck
 */
module freck.streams.exception;

package static immutable boundsError = "Attempt reading outside of the stream";
package static immutable appendNonreadableStream = "Each stream of AppendStream must be readable";
package static immutable cantOpenFile = "Cant't open file ";
package static immutable cantGetFilestat = "Cant't get filestat ";
package static immutable invalidMode = "Invalid mode specified during file open";
package static immutable nonSeekable = "This stream is not seekable";
package static immutable onlySetOrigin = "This stream can only seek with Seek.set";
package static immutable writeToNonwritable = "This stream is non-writable";
package static immutable readFromNoreadable = "This stream is non-readable";

///Package default exception
class StreamsException : Exception {
	///constructor
	this(string s, string fn = __FILE__, size_t ln = __LINE__) @safe pure nothrow
	{
		super(s, fn, ln);
	}
}
