# ball-lang: the unified `ball` CLI (issue #367/#368) for the Ball
# programming language — compile / encode / run subcommands, plus the
# self-hosted info/validate/tree/version verbs.
#
# This is a pure CLI application: no headers or libraries are installed, so
# (like ports/vcpkg-tool-ninja, which packages the `ninja` build tool the
# same way) we only need a release build.
set(VCPKG_BUILD_TYPE release)

# ...and, for the same reason, ${CURRENT_PACKAGES_DIR}/include stays empty.
# Without this, vcpkg's post-build validation reports
#   "The folder ${CURRENT_PACKAGES_DIR}/include is empty or not present ...
#    If this is not a CMake helper port but this is otherwise intentional, add
#    set(VCPKG_POLICY_EMPTY_INCLUDE_FOLDER enabled) to suppress this message."
#   "Found 1 post-build check problem(s) ... Please correct these before
#    submitting this port to the curated registry."
# — i.e. a submission blocker, surfaced by the ci.yml vcpkg smoke's own log.
# NOT VCPKG_POLICY_CMAKE_HELPER_PORT (what ports/vcpkg-tool-ninja uses): that
# one declares a port which ships only CMake scripts, which this is not.
set(VCPKG_POLICY_EMPTY_INCLUDE_FOLDER enabled)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Ball-Lang/ball
    REF "v${VERSION}"
    # SHA512 of https://github.com/Ball-Lang/ball/archive/v1.64.0.tar.gz,
    # obtained the way vcpkg's packaging tutorial prescribes: run the install
    # once with `SHA512 0` and paste the hash from its "the expected SHA512 was
    # all zeros, please change the expected SHA512 to: <hash>" error. Verified
    # three ways (that message, `sha512sum` of vcpkg's own downloads/ copy, and
    # `sha512sum` of an independent `curl` of the same URL).
    # ON A VERSION BUMP this MUST be recomputed together with `version-semver`
    # in vcpkg.json and the sidecar SHA512 below — all three name one tag.
    SHA512 0622de99d53d923b5e41e091edca3bc7e24ab13ead3db1a557540f2cf70c75a415a3544c2dd44da5813a0540868c756dd604e46d68eb08353b5d9b16a63fca28
    HEAD_REF main
)

# ── Self-hosted verbs: the pre-generated C++ sidecar (issues #368/#361) ──────
# `ball compile` / `ball encode` / `ball version` only need the C++ compiler and
# encoder libraries built here, so they are always real. `ball run` and the
# self-hosted `info`/`validate`/`tree` verbs are the SELF-HOSTED half of the CLI
# (issue #367): they are Ball programs compiled to C++ by Ball's own compiler
# into dart/self_host/lib/{engine_rt.cpp,cli_rt.h}, which cpp/cli/CMakeLists.txt
# EXISTS-gates at configure time. Producing them needs Dart plus a bootstrap
# build of `ball_cpp_compile` — neither of which exists inside vcpkg's
# sandboxed, network-isolated build.
#
# So the release workflow (.github/workflows/release-cpp.yml) runs that Dart
# pipeline once per tag and publishes the two generated sources as a release
# asset beside the `ball` binaries; this port downloads and unpacks that asset
# into ${SOURCE_PATH}/dart/self_host/lib/ before configuring, and the same
# EXISTS gates that give the Releases binaries every verb fire here too.
#
# It is a FEATURE, on by default, rather than an unconditional download:
# vcpkg_download_distfile has no non-fatal mode, so gating it is the only way
# vcpkg supports "this build does not need the sidecar". `vcpkg install
# ball-lang[core]` therefore still yields exactly the compile/encode/version-only
# `ball` this port shipped before — no download attempted, no hard failure —
# while the default install gets every verb.
#
# FEATURE_OPTIONS is intentionally NOT forwarded to vcpkg_cmake_configure below:
# the feature selects whether the two generated sources are *present*, and
# cpp/cli/CMakeLists.txt keys off their existence, not off a -D flag. Passing an
# unused -DBALL_WITH_SELFHOST would only earn a "manually-specified variables
# were not used" warning from CMake.
vcpkg_check_features(
    OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        selfhost BALL_WITH_SELFHOST
)

