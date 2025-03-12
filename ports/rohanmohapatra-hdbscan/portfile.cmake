vcpkg_from_git(
    OUT_SOURCE_PATH SOURCE_PATH
    URL https://github.com/rohanmohapatra/hdbscan-cpp.git
    REF 843dcfd9ee4c88d9f645d9619cff600b2d16aa85
    HEAD_REF master
)

file(COPY "${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt" DESTINATION "${SOURCE_PATH}")

vcpkg_cmake_configure(
    SOURCE_PATH ${SOURCE_PATH}
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup() # CONFIG_PATH lib/cmake/${PORT})
vcpkg_install_copyright(FILE_LIST ${SOURCE_PATH}/LICENSE.md)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")