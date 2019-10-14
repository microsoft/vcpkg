include(vcpkg_common_functions)

vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO htacg/tidy-html5
    REF d1b906991a7587688d384b648c55731f9be52506
    SHA512 ac1229f95db9ab6367d7650e27b87e76a0874e01c9d404e8c5fb75ba2761318218b658a4f7522188fda8008974393a333a8a5fbed8e3a472c98445f13e459ad5
    HEAD_REF master
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    NO_CHARSET_FLAG
    OPTIONS
        -DBUILD_SHARED_LIB=OFF
        -DTIDY_CONSOLE_SHARED=OFF
)

vcpkg_install_cmake()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(REMOVE ${CURRENT_PACKAGES_DIR}/debug/bin/tidyd.exe)
file(MAKE_DIRECTORY ${CURRENT_PACKAGES_DIR}/tools/tidy-html5)
file(RENAME ${CURRENT_PACKAGES_DIR}/bin/tidy.exe ${CURRENT_PACKAGES_DIR}/tools/tidy-html5/tidy.exe)

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/bin ${CURRENT_PACKAGES_DIR}/debug/bin)
endif()

vcpkg_copy_tool_dependencies(${CURRENT_PACKAGES_DIR}/tools/${PORT})

file(INSTALL ${SOURCE_PATH}/README/LICENSE.md DESTINATION ${CURRENT_PACKAGES_DIR}/share/tidy-html5 RENAME copyright)
