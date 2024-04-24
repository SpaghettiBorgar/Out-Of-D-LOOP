module stack;
@safe:

import std.exception;

class StackException : Exception
{
	mixin basicExceptionCtors;
}

class Stack(T)
{
	T[] data;

	this(T[] elements...)
	{
		this.data = elements.dup;
	}

	void push(T[] e...)
	{
		data ~= e;
	}

	T pop()
	{
		if (data.length == 0)
			throw new StackException("Tried to pop empty stack");

		T ret = data[$ - 1];
		data = data[0 .. $ - 1];
		return ret;
	}

	T[] popN(uint n)
	{
		if (data.length < n)
			throw new StackException("Tried to pop more elements than available");

		T[] ret = [];
		foreach (i; 0 .. n)
			ret ~= pop();

		return ret;
	}

	T peek()
	{
		if (data.length == 0)
			throw new StackException("Tried to peek empty stack");

		return data[$ - 1];
	}

	T peekBelow(uint i)
	{
		if (i >= data.length)
			throw new StackException("Tried to peek below stack base");

		return data[$ - i - 1];
	}

	ulong size()
	{
		return data.length;
	}

	override string toString() const
	{
		import std.format;

		return format!"%s"(data);
	}
}
