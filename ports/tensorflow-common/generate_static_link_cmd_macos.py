import os.path
import re
import sys

params_path = sys.argv[2]
version = sys.argv[3]
lib_suffix = "" if len(sys.argv) < 5 else sys.argv[4]

with open(sys.argv[1], "r") as f_in:
    with open("static_link.sh", "w") as f_out:
        if os.path.isfile(f"{params_path}/libtensorflow_framework.{version}.dylib-2.params"):
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
        else:
            # old behaviour (still on some platforms): inline all parameters instead of using -2.params file
            p_cd = re.compile(r"^\((cd .*) && \\$")
            p_linker1 = re.compile(fr"^.*cc_wrapper.sh.+-shared.+-o (bazel-out\S+libtensorflow{lib_suffix}\.\d\.\d\.\d\.dylib)")
            p_linker2 = re.compile("^.*cc_wrapper.sh.+-shared.+-o (bazel-out\\S+libtensorflow_framework\\.\\d\\.\\d\\.\\d\\.dylib)")
            f_out.write("#!/bin/bash\n# note: ar/binutils version 2.27 required to support output files > 4GB\n")
            env = []
            parts = None
            for line in f_in:
                if line.startswith("(cd"):
                    # new command, reset
                    env = [line]
                else:
                    m1 = p_linker1.match(line)
                    m2 = p_linker2.match(line)
                    if m1:
                        tokens = line.split()
                        if parts is None:
                            parts = [t[16:] for t in tokens if t.startswith("-Wl,-force_load,")]
                        else:
                            m = p_cd.match(env[0])
                            f_out.write(m.group(1) + "\n")
                            tmp = [t[16:] for t in tokens if t.startswith("-Wl,-force_load,")]
                            old = set(parts)
                            parts += [t for t in tmp if t not in old]
                            line = f"libtool -static -o {m1.group(1).replace('.dylib', '.a')} {' '.join(parts)}\n"
                            f_out.write(line)
                            break
                    elif m2 and len(env) > 6:
                        tokens = line.split()
                        if parts is None:
                            parts = [t[16:] for t in tokens if t.startswith("-Wl,-force_load,")]
                        else:
                            m = p_cd.match(env[0])
                            f_out.write(m.group(1) + "\n")
                            tmp = [t[16:] for t in tokens if t.startswith("-Wl,-force_load,")]
                            old = set(parts)
                            parts += [t for t in tmp if t not in old]
                            line = f"libtool -static -o {m2.group(1).replace('_framework', lib_suffix).replace('.dylib', '.a')} {' '.join(parts)}\n"
                            f_out.write(line)
                            break
                    else:
                        env.append(line)
