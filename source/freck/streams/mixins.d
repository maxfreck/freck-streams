module freck.streams.mixins;

template from(string moduleName)
{
	mixin("import from = " ~ moduleName ~ ";");
}
