import sys

version = sys.argv[1]
lib_suffix = "" if len(sys.argv) < 3 else sys.argv[2]

with open(f"libtensorflow{lib_suffix}.{version}.a-2.params", "w") as f_out:
    parts = []
    with open(f"libtensorflow_framework.{version}.dylib-2.params", "r") as f_in:
        for line in f_in:
            if line.startswith("-Wl,-force_load,"):
                f_out.write(line[16:])
                parts.append(line[16:])
    parts = set(parts)
    with open(f"libtensorflow{lib_suffix}.{version}.dylib-2.params", "r") as f_in:
        for line in f_in:
            if line.startswith("-Wl,-force_load,"):
                if line[16:] not in parts:
                    f_out.write(line[16:])
