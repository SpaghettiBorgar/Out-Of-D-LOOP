module interpreter;
@safe:

import std.exception;
import std.conv;
import std.stdio;

import tree;
import band;
import lexer;

class InterpretingError : Exception
{
	mixin basicExceptionCtors;
}

uint[] interpret(Tree!Token program, uint[] input)
{
	if (!program.val.isProg)
		throw new InterpretingError("Parsetree root is not a program");

	auto band = new Band!uint(input);

	writeln(band);

	uint evaluate(Tree!Token term)
	{
		switch (term.val.type)
		{
		case TokenType.VAR:
			return band[term.val.value.to!uint];
		case TokenType.CONST:
			return term.val.value.to!uint;
		case TokenType.PLUS:
			return evaluate(term.children[0]) + evaluate(term.children[1]);
		default:
			assert(0);
		}
	}

	void execute(Tree!Token prog)
	{
		if (!prog.val.isProg)
			throw new InterpretingError("Tried to execute non program subtree: ", prog.toString);

		writeln(prog);

		switch (prog.val.type)
		{
		case TokenType.SEMPROG:
			foreach (p; prog.children)
				execute(p);
			break;
		case TokenType.ASSIGN:
			band[prog.children[0].val.value.to!uint] = evaluate(prog.children[1]);
			break;
		case TokenType.LOOPPROG:
			uint loops = evaluate(prog.children[0]);
			foreach (i; 0 .. loops)
				execute(prog.children[1]);
			break;
		default:
			assert(0);
		}

		writeln(band);
	}

	execute(program);

	return cast(uint[]) band;
}
