import os
import sys

file_no = 1
with open("tensorflow_cc.dll-2.params", "r") as f_in:
    lib_name = None
    acc_size = 0
    f_out = open("tensorflow_cc.lib-2.params-part1", "w")
    for line in f_in:
        if line.startswith("/OUT:"):
            lib_name = line
            line = line.replace(".dll", "-part1.lib")
            f_out.write(line)
        elif line.startswith("/WHOLEARCHIVE:"):
            line = line[len("/WHOLEARCHIVE:"):]
            size = os.stat(f"../../{line.strip()}").st_size
            if acc_size + size > 0xFFFFFFFF:
                # we need to split the library if it is >4GB, because it's not supported even on x64 Windows
                f_out.close()
                file_no += 1
                f_out = open(f"tensorflow_cc.lib-2.params-part{file_no}", "w")
                acc_size = 0
                f_out.write(lib_name.replace(".dll", f"-part{file_no}.lib"))
            acc_size += size
            f_out.write(line)
    f_out.close()

