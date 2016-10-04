/*
 *  Copyright 2001-2007 Adrian Thurston <thurston@complang.org>
 */

/*  This file is part of Ragel.
 *
 *  Ragel is free software; you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation; either version 2 of the License, or
 *  (at your option) any later version.
 * 
 *  Ragel is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 * 
 *  You should have received a copy of the GNU General Public License
 *  along with Ragel; if not, write to the Free Software
 *  Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA 
 */

#include <stdlib.h>
#include <string.h>
#include <stdio.h>
#include <iostream>
#include <fstream>
#include <sstream>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <errno.h>

#ifdef _WIN32
#include <windows.h>
#include <psapi.h>
#include <time.h>
#include <io.h>
#include <process.h>

#if _MSC_VER
#define S_IRUSR _S_IREAD
#define S_IWUSR _S_IWRITE
#endif
#endif

/* Parsing. */
#include "ragel.h"
#include "rlscan.h"

/* Parameters and output. */
#include "pcheck.h"
#include "vector.h"
#include "version.h"
#include "common.h"
#include "inputdata.h"

using std::istream;
using std::ostream;
using std::ifstream;
using std::ofstream;
using std::cin;
using std::cout;
using std::cerr;
using std::endl;
using std::ios;
using std::streamsize;

/* Controls minimization. */
MinimizeLevel minimizeLevel = MinimizePartition2;
MinimizeOpt minimizeOpt = MinimizeMostOps;

/* Graphviz dot file generation. */
const char *machineSpec = 0, *machineName = 0;
bool machineSpecFound = false;
bool wantDupsRemoved = true;

bool printStatistics = false;
bool generateXML = false;
bool generateDot = false;

/* Target language and output style. */
CodeStyle codeStyle = GenTables;

int numSplitPartitions = 0;
bool noLineDirectives = false;

bool displayPrintables = false;

/* Target ruby impl */
RubyImplEnum rubyImpl = MRI;

/* Print a summary of the options. */
void usage()
{
	cout <<
"usage: ragel [options] file\n"
"general:\n"
"   -h, -H, -?, --help   Print this usage and exit\n"
"   -v, --version        Print version information and exit\n"
"   -o <file>            Write output to <file>\n"
"   -s                   Print some statistics on stderr\n"
"   -d                   Do not remove duplicates from action lists\n"
"   -I <dir>             Add <dir> to the list of directories to search\n"
"                        for included an imported files\n"
"error reporting format:\n"
"   --error-format=gnu   file:line:column: message (default)\n"
"   --error-format=msvc  file(line,column): message\n"
"fsm minimization:\n"
"   -n                   Do not perform minimization\n"
"   -m                   Minimize at the end of the compilation\n"
"   -l                   Minimize after most operations (default)\n"
"   -e                   Minimize after every operation\n"
"visualization:\n"
"   -x                   Run the frontend only: emit XML intermediate format\n"
"   -V                   Generate a dot file for Graphviz\n"
"   -p                   Display printable characters on labels\n"
"   -S <spec>            FSM specification to output (for graphviz output)\n"
"   -M <machine>         Machine definition/instantiation to output (for graphviz output)\n"
"host language:\n"
"   -C                   The host language is C, C++, Obj-C or Obj-C++ (default)\n"
"   -D                   The host language is D\n"
"   -Z                   The host language is Go\n"
"   -J                   The host language is Java\n"
"   -R                   The host language is Ruby\n"
"   -A                   The host language is C#\n"
"   -O                   The host language is OCaml\n"
"line directives: (C/D/Ruby/C#/OCaml)\n"
"   -L                   Inhibit writing of #line directives\n"
"code style: (C/D/Java/Ruby/C#/OCaml)\n"
"   -T0                  Table driven FSM (default)\n"
"code style: (C/D/Ruby/C#/OCaml)\n"
"   -T1                  Faster table driven FSM\n"
"   -F0                  Flat table driven FSM\n"
"   -F1                  Faster flat table-driven FSM\n"
"code style: (C/D/C#/OCaml)\n"
"   -G0                  Goto-driven FSM\n"
"   -G1                  Faster goto-driven FSM\n"
"code style: (C/D)\n"
"   -G2                  Really fast goto-driven FSM\n"
"   -P<N>                N-Way Split really fast goto-driven FSM\n"
	;	

	exit(0);
}

