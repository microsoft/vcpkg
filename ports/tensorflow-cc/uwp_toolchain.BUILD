package(default_visibility = ["//visibility:public"])

load("@rules_cc//cc:defs.bzl", "cc_toolchain", "cc_toolchain_suite")
load("@local_config_cc//:windows_cc_toolchain_config.bzl", "cc_toolchain_config")

filegroup(
    name = "empty",
    srcs = [],
)

filegroup(
    name = "msvc_compiler_files_patched",
    srcs = [":builtin_include_directory_paths_msvc"]
)

cc_toolchain_suite(
    name = "uwp_suite",
    toolchains = {
        "x64_windows|msvc-cl": ":cc-compiler-x64_windows_patched",
        "x64_windows": ":cc-compiler-x64_windows_patched",
    },
)

cc_toolchain(
    name = "cc-compiler-x64_windows_patched",
    toolchain_identifier = "msvc_x64",
    toolchain_config = ":msvc_x64",
    all_files = ":empty",
    ar_files = ":empty",
    as_files = ":msvc_compiler_files_patched",
    compiler_files = ":msvc_compiler_files_patched",
    dwp_files = ":empty",
    linker_files = ":empty",
    objcopy_files = ":empty",
    strip_files = ":empty",
    supports_param_files = 1,
)

cc_toolchain_config(name = "msvc_x64", cpu = "x64_windows")

toolchain(
    name = "cc-toolchain-x64_windows_patched",
    exec_compatible_with = [
        "@platforms//cpu:x86_64",
        "@platforms//os:windows",
    ],
    target_compatible_with = [
        "@platforms//cpu:x86_64",
        "@platforms//os:windows",
    ],
    toolchain = ":cc-compiler-x64_windows_patched",
    toolchain_type = "@bazel_tools//tools/cpp:toolchain_type",
)
