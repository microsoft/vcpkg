include(vcpkg_common_functions)
set(XXHASH_VERSION 0.6.2)
set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/xxhash-${XXHASH_VERSION})
vcpkg_download_distfile(ARCHIVE
    URLS "https://github.com/Cyan4973/xxHash/archive/v${XXHASH_VERSION}.zip"
    FILENAME "xxhash-${XXHASH_VERSION}.zip"
    SHA512 a2364421f46116a6e7f6bd686665fe4ee58670af6dad611ca626283c1b448fb1120ab3495903a5c8653d341ef22c0d244604edc20bf82a42734ffb4b871e2724)

vcpkg_extract_source_archive(${ARCHIVE})

if(VCPKG_LIBRARY_LINKAGE STREQUAL static)
    set(XXH_STATIC ON)
else()
    set(XXH_STATIC OFF)
endif()

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}/cmake_unofficial
    PREFER_NINJA
    OPTIONS
        -DBUILD_STATIC_LIBS=${XXH_STATIC}
        -DCMAKE_WINDOWS_EXPORT_ALL_SYMBOLS=ON)

vcpkg_install_cmake()
vcpkg_copy_pdbs()

if(VCPKG_LIBRARY_LINKAGE STREQUAL dynamic)
    file(READ ${CURRENT_PACKAGES_DIR}/include/xxhash.h XXHASH_H)
    string(REPLACE "#  define XXH_PUBLIC_API   /* do nothing */" "#  define XXH_PUBLIC_API __declspec(dllimport)" XXHASH_H "${XXHASH_H}")
    file(WRITE ${CURRENT_PACKAGES_DIR}/include/xxhash.h "${XXHASH_H}")
endif()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(COPY ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/xxhash)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/xxhash/LICENSE ${CURRENT_PACKAGES_DIR}/share/xxhash/copyright)
