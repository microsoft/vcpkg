for sub in ("cc", "framework"):
    with open("libtensorflow_" + sub + ".so.2.3.0-2.params", "r") as f_in:
        with open("libtensorflow_" + sub + ".a.2.3.0-2.params", "w") as f_out:
            for line in f_in:
                if line.startswith("-o "):
                    line = line.replace(".so", ".a")
                    f_out.write(line)
                elif line.startswith("bazel-out"):
                    f_out.write(line)
