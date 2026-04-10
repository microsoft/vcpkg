#!/usr/bin/env python3
from __future__ import annotations

import importlib.util
import pathlib
import sys
import tempfile
import unittest
from unittest import mock

SCRIPT_PATH = pathlib.Path(__file__).with_name(
    "generate_external_third_party.py")
SPEC = importlib.util.spec_from_file_location("generate_external_third_party",
                                              SCRIPT_PATH)
assert SPEC is not None
assert SPEC.loader is not None
MODULE = importlib.util.module_from_spec(SPEC)
sys.modules[SPEC.name] = MODULE
SPEC.loader.exec_module(MODULE)


class GenerateExternalThirdPartyTest(unittest.TestCase):

    def test_script_has_no_lines_over_120_columns(self) -> None:
        script_path = pathlib.Path(MODULE.__file__)
        long_lines = [(line_number, len(line))
                      for line_number, line in enumerate(
                          script_path.read_text().splitlines(), 1)
                      if len(line) > 120]

        self.assertEqual(long_lines, [])

    def test_make_header_forwarder_renders_expected_include(self) -> None:
        self.assertEqual(
            MODULE.make_header_forwarder("opus/opus.h"),
            "#pragma once\n#include <opus/opus.h>\n",
        )

    def test_make_linked_source_set_build_gn_renders_expected_sections(
            self) -> None:
        text = MODULE.make_linked_source_set_build_gn(
            "sample",
            ["include", "{include_root}"],
            "samplelib",
            ["include/sample.h", "src/sample.cc"],
            public_config_name="sample_public_config",
            config_name="sample_config",
            deps=[":base"],
            extra_configs=["//build:no_chromium_code"],
            testonly=True,
        )

        self.assertIn('config("sample_public_config") {', text)
        self.assertIn('config("sample_config") {', text)
        self.assertIn('config("sample_link") {', text)
        self.assertIn('lib_dirs = [ "{lib_root}" ]', text)
        self.assertIn('testonly = true', text)
        self.assertIn('deps = [ ":base" ]', text)
        self.assertIn('"//build:no_chromium_code"', text)
        self.assertIn('"src/sample.cc",', text)

    def test_resolve_spec_normalizes_optional_fields(self) -> None:
        spec = MODULE.resolve_spec("libsrtp")

        self.assertEqual(spec.dep, "libsrtp")
        self.assertEqual(spec.relative_root, "third_party/libsrtp")
        self.assertEqual(spec.dirs, ("include", "srtp"))
        self.assertFalse(spec.preserve_root)
        self.assertEqual(spec.copy_files, {})
        self.assertIn("BUILD.gn", spec.files)

    def test_resolve_spec_rejects_missing_required_key(self) -> None:
        with self.assertRaisesRegex(ValueError, "relative_root"):
            MODULE.resolve_spec(
                "custom",
                specs={"custom": {
                    "dirs": [],
                    "files": {},
                }},
            )

    def test_resolve_spec_rejects_invalid_optional_type(self) -> None:
        with self.assertRaisesRegex(ValueError, "copy_files"):
            MODULE.resolve_spec(
                "custom",
                specs={
                    "custom": {
                        "relative_root": "third_party/custom",
                        "dirs": [],
                        "files": {},
                        "copy_files": [],
                    }
                },
            )

    def test_build_generation_plan_normalizes_output_and_files(self) -> None:
        with tempfile.TemporaryDirectory() as tempdir:
            source_root = pathlib.Path(tempdir)
            spec = MODULE.resolve_spec("libsrtp")

            plan = MODULE.build_generation_plan(
                source_root,
                "/test/include",
                "/test/lib",
                "",
                spec,
            )

            self.assertEqual(plan.output_root,
                             source_root / "third_party" / "libsrtp")
            self.assertFalse(plan.preserve_root)
            self.assertIn(source_root / "third_party" / "libsrtp" / "include",
                          plan.directories)
            build_file = next(item for item in plan.files
                              if item.relative_path == "BUILD.gn")
            self.assertIn('include_dirs = [ "/test/include" ]',
                          build_file.content)
            self.assertIn('lib_dirs = [ "/test/lib" ]', build_file.content)

    def test_build_generation_plan_renders_tool_path(self) -> None:
        with tempfile.TemporaryDirectory() as tempdir:
            source_root = pathlib.Path(tempdir)
            spec = MODULE.resolve_spec("nasm")

            plan = MODULE.build_generation_plan(
                source_root,
                "/test/include",
                "/test/lib",
                "/tool/nasm",
                spec,
            )

            wrapper = next(item for item in plan.files
                           if item.relative_path == "nasm_wrapper.cc")
            self.assertIn('args.push_back(const_cast<char*>("/tool/nasm"));',
                          wrapper.content)
            self.assertIn('CreateProcessA(', wrapper.content)

    def test_build_generation_plan_preserves_root_flag(self) -> None:
        with tempfile.TemporaryDirectory() as tempdir:
            source_root = pathlib.Path(tempdir)
            spec = MODULE.resolve_spec("third_party_root")

            plan = MODULE.build_generation_plan(
                source_root,
                "/test/include",
                "/test/lib",
                "",
                spec,
            )

            self.assertEqual(plan.output_root, source_root / "third_party")
            self.assertTrue(plan.preserve_root)
            self.assertEqual(plan.directories, ())

    def test_plan_generation_uses_resolved_spec(self) -> None:
        with tempfile.TemporaryDirectory() as tempdir:
            source_root = pathlib.Path(tempdir)

            plan = MODULE.plan_generation(
                source_root,
                "testing",
                "/test/include",
                "/test/lib",
                "",
            )

            self.assertEqual(plan.output_root, source_root / "testing")
            self.assertIn(source_root / "testing" / "gmock", plan.directories)
            self.assertTrue(
                any(item.relative_path == "gtest/BUILD.gn"
                    for item in plan.files))

    def test_plan_generation_exposes_copied_files_tuple(self) -> None:
        with tempfile.TemporaryDirectory() as tempdir:
            source_root = pathlib.Path(tempdir)

            plan = MODULE.plan_generation(
                source_root,
                "libsrtp",
                "/test/include",
                "/test/lib",
                "",
            )

            self.assertEqual(plan.copied_files, ())

    def test_apply_generation_plan_writes_planned_files(self) -> None:
        with tempfile.TemporaryDirectory() as tempdir:
            source_root = pathlib.Path(tempdir)
            plan = MODULE.plan_generation(
                source_root,
                "libsrtp",
                "/test/include",
                "/test/lib",
                "",
            )

            MODULE.apply_generation_plan(plan)

            dep_root = source_root / "third_party" / "libsrtp"
            self.assertTrue((dep_root / "include").is_dir())
            self.assertIn('source_set("libsrtp")',
                          (dep_root / "BUILD.gn").read_text())

    def test_generate_external_dep_applies_plan(self) -> None:
        with tempfile.TemporaryDirectory() as tempdir:
            source_root = pathlib.Path(tempdir)

            MODULE.generate_external_dep(
                source_root,
                "nasm",
                "/test/include",
                "/test/lib",
                "/tool/nasm",
            )

            wrapper = (source_root / "third_party" / "nasm" /
                       "nasm_wrapper.cc").read_text()
            self.assertIn('args.push_back(const_cast<char*>("/tool/nasm"));',
                          wrapper)

    def test_write_tree_generates_libsrtp_with_substitution(self) -> None:
        with tempfile.TemporaryDirectory() as tempdir:
            source_root = pathlib.Path(tempdir)

            MODULE.write_tree(source_root, "libsrtp", "/test/include",
                              "/test/lib", "")

            dep_root = source_root / "third_party" / "libsrtp"
            self.assertTrue((dep_root / "include").is_dir())
            self.assertTrue((dep_root / "srtp").is_dir())
            build_gn = (dep_root / "BUILD.gn").read_text()
            self.assertIn('include_dirs = [ "/test/include" ]', build_gn)
            self.assertIn('lib_dirs = [ "/test/lib" ]', build_gn)
            self.assertIn('libs = [ "srtp2" ]', build_gn)
            header = (dep_root / "include" / "srtp.h").read_text()
            self.assertIn("#if __has_include(<srtp.h>)", header)

    def test_write_tree_preserves_existing_root_when_requested(self) -> None:
        with tempfile.TemporaryDirectory() as tempdir:
            source_root = pathlib.Path(tempdir)
            dep_root = source_root / "third_party"
            dep_root.mkdir(parents=True, exist_ok=True)
            marker = dep_root / "keep.txt"
            marker.write_text("keep")

            MODULE.write_tree(source_root, "third_party_root", "/test/include",
                              "/test/lib", "")

            self.assertEqual(marker.read_text(), "keep")
            self.assertEqual((dep_root / "BUILD.gn").read_text(),
                             'group("jpeg") {\n}\n')

    def test_write_tree_renders_nasm_tool_path(self) -> None:
        with tempfile.TemporaryDirectory() as tempdir:
            source_root = pathlib.Path(tempdir)

            MODULE.write_tree(source_root, "nasm", "/test/include",
                              "/test/lib", "/tool/nasm")

            wrapper = (source_root / "third_party" / "nasm" /
                       "nasm_wrapper.cc").read_text()
            self.assertIn('args.push_back(const_cast<char*>("/tool/nasm"));',
                          wrapper)
            self.assertIn('execv(args[0], args.data());', wrapper)
            self.assertIn('CreateProcessA(', wrapper)

    def test_write_tree_generates_nested_testing_tree(self) -> None:
        with tempfile.TemporaryDirectory() as tempdir:
            source_root = pathlib.Path(tempdir)

            MODULE.write_tree(source_root, "testing", "/test/include",
                              "/test/lib", "")

            dep_root = source_root / "testing"
            self.assertTrue((dep_root / "gmock").is_dir())
            self.assertTrue((dep_root / "gtest").is_dir())
            self.assertIn('group("pytype_dependencies")',
                          (dep_root / "BUILD.gn").read_text())
            self.assertIn('group("gtest")',
                          (dep_root / "gtest" / "BUILD.gn").read_text())
            self.assertIn('group("gmock")',
                          (dep_root / "gmock" / "BUILD.gn").read_text())

    def test_main_generates_representative_output_tree(self) -> None:
        with tempfile.TemporaryDirectory() as tempdir:
            source_root = pathlib.Path(tempdir)
            argv = [
                "generate_external_third_party.py",
                "--source-root",
                str(source_root),
                "--dep",
                "libsrtp",
                "--include-root",
                "/test/include",
                "--lib-root",
                "/test/lib",
            ]
            with mock.patch("sys.argv", argv):
                MODULE.main()

            dep_root = source_root / "third_party" / "libsrtp"
            self.assertTrue(dep_root.is_dir())
            self.assertTrue((dep_root / "include" / "srtp.h").is_file())
            self.assertIn('source_set("libsrtp")',
                          (dep_root / "BUILD.gn").read_text())

    def test_argparse_rejects_unknown_dep(self) -> None:
        with tempfile.TemporaryDirectory() as tempdir:
            argv = [
                "generate_external_third_party.py",
                "--source-root",
                tempdir,
                "--dep",
                "does-not-exist",
                "--include-root",
                "/test/include",
                "--lib-root",
                "/test/lib",
            ]
            with mock.patch("sys.argv", argv):
                with self.assertRaises(SystemExit):
                    MODULE.main()


if __name__ == "__main__":
    unittest.main()
