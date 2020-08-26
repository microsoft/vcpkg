for sub in ("cc", "framework"):
    with open("libtensorflow_" + sub + ".2.3.0.dylib-2.params", "r") as f_in:
        with open("libtensorflow_" + sub + ".2.3.0.a-2.params", "w") as f_out:
            for line in f_in:
                if line.startswith("-o "):
                    line = line.replace(".dylib", ".a")
                    f_out.write(line)
                elif line.startswith("bazel-out"):
                    f_out.write(line)
