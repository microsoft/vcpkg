if (VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic")
    message(STATUS "Warning: Dynamic building not supported. Building static.")
    set(VCPKG_LIBRARY_LINKAGE static)
endif()

include(vcpkg_common_functions)
set (MUPDF_VERSION 1.12.0)
set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/mupdf-${MUPDF_VERSION}-source)
vcpkg_download_distfile(ARCHIVE
    URLS "https://mupdf.com/downloads/archive/mupdf-${MUPDF_VERSION}-source.tar.gz"
    FILENAME "mupdf.tar.gz"
    SHA512 11ae620e55e9ebd5844abd7decacc0dafc90dd1f4907ba6ed12f5c725d3920187fc730a7fc33979bf3ff9451da7dbb51f34480a878083e2064f3455555f47d96
)
vcpkg_extract_source_archive(${ARCHIVE})
vcpkg_apply_patches(SOURCE_PATH ${SOURCE_PATH}
    PATCHES
        ${CMAKE_CURRENT_LIST_DIR}/missing-includes.patch
)

file(COPY ${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt DESTINATION ${SOURCE_PATH})

vcpkg_configure_cmake(
    SOURCE_PATH "${SOURCE_PATH}"
    PREFER_NINJA
)

vcpkg_install_cmake()

file(COPY ${SOURCE_PATH}/include/mupdf DESTINATION ${CURRENT_PACKAGES_DIR}/include)

vcpkg_copy_pdbs()

#copyright
file(COPY ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT})
file(RENAME ${CURRENT_PACKAGES_DIR}/share/${PORT}/COPYING ${CURRENT_PACKAGES_DIR}/share/${PORT}/COPYRIGHT)
