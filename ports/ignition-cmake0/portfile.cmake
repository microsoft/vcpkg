include(${CURRENT_INSTALLED_DIR}/share/ignitionmodularscripts/ignition_modular_library.cmake)

set(PACKAGE_VERSION "0.6.1")

ignition_modular_library(NAME cmake
                         VERSION ${PACKAGE_VERSION} 
                         REF "ignition-cmake_${PACKAGE_VERSION}"
                         SHA512 bd57cd43dd944fef264353b67fbbbab989d4bb638b684f80868a8b61fe0b854e156e00852b967c7caa8598315bea60bd8b27ff000410e93c4f04185a13c90489
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
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/lib ${CURRENT_PACKAGES_DIR}/debug)

# Install custom usage
configure_file(${CMAKE_CURRENT_LIST_DIR}/usage ${CURRENT_PACKAGES_DIR}/share/${PORT}/usage @ONLY)
