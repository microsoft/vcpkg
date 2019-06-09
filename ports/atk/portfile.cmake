include(vcpkg_common_functions)

vcpkg_check_linkage(ONLY_DYNAMIC_LIBRARY ONLY_DYNAMIC_CRT)

set(ATK_VERSION 2.24.0)
set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/atk-${ATK_VERSION})
vcpkg_download_distfile(ARCHIVE
    URLS "http://ftp.gnome.org/pub/GNOME/sources/atk/2.24/atk-${ATK_VERSION}.tar.xz"
    FILENAME "atk-${ATK_VERSION}.tar.xz"
    SHA512 3ae0a4d5f28d5619d465135c685161f690732053bcb70a47669c951fbf389b5d2ccc5c7c73d4ee8c5a3b2df14e2f5b082e812a215f10a79b27b412d077f5e962)

vcpkg_extract_source_archive(${ARCHIVE})
vcpkg_apply_patches(SOURCE_PATH ${SOURCE_PATH}/atk
    PATCHES
        ${CMAKE_CURRENT_LIST_DIR}/fix-encoding.patch)

file(COPY ${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt DESTINATION ${SOURCE_PATH})

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DCMAKE_PROGRAM_PATH=${CURRENT_INSTALLED_DIR}/tools/glib
    OPTIONS_DEBUG
        -DATK_SKIP_HEADERS=ON)

vcpkg_install_cmake()
vcpkg_copy_pdbs()

file(COPY ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/atk)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/atk/COPYING ${CURRENT_PACKAGES_DIR}/share/atk/copyright)
