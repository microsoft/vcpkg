#!/usr/bin/env python3
from __future__ import annotations

import argparse
import collections
import dataclasses
import pathlib
import re
import shutil

ROOT_TARGETS = [
    "absl",
    "absl_component_deps",
    "absl_full",
    "absl_full_deps",
    "test_support",
]

FORBIDDEN_IMPORTED_LINK_LIBRARIES = ("abseil_test_dll", )


@dataclasses.dataclass(frozen=True)
class ImportedCMakeTargets:
    all_targets: tuple[str, ...]
    static_targets: tuple[str, ...]
    interface_targets: tuple[str, ...]


@dataclasses.dataclass(frozen=True)
class AbslGenerationPlan:
    root_targets: tuple[str, ...]
    grouped_targets: tuple[tuple[str, tuple[str, ...]], ...]
    cmake_targets: ImportedCMakeTargets
    static_libs: tuple[str, ...]


def build_imported_cmake_targets(
        known_targets: dict[str, str]) -> ImportedCMakeTargets:
    return ImportedCMakeTargets(
        all_targets=tuple(sorted(known_targets)),
        static_targets=tuple(target
                             for target, kind in sorted(known_targets.items())
                             if kind == "STATIC"),
        interface_targets=tuple(
            target for target, kind in sorted(known_targets.items())
            if kind == "INTERFACE"),
    )


def make_generation_plan(
    root_targets: list[str],
    grouped_targets: dict[str, list[str]],
    known_targets: dict[str, str],
) -> AbslGenerationPlan:
    unexpected_root_targets = sorted(set(root_targets) - set(ROOT_TARGETS))
    if unexpected_root_targets:
        raise ValueError("Unexpected root absl labels: " +
                         ", ".join(unexpected_root_targets))
    imported_targets = build_imported_cmake_targets(known_targets)
    return AbslGenerationPlan(
        root_targets=tuple(ROOT_TARGETS),
        grouped_targets=tuple(
            (path_part, tuple(sorted(set(targets))))
            for path_part, targets in sorted(grouped_targets.items())),
        cmake_targets=imported_targets,
        static_libs=tuple(
            cmake_target_to_gn_lib_name(target)
            for target in imported_targets.static_targets),
    )


def split_manifest_labels(
        labels: list[str]) -> tuple[list[str], dict[str, list[str]]]:
    root_targets = []
    grouped_targets: dict[str, list[str]] = collections.defaultdict(list)
    for label in labels:
        path_part, target = split_label(label)
        if path_part:
            grouped_targets[path_part].append(target)
        else:
            root_targets.append(target)
    return root_targets, grouped_targets


def read_labels(path: pathlib.Path) -> list[str]:
    labels = []
    for line in path.read_text().splitlines():
        line = line.strip()
        if not line or line.startswith("#"):
            continue
        labels.append(line)
    return sorted(set(labels))


def split_label(label: str) -> tuple[str, str]:
    if not label.startswith("//third_party/abseil-cpp"):
        raise ValueError(f"Invalid absl label prefix: {label}")
    body = label[len("//third_party/abseil-cpp"):]
    if ":" not in body:
        raise ValueError(f"Missing target separator in absl label: {label}")
    path_part, target = body.split(":", 1)
    return path_part.lstrip("/"), target


def write_absl_gni(path: pathlib.Path) -> None:
    path.write_text(render_absl_gni())


def render_absl_gni() -> str:
    return """declare_args() {
  absl_build_tests = false
}

template("absl_source_set") {
  source_set(target_name) {
    forward_variables_from(invoker, "*")
    if (!defined(public_configs)) {
      public_configs = []
    }
    public_configs += [
      "//third_party/abseil-cpp:absl_include_config",
      "//third_party/abseil-cpp:absl_define_config",
    ]
    if (!defined(visibility)) {
      visibility = [ "*" ]
    }
  }
}

template("absl_test") {
  source_set(target_name) {
    not_needed(invoker, "*")
  }
}
"""


def write_root_build(
    path: pathlib.Path,
    include_root: str,
    lib_root: str,
    static_libs: list[str],
    generated_targets: list[tuple[str, str]],
) -> None:
    path.write_text(
        render_root_build(include_root, lib_root, static_libs,
                          generated_targets))


