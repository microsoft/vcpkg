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

if ("polyfill-cxx20" IN_LIST FEATURES)
    message(WARNING [=[
    Outcome depends on QuickCppLib which uses the vcpkg versions of gsl-lite and byte-lite, rather than the versions tested by QuickCppLib's and Outcome's CI. It is not guaranteed to work with other versions, with failures experienced in the past up-to-and-including runtime crashes. See the warning message from QuickCppLib for how you can pin the versions of those dependencies in your manifest file to those with which QuickCppLib was tested. Do not report issues to upstream without first pinning the versions as QuickCppLib was tested against.
    ]=])
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO ned14/outcome
    REF v${VERSION}
    SHA512 44c692472a59ffdf77574c25aab9b43f6418a9a384dc9d47eabf5af9e28881d8e7a8c3dfac166c53747a5e2a692055ba4e135e2425a24bca81eee7220212de44
    HEAD_REF develop
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
