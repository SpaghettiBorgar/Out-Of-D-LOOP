module parser;
@safe:

import std.exception;
import std.format;
import std.stdio;

import lexer;
import tree;
import stack;

class ParsingException : Exception
{
	mixin basicExceptionCtors;
}

Tree!Token parse(Token[] tokens)
{
	import core.memory;

	auto stack = new Stack!(Tree!Token)();

	void reduce()
	{
		switch (stack.peek().val.type)
		{
		case TokenType.VAR:
			Tree!Token[] args = stack.popN(3);
			writeln(args);

			if (args[1].val.type != TokenType.ASSIGN || args[2].val.type != TokenType.VAR)
				throw new ParsingException("invalid assignment: " ~ args.format!"%s");

			stack.push(
				args[1].insert(
					args[2],
					args[0]
			)
			);
			writeln(stack.peek());

			break;
		case TokenType.CONST:
			Token lookbehind = stack.peekBelow(1).val;
			if(lookbehind.type == TokenType.ASSIGN)
			{
				Tree!Token[] args = stack.popN(3);
				writeln(args);

				if (args[1].val.type != TokenType.ASSIGN || args[2].val.type != TokenType.VAR)
					throw new ParsingException("invalid assignment: " ~ args.format!"%s");

				stack.push(
					args[1].insert(
						args[2],
						args[0]
					)
				);
			}
			else if(lookbehind.type == TokenType.PLUS)
			{
				Tree!Token[] args = stack.popN(5);
				writeln(args);

				if (args[1].val.type != TokenType.PLUS || args[2].val.type != TokenType.VAR || args[3].val.type != TokenType
					.ASSIGN
					|| args[4].val.type != TokenType.VAR)
					throw new ParsingException("invalid assignment: " ~ args.format!"%s");

				stack.push(
					args[3].insert(
						args[4],
						args[1].insert(
						args[2],
						args[0]
					)
				)
				);
			}
			else
				throw new ParsingException("Invalid assignment");

			writeln(stack.peek());

			break;
		case TokenType.END:
			Tree!Token[] args = stack.popN(5);
			writeln(args);

			if (!args[1].val.isProg || args[2].val.type != TokenType.DO || args[3].val.type != TokenType.VAR
				|| args[4].val.type != TokenType.LOOP)
				throw new ParsingException("invalid loop: " ~ args.format!"%s");

			Tree!Token loopprog =
				new Tree!Token(Token(TokenType.LOOPPROG),
					args[3],
					args[1]
				);

			if (stack.peek().val.type == TokenType.SEMPROG)
				stack.peek().insert(loopprog);
			else
				stack.push(loopprog);
			writeln(stack.peek());

			break;
		case TokenType.SEM:
			Tree!Token[] args = stack.popN(2);
			writeln(args);

			if (!args[1].val.isProg)
				throw new ParsingException("invalid prog: " ~ args.format!"%s");

			if (stack.size > 0 && stack.peek().val.type == TokenType.SEMPROG)
				stack.peek().insert(args[1]);
			else
			{
				stack.push(
					new Tree!Token(Token(TokenType.SEMPROG),
						args[1]
				)
				);
			}
			writeln(stack.peek());

			break;
		case TokenType.EOF:
			stack.pop();
			break;
		default:
			assert(0);
		}
	}

	foreach (i, tok; tokens)
	{
		stack.push(new Tree!Token(tok));

		writeln(tok);

		switch (tok.type)
		{
		case TokenType.VAR:
			Token lookahead = tokens[i + 1];
			if (lookahead.isTerminator)
				reduce();
			break;
		case TokenType.CONST:
			reduce();
			break;
		case TokenType.ASSIGN:
		case TokenType.PLUS:
		case TokenType.LOOP:
		case TokenType.DO:
			break;
		case TokenType.END:
		case TokenType.SEM:
		case TokenType.EOF:
			reduce();
			break;
		case TokenType.LOOPPROG:
		case TokenType.SEMPROG:
		default:
			throw new ParsingException("Bad TokenType " ~ tok.format!"%s");
		}

		writeln();
	}

	if (stack.size != 1)
		throw new ParsingException("Error: stack size not 1");

	return stack.peek();
}
