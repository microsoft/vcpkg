vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_sourceforge(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO tinyfiledialogs
    FILENAME tinyfiledialogs-current.zip
    SHA512 6e890014646e69f0002a342d6331ec03dc41749a760dd30ac8a99919adbfc8ba646f988d1f44b0c1991a075d9cd054e481014c8cc8c5e9e8ec56ce2600d6fb03
)

file(REMOVE_RECURSE "${SOURCE_PATH}/dll_cs_lua_R_fortran_pascal")

file(COPY "${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt" DESTINATION "${SOURCE_PATH}")

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

file(READ "${CURRENT_PACKAGES_DIR}/include/tinyfiledialogs/tinyfiledialogs.h" _contents)
# reads between the line "- License -" and a closing "*/"
if (NOT _contents MATCHES [[- License -(([^*]|\*[^/])*)\*/]])
    message(FATAL_ERROR "Failed to parse license from tinyfiledialogs.h")
endif()
file(WRITE "${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright" "${CMAKE_MATCH_1}")
