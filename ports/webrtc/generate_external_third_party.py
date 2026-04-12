#!/usr/bin/env python3
from __future__ import annotations

import argparse
import dataclasses
import pathlib
import shutil

NASM_ASSEMBLE_GNI = """# Copyright 2018 The Chromium Authors
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file.

# This provides the nasm_assemble() template which uses NASM to assemble
# assembly files.
#
# Files to be assembled with NASM should have an extension of .asm.
#
# Parameters
#
#   nasm_flags (optional)
#       [list of strings] Pass additional flags into NASM. These are appended
#       to the command line. Note that the output format is already set up
#       based on the current toolchain so you don't need to specify these
#       things (see below).
#
#       Example: nasm_flags = [ "-Wall" ]
#
#   include_dirs (optional)
#       [list of dir names] List of additional include dirs. Note that the
#       source root and the root generated file dir is always added, just like
#       our C++ build sets up.
#
#       Example: include_dirs = [ "//some/other/path", target_gen_dir ]
#
#   defines (optional)
#       [list of strings] List of defines, as with the native code defines.
#
#       Example: defines = [ "FOO", "BAR=1" ]
#
#   inputs, deps, visibility  (optional)
#       These have the same meaning as in an action.
#
# Example
#
#   nasm_assemble("my_nasm_target") {
#     sources = [
#       "ultra_optimized_awesome.asm",
#     ]
#     include_dirs = [ "assembly_include" ]
#   }

import("//build/compiled_action.gni")
import("//build/config/ios/config.gni")
import("//build/config/ios/ios_sdk_overrides.gni")
import("//build/config/sanitizers/sanitizers.gni")
if (is_mac) {
  import("//build/config/mac/mac_sdk.gni")
}

if ((is_mac || is_ios) && (current_cpu == "x86" || current_cpu == "x64")) {
  if (current_cpu == "x86") {
    _nasm_flags = [ "-fmacho32" ]
  } else if (current_cpu == "x64") {
    _nasm_flags = [ "-fmacho64" ]
  }
  if (is_mac) {
    _nasm_flags += [ "--macho-min-os=macos$mac_deployment_target" ]
  } else if (is_ios) {
    if (target_environment == "device") {
      _nasm_flags += [ "--macho-min-os=ios$ios_deployment_target" ]
    } else {
      _nasm_flags +=
          [ "--macho-min-os=ios$ios_deployment_target-$target_environment" ]
    }
  }
} else if (is_posix || is_fuchsia) {
  if (current_cpu == "x86") {
    _nasm_flags = [ "-felf32" ]
  } else if (current_cpu == "x64") {
    _nasm_flags = [
      "-DPIC",
      "-felf64",
    ]
  }
} else if (is_win) {
  if (current_cpu == "x86") {
    _nasm_flags = [
      "-DPREFIX",
      "-fwin32",
    ]
  } else if (current_cpu == "x64") {
    _nasm_flags = [ "-fwin64" ]
  }
}

if (is_win) {
  asm_obj_extension = "obj"
} else {
  asm_obj_extension = "o"
}

template("nasm_assemble") {
  assert(defined(invoker.sources), "Need sources defined for $target_name")

  # Only depend on NASM on x86 systems. Force compilation of .asm files for
  # ARM to fail.
  assert(current_cpu == "x86" || current_cpu == "x64")

  action_name = "${target_name}_action"
  source_set_name = target_name

  action_foreach(action_name) {
    # Only the source set can depend on this.
    visibility = [ ":$source_set_name" ]

    forward_variables_from(invoker,
                           [
                             "sources",
                             "inputs",
                             "deps",
                           ])

    if (!defined(deps)) {
      deps = []
    }
    if (host_toolchain_is_msan) {
      deps += [ "//third_party/instrumented_libs:ld-linux($host_toolchain)" ]
      configs = [
        "//third_party/instrumented_libs:msan_runtime_libs($host_toolchain)",
      ]
    }

    script = "{tool_path}"

    args = _nasm_flags
    if (defined(invoker.nasm_flags)) {
      args += invoker.nasm_flags
    }

    args += [ "--reproducible" ]

    if (defined(invoker.include_dirs)) {
      foreach(include, invoker.include_dirs) {
        args += [ "-I" + rebase_path(include, root_build_dir) + "/" ]
      }
    }

    args += [
      "-I./",
      "-I" + rebase_path("//", root_build_dir),
      "-I" + rebase_path(root_gen_dir, root_build_dir) + "/",
    ]

    if (defined(invoker.defines)) {
      foreach(def, invoker.defines) {
        args += [ "-D$def" ]
      }
    }

    outputs = [ "$target_out_dir/$source_set_name/{{source_name_part}}.${asm_obj_extension}" ]
    args += [
      "-MD",
      rebase_path(outputs[0] + ".d", root_build_dir),
      "-o",
      rebase_path(outputs[0], root_build_dir),
      "{{source}}",
    ]

    depfile = outputs[0] + ".d"
  }

  static_library(source_set_name) {
    if (defined(invoker.visibility)) {
      visibility = invoker.visibility
    }

    if (defined(invoker.all_dependent_configs)) {
      all_dependent_configs = invoker.all_dependent_configs
    }

    sources = get_target_outputs(":$action_name")
    public = []
    deps = [ ":$action_name" ]
  }
}
"""

