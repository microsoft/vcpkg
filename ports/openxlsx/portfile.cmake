vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO troldal/OpenXLSX
    REF 5723411d47643ce3b5b9994064c26ca8cd841f13
    SHA512 edc7abe4da26699ea91c2ef84279a4f224af11c8ed298bea514c5992cd2c9a046ecdcd37c306f2b65cfb5ae398aaa98d027ad5b53a71c5119c3fafd7c7d60337
    HEAD_REF master
    PATCHES
        pugixml.patch
        fix-dependencies.patch
        use-public-pugixml.patch
        missing-header.patch)

file(REMOVE_RECURSE "${SOURCE_PATH}/external/nowide")
file(REMOVE_RECURSE "${SOURCE_PATH}/external/pugixml")

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    set(OPENXLSX_LIBRARY_TYPE "STATIC")
else()
    set(OPENXLSX_LIBRARY_TYPE "SHARED")
endif()

vcpkg_cmake_configure(
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS
        ${FEATURE_OPTIONS}
        -DOPENXLSX_CREATE_DOCS=OFF
        -DOPENXLSX_BUILD_BENCHMARKS:BOOL=OFF
        -DOPENXLSX_BUILD_SAMPLES:BOOL=OFF
        -DOPENXLSX_BUILD_TESTS:BOOL=OFF
        -DOPENXLSX_COMPACT_MODE:BOOL=OFF
        -DOPENXLSX_CREATE_DOCS:BOOL=OFF
        -DOPENXLSX_LIBRARY_TYPE:STRING=${OPENXLSX_LIBRARY_TYPE})

vcpkg_cmake_install()
vcpkg_copy_pdbs()
vcpkg_cmake_config_fixup(CONFIG_PATH "lib/cmake/OpenXLSX")

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/license")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/license")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE.md")
