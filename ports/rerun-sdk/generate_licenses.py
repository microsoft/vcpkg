"""Render cargo-about's JSON output as THIRDPARTY-LICENSES.txt.

cargo-about's `overview` already lists each license once with a canonical copy
of its text.  This script simply renders that as a plain-text file, collects the
individual copyright notices (which live in the per-crate entries under
`licenses`) and renders them as a list of notices.
"""

import json
import re
import sys

RULE = "=" * 78

# A copyright notice, as opposed to a wrapped line of license body text starting
# with the word "copyright".  Requires a year to reject certain boilerplate.
NOTICE_RE = re.compile(r"^(?://\s*|[#*]\s*)?(?:Copyright|COPYRIGHT|©)\b.*?\d{4}")
RESERVED_RE = re.compile(r"^(?://\s*|[#*]\s*)?All rights reserved\.?$", re.IGNORECASE)

# How far into a license text a copyright notice still counts as the file's own
# heading. Past that it belongs to Apache-2.0's appendix, which is a template
# rather than a claim and so is restored instead of removed.
HEAD_LINES = 10
PLACEHOLDER = "Copyright [yyyy] [name of copyright owner]"

HEADER = """\
Third-party licenses for the prebuilt rerun_c library
=====================================================

The Rerun C++ SDK ships a prebuilt rerun_c static library that statically links
the Rust crates listed below, so their licenses apply to anything linking the
SDK in addition to Rerun's own MIT and Apache-2.0 licenses.

The crates and their license expressions are those of the rerun_c crate at
https://github.com/rerun-io/rerun, from which this listing was generated.

Each license is given once, with the copyright notices of the components it
covers followed by a copy of its text.
"""


def notices(text):
    for line in text.splitlines():
        line = " ".join(line.split())
        if NOTICE_RE.match(line):
            yield line.lstrip("/#* ")


def remove_named_holders(text):
    """Take one crate's copyright holders out of a shared license text.

    cargo-about represents each license with a copy taken from one of the crates
    using it.  That copy names a single holder for a text covering every
    component under the license.  Almost every notice is listed above the text,
    so the heading can simply go.  The Apache-2.0 notice will instetad list its
    notices in the appendix, where the boilerplate is filled in.  This is
    restored to the placeholder the license is published with.
    """
    kept = []
    for index, line in enumerate(text.splitlines()):
        flat = " ".join(line.split())
        head = index < HEAD_LINES
        if NOTICE_RE.match(flat):
            if not head:
                indent = line[: len(line) - len(line.lstrip())]
                kept.append(indent + PLACEHOLDER)
            continue
        if head and RESERVED_RE.match(flat):
            continue
        # Blank lines and bare comment markers left behind by the heading.
        if head and not flat.strip("/#* ") and not (kept and kept[-1].strip("/#* ")):
            continue
        kept.append(line)
    return "\n".join(kept).strip()


def main():
    about = json.load(sys.stdin)

    out = [HEADER, "", RULE, "Components", RULE, ""]
    for entry in about["crates"]:
        package = entry["package"]
        out.append(f"  {package['name']} v{package['version']}: {entry['license']}")

    for license in about["overview"]:
        found = {
            notice
            for index in license["indices"]
            for notice in notices(about["licenses"][index]["text"])
        }
        out += ["", RULE, f"{license['name']} ({license['id']})", RULE, ""]
        if found:
            out.append("Copyright notices:")
            out += ["  " + notice for notice in sorted(found, key=str.lower)]
            out.append("")
        out.append(remove_named_holders(license["text"]))

    sys.stdout.write("\n".join(out).rstrip() + "\n")


if __name__ == "__main__":
    main()