LIBSRTP_OPTIONS_GNI = """declare_args() {
  libsrtp_build_boringssl = false
  libsrtp_ssl_root = ""
}
"""

TESTING_TEST_GNI = """declare_args() {
  tests_have_location_tags = false
  use_fuzztest_wrapper = false
}

exec_target_suffix = ""

template("test") {
  group(target_name) {
    forward_variables_from(invoker, [
      "testonly",
      "visibility",
      "deps",
      "public_deps",
      "data_deps",
    ])
  }
}
"""

GOOGLETEST_BUILD_GN = """config("gtest_config") {
  include_dirs = [
    "custom",
    "src/googletest/include",
  ]
}

config("gmock_config") {
  include_dirs = [
    "custom",
    "src/googletest/include",
    "src/googlemock/include",
  ]
}

source_set("gtest") {
  testonly = true
  public_configs = [ ":gtest_config" ]
  sources = [
    "src/googletest/include/gtest/gtest.h",
    "src/googletest/src/gtest.cc",
  ]
}

source_set("gtest_main") {
  testonly = true
  public_configs = [ ":gtest_config" ]
  deps = [ ":gtest" ]
  sources = [ "src/googletest/src/gtest_main.cc" ]
}

source_set("gmock") {
  testonly = true
  public_configs = [ ":gmock_config" ]
  deps = [ ":gtest" ]
  sources = [
    "src/googlemock/include/gmock/gmock.h",
    "src/googlemock/src/gmock.cc",
  ]
}

source_set("gmock_main") {
  testonly = true
  public_configs = [ ":gmock_config" ]
  deps = [ ":gmock" ]
  sources = [ "src/googlemock/src/gmock_main.cc" ]
}
"""

RNNOISE_BUILD_GN = """config("rnnoise_config") {
  include_dirs = [
    ".",
    "include",
    "src",
    "{include_root}",
  ]
}

source_set("rnn_vad") {
  public_configs = [ ":rnnoise_config" ]
  configs -= [ "//build/config/compiler:chromium_code" ]
  configs += [ "//build/config/compiler:no_chromium_code" ]
  sources = [
    "src/nnet.c",
    "src/nnet_default.c",
    "src/parse_lpcnet_weights.c",
    "src/rnn.c",
    "src/rnnoise_data.c",
  ]
}
"""

RNNOISE_OS_SUPPORT_H = """#ifndef OS_SUPPORT_H
#define OS_SUPPORT_H

#include <opus/opus_defines.h>
#include <opus/opus_types.h>

#include <stdlib.h>
#include <string.h>

#ifndef OVERRIDE_OPUS_ALLOC
static OPUS_INLINE void* opus_alloc(size_t size) {
  return malloc(size);
}
#endif

#ifndef OVERRIDE_OPUS_REALLOC
static OPUS_INLINE void* opus_realloc(void* ptr, size_t size) {
  return realloc(ptr, size);
}
#endif

#ifndef OVERRIDE_OPUS_ALLOC_SCRATCH
static OPUS_INLINE void* opus_alloc_scratch(size_t size) {
  return opus_alloc(size);
}
#endif

#ifndef OVERRIDE_OPUS_FREE
static OPUS_INLINE void opus_free(void* ptr) {
  free(ptr);
}
#endif

#ifndef OVERRIDE_OPUS_COPY
#define OPUS_COPY(dst, src, n) (memcpy((dst), (src), (n) * sizeof(*(dst)) + 0 * ((dst) - (src))))
#endif

#ifndef OVERRIDE_OPUS_MOVE
#define OPUS_MOVE(dst, src, n) (memmove((dst), (src), (n) * sizeof(*(dst)) + 0 * ((dst) - (src))))
#endif

#ifndef OVERRIDE_OPUS_CLEAR
#define OPUS_CLEAR(dst, n) (memset((dst), 0, (n) * sizeof(*(dst))))
#endif

#endif
"""

NASM_BUILD_GN = ""

GOOGLETEST_GTEST_SPI_H = """#pragma once
#define EXPECT_FATAL_FAILURE(statement, substring) do { statement; } while (0)
#define EXPECT_NONFATAL_FAILURE(statement, substring) do { statement; } while (0)
"""

