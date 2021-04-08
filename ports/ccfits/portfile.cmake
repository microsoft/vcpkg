vcpkg_download_distfile(ARCHIVE
    URLS "https://heasarc.gsfc.nasa.gov/fitsio/ccfits/CCfits-2.5.tar.gz"
    FILENAME "CCfits-2.5.tar.gz"
    SHA512 63ab4d153063960510cf60651d5c832824cf85f937f84adc5390c7c2fb46eb8e9f5d8cda2554d79d24c7a4f1b6cf0b7a6e20958fb69920b65d7c362c0a5f26b5
)

vcpkg_extract_source_archive_ex(
    ARCHIVE ${ARCHIVE}
    OUT_SOURCE_PATH SOURCE_PATH
    PATCHES
        dll_exports.patch
        fix-dependency.patch
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DCFITSIO_INCLUDE_DIR=${CURRENT_INSTALLED_DIR}/include/cfitsio
)

vcpkg_install_cmake()

if(VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic")
    file(MAKE_DIRECTORY ${CURRENT_PACKAGES_DIR}/bin)
    file(MAKE_DIRECTORY ${CURRENT_PACKAGES_DIR}/debug/bin)
    file(RENAME ${CURRENT_PACKAGES_DIR}/lib/CCfits.dll ${CURRENT_PACKAGES_DIR}/bin/CCfits.dll)
    file(RENAME ${CURRENT_PACKAGES_DIR}/debug/lib/CCfits.dll ${CURRENT_PACKAGES_DIR}/debug/bin/CCfits.dll)
endif()

# Remove duplicate include files
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

# Patch installed headers to look in the correct subdirectory
file(GLOB HEADERS ${CURRENT_PACKAGES_DIR}/include/CCfits/*)
foreach(HEADER IN LISTS HEADERS)
    file(READ "${HEADER}" _contents)
    string(REPLACE "\"fitsio.h\"" "\"cfitsio/fitsio.h\"" _contents "${_contents}")
    file(WRITE "${HEADER}" "${_contents}")
endforeach()

# Handle copyright
file(INSTALL ${SOURCE_PATH}/License.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
