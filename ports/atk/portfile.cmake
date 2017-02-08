# ATK uses DllMain
if (VCPKG_LIBRARY_LINKAGE STREQUAL static)
    message(STATUS "Warning: Static building not supported. Building dynamic.")
    set(VCPKG_LIBRARY_LINKAGE dynamic)
endif()

include(vcpkg_common_functions)
set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/atk-2.22.0)
vcpkg_download_distfile(ARCHIVE
    URLS "http://ftp.gnome.org/pub/GNOME/sources/atk/2.22/atk-2.22.0.tar.xz"
    FILENAME "atk-2.22.0.tar.xz"
    SHA512 af3f6197eb97de869ee706f19564449b02c1444c413e5418323e4bf4c8cf1d98c7c8baa25189f6879d63606d4bc75f33799cb901f4697c087e868bb9a5643cba
)
vcpkg_extract_source_archive(${ARCHIVE})
file(COPY ${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt DESTINATION ${SOURCE_PATH})

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS
        -DCMAKE_PROGRAM_PATH=${CURRENT_INSTALLED_DIR}/tools/glib
    OPTIONS_DEBUG
        -DATK_SKIP_HEADERS=ON)

vcpkg_install_cmake()
vcpkg_copy_pdbs()

file(COPY ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/atk)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/atk/COPYING ${CURRENT_PACKAGES_DIR}/share/atk/copyright)