GOOGLETEST_GTEST_H = """#pragma once
#define GTEST_HAS_DEATH_TEST 0
#define FRIEND_TEST(test_case_name, test_name) friend class test_case_name##_##test_name##_Test
#define TEST(test_case_name, test_name) static void test_case_name##_##test_name()
#define TEST_F(test_fixture, test_name) static void test_fixture##_##test_name()
#define EXPECT_TRUE(condition) do { (void)(condition); } while (0)
#define EXPECT_FALSE(condition) do { (void)(condition); } while (0)
#define EXPECT_EQ(expected, actual) do { (void)(expected); (void)(actual); } while (0)
#define EXPECT_NE(expected, actual) do { (void)(expected); (void)(actual); } while (0)
#define ASSERT_TRUE(condition) do { (void)(condition); } while (0)
#define ASSERT_FALSE(condition) do { (void)(condition); } while (0)
#define ASSERT_EQ(expected, actual) do { (void)(expected); (void)(actual); } while (0)
namespace testing { class Test {}; }
"""

GOOGLETEST_ASSERTION_RESULT_H = """#pragma once
namespace testing { class AssertionResult {}; }
"""

GOOGLETEST_GTEST_PROD_H = """#pragma once
#define FRIEND_TEST(test_case_name, test_name) \
  friend class test_case_name##_##test_name##_Test
"""

TEST_MAIN_CC = """int main(int argc, char** argv) {
  (void)argc;
  (void)argv;
  return 0;
}
"""

LIBAOM_OPTIONS_GNI = """import("//build/config/cast.gni")
import("//build/config/chromeos/ui_mode.gni")
import("//build/config/gclient_args.gni")

declare_args() {
  enable_libaom = !(is_android && current_cpu != "arm64" &&
                    current_cpu != "x64") && !is_castos
}
"""

LIBAOM_BUILD_GN = """config("libaom_public_config") {
  include_dirs = [ "{include_root}" ]
}

config("libaom_config") {
  include_dirs = [ "{include_root}" ]
}

config("libaom_link") {
  lib_dirs = [ "{lib_root}" ]
  libs = [ "aom" ]
}

source_set("libaom") {
  public_configs = [ ":libaom_public_config" ]
  configs += [
    ":libaom_config",
    ":libaom_link",
  ]
  sources = [
    "source/libaom/aom/aom_codec.h",
    "source/libaom/aom/aom_encoder.h",
    "source/libaom/aom/aom_image.h",
    "source/libaom/aom/aomcx.h",
  ]
}
"""

LIBAOM_AOMCX_H = """#pragma once
#include <aom/aomcx.h>
#ifndef AOM_EFLAG_FREEZE_INTERNAL_STATE
#define AOM_EFLAG_FREEZE_INTERNAL_STATE 0
#endif
"""

PROTOBUF_BUILD_GN = """config("protobuf_config") {
}

group("protobuf_lite") {
  public_configs = [ ":protobuf_config" ]
}
"""

PROTOBUF_PROTO_LIBRARY_GNI = """template("proto_library") {
  group(target_name) {
    forward_variables_from(invoker, [
      "testonly",
      "visibility",
    ])
  }
}
"""

GENERATE_STUBS_SCRIPT = """#!/usr/bin/env python3
raise SystemExit("generate_stubs shim should not execute in this build")
"""

GENERATE_STUBS_RULES_GNI = """template("generate_stubs") {
  group(target_name) {
    forward_variables_from(invoker, [
      "testonly",
      "visibility",
      "deps",
      "public_deps",
      "data_deps",
    ])
  }
}
"""


def make_header_forwarder(include_path: str) -> str:
    return f"""#pragma once
#include <{include_path}>
"""


def make_trivial_group_build_gn(*group_names: str) -> str:
    return "\n\n".join(f'group("{group_name}") {{\n}}'
                       for group_name in group_names) + "\n"


def make_config_only_build_gn(config_name: str,
                              include_dirs: list[str]) -> str:
    include_lines = "\n".join(f'    "{include_dir}",'
                              for include_dir in include_dirs)
    return f"""config("{config_name}") {{
  include_dirs = [
{include_lines}
  ]
}}
"""


