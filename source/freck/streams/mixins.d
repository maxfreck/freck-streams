/**
 * Easy-to-use I/O streams: mixins for internal use
 *
 * License:   $(LINK2 http://www.boost.org/LICENSE_1_0.txt, Boost License 1.0)
 * Copyright: Maxim Freck, 2016–2017.
 * Authors:   Maxim Freck
 */
module freck.streams.mixins;

template from(string moduleName)
{
	mixin("import from = " ~ moduleName ~ ";");
}
