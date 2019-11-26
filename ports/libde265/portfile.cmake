vcpkg_fail_port_install(ON_ARCH "arm" "arm64" ON_TARGET "uwp" "osx")

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO strukturag/libde265
    REF 7f848e2e257d7a29e2a73c7f4950ef596804789d
    SHA512 2b2f8fdc9bce7dd1b36c1a9b0fd96b8771233ad9cafecb6e8c3456178a87be0ecf91f6545252137be9b0dbeb435a0caed262fdc1810c1df4fa2776409fd1b910
    HEAD_REF master
    PATCHES 
        fix-install-targets-and-headers.patch
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DDISABLE_SSE=ON
)

vcpkg_install_cmake()

vcpkg_copy_pdbs()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

if(VCPKG_LIBRARY_LINKAGE STREQUAL static)
    file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/bin ${CURRENT_PACKAGES_DIR}/debug/bin)
endif()

# Handle copyright
file(INSTALL ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)