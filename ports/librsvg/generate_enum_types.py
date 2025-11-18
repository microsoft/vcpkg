#!/usr/bin/env python3

import argparse
import pathlib
import subprocess
import sys

def main():
    parser = argparse.ArgumentParser(description="Generate librsvg2 enum type definitions.")
    parser.add_argument("--glib-mkenums", type=str, required=True, help="Path to glib-mkenums tool")
    parser.add_argument("--input-dir", type=str, required=True, help="Source path containing input enum definition files")
    parser.add_argument("--output-dir", type=str, required=True, help="Directory to output generated files")
    parser.add_argument("inputs", nargs='+', help="Input enum definition files")
    args = parser.parse_args()

    output_dir = pathlib.Path(args.output_dir)
    input_dir = pathlib.Path(args.input_dir)

    output_dir.mkdir(parents=True, exist_ok=True)

    inputs = [p.relative_to(input_dir) for p in map(pathlib.Path, args.inputs)]

    header_arguments = [
        sys.executable,
        args.glib_mkenums,
        "--fhead",
        R'#if !defined (__RSVG_RSVG_H_INSIDE__) && !defined (RSVG_COMPILATION)\n#warning \"Including <librsvg/librsvg-enum-types.h> directly is deprecated.\"\n#endif\n\n#ifndef __LIBRSVG_ENUM_TYPES_H__\n#define __LIBRSVG_ENUM_TYPES_H__\n\n#include <glib-object.h>\n\nG_BEGIN_DECLS\n',
        "--fprod",
        R'/* enumerations from \"@filename@\" */\n',
        "--vhead",
        R'GType @enum_name@_get_type (void);\n#define RSVG_TYPE_@ENUMSHORT@ (@enum_name@_get_type())\n',
        "--ftail",
        R'G_END_DECLS\n\n#endif /* __LIBRSVG_ENUM_TYPES_H__ */',
        "--output",
        output_dir / "librsvg-enum-types.h"
    ] + inputs

    subprocess.run(header_arguments, cwd=input_dir, check=True)

    source_arguments = [
        sys.executable,
        args.glib_mkenums,
        "--fhead",
        R'#include "rsvg.h"',
        "--fprod",
        R'\n/* enumerations from "@filename@" */\n',
        "--vhead",
        R'GType\n@enum_name@_get_type (void)\n{\n  static GType etype = 0;\n  if (etype == 0) {\n    static const G@Type@Value values[] = { ',
        "--vprod",
        R'      { @VALUENAME@, "@VALUENAME@", "@valuenick@" }, ',
        "--vtail",
        R'      { 0, NULL, NULL }\n    };\n    etype = g_@type@_register_static ("@EnumName@", values);\n  }\n  return etype;\n}\n ',
        "--output",
        output_dir / "librsvg-enum-types.c"
    ] + inputs

    subprocess.run(source_arguments, cwd=input_dir, check=True)

    return 0

if __name__ == "__main__":
    main()
