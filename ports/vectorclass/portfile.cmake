vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO vectorclass/version2
    REF v2.00.01
    SHA512 2e1f714cf0e23cf7986f0e78b4c1eeab4da6434ac92449b81990931e19ae189df6fbbef50f11e9532a41dc6eaff0a4fea840349a3747621ff537bbd7519f2c3d
    HEAD_REF master
)

file(COPY ${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt DESTINATION ${SOURCE_PATH})

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
)

vcpkg_install_cmake()
vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake TARGET_PATH share)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

# Put the licence file where vcpkg expects it
file(COPY ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT})
file(RENAME  ${CURRENT_PACKAGES_DIR}/share/${PORT}/LICENSE ${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright)
