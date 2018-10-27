include(vcpkg_common_functions)

vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO alecthomas/entityx
    REF 1.2.0
    SHA512 682aa302cb4495666aab2c0b39a286f88cb28046bc8b2deb603402105e15e4b9692e32807077abc3f465e42a4e0f34a7e69169bc74fc5579a5c3d0e17b02fdb8
    HEAD_REF master
    PATCHES fix-cmake.patch
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DENTITYX_BUILD_TESTING=false
)

vcpkg_install_cmake()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

# Handle copyright
file(COPY ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/entityx)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/entityx/COPYING ${CURRENT_PACKAGES_DIR}/share/entityx/copyright)
