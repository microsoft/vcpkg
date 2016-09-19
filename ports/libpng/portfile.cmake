include(vcpkg_common_functions)
vcpkg_download_distfile(ARCHIVE
    URL "http://download.sourceforge.net/libpng/libpng-1.6.24.tar.xz"
    FILENAME "libpng-1.6.24.tar.xz"
    MD5 ffcdbd549814787fa8010c372e35ff25
)
vcpkg_extract_source_archive(${ARCHIVE})

find_program(GIT git)
vcpkg_execute_required_process(
    COMMAND ${GIT} init
    WORKING_DIRECTORY ${CURRENT_BUILDTREES_DIR}/src/libpng-1.6.24
    LOGNAME git-init
)
execute_process(
    COMMAND ${GIT} apply "${CMAKE_CURRENT_LIST_DIR}/use-abort-on-all-platforms.patch" --ignore-whitespace --whitespace=nowarn
    WORKING_DIRECTORY ${CURRENT_BUILDTREES_DIR}/src/libpng-1.6.24
)

vcpkg_configure_cmake(
    SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/libpng-1.6.24
    OPTIONS
        -DPNG_STATIC=OFF
        -DPNG_TESTS=OFF
        -DSKIP_INSTALL_PROGRAMS=ON
        -DSKIP_INSTALL_EXECUTABLES=ON
        -DSKIP_INSTALL_FILES=ON
    OPTIONS_DEBUG
        -DSKIP_INSTALL_HEADERS=ON
)

vcpkg_build_cmake()
vcpkg_install_cmake()

file(REMOVE_RECURSE
    ${CURRENT_PACKAGES_DIR}/debug/share
)
file(MAKE_DIRECTORY ${CURRENT_PACKAGES_DIR}/share)
file(RENAME ${CURRENT_PACKAGES_DIR}/lib/libpng ${CURRENT_PACKAGES_DIR}/share/libpng)
file(RENAME ${CURRENT_PACKAGES_DIR}/debug/lib/libpng/libpng16-debug.cmake ${CURRENT_PACKAGES_DIR}/share/libpng/libpng16-debug.cmake)
file(REMOVE_RECURSE
    ${CURRENT_PACKAGES_DIR}/debug/lib/libpng
)
file(COPY ${CURRENT_BUILDTREES_DIR}/src/libpng-1.6.24/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/libpng)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/libpng/LICENSE ${CURRENT_PACKAGES_DIR}/share/libpng/copyright)
vcpkg_copy_pdbs()