if(BALL_WITH_SELFHOST)
    vcpkg_download_distfile(
        BALL_SELFHOST_ARCHIVE
        URLS "https://github.com/Ball-Lang/ball/releases/download/v${VERSION}/ball-selfhost-cpp-src-v${VERSION}.tar.gz"
        FILENAME "ball-selfhost-cpp-src-v${VERSION}.tar.gz"
        # SHA512 of the v1.64.0 release asset, cross-checked against the
        # `ball-selfhost-cpp-src-v1.64.0.tar.gz.sha256` (and `SHA256SUMS.txt`)
        # that release-cpp.yml publishes beside it. Recompute on a version bump.
        SHA512 ee24364ebe55545b65384960e04ae5ebb7593133a4c6d65ba6fdccfc0c80e3ddee0ac776d00e7891cf499f26353fb670497e7e2e533fc17b56c188730c523f96
    )
    # NO_REMOVE_ONE_LEVEL: the asset is a flat archive of the two generated
    # sources, deliberately with no wrapping directory, so the file names it
    # unpacks are exactly the names cpp/cli/CMakeLists.txt gates on.
    vcpkg_extract_source_archive(
        BALL_SELFHOST_DIR
        ARCHIVE "${BALL_SELFHOST_ARCHIVE}"
        SOURCE_BASE "ball-selfhost-cpp-src"
        NO_REMOVE_ONE_LEVEL
    )
    # Fail loud, not silently verbless: a sidecar that unpacked to something
    # other than these two names would otherwise leave the EXISTS gates unmet
    # and hand the user a stub `ball run` with a green install log.
    foreach(_ball_selfhost_file IN ITEMS cli_rt.h engine_rt.cpp)
        if(NOT EXISTS "${BALL_SELFHOST_DIR}/${_ball_selfhost_file}")
            message(FATAL_ERROR
                "ball-lang[selfhost]: ${_ball_selfhost_file} is missing from "
                "ball-selfhost-cpp-src-v${VERSION}.tar.gz. Install "
                "ball-lang[core] for the compile/encode/version-only build, or "
                "report this against https://github.com/Ball-Lang/ball/issues.")
        endif()
    endforeach()
    file(COPY
        "${BALL_SELFHOST_DIR}/cli_rt.h"
        "${BALL_SELFHOST_DIR}/engine_rt.cpp"
        DESTINATION "${SOURCE_PATH}/dart/self_host/lib"
    )
    message(STATUS "ball-lang: self-hosted verbs ENABLED (run/info/validate/tree)")
else()
    message(STATUS "ball-lang: self-hosted verbs stubbed (feature 'selfhost' not selected) — compile/encode/version only")
endif()

# This configures the FULL cpp/ CMake project (shared + compiler + encoder +
# cli + test) — there is no standalone `cpp/cli/CMakeLists.txt` entry point
# today, matching how a human would build the repo locally (see the root
# CLAUDE.md "Build & Test" section). Only the `ball` target and its link
# dependencies are ever BUILT or INSTALLED though, via the target-scoped
# `install(TARGETS ball ...)` rule in cpp/cli/CMakeLists.txt (issue #368) —
# vcpkg_cmake_install()'s generated `install` target does not pull in
# cpp/test/'s targets, which register no install() rules of their own.
#
# NOTE the `/cpp` suffix: SOURCE_PATH is the REPOSITORY root, which has no
# CMakeLists.txt of its own (`cmake -S cpp -B cpp/build` is the documented
# build). Configuring the bare SOURCE_PATH fails with "The source directory
# ... does not appear to contain CMakeLists.txt" — which is exactly what the
# ci.yml `vcpkg port smoke` job caught the first time this port was ever built
# by any tool. vcpkg_install_copyright below still uses the bare SOURCE_PATH,
# since LICENSE lives at the repository root.
#
# BALL_BUILD_PROTOBUF_RT / BALL_BUILD_UPSTREAM_CONFORMANCE both default OFF
# upstream; passed explicitly so a future default flip in the Ball repo can't
# silently start FetchContent'ing Google protobuf/abseil inside a vcpkg build.
vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}/cpp"
    OPTIONS
        -DBALL_BUILD_PROTOBUF_RT=OFF
        -DBALL_BUILD_UPSTREAM_CONFORMANCE=OFF
)
vcpkg_cmake_install()
vcpkg_copy_tools(
    TOOL_NAMES ball
    DESTINATION "${CURRENT_PACKAGES_DIR}/tools/${PORT}"
    AUTO_CLEAN
)

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
