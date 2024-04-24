import std.stdio;
import std.getopt;
import std.json;
import std.conv;
import std.format;
import std.process;

import file = std.file;

import tree;
import lexer;
import parser;
import interpreter;

// config/command line variables
string input;
string preprocessor = "cpp";

int main(string[] args)
{
	//dfmt off
	version(linux) version(DigitalMars)
	{
		import etc.linux.memoryerror;
		registerMemoryErrorHandler();
	}

	auto helpInformation = (() @trusted => getopt(args,
		"input", "Input file to process", &input,
		"preprocessor", "Path to preprocessor to use for macro processing (default=cpp, empty string to skip)", &preprocessor))();
	//dfmt on

	if (helpInformation.helpWanted)
	{
		(() @trusted => defaultGetoptPrinter("Loop program interpreter", helpInformation.options))();
		return 2;
	}

	if (input is null)
	{
		writeln("No input file specified, use --help for help");
		return 2;
	}

	if (!file.exists(input))
	{
		writeln("File not found");
		return 1;
	}

	string programtext;

	if (preprocessor !is null && preprocessor != "")
	{
		writeln("Preprocessing...");
		auto cpp = execute([preprocessor, input]);

		if (cpp.status != 0)
		{
			writeln("Error when invoking preprocessor: exit status ", cpp.status);
			writeln(cpp.output);
			return 1;
		}

		programtext = cpp.output;
	}
	else
	{
		writeln("Skipping Preprocessing...");
		programtext = file.readText(input);
	}

	writeln("Lexing...");
	auto tokens = lex(programtext);
	writeln(tokens);

	writeln("Parsing...");
	auto parsetree = parser.parse(tokens);
	writeln(parsetree);

	writeln("Interpreting...");
	auto output = interpret(parsetree, args[1 .. $].to!(uint[]));

	writeln("Program finished. Output:");
	writeln(output.format!"%(%s %)");

	return 0;
}
