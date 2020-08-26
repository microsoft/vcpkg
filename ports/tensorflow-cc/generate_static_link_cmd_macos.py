import re
import sys

with open(sys.argv[1], "r") as f_in:
    with open("static_link.sh", "w") as f_out:
        p_linker1 = re.compile("^\\s*(.+)gcc.+-shared.+-o (bazel-out\\S+libtensorflow_cc\\.2\\.3\\.0\\.dylib).+(@bazel-out\\S+libtensorflow_cc\\.2\\.3\\.0\\.dylib-2\\.params).*")
        p_linker2 = re.compile("^\\s*(.+)gcc.+-shared.+-o (bazel-out\\S+libtensorflow_framework\\.2\\.3\\.0\\.dylib).+(@bazel-out\\S+libtensorflow_framework\\.2\\.3\\.0\\.dylib-2\\.params).*")
        f_out.write("#!/bin/bash\n# note: ar/binutils version 2.27 required to support output files > 4GB\n")
        env = []
        found1 = False
        found2 = False
        for line in f_in:
            if line.startswith("(cd"):
                # new command, reset
                env = [line]
            else:
                m1 = p_linker1.match(line)
                m2 = p_linker2.match(line)
                if m1:
                    for e in env:
                        f_out.write(e)
                    tokens = line.split()
                    line = "\"" + m1.group(1) + "ar\" -rcs " + m1.group(2).replace(".dylib", ".a")  + " " + m1.group(3).replace(".dylib", ".a") + ")"
                    f_out.write(line + "\n")
                    found1 = True
                    if found2:
                        break
                elif m2 and len(env) > 4:
                    for e in env:
                        f_out.write(e)
                    tokens = line.split()
                    line = "\"" + m2.group(1) + "ar\" -rcs " + m2.group(2).replace(".dylib", ".a")  + " " + m2.group(3).replace(".dylib", ".a") + ")"
                    f_out.write(line + "\n")
                    found2 = True
                    if found1:
                        break
                else:
                    env.append(line)