def make_linked_source_set_build_gn(
    target_name: str,
    include_dirs: list[str],
    lib_name: str,
    sources: list[str],
    *,
    public_config_name: str | None = None,
    config_name: str | None = None,
    testonly: bool = False,
    deps: list[str] | None = None,
    extra_configs: list[str] | None = None,
) -> str:
    public_config_name = public_config_name or config_name or f"{target_name}_config"
    config_name = config_name or public_config_name
    deps = [] if deps is None else deps
    extra_configs = [] if extra_configs is None else extra_configs
    link_config_name = f"{target_name}_link"

    def render_include_block(name: str) -> str:
        include_lines = "\n".join(f'    "{include_dir}",'
                                  for include_dir in include_dirs)
        return f"""config("{name}") {{
  include_dirs = [
{include_lines}
  ]
}}"""

    config_blocks = [render_include_block(public_config_name)]
    if config_name != public_config_name:
        config_blocks.append(render_include_block(config_name))
    config_blocks.append(f"""config("{link_config_name}") {{
  lib_dirs = [ "{{lib_root}}" ]
  libs = [ "{lib_name}" ]
}}""")

    source_lines = "\n".join(f'    "{source}",' for source in sources)
    target_lines = [f'source_set("{target_name}") {{']
    if testonly:
        target_lines.append("  testonly = true")
    target_lines.append(f'  public_configs = [ ":{public_config_name}" ]')
    if deps:
        deps_line = ", ".join(f'"{dep}"' for dep in deps)
        target_lines.append(f"  deps = [ {deps_line} ]")
    configs = [f'":{link_config_name}"']
    if config_name != public_config_name:
        configs.insert(0, f'":{config_name}"')
    configs.extend(f'"{config}"' for config in extra_configs)
    if len(configs) == 1:
        target_lines.append(f"  configs += [ {configs[0]} ]")
    else:
        target_lines.append("  configs += [")
        target_lines.extend(f"    {config}," for config in configs)
        target_lines.append("  ]")
    target_lines.append("  sources = [")
    target_lines.append(source_lines)
    target_lines.append("  ]")
    target_lines.append("}")

    return "\n\n".join(config_blocks + ["\n".join(target_lines)]) + "\n"


