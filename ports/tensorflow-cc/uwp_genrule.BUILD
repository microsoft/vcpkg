genrule(
    name = "patch_include_dirs",
    cmd = """
mkdir $@@
cp '@CMAKE_CURRENT_LIST_DIR@/uwppatch.h' $@@
echo \\\"$@@\\\" >> $(location @@local_config_cc//:builtin_include_directory_paths_msvc)
""",
    srcs = [
        "@@local_config_cc//:toolchain",
        "@@local_config_cc//:builtin_include_directory_paths_msvc",
    ],
    outs = [
        "patched_includes"
    ],
)
