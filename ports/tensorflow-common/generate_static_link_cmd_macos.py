import re
import sys

lib_suffix = "" if len(sys.argv) < 3 else sys.argv[2]
with open(sys.argv[1], "r") as f_in:
    with open("static_link.sh", "w") as f_out:
        p_cd = re.compile(r"^\((cd .*) && \\$")
        p_linker = re.compile(fr"^\s*.+cc_wrapper.sh.+(@bazel-out\S+libtensorflow{lib_suffix}\.\d\.\d\.\d\.dylib-2\.params).*")
        f_out.write("#!/bin/bash\n# note: ar/binutils version 2.27 required to support output files > 4GB\n")
        env = []
        for line in f_in:
            if line.startswith("(cd"):
                # new command, reset
                env = [line]
            else:
                m1 = p_linker.match(line)
                if m1:
                    m2 = p_cd.match(env[0])
                    f_out.write(m2.group(1) + "\n")
                    line = f'"/usr/bin/libtool" -static -o {m1.group(1)[1:-9].replace(".dylib", ".a")} {m1.group(1).replace(".dylib", ".a")}\n'
                    f_out.write(line)
                else:
                    env.append(line)
