module tree;
@safe:

import std.algorithm;
import std.array;

class Tree(T)
{
	T val;
	Tree!T parent;
	Tree!T[] children;

	this(T val, Tree!T[] children...)
	{
		this.val = val;
		foreach (c; children)
			c.parent = this;
		this.children = children.dup;
	}

	@property bool isRoot() const
	{
		return parent is null;
	}

	@property bool isLeaf() const
	{
		return children.length == 0;
	}

	Tree!T insert(Tree!T[] nodes...)
	{
		foreach (n; nodes)
			n.parent = this;
		children ~= nodes;

		return this;
	}

	Tree!T detach(uint i)
	{
		if (i >= children.length)
			return null;

		children[i].parent = null;
		auto ret = children[i];
		children = children[0 .. i] ~ children[i + 1 .. $];

		return ret;
	}

	Tree!T detach()
	{
		if (isRoot)
			return this;
		else
			return parent.detach(cast(uint) parent.children.countUntil!(a => a is this));
	}

	const(T[]) traverse() const
	{
		return [val] ~ children.map!q{a.traverse()}.join;
	}

	const(T[]) traverseLeafFirst() const
	{
		return children.map!q{a.traverse()}.join ~ [val];
	}

	Tree!T search(T val)
	{
		Tree!T innerSearch()
		{
			foreach (n; children)
			{
				auto a = n.search(val);
				if (a !is null)
					return a;
			}
			return null;
		}

		return this.val == val ? this : (isLeaf ? null : innerSearch());
	}

	@property uint depth() const
	{
		return isLeaf ? 1 : 1 + children.map!q{a.depth}.maxElement;
	}

	@property uint numElements() const
	{
		return isLeaf ? 1 : 1 + children.map!q{a.numElements}.sum;
	}

	override string toString() const
	{
		import std.format;

		return isLeaf ? val.format!"%s" : format!"%s[ %(%s %) ]"(val, children);
	}

	const(T) opCast() const
	{
		return this.val;
	}

	Tree!T opIndex(int i)
	{
		return this.children[i];
	}
}

unittest
{
	//dfmt off
	Tree!int tree =
		new Tree!int(5,
			new Tree!int(2,
				new Tree!int(3),
				new Tree!int(4,
					new Tree!int(1)
				)
			),
			new Tree!int(6,
				new Tree!int(7),
				new Tree!int(8),
				new Tree!int(9)
			),
			new Tree!int(0)
		);
	//dfmt on

	assert(tree.traverse() == [5, 2, 3, 4, 1, 6, 7, 8, 9, 0]);
	assert(tree.toString() == "5[ 2[ 3 4[ 1 ] ] 6[ 7 8 9 ] 0 ]");
	assert(tree.isRoot);
	assert(!tree.isLeaf);
	assert(cast(int) tree == 5);
	assert(tree[2].val == 0);
	assert(tree[1][0].parent is tree[1]);
	assert(tree.depth == 4);
	assert(tree.numElements == 10);
	assert(tree.search(7).parent is tree.search(6));
	assert(tree.search(11) is null);
	assert(tree.detach(1).numElements == 4);
	assert(tree.numElements == 6);
	assert(cast(int) tree.search(4).detach()[0] == 1);
}
