include(vcpkg_common_functions)

vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO whoshuu/cpr
    REF v1.5.1
    SHA512 ef97ee553cedf0fd95706574698b7e3dbb4e37b1f92dd3d5b6603daa431984a0361c2cf0ad0ab7cbe5be40376e60f7bb1a34b4687e260d58840bcb2af74d556d
    HEAD_REF master
    PATCHES
        001-cpr-config.patch
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS 
        -DBUILD_CPR_TESTS=OFF
        -DUSE_SYSTEM_CURL=ON
    OPTIONS_DEBUG
        -DDISABLE_INSTALL_HEADERS=ON
)

vcpkg_install_cmake()

file(INSTALL ${CMAKE_CURRENT_LIST_DIR}/cprConfig.cmake DESTINATION ${CURRENT_PACKAGES_DIR}/lib/cmake/cpr)
vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/cpr)

vcpkg_copy_pdbs()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

# Handle copyright
file(COPY ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/cpr)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/cpr/LICENSE ${CURRENT_PACKAGES_DIR}/share/cpr/copyright)
