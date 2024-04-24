module band;
@safe:

class Band(T)
{
	T[] data;

	this(T[] data...)
	{
		this.data = data.dup;
	}

	ref auto opIndex(size_t index)
	{
		if (index >= data.length)
			data.length = index + 1;

		return data[index];
	}

	auto opIndexAssign(T)(T value, size_t index)
	{
		if (index >= data.length)
			data.length = index + 1;

		data[index] = value;

		return value;
	}

	T[] opCast()
	{
		return data;
	}

	override string toString() const @safe pure
	{
		import std.format;

		return data.format!"%(%s %)";
	}

	@property size_t length()
	{
		return data.length;
	}
}
