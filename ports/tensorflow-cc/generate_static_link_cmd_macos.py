import re
import sys

with open(sys.argv[1], "r") as f_in:
    with open("static_link.sh", "w") as f_out:
        p_cd = re.compile("^\\((cd .*) && \\\\$")
        p_linker1 = re.compile("^.*cc_wrapper.sh.+-shared.+-o (bazel-out\\S+libtensorflow_cc\\.2\\.3\\.0\\.dylib)")
        p_linker2 = re.compile("^.*cc_wrapper.sh.+-shared.+-o (bazel-out\\S+libtensorflow_framework\\.2\\.3\\.0\\.dylib)")
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
                    m = p_cd.match(env[0])
                    f_out.write(m.group(1) + "\n")
                    tokens = line.split()
                    parts = [t[16:] for t in tokens if t.startswith("-Wl,-force_load,")]
                    line = "ar -rcs " + m1.group(1).replace(".dylib", ".a")  + " " + " ".join(parts)
                    f_out.write(line + "\n")
                    found1 = True
                    if found2:
                        break
                elif m2 and len(env) > 4:
                    m = p_cd.match(env[0])
                    f_out.write(m.group(1) + "\n")
                    tokens = line.split()
                    parts = [t[16:] for t in tokens if t.startswith("-Wl,-force_load,")]
                    line = "ar -rcs " + m2.group(1).replace(".dylib", ".a")  + " " + " ".join(parts)
                    f_out.write(line + "\n")
                    found2 = True
                    if found1:
                        break
