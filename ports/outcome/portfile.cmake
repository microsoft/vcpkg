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

include(${CURRENT_PORT_DIR}/sha_manifest.cmake)

message(WARNING [=[
Outcome was tested against gsl-lite version 0.37.0 and byte-lite version 0.2.0.
It is not guaranteed to work with newer versions, with failures up-to-and-including runtime crashes.
You can pin these versions in your manifest file by adding
    "overrides": [
        { "name": "gsl-lite", "version": "0.37.0" },
        { "name": "byte-lite", "version": "0.2.0" }
    ]
Do not report issues to upstream without first pinning these previous versions.
]=])

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO ned14/outcome
    REF ${OUTCOME_REF}
    SHA512 ${OUTCOME_SHA512}
    HEAD_REF develop
    PATCHES outcome-deptest.patch
)

vcpkg_from_github(
    OUT_SOURCE_PATH QC_SOURCE_PATH
    REPO ned14/quickcpplib
    REF ${QUICKCPPLIB_REF}
    SHA512 ${QUICKCPPLIB_SHA512}
    HEAD_REF master
    PATCHES
        quickcpp-disablegit.patch
        quicklib-depheaders.patch
)

file(COPY "${QC_SOURCE_PATH}/." DESTINATION "${SOURCE_PATH}/quickcpplib/repo/")

# Quickcpplib deploys subsets of the dependency headers into a private subdirectory
file(COPY "${CURRENT_INSTALLED_DIR}/include/nonstd/byte.hpp"
    DESTINATION "${SOURCE_PATH}/quickcpplib/repo/include/quickcpplib/byte/include/nonstd")
file(COPY "${CURRENT_INSTALLED_DIR}/include/gsl/gsl-lite.hpp"
    DESTINATION "${SOURCE_PATH}/quickcpplib/repo/include/quickcpplib/gsl-lite/include/gsl")
file(COPY "${CURRENT_INSTALLED_DIR}/include/gsl-lite/gsl-lite.hpp"
    DESTINATION "${SOURCE_PATH}/quickcpplib/repo/include/quickcpplib/gsl-lite/include/gsl-lite")

vcpkg_from_github(
    OUT_SOURCE_PATH OPT_SOURCE_PATH
    REPO akrzemi1/Optional
    REF ${OPTIONAL_REF}
    SHA512 ${OPTIONAL_SHA512}
    HEAD_REF master
)

file(COPY "${OPT_SOURCE_PATH}/." DESTINATION "${SOURCE_PATH}/quickcpplib/repo/include/quickcpplib/optional")

vcpkg_from_github(
    OUT_SOURCE_PATH SC_SOURCE_PATH
    REPO ned14/status-code
    REF ${STATUS_CODE_REF}
    SHA512 ${STATUS_CODE_SHA512}
    HEAD_REF master
)

file(COPY "${SC_SOURCE_PATH}/." DESTINATION "${SOURCE_PATH}/include/outcome/experimental/status-code/")

# Because outcome's deployed files are header-only, the debug build it not necessary
set(VCPKG_BUILD_TYPE release)

# Use Outcome's own build process, skipping examples and tests, bundling the
# embedded quickcpplib with the Outcome targets.
vcpkg_configure_cmake(
    SOURCE_PATH "${SOURCE_PATH}"
    PREFER_NINJA
    OPTIONS
        -DPROJECT_IS_DEPENDENCY=On
        -DOUTCOME_BUNDLE_EMBEDDED_QUICKCPPLIB=On
        -DQUICKCPPLIB_USE_VCPKG_BYTE_LITE=ON
        -DQUICKCPPLIB_USE_VCPKG_GSL_LITE=ON
        -DOUTCOME_ENABLE_DEPENDENCY_TEST=ON
        -DCMAKE_DISABLE_FIND_PACKAGE_Git=ON
        -DCMAKE_DISABLE_FIND_PACKAGE_Doxygen=ON
)

vcpkg_install_cmake()

vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/quickcpplib TARGET_PATH share/quickcpplib DO_NOT_DELETE_PARENT_CONFIG_PATH)
vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/outcome)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/lib")

file(RENAME "${CURRENT_PACKAGES_DIR}/share/cmakelib" "${CURRENT_PACKAGES_DIR}/share/quickcpplib/cmakelib")
file(RENAME "${CURRENT_PACKAGES_DIR}/share/scripts" "${CURRENT_PACKAGES_DIR}/share/quickcpplib/scripts")

# Fix find dependency quickcpplib
vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/share/outcome/outcomeConfig.cmake"
    "CONFIG_MODE)\n"
    "CONFIG_MODE)\ninclude(CMakeFindDependencyMacro)\nfind_dependency(quickcpplib CONFIG)\n"
)

file(INSTALL "${CURRENT_PORT_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
file(INSTALL "${SOURCE_PATH}/Licence.txt" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