/* Print version information and exit. */
void version()
{
	cout << "Ragel State Machine Compiler version " VERSION << " " PUBDATE << endl <<
			"Copyright (c) 2001-2009 by Adrian Thurston" << endl;
	exit(0);
}

/* Error reporting format. */
ErrorFormat errorFormat = ErrorFormatGNU;

InputLoc makeInputLoc( const char *fileName, int line, int col)
{
	InputLoc loc = { fileName, line, col };
	return loc;
}

ostream &operator<<( ostream &out, const InputLoc &loc )
{
	assert( loc.fileName != 0 );
	switch ( errorFormat ) {
	case ErrorFormatMSVC:
		out << loc.fileName << "(" << loc.line;
		if ( loc.col )
			out << "," << loc.col;
		out << ")";
		break;

	default:
		out << loc.fileName << ":" << loc.line;
		if ( loc.col )
			out << ":" << loc.col;
		break;
	}
	return out;
}

/* Total error count. */
int gblErrorCount = 0;

/* Print the opening to a warning in the input, then return the error ostream. */
ostream &warning( const InputLoc &loc )
{
	cerr << loc << ": warning: ";
	return cerr;
}

/* Print the opening to a program error, then return the error stream. */
ostream &error()
{
	gblErrorCount += 1;
	cerr << PROGNAME ": ";
	return cerr;
}

ostream &error( const InputLoc &loc )
{
	gblErrorCount += 1;
	cerr << loc << ": ";
	return cerr;
}

void escapeLineDirectivePath( std::ostream &out, char *path )
{
	for ( char *pc = path; *pc != 0; pc++ ) {
		if ( *pc == '\\' )
			out << "\\\\";
		else
			out << *pc;
	}
}

