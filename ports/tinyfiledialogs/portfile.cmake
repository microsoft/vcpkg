vcpkg_fail_port_install(ON_TARGET "uwp")

vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_download_distfile(ARCHIVE
    URLS "https://sourceforge.net/projects/tinyfiledialogs/files/v3.4/tinyfiledialogs-3.4.3.zip/download"
    FILENAME "tinyfiledialogs.zip"
    SHA512 b4a8c8fa5ff53a0972ce9dd1a4a473eaeb82689e5a47553b83e9220ea7e0ec582d87111728088ab6d314972e6531653b11fbd8c05c5e46fbe5bc4d29c7fe23fb
)

vcpkg_extract_source_archive_ex(
    OUT_SOURCE_PATH SOURCE_PATH
    ARCHIVE ${ARCHIVE} 
    REF v3.4.3
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
