vcpkg_fail_port_install(ON_TARGET "uwp")

vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_download_distfile(
    OUT_SOURCE_PATH tinyfiledialogs.zip
    URLS "https://sourceforge.net/code-snapshots/git/t/ti/tinyfiledialogs/code.git/tinyfiledialogs-code-ab6f4f916aaa95d05247ffa66a30867e7f55e875.zip"
    FILENAME "tinyfiledialogs.zip"
    SHA512 0b4bd0f9388a5b11c75b8d4128ced8855281a2a27778035556de5a1812015da1
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
