if(NOT VCPKG_TARGET_ARCHITECTURE STREQUAL x64)
  message(FATAL_ERROR "Folly only supports the x64 architecture.")
endif()

if (VCPKG_LIBRARY_LINKAGE STREQUAL dynamic)
    message(STATUS "Warning: Dynamic building not supported yet. Building static.")
    set(VCPKG_LIBRARY_LINKAGE static)
endif()

include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO facebook/folly
    REF c2e28878d8f88359599da03080fbbe71dac2e80f
    SHA512 3321b19c5d67a172f056ef657256ff5a960a3228c2d2812dd920036def646eea192e62668c983c6c69f99bb906592ef72733d6c8b95dc3193865f922dae558d5
    HEAD_REF master
)

vcpkg_apply_patches(
    SOURCE_PATH ${SOURCE_PATH}
    PATCHES "${CMAKE_CURRENT_LIST_DIR}/fix-cmakelists.patch"
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
)

vcpkg_install_cmake()

vcpkg_copy_pdbs()

vcpkg_fixup_cmake_targets()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

# Handle copyright
file(COPY ${CURRENT_BUILDTREES_DIR}/src/folly-c2e28878d8f88359599da03080fbbe71dac2e80f/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/folly)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/folly/LICENSE ${CURRENT_PACKAGES_DIR}/share/folly/copyright)
