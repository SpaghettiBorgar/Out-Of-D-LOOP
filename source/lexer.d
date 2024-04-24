module lexer;
@safe:

import std.format;
import std.exception;

enum TokenType
{
	NONE,
	VAR,
	CONST,
	ASSIGN,
	PLUS,
	LOOP,
	DO,
	END,
	SEM,
	LOOPPROG,
	SEMPROG,
	EOF
}

enum CharClass
{
	NONE,
	WHITE,
	ALPHNUM,
	SYMB,
	SEP
}

struct Token
{
	TokenType type;
	string value;

	this(TokenType type, string value = null)
	{
		this.type = type;
		this.value = value;
	}

	@property bool isProg() const
	{
		return type == TokenType.SEMPROG || type == TokenType.ASSIGN || type == TokenType.LOOPPROG;
	}

	@property bool isTerminator() const
	{
		return type == TokenType.EOF || type == TokenType.SEM || type == TokenType.END;
	}

	const(string) toString() const
	{
		return format!"%s%s"(type, value);
	}
}

class LexingException : Exception
{
	mixin basicExceptionCtors;
}

Token[] lex(string inp)
{
	string[] seps = separate(inp);
	Token[] ret = [];

	foreach (i, e; seps)
	{
		import std.stdio;

		writeln(e);
		TokenType type = TokenType.NONE;
		string value;
		switch (e)
		{
		case ":=":
			type = TokenType.ASSIGN;
			break;
		case "+":
			type = TokenType.PLUS;
			break;
		case "0":
		case "1":
			type = TokenType.CONST;
			value = e;
			break;
		case ";":
			type = TokenType.SEM;
			break;
		case "LOOP":
			type = TokenType.LOOP;
			break;
		case "DO":
			type = TokenType.DO;
			break;
		case "ENDLOOP":
			type = TokenType.END;
			break;
		default:
			import std.algorithm.searching : all;

			if (e[0] == 'x' && e.length > 1 && e[1 .. $].all!q{a >= '0' && a <= '9'})
			{
				type = TokenType.VAR;
				value = e[1 .. $];
				break;
			}
			throw new LexingException(format!"Token %d: %s"(i, e));
		}
		ret ~= Token(type, value);
	}

	return ret ~ Token(TokenType.EOF);
}

string[] separate(string inp)
{
	inp ~= '\n';
	string[] ret = [];

	CharClass currentparsing = CharClass.NONE;
	uint start, read = 0;

	while (start + read < inp.length)
	{
		void push()
		{
			ret ~= inp[start .. start + read];
			start += read;
			read = 0;
			currentparsing = CharClass.NONE;
		}

		switch (inp[start + read])
		{
		case ' ':
		case '\t':
		case '\n':
		case '\r':
			if (read > 0)
				push();
			else
				++start;
			break;
		case '0': .. case '9':
		case 'A': .. case 'Z':
		case 'a': .. case 'z':
			if (
				currentparsing != CharClass.ALPHNUM && read > 0)
			{
				push();
			}
			else
			{
				currentparsing = CharClass.ALPHNUM;
				++read;
			}
			break;
		case '+':
		case ':':
		case '=':
			if (currentparsing != CharClass.SYMB && read > 0)
			{
				push();
			}
			else
			{
				currentparsing = CharClass.SYMB;
				++read;
			}
			break;
		case ';':
			if (read == 0)
				++read;
			push();
			currentparsing = CharClass.NONE;
			break;
		case '#':
			start += read;
			read = 0;
			do
				++start;
			while (inp[start] != '\n');

			break;
		default:
			import std.algorithm.searching : count;

			throw new LexingException(format!"Line %d: %s"(inp[0 .. start + read].count('\n') + 1, inp[start + read]));
		}
	}

	import std.stdio;

	foreach (e; ret)
		writeln(e);
	return ret;
}
