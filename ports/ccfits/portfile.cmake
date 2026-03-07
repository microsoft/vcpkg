vcpkg_download_distfile(ARCHIVE
    URLS "https://heasarc.gsfc.nasa.gov/FTP/software/fitsio/ccfits/v${VERSION}/CCfits-${VERSION}.tar.gz"
    FILENAME "CCfits-${VERSION}.tar.gz"
    SHA512 5cb802f41cf0695d0e49924ee163151ee657b93158246766d04c192518c7bed30383405d87b5fb312f5f44af26d5ede3104fab90d93cc232e950f8ae66050fde
)

vcpkg_extract_source_archive(
    SOURCE_PATH
    ARCHIVE "${ARCHIVE}"
    PATCHES
        dll_exports.patch
#        fix-dependency.patch
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
    vcpkg_replace_string("${HEADER}" "\"fitsio.h\"" "\"cfitsio/fitsio.h\"" IGNORE_UNCHANGED)
endforeach()

vcpkg_replace_string(${CURRENT_PACKAGES_DIR}/include/CCfits/CCfits.h
    "#include \"longnam.h\"" "#include \"cfitsio/longnam.h\""
)

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/License.txt")
