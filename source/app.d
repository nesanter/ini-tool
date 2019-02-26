/* Copyright © 2019 Noah Santer <n.ed.santer@gmail.com>
 *
 * This file is part of ini-tool.
 * 
 * ini-tool is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 * 
 * ini-tool is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 * 
 * You should have received a copy of the GNU General Public License
 * along with ini-tool.  If not, see <https://www.gnu.org/licenses/>.
 */

/***
 * A simple utility for working with INI files.
 */

import std.stdio;
import std.getopt;
import std.conv : ConvException, to;

import ini;

void optprinter(Option[] options, File file) {
    import std.process : environment;
    import std.format : format;

    enum fallback = 80;

    size_t twidth = to!size_t(environment.get("COLUMNS", to!string(fallback)));

    size_t maxName;

    enum indent = "  ";

    // max name
    foreach (opt; options) {
        if (opt.optLong.length > maxName) {
            maxName = opt.optLong.length;
        }
    }

    size_t padTo = maxName + indent.length;

    if (padTo > twidth) {
        // fallback
        twidth = fallback;
    }

    foreach (opt; options[0 .. $-1]) { // drop the last option as it is redundant help
        string s = indent ~ opt.optLong;
        foreach (i; s.length .. padTo) {
            s ~= " ";
        }
        file.write(s);
        if (padTo + indent.length + opt.help.length < twidth) {
            file.writeln(indent, opt.help);
        } else {
            string help = opt.help.dup;
            size_t l = twidth - padTo - indent.length;
            string pad;
            foreach (i; 0 .. padTo + indent.length) {
                pad ~= " ";
            }

            file.writeln();
            while (help.length >= l) {
                file.writeln(pad, help[0 .. l]);
                help = help[l .. $];
            }

            if (help.length > 0) {
                file.writeln(pad, help);
            }
        }
    }
}


int main(string[] args)
{
    enum INFO = "";

    string outName;
    bool[Warning] warnings;
    bool warn;

    bool help;
    bool longHelp;
    bool license;
    bool justVersion;

    arraySep = ",";

    try {
        auto helpInfo = getopt(args,
                "output|o", "Write output to file (use - for stdout)", &outName,
                "warn|w", "Set warnings to enabled by defeault", &warn,
                "warnings", "Set enable status for specific warnings\n", &warnings,

                "h|h", "Show shorter help", &help,
                "help", "Show longer help", &longHelp,
                "license", "Show full license information", &license,
                "version", "Print the bare version", &justVersion,
            );

        if (license) {
            writeln(import("LICENSE"));
            return 1;
        }

        if (justVersion) {
            writeln(VERSION);
            return 1;
        }

        if (help || longHelp) {
            writeln(import("HELP.pre"));
            optprinter(helpInfo.options, stdout);
            //defaultGetoptPrinter(import("HELP.pre"), helpInfo.options);
            writeln();

            if (longHelp) {
                writeln("VERSION\n\n", VERSION, " [", import("BUILDINFO.gen"), "]");
                writeln(import("HELP.post"));
                writeln(import("COPYING.post"));
            } else {
                writeln("version ", VERSION);
            }

            writeln(import("COPYING.short"));
            
            return 1;
        }

    } catch (ConvException e) {
        stderr.writeln("invalid argument passed to option(s)");
        return 1;
    } catch (Exception e) {
        stderr.writeln(e.msg);
        return 1;
    }

    if (warn) {
        warnings[Warning.all] = true;
    }

    bool check;
    File outFile;
    if (outName == "") {
        check = true;
    } else if (outName == "-") {
        outFile = stdout;
    } else {
        try {
            outFile = File(outName, "w");
        } catch (StdioException e) {
            stderr.writeln(e);
            return 1;
        }
    }

    void process(File inFile)
    {
        auto ini = new INI(inFile, warnings);
        if (!check) {
            ini.write(outFile);
        }
    }

    if (args.length == 1) {
        process(stdin);
    } else {
        foreach (arg; args[1 .. $]) {
            if (arg == "-" ) {
                process(stdin);
            } else {
                try {
                    process(File(arg, "r"));
                } catch (StdioException e) {
                    stderr.writeln(e);
                    return 1;
                }
            }
        }
    }

    return 0;
}

