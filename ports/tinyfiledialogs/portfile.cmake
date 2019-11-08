include(vcpkg_common_functions)

vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_git(
    OUT_SOURCE_PATH SOURCE_PATH
    URL https://git.code.sf.net/p/tinyfiledialogs/code
    REF c5ea3d553f044e3c24655524736e0c084a964e25
)

file(COPY ${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt DESTINATION ${SOURCE_PATH})

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
)

vcpkg_install_cmake()

vcpkg_fixup_cmake_targets()
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

file(READ ${CURRENT_PACKAGES_DIR}/include/tinyfiledialogs/tinyfiledialogs.h _contents)
string(SUBSTRING "${_contents}" 0 1024 _contents)
file(WRITE ${CURRENT_PACKAGES_DIR}/share/tinyfiledialogs/copyright "${_contents}")
