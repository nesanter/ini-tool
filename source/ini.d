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
module ini;

enum VERSION = import("VERSION");

import std.stdio : File;

enum Warning {
    /// key appears 2+ in single section
    duplicate,

    /// key appears with empty value (e.g. "foo = ")
    empty,

    /// key appears without assignment (e.g. "foo")
    remove,

    /*** potential key/section confusion, either
     *   open bracket without close or
     *   "=" in section name
     ***/
    sections,

    /// weakly enable all types
    all
}

class INI {
    string[string][string] sections;
    private string[string] currentSection;

    alias sections this;

    bool[Warning] warnings;
    bool warnAll;
    size_t lineNumber;

    this(File file, bool[Warning] warnings = null)
    {
        this.warnings = warnings;
        this.warnAll = warnings.get(Warning.all, false);

        setSection(null);

        foreach (ln; file.byLine) {
            lineNumber++;
            parseLine(ln.dup);
        }
    }

    /*
    this(string source)
    {
        import std.string : lineSplitter;

        setSection(null);

        foreach (ln; source.lineSplitter) {
            parseLine(ln.dup);
        }
    }
    */

    private void setSection(string name)
    {
        if (name !in sections) {
            sections[name] = [null:name];
        }
        
        currentSection = sections[name];
    }

    private void parseLine(string line)
    {
        import std.string : strip, indexOf;

        // strip leading and trailing whitespace
        line = line.strip;

        if (line.length == 0) {
            // blank line
            return;
        }

        if (line[0] == '#') {
            // comment line
            return;
        }

        if (line[0] == '[' && line[$-1] == ']') {
            // section line
            setSection(line[1 .. $ - 1]);

            if (warnings.get(Warning.sections, warnAll)) {
                if (line.indexOf('=') != -1) {
                    warn("section name contains '='");
                }
            }
            return;
        }

        if (warnings.get(Warning.sections, warnAll)) {
            if (line[0] == '[') {
                if (line.indexOf(']') == -1) {
                    warn("key begins with '['");
                } else {
                    warn("key begins with '[' and contains ']'");
                }
            }
        }

        // key/value line

        // find '='
        auto eq = line.indexOf('=');

        if (eq == -1) {
            if (warnings.get(Warning.remove, warnAll)) {
                warn("key form is removal");
            }

            // reset key line
            if (line in currentSection) {
                currentSection.remove(line);
            }
            return;
        }

        auto key = line[0 .. eq].strip;
        auto val = line[eq + 1 .. $].strip;

        if (warnings.get(Warning.sections, warnAll)) {
            if (key.length >= 2 && key[0] == '[' && key[$-1] == ']') {
                warn("key name is section-like");
            }
        }

        if (warnings.get(Warning.duplicate, warnAll)) {
            if (key in currentSection) {
                warn("key name is duplicate");
                if (currentSection[key] == val) {
                    warn("key value is duplicate");
                }
            }
        }

        if (warnings.get(Warning.empty, warnAll)) {
            if (val.length == 0) {
                warn("key value is empty");
            }
            if (key.length == 0) {
                warn("key name is empty");
            }
        }

        currentSection[key] = val;
    }

    void write(File file)
    {
        foreach (name, sec; sections) {
            if (name !is null) {
                file.writeln("\n[", name, "]");
            }

            foreach (k, v; sec) {
                if (k == "" && v == name) {
                    continue;
                }
                file.writeln(k, " = ", v);
            }
        }
    }

    private void warn(string msg) {
        import std.stdio : stderr;
        stderr.writeln("warning (line ", lineNumber, "): ", msg);
    }
}