void processArgs( int argc, const char **argv, InputData &id )
{
	ParamCheck pc("xo:dnmleabjkS:M:I:CDEJZRAOvHh?-:sT:F:G:P:LpV", argc, argv);

	/* FIXME: Need to check code styles VS langauge. */

	while ( pc.check() ) {
		switch ( pc.state ) {
		case ParamCheck::match:
			switch ( pc.parameter ) {
			case 'V':
				generateDot = true;
				break;

			case 'x':
				generateXML = true;
				break;

			/* Output. */
			case 'o':
				if ( *pc.paramArg == 0 )
					error() << "a zero length output file name was given" << endl;
				else if ( id.outputFileName != 0 )
					error() << "more than one output file name was given" << endl;
				else {
					/* Ok, remember the output file name. */
					id.outputFileName = pc.paramArg;
				}
				break;

			/* Flag for turning off duplicate action removal. */
			case 'd':
				wantDupsRemoved = false;
				break;

			/* Minimization, mostly hidden options. */
			case 'n':
				minimizeOpt = MinimizeNone;
				break;
			case 'm':
				minimizeOpt = MinimizeEnd;
				break;
			case 'l':
				minimizeOpt = MinimizeMostOps;
				break;
			case 'e':
				minimizeOpt = MinimizeEveryOp;
				break;
			case 'a':
				minimizeLevel = MinimizeApprox;
				break;
			case 'b':
				minimizeLevel = MinimizeStable;
				break;
			case 'j':
				minimizeLevel = MinimizePartition1;
				break;
			case 'k':
				minimizeLevel = MinimizePartition2;
				break;

			/* Machine spec. */
			case 'S':
				if ( *pc.paramArg == 0 )
					error() << "please specify an argument to -S" << endl;
				else if ( machineSpec != 0 )
					error() << "more than one -S argument was given" << endl;
				else {
					/* Ok, remember the path to the machine to generate. */
					machineSpec = pc.paramArg;
				}
				break;

			/* Machine path. */
			case 'M':
				if ( *pc.paramArg == 0 )
					error() << "please specify an argument to -M" << endl;
				else if ( machineName != 0 )
					error() << "more than one -M argument was given" << endl;
				else {
					/* Ok, remember the machine name to generate. */
					machineName = pc.paramArg;
				}
				break;

			case 'I':
				if ( *pc.paramArg == 0 )
					error() << "please specify an argument to -I" << endl;
				else {
					id.includePaths.append( pc.paramArg );
				}
				break;

			/* Host language types. */
			case 'C':
				hostLang = &hostLangC;
				break;
			case 'D':
				hostLang = &hostLangD;
				break;
			case 'E':
				hostLang = &hostLangD2;
				break;
			case 'Z':
				hostLang = &hostLangGo;
				break;
			case 'J':
				hostLang = &hostLangJava;
				break;
			case 'R':
				hostLang = &hostLangRuby;
				break;
			case 'A':
				hostLang = &hostLangCSharp;
				break;
			case 'O':
				hostLang = &hostLangOCaml;
				break;

			/* Version and help. */
			case 'v':
				version();
				break;
			case 'H': case 'h': case '?':
				usage();
				break;
			case 's':
				printStatistics = true;
				break;
			case '-': {
				char *arg = strdup( pc.paramArg );
				char *eq = strchr( arg, '=' );

				if ( eq != 0 )
					*eq++ = 0;

				if ( strcmp( arg, "help" ) == 0 )
					usage();
				else if ( strcmp( arg, "version" ) == 0 )
					version();
				else if ( strcmp( arg, "error-format" ) == 0 ) {
					if ( eq == 0 )
						error() << "expecting '=value' for error-format" << endl;
					else if ( strcmp( eq, "gnu" ) == 0 )
						errorFormat = ErrorFormatGNU;
					else if ( strcmp( eq, "msvc" ) == 0 )
						errorFormat = ErrorFormatMSVC;
					else
						error() << "invalid value for error-format" << endl;
				}
				else if ( strcmp( arg, "rbx" ) == 0 )
					rubyImpl = Rubinius;
				else {
					error() << "--" << pc.paramArg << 
							" is an invalid argument" << endl;
				}
				free( arg );
				break;
			}

			/* Passthrough args. */
			case 'T': 
				if ( pc.paramArg[0] == '0' )
					codeStyle = GenTables;
				else if ( pc.paramArg[0] == '1' )
					codeStyle = GenFTables;
				else {
					error() << "-T" << pc.paramArg[0] << 
							" is an invalid argument" << endl;
					exit(1);
				}
				break;
			case 'F': 
				if ( pc.paramArg[0] == '0' )
					codeStyle = GenFlat;
				else if ( pc.paramArg[0] == '1' )
					codeStyle = GenFFlat;
				else {
					error() << "-F" << pc.paramArg[0] << 
							" is an invalid argument" << endl;
					exit(1);
				}
				break;
			case 'G': 
				if ( pc.paramArg[0] == '0' )
					codeStyle = GenGoto;
				else if ( pc.paramArg[0] == '1' )
					codeStyle = GenFGoto;
				else if ( pc.paramArg[0] == '2' )
					codeStyle = GenIpGoto;
				else {
					error() << "-G" << pc.paramArg[0] << 
							" is an invalid argument" << endl;
					exit(1);
				}
				break;
			case 'P':
				codeStyle = GenSplit;
				numSplitPartitions = atoi( pc.paramArg );
				break;

			case 'p':
				displayPrintables = true;
				break;

			case 'L':
				noLineDirectives = true;
				break;
			}
			break;

		case ParamCheck::invalid:
			error() << "-" << pc.parameter << " is an invalid argument" << endl;
			break;

		case ParamCheck::noparam:
			/* It is interpreted as an input file. */
			if ( *pc.curArg == 0 )
				error() << "a zero length input file name was given" << endl;
			else if ( id.inputFileName != 0 )
				error() << "more than one input file name was given" << endl;
			else {
				/* OK, Remember the filename. */
				id.inputFileName = pc.curArg;
			}
			break;
		}
	}
}

