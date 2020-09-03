for sub in ("cc", "framework"):
    with open("libtensorflow_" + sub + ".so.2.3.0-2.params", "r") as f_in:
        with open("libtensorflow_" + sub + ".a.2.3.0-2.params", "w") as f_out:
            skip_next = False
            for line in f_in:
                if skip_next:
                    skip_next = False
                    continue
                if line.startswith("-o"):
                    skip_next = True
                elif line.startswith("bazel-out"):
                    f_out.write(line)
