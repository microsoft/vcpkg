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
# have passed Outcome's CI process, but it may also be the
# case that vcpkg users want to combine Outcome with the vcpkg
# edition of a dependency. We expose that facility via vcpkg
# features.
#
# The default is to choose the dependency SHAs exactly matching
# the Outcome release SHA. These are listed in sha_manifest.cmake.

include(${CURRENT_PORT_DIR}/sha_manifest.cmake)
include(${CURRENT_PORT_DIR}/dependency_quickcpplib.cmake)
include(${CURRENT_PORT_DIR}/dependency_status_code.cmake)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO ned14/outcome
    REF ${OUTCOME_REF}
    SHA512 ${OUTCOME_SHA512}
    HEAD_REF develop
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
  vcpkg-byte-lite QUICKCPPLIB_USE_VCPKG_BYTE_LITE
  vcpkg-gsl-lite QUICKCPPLIB_USE_VCPKG_GSL_LITE
)

# Dependencies
download_quickcpplib("${SOURCE_PATH}/quickcpplib/repo/")
download_status_code("${SOURCE_PATH}/include/outcome/experimental/status-code/")

# Use Outcome's own build process, skipping examples and tests, bundling the
# embedded quickcpplib with the Outcome targets.
vcpkg_configure_cmake(
    SOURCE_PATH "${SOURCE_PATH}"
    PREFER_NINJA
    OPTIONS
        -DPROJECT_IS_DEPENDENCY=On
        -DOUTCOME_BUNDLE_EMBEDDED_QUICKCPPLIB=On
)

vcpkg_install_cmake()

vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/quickcpplib TARGET_PATH share/quickcpplib DO_NOT_DELETE_PARENT_CONFIG_PATH)
vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/outcome)

file(RENAME "${CURRENT_PACKAGES_DIR}/share/cmakelib" "${CURRENT_PACKAGES_DIR}/share/quickcpplib/cmakelib")
file(RENAME "${CURRENT_PACKAGES_DIR}/share/scripts" "${CURRENT_PACKAGES_DIR}/share/quickcpplib/scripts")

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug" "${CURRENT_PACKAGES_DIR}/lib")

# Fix find dependency quickcpplib
vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/share/outcome/outcomeConfig.cmake"
    "CONFIG_MODE)\n"
    "CONFIG_MODE)\ninclude(CMakeFindDependencyMacro)\nfind_dependency(quickcpplib CONFIG)\n"
)

file(INSTALL "${SOURCE_PATH}/Licence.txt" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