void process( InputData &id )
{
	/* Open the input file for reading. */
	assert( id.inputFileName != 0 );
	ifstream *inFile = new ifstream( id.inputFileName );
	if ( ! inFile->is_open() )
		error() << "could not open " << id.inputFileName << " for reading" << endp;

	/* Used for just a few things. */
	std::ostringstream hostData;

	/* Make the first input item. */
	InputItem *firstInputItem = new InputItem;
	firstInputItem->type = InputItem::HostData;
	firstInputItem->loc.fileName = id.inputFileName;
	firstInputItem->loc.line = 1;
	firstInputItem->loc.col = 1;
	id.inputItems.append( firstInputItem );

	Scanner scanner( id, id.inputFileName, *inFile, 0, 0, 0, false );
	scanner.do_scan();

	/* Finished, final check for errors.. */
	if ( gblErrorCount > 0 )
		exit(1);

	/* Now send EOF to all parsers. */
	id.terminateAllParsers();

	/* Bail on above error. */
	if ( gblErrorCount > 0 )
		exit(1);

	/* Locate the backend program */
	/* Compiles machines. */
	id.prepareMachineGen();

	if ( gblErrorCount > 0 )
		exit(1);

	id.makeOutputStream();

	/* Generates the reduced machine, which we use to write output. */
	if ( !generateXML ) {
		id.generateReduced();

		if ( gblErrorCount > 0 )
			exit(1);
	}

	id.verifyWritesHaveData();
	if ( gblErrorCount > 0 )
		exit(1);

	/*
	 * From this point on we should not be reporting any errors.
	 */

	id.openOutput();
	id.writeOutput();

	/* Close the input and the intermediate file. */
	delete inFile;

	/* If writing to a file, delete the ostream, causing it to flush.
	 * Standard out is flushed automatically. */
	if ( id.outputFileName != 0 ) {
		delete id.outStream;
		delete id.outFilter;
	}

	assert( gblErrorCount == 0 );
}

char *makeIntermedTemplate( const char *baseFileName )
{
	char *result = 0;
	const char *templ = "ragel-XXXXXX.xml";
	const char *lastSlash = strrchr( baseFileName, '/' );
	if ( lastSlash == 0 ) {
		result = new char[strlen(templ)+1];
		strcpy( result, templ );
	}
	else {
		int baseLen = lastSlash - baseFileName + 1;
		result = new char[baseLen + strlen(templ) + 1];
		memcpy( result, baseFileName, baseLen );
		strcpy( result+baseLen, templ );
	}
	return result;
};

/* Main, process args and call yyparse to start scanning input. */
int main( int argc, const char **argv )
{
	InputData id;

	processArgs( argc, argv, id );

	/* Require an input file. If we use standard in then we won't have a file
	 * name on which to base the output. */
	if ( id.inputFileName == 0 )
		error() << "no input file given" << endl;

	/* Bail on argument processing errors. */
	if ( gblErrorCount > 0 )
		exit(1);

	/* Make sure we are not writing to the same file as the input file. */
	if ( id.inputFileName != 0 && id.outputFileName != 0 && 
			strcmp( id.inputFileName, id.outputFileName  ) == 0 )
	{
		error() << "output file \"" << id.outputFileName  << 
				"\" is the same as the input file" << endp;
	}

	process( id );

	return 0;
}
