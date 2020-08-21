import os
import sys

required_number = int(sys.argv[1])

file_no = 1
with open("tensorflow_cc.dll-2.params", "r") as f_in:
    lib_name = None
    acc_size = 0
    f_out = open("tensorflow_cc.lib-2.params", "w")
    for line in f_in:
        if line.startswith("/OUT:"):
            lib_name = line
            line = line.replace(".dll", ".lib")
            f_out.write(line)
        elif line.startswith("/WHOLEARCHIVE:"):
            line = line[len("/WHOLEARCHIVE:"):]
            size = os.stat("../../" + line.strip()).st_size
            if acc_size + size > 0xFFFFFFFF:
                # we need to split the library if it is >4GB, because it's not supported even on x64 Windows
                f_out.close()
                file_no += 1
                f_out = open("tensorflow_cc.lib-2.params-part%d" % file_no, "w")
                acc_size = 0
                f_out.write(lib_name.replace(".dll", "-part%d.lib" % file_no))
            acc_size += size
            f_out.write(line)
    f_out.close()

if file_no < required_number:  # vcpkg requires the same number of libs for release build
    missing = required_number - file_no
    lines = None
    with open("tensorflow_cc.lib-2.params-part%d" % file_no, "r") as f_in:
        lines = f_in.readlines()
    if len(lines) < missing + 2:  # last lib to small, also use the one before
        lines = lines[1:]
        file_no -= 1
        missing += 1
        with open("tensorflow_cc.lib-2.params-part%d" % file_no, "r") as f_in:
            lines = f_in.readlines() + lines
    assert len(lines) >= missing + 2
    with open("tensorflow_cc.lib-2.params-part%d" % file_no, "w") as f_out:
        f_out.writelines(lines[:-missing])
    for i in range(missing):
        with open("tensorflow_cc.lib-2.params-part%d" % (file_no + i + 1), "w") as f_out:
            f_out.writeline(lines[0])
            f_out.writeline(lines[-(missing - i)])