SPECS = {
    "libsrtp": {
        "relative_root": "third_party/libsrtp",
        "dirs": ["include", "srtp"],
        "files": {
            "options.gni":
            LIBSRTP_OPTIONS_GNI,
            "BUILD.gn":
            """import("//third_party/libsrtp/options.gni")

config("libsrtp_config") {
  include_dirs = [ "{include_root}" ]
}

config("libsrtp_link") {
  lib_dirs = [ "{lib_root}" ]
  libs = [ "srtp2" ]
}

source_set("libsrtp") {
  public_configs = [ ":libsrtp_config" ]
  configs += [ ":libsrtp_link" ]
  sources = [ "include/srtp.h" ]
}
""",
            "include/srtp.h":
            """#pragma once

#if __has_include(<srtp.h>)
#include <srtp.h>
#else
#include <srtp2/srtp.h>
#endif
""",
        },
    },
    "opus": {
        "relative_root": "third_party/opus",
        "dirs": ["src/include"],
        "files": {
            "BUILD.gn":
            make_linked_source_set_build_gn(
                "opus",
                ["{include_root}"],
                "opus",
                [
                    "src/include/opus.h",
                    "src/include/opus_defines.h",
                    "src/include/opus_multistream.h",
                    "src/include/opus_types.h",
                ],
            ),
            "src/include/opus.h":
            make_header_forwarder("opus/opus.h"),
            "src/include/opus_defines.h":
            make_header_forwarder("opus/opus_defines.h"),
            "src/include/opus_multistream.h":
            make_header_forwarder("opus/opus_multistream.h"),
            "src/include/opus_types.h":
            make_header_forwarder("opus/opus_types.h"),
        },
    },
    "libvpx": {
        "relative_root": "third_party/libvpx",
        "dirs": ["source/libvpx/vpx"],
        "files": {
            "BUILD.gn":
            make_linked_source_set_build_gn(
                "libvpx",
                ["source/libvpx"],
                "vpx",
                [
                    "source/libvpx/vpx/vp8.h",
                    "source/libvpx/vpx/vp8cx.h",
                    "source/libvpx/vpx/vp8dx.h",
                    "source/libvpx/vpx/vpx_codec.h",
                    "source/libvpx/vpx/vpx_decoder.h",
                    "source/libvpx/vpx/vpx_encoder.h",
                    "source/libvpx/vpx/vpx_ext_ratectrl.h",
                    "source/libvpx/vpx/vpx_frame_buffer.h",
                    "source/libvpx/vpx/vpx_image.h",
                    "source/libvpx/vpx/vpx_integer.h",
                ],
                public_config_name="libvpx_public_config",
                config_name="libvpx_config",
            ),
            "source/libvpx/vpx/vp8.h":
            make_header_forwarder("vpx/vp8.h"),
            "source/libvpx/vpx/vp8cx.h":
            make_header_forwarder("vpx/vp8cx.h"),
            "source/libvpx/vpx/vp8dx.h":
            make_header_forwarder("vpx/vp8dx.h"),
            "source/libvpx/vpx/vpx_codec.h":
            make_header_forwarder("vpx/vpx_codec.h"),
            "source/libvpx/vpx/vpx_decoder.h":
            make_header_forwarder("vpx/vpx_decoder.h"),
            "source/libvpx/vpx/vpx_encoder.h":
            make_header_forwarder("vpx/vpx_encoder.h"),
            "source/libvpx/vpx/vpx_ext_ratectrl.h":
            make_header_forwarder("vpx/vpx_ext_ratectrl.h"),
            "source/libvpx/vpx/vpx_frame_buffer.h":
            make_header_forwarder("vpx/vpx_frame_buffer.h"),
            "source/libvpx/vpx/vpx_image.h":
            make_header_forwarder("vpx/vpx_image.h"),
            "source/libvpx/vpx/vpx_integer.h":
            make_header_forwarder("vpx/vpx_integer.h"),
        },
    },
    "libyuv": {
        "relative_root": "third_party/libyuv",
        "dirs": ["include/libyuv"],
        "files": {
            "BUILD.gn":
            make_linked_source_set_build_gn(
                "libyuv",
                ["include"],
                "yuv",
                [
                    "include/libyuv/compare.h",
                    "include/libyuv/convert.h",
                    "include/libyuv/convert_from.h",
                    "include/libyuv/planar_functions.h",
                    "include/libyuv/rotate.h",
                    "include/libyuv/rotate_argb.h",
                    "include/libyuv/scale.h",
                    "include/libyuv/video_common.h",
                ],
            ),
            "include/libyuv/compare.h":
            make_header_forwarder("libyuv/compare.h"),
            "include/libyuv/convert.h":
            make_header_forwarder("libyuv/convert.h"),
            "include/libyuv/convert_from.h":
            make_header_forwarder("libyuv/convert_from.h"),
            "include/libyuv/planar_functions.h":
            make_header_forwarder("libyuv/planar_functions.h"),
            "include/libyuv/rotate.h":
            make_header_forwarder("libyuv/rotate.h"),
            "include/libyuv/rotate_argb.h":
            make_header_forwarder("libyuv/rotate_argb.h"),
            "include/libyuv/scale.h":
            make_header_forwarder("libyuv/scale.h"),
            "include/libyuv/video_common.h":
            make_header_forwarder("libyuv/video_common.h"),
        },
    },
    "libaom": {
        "relative_root": "third_party/libaom",
        "dirs": ["source/libaom/aom"],
        "files": {
            "options.gni":
            LIBAOM_OPTIONS_GNI,
            "BUILD.gn":
            LIBAOM_BUILD_GN,
            "source/libaom/aom/aom_codec.h":
            make_header_forwarder("aom/aom_codec.h"),
            "source/libaom/aom/aom_encoder.h":
            make_header_forwarder("aom/aom_encoder.h"),
            "source/libaom/aom/aom_image.h":
            make_header_forwarder("aom/aom_image.h"),
            "source/libaom/aom/aomcx.h":
            LIBAOM_AOMCX_H,
        },
    },
    "jsoncpp": {
        "relative_root": "third_party/jsoncpp",
        "dirs": ["source/include"],
        "files": {
            "BUILD.gn":
            make_linked_source_set_build_gn(
                "jsoncpp",
                ["{include_root}"],
                "jsoncpp",
                ["source/include/jsoncpp_shim.h"],
            ),
            "source/include/jsoncpp_shim.h":
            "#pragma once\n",
        },
    },
    "dav1d": {
        "relative_root": "third_party/dav1d",
        "dirs": [],
        "files": {
            "BUILD.gn": make_trivial_group_build_gn("dav1d"),
        },
    },
    "llvm-libc": {
        "relative_root": "third_party/llvm-libc",
        "dirs": [],
        "files": {
            "BUILD.gn": make_trivial_group_build_gn("llvm-libc-shared"),
        },
    },
    "protobuf": {
        "relative_root": "third_party/protobuf",
        "dirs": [],
        "files": {
            "BUILD.gn": PROTOBUF_BUILD_GN,
            "proto_library.gni": PROTOBUF_PROTO_LIBRARY_GNI,
        },
    },
    "pffft": {
        "relative_root": "third_party/pffft",
        "dirs": ["src"],
        "files": {
            "BUILD.gn":
            make_linked_source_set_build_gn(
                "pffft",
                ["{include_root}"],
                "pffft",
                ["src/pffft.h"],
            ),
            "src/pffft.h":
            make_header_forwarder("pffft/pffft.h"),
        },
    },
    "alsa": {
        "relative_root": "third_party/alsa",
        "dirs": [],
        "files": {
            "BUILD.gn": make_config_only_build_gn("headers",
                                                  ["{include_root}"]),
        },
    },
    "pulseaudio": {
        "relative_root": "third_party/pulseaudio",
        "dirs": [],
        "files": {
            "BUILD.gn": make_config_only_build_gn("headers",
                                                  ["{include_root}"]),
        },
    },
    "rnnoise": {
        "relative_root": "third_party/rnnoise",
        "dirs": [],
        "preserve_root": True,
        "files": {
            "BUILD.gn": RNNOISE_BUILD_GN,
            "src/os_support.h": RNNOISE_OS_SUPPORT_H,
        },
    },
    "third_party_root": {
        "relative_root": "third_party",
        "dirs": [],
        "preserve_root": True,
        "files": {
            "BUILD.gn": make_trivial_group_build_gn("jpeg"),
        },
    },
    "testing": {
        "relative_root": "testing",
        "dirs": ["gmock", "gtest"],
        "files": {
            "BUILD.gn":
            """group("pytype_dependencies") {
  testonly = true
}
""",
            "test.gni":
            TESTING_TEST_GNI,
            "gtest/BUILD.gn":
            """group("gtest") {
  testonly = true
}

group("gtest_main") {
  testonly = true
  public_deps = [ ":gtest" ]
}
""",
            "gmock/BUILD.gn":
            """group("gmock") {
  testonly = true
}

group("gmock_main") {
  testonly = true
  public_deps = [ ":gmock" ]
}
""",
        },
    },
    "googletest": {
        "relative_root":
        "third_party/googletest",
        "dirs": [
            "custom/gtest/internal/custom",
            "src/googletest/include/gtest/internal/custom",
            "src/googletest/include/gtest/internal",
            "src/googletest/include/gtest",
            "src/googletest/src",
            "src/googlemock/include/gmock/internal/custom",
            "src/googlemock/include/gmock/internal",
            "src/googlemock/include/gmock",
            "src/googlemock/src",
        ],
        "files": {
            "BUILD.gn":
            GOOGLETEST_BUILD_GN,
            "custom/gtest/internal/custom/gtest.h":
            "#pragma once\n",
            "custom/gtest/internal/custom/stack_trace_getter.cc":
            "namespace testing {}\n",
            "custom/gtest/internal/custom/stack_trace_getter.h":
            "#pragma once\n",
            "custom/gtest/internal/custom/chrome_custom_temp_dir.cc":
            "namespace testing {}\n",
            "custom/gtest/internal/custom/chrome_custom_temp_dir.h":
            "#pragma once\n",
            "custom/gtest/internal/custom/gtest_port_wrapper.cc":
            "namespace testing {}\n",
            "src/googletest/include/gtest/gtest-assertion-result.h":
            GOOGLETEST_ASSERTION_RESULT_H,
            "src/googletest/include/gtest/gtest-death-test.h":
            "#pragma once\n",
            "src/googletest/include/gtest/gtest-matchers.h":
            "#pragma once\n",
            "src/googletest/include/gtest/gtest-message.h":
            "#pragma once\nnamespace testing { class Message {}; }\n",
            "src/googletest/include/gtest/gtest-param-test.h":
            "#pragma once\n",
            "src/googletest/include/gtest/gtest-printers.h":
            "#pragma once\n",
            "src/googletest/include/gtest/gtest-spi.h":
            GOOGLETEST_GTEST_SPI_H,
            "src/googletest/include/gtest/gtest-test-part.h":
            "#pragma once\n",
            "src/googletest/include/gtest/gtest-typed-test.h":
            "#pragma once\n",
            "src/googletest/include/gtest/gtest.h":
            GOOGLETEST_GTEST_H,
            "src/googletest/include/gtest/gtest_pred_impl.h":
            "#pragma once\n",
            "src/googletest/include/gtest/gtest_prod.h":
            GOOGLETEST_GTEST_PROD_H,
            "src/googletest/include/gtest/internal/custom/gtest-port.h":
            "#pragma once\n",
            "src/googletest/include/gtest/internal/custom/gtest-printers.h":
            "#pragma once\n",
            "src/googletest/include/gtest/internal/gtest-death-test-internal.h":
            "#pragma once\n",
            "src/googletest/include/gtest/internal/gtest-filepath.h":
            "#pragma once\n",
            "src/googletest/include/gtest/internal/gtest-internal.h":
            "#pragma once\n",
            "src/googletest/include/gtest/internal/gtest-param-util.h":
            "#pragma once\n",
            "src/googletest/include/gtest/internal/gtest-port-arch.h":
            "#pragma once\n",
            "src/googletest/include/gtest/internal/gtest-port.h":
            "#pragma once\n",
            "src/googletest/include/gtest/internal/gtest-string.h":
            "#pragma once\n",
            "src/googletest/include/gtest/internal/gtest-type-util.h":
            "#pragma once\n",
            "src/googletest/src/gtest-assertion-result.cc":
            "namespace testing {}\n",
            "src/googletest/src/gtest-death-test.cc":
            "namespace testing {}\n",
            "src/googletest/src/gtest-filepath.cc":
            "namespace testing {}\n",
            "src/googletest/src/gtest-internal-inl.h":
            "#pragma once\n",
            "src/googletest/src/gtest-matchers.cc":
            "namespace testing {}\n",
            "src/googletest/src/gtest-printers.cc":
            "namespace testing {}\n",
            "src/googletest/src/gtest-test-part.cc":
            "namespace testing {}\n",
            "src/googletest/src/gtest-typed-test.cc":
            "namespace testing {}\n",
            "src/googletest/src/gtest.cc":
            "namespace testing {}\n",
            "src/googletest/src/gtest_main.cc":
            TEST_MAIN_CC,
            "src/googlemock/include/gmock/gmock-actions.h":
            "#pragma once\n",
            "src/googlemock/include/gmock/gmock-cardinalities.h":
            "#pragma once\n",
            "src/googlemock/include/gmock/gmock-function-mocker.h":
            "#pragma once\n#define MOCK_METHOD(...) \n",
            "src/googlemock/include/gmock/gmock-matchers.h":
            "#pragma once\n",
            "src/googlemock/include/gmock/gmock-more-matchers.h":
            "#pragma once\n",
            "src/googlemock/include/gmock/gmock-nice-strict.h":
            "#pragma once\n",
            "src/googlemock/include/gmock/gmock-spec-builders.h":
            "#pragma once\n",
            "src/googlemock/include/gmock/gmock.h":
            "#pragma once\n#include \"gmock-function-mocker.h\"\n",
            "src/googlemock/include/gmock/internal/custom/gmock-generated-actions.h":
            "#pragma once\n",
            "src/googlemock/include/gmock/internal/custom/gmock-matchers.h":
            "#pragma once\n",
            "src/googlemock/include/gmock/internal/gmock-internal-utils.h":
            "#pragma once\n",
            "src/googlemock/include/gmock/internal/gmock-port.h":
            "#pragma once\n",
            "src/googlemock/include/gmock/internal/gmock-pp.h":
            "#pragma once\n",
            "src/googlemock/src/gmock-cardinalities.cc":
            "namespace testing {}\n",
            "src/googlemock/src/gmock-internal-utils.cc":
            "namespace testing {}\n",
            "src/googlemock/src/gmock-matchers.cc":
            "namespace testing {}\n",
            "src/googlemock/src/gmock-spec-builders.cc":
            "namespace testing {}\n",
            "src/googlemock/src/gmock.cc":
            "namespace testing {}\n",
            "src/googlemock/src/gmock_main.cc":
            TEST_MAIN_CC,
        },
    },
    "catapult": {
        "relative_root":
        "third_party/catapult",
        "dirs": [
            "third_party/typ",
            "tracing",
            "tracing/tracing",
            "tracing/tracing/proto",
        ],
        "files": {
            "tracing/BUILD.gn":
            """group("tracing_common") {
}

group("convert_chart_json") {
  data_deps = [ ":tracing_common" ]
}
""",
            "tracing/tracing/BUILD.gn":
            make_trivial_group_build_gn("histogram", "reserved_infos"),
            "tracing/tracing/proto/BUILD.gn":
            make_trivial_group_build_gn("histogram_proto"),
        },
    },
    "tools": {
        "relative_root": "tools",
        "dirs": ["clang/scripts", "generate_stubs", "rust"],
        "files": {
            "clang/scripts/update.py":
            "CLANG_REVISION = 'llvmorg-0-init'\nCLANG_SUB_REVISION = 0\n",
            "generate_stubs/generate_stubs.py":
            GENERATE_STUBS_SCRIPT,
            "generate_stubs/rules.gni":
            GENERATE_STUBS_RULES_GNI,
            "rust/update_rust.py":
            "RUST_REVISION = 'llvmorg-0-init'\nRUST_SUB_REVISION = 0\n",
        },
    },
    "nasm": {
        "relative_root": "third_party/nasm",
        "dirs": [],
        "files": {
            "BUILD.gn": NASM_BUILD_GN,
            "nasm_assemble.gni": NASM_ASSEMBLE_GNI,
        },
    },
}


