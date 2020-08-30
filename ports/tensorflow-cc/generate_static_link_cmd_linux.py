import re
import sys

with open(sys.argv[1], "r") as f_in:
    with open("static_link.sh", "w") as f_out:
        p_cd = re.compile("^\\((cd .*) && \\$")
        p_linker1 = re.compile("^\\s*(.+)gcc.+(@bazel-out\\S+libtensorflow_cc\\.so\\.2\\.3\\.0-2\\.params).*")
        p_linker2 = re.compile("^\\s*(.+)gcc.+(@bazel-out\\S+libtensorflow_framework\\.so\\.2\\.3\\.0-2\\.params).*")
        f_out.write("#!/bin/bash\n# note: ar/binutils version 2.27 required to support output files > 4GB\n")
        env = None
        found1 = False
        found2 = False
        for line in f_in:
            if line.startswith("(cd"):
                # new command, reset
                env = line
            else:
                m1 = p_linker1.match(line)
                m2 = p_linker2.match(line)
                if m1:
                    m = p_cd.match(env)
                    f_out.write(m.group(1) + "\n")
                    tokens = line.split()
                    line = "\"" + m1.group(1) + "ar\" rcs " + m1.group(2)[:-9].replace(".so", ".a")  + " " + m1.group(2).replace(".so", ".a")
                    f_out.write(line + "\n")
                    found1 = True
                    if found2:
                        break
                elif m2:
                    m = p_cd.match(env)
                    f_out.write(m.group(1) + "\n")
                    tokens = line.split()
                    line = "\"" + m2.group(1) + "ar\" rcs " + m2.group(2)[:-9].replace(".so", ".a")  + " " + m2.group(2).replace(".so", ".a")
                    f_out.write(line + "\n")
                    found2 = True
                    if found1:
                        break
