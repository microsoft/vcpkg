import os.path
import re
import sys

lib_suffix = "" if len(sys.argv) < 3 else sys.argv[2]
with open(sys.argv[1], "r") as f_in:
    with open("static_link.bat", "w") as f_out:
        p_setenv = re.compile("^\s*(SET .+=.*)$")
        p_linker = re.compile(fr".+link\.exe.+tensorflow{lib_suffix}\.dll-2\.params.*")
        env = []
        for line in f_in:
            if line.startswith("cd"):
                # new command, reset
                env = []
            else:
                m = p_setenv.match(line)
                if m:
                    env.append(m.group(1))
                else:
                    m = p_linker.match(line)
                    if m:
                        for e in env:
                            f_out.write(e + "\n")
                        tokens = line.split()
                        line = "\""
                        params_file = None
                        for t in tokens:
                            if t.endswith("link.exe"):
                                t = t[:-len("link.exe")] + "lib.exe\""
                            elif t == "/DLL" or t.lower()[1:].startswith("defaultlib:") or t.lower()[1:].startswith("ignore") or t.startswith("/OPT:") or t.startswith("/DEF:") or t.startswith("/DEBUG:") or t.startswith("/INCREMENTAL:"):
                                continue
                            elif t[0] == '@' and t.endswith(f"tensorflow{lib_suffix}.dll-2.params"):
                                t = t[:-len("dll-2.params")] + "lib-2.params-part1"
                                params_file = t[1:-len("-part1")]
                            line += t + " "
                        f_out.write(line + "\n")
                        # check for more parts if library needs to be split
                        file_no = 2
                        while os.path.isfile(f"{params_file}-part{file_no}"):
                            f_out.write(line.replace("lib-2.params-part1", f"lib-2.params-part{file_no}") + "\n")
                            file_no += 1
                        break
