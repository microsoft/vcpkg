#!/usr/bin/env python3
from __future__ import annotations

import importlib.util
import pathlib
import sys
import tempfile
import unittest
from unittest import mock

SCRIPT_PATH = pathlib.Path(__file__).with_name("generate_external_absl.py")
SPEC = importlib.util.spec_from_file_location("generate_external_absl",
                                              SCRIPT_PATH)
assert SPEC is not None
assert SPEC.loader is not None
MODULE = importlib.util.module_from_spec(SPEC)
sys.modules[SPEC.name] = MODULE
SPEC.loader.exec_module(MODULE)


class GenerateExternalAbslTest(unittest.TestCase):

    def test_read_labels_filters_deduplicates_and_sorts(self) -> None:
        with tempfile.TemporaryDirectory() as tempdir:
            manifest = pathlib.Path(tempdir) / "absl-labels.txt"
            manifest.write_text("\n".join([
                "",
                "  # comment",
                "//third_party/abseil-cpp/absl/strings:strings",
                "//third_party/abseil-cpp/absl/base:base",
                "//third_party/abseil-cpp/absl/strings:strings",
            ]))

            self.assertEqual(
                MODULE.read_labels(manifest),
                [
                    "//third_party/abseil-cpp/absl/base:base",
                    "//third_party/abseil-cpp/absl/strings:strings",
                ],
            )

    def test_build_imported_cmake_targets_normalizes_target_groups(
            self) -> None:
        imported_targets = MODULE.build_imported_cmake_targets({
            "absl::strings":
            "STATIC",
            "absl::core_headers":
            "INTERFACE",
            "absl::base":
            "STATIC",
        })

        self.assertEqual(
            imported_targets,
            MODULE.ImportedCMakeTargets(
                all_targets=("absl::base", "absl::core_headers",
                             "absl::strings"),
                static_targets=("absl::base", "absl::strings"),
                interface_targets=("absl::core_headers", ),
            ),
        )

    def test_make_generation_plan_exposes_normalized_model(self) -> None:
        plan = MODULE.make_generation_plan(
            root_targets=["absl"],
            grouped_targets={
                "absl/strings": ["strings", "strings"],
                "absl/base": ["base"],
            },
            known_targets={
                "absl::strings": "STATIC",
                "absl::core_headers": "INTERFACE",
                "absl::base": "STATIC",
            },
        )

        self.assertEqual(plan.root_targets, tuple(MODULE.ROOT_TARGETS))
        self.assertEqual(
            plan.grouped_targets,
            (
                ("absl/base", ("base", )),
                ("absl/strings", ("strings", )),
            ),
        )
        self.assertEqual(plan.cmake_targets.static_targets,
                         ("absl::base", "absl::strings"))
        self.assertEqual(plan.static_libs, ("absl_base", "absl_strings"))

    def test_make_generation_plan_rejects_unexpected_root_target(self) -> None:
        with self.assertRaisesRegex(ValueError, "unexpected_root"):
            MODULE.make_generation_plan(
                root_targets=["unexpected_root"],
                grouped_targets={},
                known_targets={"absl::base": "STATIC"},
            )

    def test_split_label_returns_path_and_target(self) -> None:
        self.assertEqual(
            MODULE.split_label("//third_party/abseil-cpp/absl/base:base"),
            ("absl/base", "base"),
        )
        self.assertEqual(
            MODULE.split_label("//third_party/abseil-cpp:absl"),
            ("", "absl"),
        )

    def test_split_label_rejects_invalid_prefix(self) -> None:
        with self.assertRaisesRegex(ValueError, "Invalid absl label prefix"):
            MODULE.split_label("//third_party/not-abseil/absl/base:base")

    def test_split_label_rejects_missing_target_separator(self) -> None:
        with self.assertRaisesRegex(ValueError, "Missing target separator"):
            MODULE.split_label("//third_party/abseil-cpp/absl/base")

    def test_read_cmake_targets_parses_static_and_interface_targets(
            self) -> None:
        with tempfile.TemporaryDirectory() as tempdir:
            targets = pathlib.Path(tempdir) / "abslTargets.cmake"
            targets.write_text("\n".join([
                "add_library(absl::base STATIC IMPORTED)",
                "add_library(absl::core_headers INTERFACE IMPORTED)",
            ]))

            self.assertEqual(
                MODULE.read_cmake_targets(targets),
                {
                    "absl::base": "STATIC",
                    "absl::core_headers": "INTERFACE",
                },
            )

    def test_read_cmake_targets_excludes_targets_with_forbidden_link_libraries(
            self) -> None:
        with tempfile.TemporaryDirectory() as tempdir:
            targets = pathlib.Path(tempdir) / "abslTargets.cmake"
            targets.write_text("\n".join([
                "add_library(absl::base STATIC IMPORTED)",
                "set_target_properties(absl::base PROPERTIES",
                '  INTERFACE_LINK_LIBRARIES "abseil_test_dll"',
                ")",
                "add_library(absl::core_headers INTERFACE IMPORTED)",
            ]))

            self.assertEqual(
                MODULE.read_cmake_targets(targets),
                {
                    "absl::core_headers": "INTERFACE",
                },
            )

    def test_read_cmake_targets_rejects_empty_exports(self) -> None:
        with tempfile.TemporaryDirectory() as tempdir:
            targets = pathlib.Path(tempdir) / "abslTargets.cmake"
            targets.write_text("")

            with self.assertRaisesRegex(ValueError,
                                        "No imported absl targets"):
                MODULE.read_cmake_targets(targets)

    def test_read_cmake_targets_rejects_unparseable_exports(self) -> None:
        with tempfile.TemporaryDirectory() as tempdir:
            targets = pathlib.Path(tempdir) / "abslTargets.cmake"
            targets.write_text("set(not_a_target value)\n")

            with self.assertRaisesRegex(ValueError,
                                        "No imported absl targets"):
                MODULE.read_cmake_targets(targets)

    def test_render_cmake_targets_preserves_static_lib_mapping(self) -> None:
        known_targets = {
            "absl::base": "STATIC",
            "absl::core_headers": "INTERFACE",
            "absl::strings": "STATIC",
        }

        imported_targets = MODULE.build_imported_cmake_targets(known_targets)
        static_libs = [
            MODULE.cmake_target_to_gn_lib_name(target)
            for target in imported_targets.static_targets
        ]
        text = MODULE.render_cmake_targets(known_targets)

        self.assertEqual(static_libs, ["absl_base", "absl_strings"])
        self.assertIn("set(WEBRTC_ABSL_IMPORTED_TARGETS", text)
        self.assertIn("    absl::base", text)
        self.assertIn("    absl::core_headers", text)
        self.assertIn("set(WEBRTC_ABSL_STATIC_IMPORTED_TARGETS", text)
        self.assertIn("    absl::strings", text)
        self.assertIn("$<TARGET_LINKER_FILE:absl::base>", text)
        self.assertIn("set(WEBRTC_ABSL_INTERFACE_IMPORTED_TARGETS", text)

    def test_render_absl_gni_contains_templates(self) -> None:
        text = MODULE.render_absl_gni()

        self.assertIn('declare_args() {', text)
        self.assertIn('template("absl_source_set")', text)
        self.assertIn('template("absl_test")', text)

    def test_render_root_build_includes_configs_and_generated_targets(
            self) -> None:
        text = MODULE.render_root_build(
            include_root="/test/include",
            lib_root="/test/lib",
            static_libs=["absl_base", "absl_strings"],
            generated_targets=[("absl/base", "base"),
                               ("absl/strings", "strings")],
        )

        self.assertIn('include_dirs = [ "/test/include" ]', text)
        self.assertIn('lib_dirs = [ "/test/lib" ]', text)
        self.assertIn('"//third_party/abseil-cpp/absl/base:base"', text)
        self.assertIn('source_set("absl") {', text)

    def test_render_subdir_build_includes_targets_and_configs(self) -> None:
        text = MODULE.render_subdir_build(["base", "core_headers"])

        self.assertIn('source_set("base") {', text)
        self.assertIn('source_set("core_headers") {', text)
        self.assertIn('"//third_party/abseil-cpp:absl_all_link"', text)

    def test_render_cmake_targets_includes_imported_target_lists(self) -> None:
        text = MODULE.render_cmake_targets({
            "absl::base": "STATIC",
            "absl::core_headers": "INTERFACE",
            "absl::strings": "STATIC",
        })

        self.assertIn("set(WEBRTC_ABSL_IMPORTED_TARGETS", text)
        self.assertIn("    absl::core_headers", text)
        self.assertIn("set(WEBRTC_ABSL_STATIC_ARCHIVES", text)
        self.assertIn("$<TARGET_LINKER_FILE:absl::strings>", text)

    def test_render_cmake_targets_from_imported_targets_uses_plan_model(
            self) -> None:
        text = MODULE.render_cmake_targets_from_imported_targets(
            MODULE.ImportedCMakeTargets(
                all_targets=("absl::base", "absl::core_headers",
                             "absl::strings"),
                static_targets=("absl::base", "absl::strings"),
                interface_targets=("absl::core_headers", ),
            ))

        self.assertIn("set(WEBRTC_ABSL_IMPORTED_TARGETS", text)
        self.assertIn("    absl::core_headers", text)
        self.assertIn("$<TARGET_LINKER_FILE:absl::base>", text)

    def test_cmake_target_to_gn_lib_name_uses_current_prefix_mapping(
            self) -> None:
        self.assertEqual(MODULE.cmake_target_to_gn_lib_name("absl::base"),
                         "absl_base")
        self.assertEqual(
            MODULE.cmake_target_to_gn_lib_name("absl::strings_internal"),
            "absl_strings_internal",
        )

    def test_main_generates_expected_files(self) -> None:
        with tempfile.TemporaryDirectory() as tempdir:
            root = pathlib.Path(tempdir)
            manifest = root / "absl-labels.txt"
            cmake_targets = root / "abslTargets.cmake"
            output = root / "abseil-cpp"
            cmake_output = root / "webrtc-absl-targets.cmake"

            manifest.write_text("\n".join([
                "//third_party/abseil-cpp:absl",
                "//third_party/abseil-cpp/absl/base:base",
                "//third_party/abseil-cpp/absl/strings:strings",
            ]))
            cmake_targets.write_text("\n".join([
                "add_library(absl::base STATIC IMPORTED)",
                "add_library(absl::strings STATIC IMPORTED)",
                "add_library(absl::core_headers INTERFACE IMPORTED)",
            ]))

            argv = [
                "generate_external_absl.py",
                "--manifest",
                str(manifest),
                "--output",
                str(output),
                "--include-root",
                "/test/include",
                "--lib-root",
                "/test/lib",
                "--cmake-absl-targets",
                str(cmake_targets),
                "--cmake-output",
                str(cmake_output),
            ]
            with mock.patch("sys.argv", argv):
                MODULE.main()

            absl_gni = (output / "absl.gni").read_text()
            root_build = (output / "BUILD.gn").read_text()
            base_build = (output / "absl" / "base" / "BUILD.gn").read_text()
            generated_cmake = cmake_output.read_text()

            self.assertIn('template("absl_source_set")', absl_gni)
            self.assertIn('include_dirs = [ "/test/include" ]', root_build)
            self.assertIn('lib_dirs = [ "/test/lib" ]', root_build)
            self.assertIn('"//third_party/abseil-cpp/absl/base:base"',
                          root_build)
            self.assertIn('source_set("absl") {', root_build)
            self.assertIn('source_set("test_support") {', root_build)
            self.assertIn('source_set("base") {', base_build)
            self.assertIn('"//third_party/abseil-cpp:absl_all_link"',
                          base_build)
            self.assertIn("set(WEBRTC_ABSL_STATIC_ARCHIVES", generated_cmake)
            self.assertIn("$<TARGET_LINKER_FILE:absl::strings>",
                          generated_cmake)

    def test_main_rejects_unexpected_root_label(self) -> None:
        with tempfile.TemporaryDirectory() as tempdir:
            root = pathlib.Path(tempdir)
            manifest = root / "absl-labels.txt"
            cmake_targets = root / "abslTargets.cmake"
            output = root / "abseil-cpp"
            cmake_output = root / "webrtc-absl-targets.cmake"

            manifest.write_text("\n".join(
                ["//third_party/abseil-cpp:unexpected_root"]))
            cmake_targets.write_text(
                "add_library(absl::base STATIC IMPORTED)\n")

            argv = [
                "generate_external_absl.py",
                "--manifest",
                str(manifest),
                "--output",
                str(output),
                "--include-root",
                "/test/include",
                "--lib-root",
                "/test/lib",
                "--cmake-absl-targets",
                str(cmake_targets),
                "--cmake-output",
                str(cmake_output),
            ]
            with mock.patch("sys.argv", argv):
                with self.assertRaisesRegex(ValueError, "unexpected_root"):
                    MODULE.main()


if __name__ == "__main__":
    unittest.main()
