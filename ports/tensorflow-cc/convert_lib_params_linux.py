import sys

version = sys.argv[1]

with open(f"libtensorflow_cc.a.{version}-2.params", "w") as f_out:
    parts = []
    with open(f"libtensorflow_framework.so.{version}-2.params", "r") as f_in:
        skip_next = False
        for line in f_in:
            if skip_next:
                skip_next = False
                continue
            if line.startswith("-o"):
                skip_next = True
            elif line.startswith("bazel-out"):
                f_out.write(line)
                parts.append(line)
    parts = set(parts)
    with open(f"libtensorflow_cc.so.{version}-2.params", "r") as f_in:
        skip_next = False
        for line in f_in:
            if skip_next:
                skip_next = False
                continue
            if line.startswith("-o"):
                skip_next = True
            elif line.startswith("bazel-out"):
                if line not in parts:
                    f_out.write(line)
