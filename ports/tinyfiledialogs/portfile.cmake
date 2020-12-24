vcpkg_fail_port_install(ON_TARGET "uwp")

vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_sourceforge(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO tinyfiledialogs
    FILENAME "frozen_versions/tinyfiledialogs-3.6.3.zip"
    SHA512 42c3bd34b0287cf2477f9ede049bea29a9306304e8fab7740065957d3737f4041899f26f29a0693e801cb0a7b63844509f86441262303ff0a4030a431ffac648
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
file(WRITE ${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright "${_contents}")
