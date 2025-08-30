# Outcome is composed of other third party libraries:
#    Outcome
#      <= status-code
#      <= quickcpplib
#         <= byte-lite
#         <= gsl-lite
#         <= Optional
#
# byte-lite and gsl-lite are in vcpkg, but may not be versions
# known to be compatible with Outcome. It has occurred in the
# past that newer versions were severely broken with Outcome.
#
# One can fetch an 'all sources' tarball from
# https://github.com/ned14/outcome/releases which contains
# the exact copy of those third party libraries known to
# have passed Outcome's CI process.

vcpkg_download_distfile(MISSING_HEADER_FIX
    URLS https://github.com/ned14/outcome/commit/d4d38266a0c889be00069600bdbc339456f8f5bd.patch?full_index=1
    FILENAME outcome-missing-swap-d4d38266a0c889be00069600bdbc339456f8f5bd.patch
    SHA512 bcc6c050001776b998ff8146b7937ab86811288a0e611b911fad5031b654b0839c41a57196f70ec314c322124e1cb6473a7c5e91472e18b5bb6d35780eaf65f8
)

if ("polyfill-cxx20" IN_LIST FEATURES)
    message(WARNING [=[
    Outcome depends on QuickCppLib which uses the vcpkg versions of gsl-lite and byte-lite, rather than the versions tested by QuickCppLib's and Outcome's CI. It is not guaranteed to work with other versions, with failures experienced in the past up-to-and-including runtime crashes. See the warning message from QuickCppLib for how you can pin the versions of those dependencies in your manifest file to those with which QuickCppLib was tested. Do not report issues to upstream without first pinning the versions as QuickCppLib was tested against.
    ]=])
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO ned14/outcome
    REF v${VERSION}
    SHA512 faa92dbee1f5c74389bc181721e12cd87ad616bdcd2e5845b19233f63cd366270eb806b88ac057ea9a3147e3df49210b7219e9b98a0a0299f00c98eaf2ab8903
    HEAD_REF develop
    PATCHES
        fix-status-code-path.patch
        "${MISSING_HEADER_FIX}"
)

# Because outcome's deployed files are header-only, the debug build is not necessary
set(VCPKG_BUILD_TYPE release)

# Use Outcome's own build process, skipping examples and tests.
vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -Doutcome_IS_DEPENDENCY=ON
        "-DCMAKE_PREFIX_PATH=${CURRENT_INSTALLED_DIR}"
        -DOUTCOME_BUNDLE_EMBEDDED_STATUS_CODE=OFF
        -DOUTCOME_ENABLE_DEPENDENCY_SMOKE_TEST=ON  # Leave this always on to test everything compiles
        -DCMAKE_DISABLE_FIND_PACKAGE_Git=ON
        -DCXX_CONCEPTS_FLAGS=
)

if("run-tests" IN_LIST FEATURES)
    vcpkg_cmake_build(TARGET test)
endif()

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/outcome)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/lib")

file(INSTALL "${CURRENT_PORT_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/Licence.txt")