@dataclasses.dataclass(frozen=True)
class ResolvedSpec:
    dep: str
    relative_root: str
    dirs: tuple[str, ...]
    files: dict[str, str]
    copy_files: dict[str, str]
    preserve_root: bool


@dataclasses.dataclass(frozen=True)
class PlannedFile:
    relative_path: str
    content: str


@dataclasses.dataclass(frozen=True)
class PlannedCopyFile:
    relative_path: str
    asset_source: pathlib.Path


@dataclasses.dataclass(frozen=True)
class GenerationPlan:
    output_root: pathlib.Path
    preserve_root: bool
    directories: tuple[pathlib.Path, ...]
    files: tuple[PlannedFile, ...]
    copied_files: tuple[PlannedCopyFile, ...]


def resolve_spec(
        dep: str,
        specs: dict[str, dict[str, object]] | None = None) -> ResolvedSpec:
    specs = SPECS if specs is None else specs
    spec = specs[dep]

    if "relative_root" not in spec:
        raise ValueError(f"Missing required 'relative_root' for {dep}")
    if "dirs" not in spec:
        raise ValueError(f"Missing required 'dirs' for {dep}")
    if "files" not in spec:
        raise ValueError(f"Missing required 'files' for {dep}")

    relative_root = spec["relative_root"]
    dirs = spec["dirs"]
    files = spec["files"]
    copy_files = spec.get("copy_files", {})
    preserve_root = spec.get("preserve_root", False)

    if not isinstance(relative_root, str):
        raise ValueError(f"Invalid 'relative_root' for {dep}")
    if not isinstance(dirs, list):
        raise ValueError(f"Invalid 'dirs' for {dep}")
    if not isinstance(files, dict):
        raise ValueError(f"Invalid 'files' for {dep}")
    if not isinstance(copy_files, dict):
        raise ValueError(f"Invalid 'copy_files' for {dep}")
    if not isinstance(preserve_root, bool):
        raise ValueError(f"Invalid 'preserve_root' for {dep}")

    return ResolvedSpec(
        dep=dep,
        relative_root=relative_root,
        dirs=tuple(dirs),
        files=dict(files),
        copy_files=dict(copy_files),
        preserve_root=preserve_root,
    )


