include(${CMAKE_TRIPLET_FILE})
if (VCPKG_LIBRARY_LINKAGE STREQUAL static)
    message(FATAL_ERROR "Static building not supported yet")
endif()
include(vcpkg_common_functions)
set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/expat-2.1.1)
vcpkg_download_distfile(ARCHIVE_FILE
    URLS "http://downloads.sourceforge.net/project/expat/expat/2.1.1/expat-2.1.1.tar.bz2"
    FILENAME "expat-2.1.1.tar.bz2"
    SHA512 088e2ef3434f2affd4fc79fe46f0e9826b9b4c3931ddc780cd18892f1cd1e11365169c6807f45916a56bb6abcc627dcd17a23f970be0bf464f048f5be2713628
)
vcpkg_extract_source_archive(${ARCHIVE_FILE})

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS
        -DBUILD_examples=OFF
        -DBUILD_tests=OFF
        -DBUILD_tools=OFF
)

vcpkg_install_cmake()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include ${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig ${CURRENT_PACKAGES_DIR}/lib/pkgconfig)
file(INSTALL ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/expat RENAME copyright)
vcpkg_copy_pdbs()