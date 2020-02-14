set(OATPP_VERSION "1.0.0")

vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO oatpp/oatpp-curl
    REF 03a3f336be70c71d0547489aa0ed50206f46dcf8 # 1.0.0
    SHA512 799cbddeb6e9d90eb43911845dd33ee272c4e86c86a07bb710ceb8c0e1722cda15412fdca10c4228a77f38e3b9e3d5d5248c8cd4366cbb9c369db4a830e29496
    HEAD_REF master
    PATCHES "curl-submodule-no-pkg-config-in-vcpkg.patch"
)

set(ENV{CL} "-D_CRT_SECURE_NO_WARNINGS")

vcpkg_configure_cmake(
    SOURCE_PATH "${SOURCE_PATH}"
    PREFER_NINJA
    OPTIONS
        "-DOATPP_BUILD_TESTS:BOOL=OFF"
)
vcpkg_install_cmake()
vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/oatpp-curl-${OATPP_VERSION})
vcpkg_copy_pdbs()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
