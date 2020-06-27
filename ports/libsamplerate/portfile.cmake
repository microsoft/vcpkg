include(vcpkg_common_functions)

vcpkg_download_distfile(ARCHIVE
    URLS "http://www.mega-nerd.com/SRC/libsamplerate-0.1.9.tar.gz"
    FILENAME "libsamplerate-0.1.9.tar.gz"
    SHA512 78596657963cbf06785e3e6e1190b093df71da52ca340e75bd8246a962cd79dd1c90fa5527c607cebcb296e2c1ee605015278b274e3b768f2f3fbeb0eadfb728
)

vcpkg_extract_source_archive_ex(
    OUT_SOURCE_PATH SOURCE_PATH
    ARCHIVE ${ARCHIVE}
)

file(COPY ${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt DESTINATION ${SOURCE_PATH}/src)
file(COPY ${SOURCE_PATH}/Win32/config.h DESTINATION ${SOURCE_PATH}/src)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}/src
    PREFER_NINJA
)

vcpkg_install_cmake()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

file(INSTALL ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/libsamplerate RENAME copyright)

vcpkg_copy_pdbs()