def render_template(content: str, include_root: str, lib_root: str,
                    tool_path: str) -> str:
    return (content.replace("{include_root}", include_root).replace(
        "{lib_root}", lib_root).replace("{tool_path}", tool_path))


def build_generation_plan(
    source_root: pathlib.Path,
    include_root: str,
    lib_root: str,
    tool_path: str,
    spec: ResolvedSpec,
) -> GenerationPlan:
    output_root = source_root / spec.relative_root
    directories = tuple(output_root / rel_dir for rel_dir in spec.dirs)
    files = tuple(
        PlannedFile(
            relative_path=rel_path,
            content=render_template(content, include_root, lib_root,
                                    tool_path),
        ) for rel_path, content in spec.files.items())
    copied_files = tuple(
        PlannedCopyFile(
            relative_path=rel_path,
            asset_source=pathlib.Path(__file__).resolve().parent /
            asset_rel_path,
        ) for rel_path, asset_rel_path in spec.copy_files.items())
    return GenerationPlan(
        output_root=output_root,
        preserve_root=spec.preserve_root,
        directories=directories,
        files=files,
        copied_files=copied_files,
    )


def plan_generation(
    source_root: pathlib.Path,
    dep: str,
    include_root: str,
    lib_root: str,
    tool_path: str,
) -> GenerationPlan:
    spec = resolve_spec(dep)
    return build_generation_plan(source_root, include_root, lib_root,
                                 tool_path, spec)


