vcpkg_download_distfile(ARCHIVE
    URLS "https://heasarc.gsfc.nasa.gov/fitsio/CCfits-2.5/CCfits-2.5.tar.gz"
    FILENAME "CCfits-2.5.tar.gz"
    SHA512 63ab4d153063960510cf60651d5c832824cf85f937f84adc5390c7c2fb46eb8e9f5d8cda2554d79d24c7a4f1b6cf0b7a6e20958fb69920b65d7c362c0a5f26b5
)

vcpkg_extract_source_archive(
    SOURCE_PATH
    ARCHIVE "${ARCHIVE}"
    PATCHES
        dll_exports.patch
        fix-dependency.patch
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_cmake_install()

if(VCPKG_TARGET_IS_WINDOWS AND VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic")
    file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/bin")
    file(RENAME "${CURRENT_PACKAGES_DIR}/lib/CCfits.dll" "${CURRENT_PACKAGES_DIR}/bin/CCfits.dll")
    if(NOT VCPKG_BUILD_TYPE)
        file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/debug/bin")
        file(RENAME "${CURRENT_PACKAGES_DIR}/debug/lib/CCfits.dll" "${CURRENT_PACKAGES_DIR}/debug/bin/CCfits.dll")
    endif()
endif()

# Remove duplicate include files
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

# Patch installed headers to look in the correct subdirectory
file(GLOB HEADERS "${CURRENT_PACKAGES_DIR}/include/CCfits/*")
foreach(HEADER IN LISTS HEADERS)
    vcpkg_replace_string("${HEADER}" "\"fitsio.h\"" "\"cfitsio/fitsio.h\"")
endforeach()

vcpkg_replace_string(${CURRENT_PACKAGES_DIR}/include/CCfits/CCfits.h
    "#include \"longnam.h\"" "#include \"cfitsio/longnam.h\""
)

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/License.txt")
