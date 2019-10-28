vcpkg_fail_port_install(ON_ARCH "arm" "arm64" ON_TARGET "UWP")

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO blitzpp/blitz
    REF 0e373f7c3478b10bd8ad8d699a291c57d9cb1e72
    SHA512 9ea0ba652b93fb3b159340b25bdef10c05662b2da23a3bd2e29ddd12d394b96513c0e5d9f348c0cc8fc767890f52d122a1b0fb8ac6adb77f1a8b4bc2beeac5d7
    HEAD_REF master
)

vcpkg_find_acquire_program(PYTHON2)
get_filename_component(PYTHON2_DIR "${PYTHON2}" DIRECTORY)
vcpkg_add_to_path(${PYTHON2_DIR})

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA   
)

vcpkg_install_cmake()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake)

# Handle copyright
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)