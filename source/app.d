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
import std.conv : ConvException;

import ini;

int main(string[] args)
{
    enum INFO = "";

    string outName;
    bool[Warning] warnings;
    bool warn;

    arraySep = ",";

    try {
        auto helpInfo = getopt(args,
                "output|o", "Write output to file (use - for stdout)", &outName,
                "warn|w", "Set warnings to enabled by defeault", &warn,
                "warnings", "Set enable status for specific warnings", &warnings,
            );

        if (helpInfo.helpWanted) {
            defaultGetoptPrinter(import("HELP.pre"), helpInfo.options);
            writeln();
            writeln(import("HELP.post"));
            writeln(import("COPYING.post"));
            writeln("Version ", VERSION);
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