def render_root_build(
    include_root: str,
    lib_root: str,
    static_libs: list[str],
    generated_targets: list[tuple[str, str]],
) -> str:
    lib_lines = "\n".join(f'    "{libname}",' for libname in static_libs)
    generated_dep_lines = "\n".join(f'    "{rel}",' for rel in sorted({
        f"//third_party/abseil-cpp/{path_part}:{target}"
        for path_part, target in generated_targets
    }))
    root_target_blocks = "\n\n".join(f"""source_set("{target}") {{
  visibility = [ "*" ]
  public_configs = [
    ":absl_include_config",
    ":absl_define_config",
    ":absl_all_link",
  ]
  public_deps = [ ":_all_generated_absl" ]
}}""" for target in ROOT_TARGETS)

    return f"""config("absl_include_config") {{
  include_dirs = [ "{include_root}" ]
}}

config("absl_define_config") {{
  defines = [ "ABSL_ALLOCATOR_NOTHROW=1" ]
}}

config("absl_all_link") {{
  lib_dirs = [ "{lib_root}" ]
  libs = [
{lib_lines}
  ]
}}

config("absl_default_cflags_cc") {{
}}

config("absl_test_config") {{
}}

group("_all_generated_absl") {{
  public_deps = [
{generated_dep_lines}
  ]
}}

{root_target_blocks}
"""


def write_subdir_build(path: pathlib.Path, targets: list[str]) -> None:
    path.write_text(render_subdir_build(targets))


def render_subdir_build(targets: list[str]) -> str:
    return "\n\n".join(f"""source_set("{target}") {{
  visibility = [ "*" ]
  public_configs = [
    "//third_party/abseil-cpp:absl_include_config",
    "//third_party/abseil-cpp:absl_define_config",
    "//third_party/abseil-cpp:absl_all_link",
  ]
}}""" for target in targets)


def should_exclude_imported_target(cmake_body: str) -> bool:
    return any(forbidden_link_library in cmake_body
               for forbidden_link_library in FORBIDDEN_IMPORTED_LINK_LIBRARIES)


def read_cmake_targets(path: pathlib.Path) -> dict[str, str]:
    text = path.read_text()
    targets: dict[str, str] = {}
    for match in re.finditer(
            r"add_library\((absl::[^ )]+) (STATIC|INTERFACE) IMPORTED\)",
            text):
        name, kind = match.groups()
        properties_match = re.search(
            rf"set_target_properties\({re.escape(name)} PROPERTIES\n(.*?)\n\)",
            text,
            re.S,
        )
        if properties_match and should_exclude_imported_target(
                properties_match.group(1)):
            continue
        targets[name] = kind
    if not targets:
        raise ValueError(
            f"No imported absl targets found in CMake exports: {path}")
    return targets


def cmake_target_to_gn_lib_name(target: str) -> str:
    return f"absl_{target.split('::', 1)[1]}"


def render_cmake_targets(known_targets: dict[str, str]) -> str:
    imported_targets = build_imported_cmake_targets(known_targets)
    return render_cmake_targets_from_imported_targets(imported_targets)


def render_cmake_targets_from_imported_targets(
        imported_targets: ImportedCMakeTargets) -> str:
    lines = ["set(WEBRTC_ABSL_IMPORTED_TARGETS"]
    lines.extend(f"    {target}" for target in imported_targets.all_targets)
    lines.append(")")
    lines.append("")
    lines.append("set(WEBRTC_ABSL_STATIC_IMPORTED_TARGETS")
    lines.extend(f"    {target}" for target in imported_targets.static_targets)
    lines.append(")")
    lines.append("")
    lines.append("set(WEBRTC_ABSL_STATIC_ARCHIVES")
    lines.extend(f"    $<TARGET_LINKER_FILE:{target}>"
                 for target in imported_targets.static_targets)
    lines.append(")")
    lines.append("")
    lines.append("set(WEBRTC_ABSL_INTERFACE_IMPORTED_TARGETS")
    lines.extend(f"    {target}"
                 for target in imported_targets.interface_targets)
    lines.append(")")
    return "\n".join(lines) + "\n"


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--manifest", required=True)
    parser.add_argument("--output", required=True)
    parser.add_argument("--include-root", required=True)
    parser.add_argument("--lib-root", required=True)
    parser.add_argument("--cmake-absl-targets", required=True)
    parser.add_argument("--cmake-output", required=True)
    args = parser.parse_args()

    manifest = pathlib.Path(args.manifest)
    output = pathlib.Path(args.output)
    cmake_targets_path = pathlib.Path(args.cmake_absl_targets)
    cmake_output = pathlib.Path(args.cmake_output)

    plan = make_generation_plan(
        *split_manifest_labels(read_labels(manifest)),
        read_cmake_targets(cmake_targets_path),
    )

    shutil.rmtree(output, ignore_errors=True)
    output.mkdir(parents=True, exist_ok=True)

    generated_targets = [(path_part, target)
                         for path_part, targets in plan.grouped_targets
                         for target in targets]
    cmake_output.write_text(
        render_cmake_targets_from_imported_targets(plan.cmake_targets))
    write_absl_gni(output / "absl.gni")
    write_root_build(
        output / "BUILD.gn",
        args.include_root,
        args.lib_root,
        list(plan.static_libs),
        generated_targets,
    )

    for path_part, targets in plan.grouped_targets:
        build_dir = output / path_part
        build_dir.mkdir(parents=True, exist_ok=True)
        write_subdir_build(build_dir / "BUILD.gn", list(targets))


if __name__ == "__main__":
    main()