def apply_generation_plan(plan: GenerationPlan) -> None:
    output = plan.output_root
    if not plan.preserve_root:
        shutil.rmtree(output, ignore_errors=True)
    output.mkdir(parents=True, exist_ok=True)
    for directory in plan.directories:
        directory.mkdir(parents=True, exist_ok=True)
    for planned_file in plan.files:
        path = output / planned_file.relative_path
        path.parent.mkdir(parents=True, exist_ok=True)
        path.write_text(planned_file.content)
    for copied_file in plan.copied_files:
        path = output / copied_file.relative_path
        path.parent.mkdir(parents=True, exist_ok=True)
        shutil.copyfile(copied_file.asset_source, path)


def write_tree(source_root: pathlib.Path, dep: str, include_root: str,
               lib_root: str, tool_path: str) -> None:
    apply_generation_plan(
        plan_generation(source_root, dep, include_root, lib_root, tool_path))


def generate_external_dep(
    source_root: pathlib.Path,
    dep: str,
    include_root: str,
    lib_root: str,
    tool_path: str,
) -> None:
    apply_generation_plan(
        plan_generation(source_root, dep, include_root, lib_root, tool_path))


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--source-root", required=True)
    parser.add_argument("--dep", choices=sorted(SPECS), required=True)
    parser.add_argument("--include-root", required=True)
    parser.add_argument("--lib-root", required=True)
    parser.add_argument("--tool-path", default="")
    args = parser.parse_args()

    generate_external_dep(
        pathlib.Path(args.source_root),
        args.dep,
        args.include_root,
        args.lib_root,
        args.tool_path,
    )


if __name__ == "__main__":
    main()
