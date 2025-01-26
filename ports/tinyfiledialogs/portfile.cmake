vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_sourceforge(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO tinyfiledialogs
    FILENAME tinyfiledialogs-current.zip
    SHA512 d7ddd37576d8d758a7bccc25cc19698d5c87645b72aaa1dd2cad32abc8c342911764ef3ab14037d1abcb255f2919fccc1bec07118c81977a89d1f7fda70f185f
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
