set(PACKAGE_VERSION "0.6.1")

ignition_modular_library(NAME cmake
                         VERSION ${PACKAGE_VERSION}
                         REF "ignition-cmake_${PACKAGE_VERSION}"
                         SHA512 9414db04ef6ce0206aba4eb1c8192524249761976b82654da89222e0931d1e2bbd63dcc7f4e6c6fddbc71e54911e9bf9fcbd159f51862e89419e0686bfb035e9
                         # Ensure that gtest is not compiled (backport of https://bitbucket.org/ignitionrobotics/ign-cmake/pull-requests/163)
                         PATCHES do-not-compile-gtest.patch
                         # Support for ARM64 (backport of https://bitbucket.org/ignitionrobotics/ign-cmake/pull-requests/168)
                                 support-arm64.patch
                         # Do not depend on pkg-config installed to find uuid
                                 uuid-do-not-require-pkg-config.patch
                         # Fix FindIgnCURL.cmake (backport of https://bitbucket.org/ignitionrobotics/ign-cmake/pull-requests/175)
                                 fix-find-ign-curl.patch
                         )

# Permit empty include folder
set(VCPKG_POLICY_EMPTY_INCLUDE_FOLDER enabled)

# Remove unneccessary directory, as ignition-cmake is a pure CMake package
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/lib" "${CURRENT_PACKAGES_DIR}/debug")

# Install custom usage
configure_file("${CMAKE_CURRENT_LIST_DIR}/usage" "${CURRENT_PACKAGES_DIR}/share/${PORT}/usage" @ONLY)
