if (VCPKG_CMAKE_SYSTEM_NAME STREQUAL "WindowsStore")
    message(FATAL_ERROR "UWP build not supported")
endif()

include(vcpkg_common_functions)
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO openexr/openexr
    REF v2.3.0
    SHA512 268ae64b40d21d662f405fba97c307dad1456b7d996a447aadafd41b640ca736d4851d9544b4741a94e7b7c335fe6e9d3b16180e710671abfc0c8b2740b147b2
    HEAD_REF develop
    PATCHES 001-26c86195935f5365685bfefe046f0ac7e98fa231.patch
            002-c2557b73c97c5dfb9e3eeff6b7622566edcfb54b.patch
            003-ef3ca9e2303fe5f74263e9ac4f7a068baf3ed01f.patch
            004-027a323e375ebe46a6a74863c3c6306dda4427aa.patch
            005-eb2392c88152c05c3b554cc14bc8a1fafb344340.patch
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DOPENEXR_BUILD_ILMBASE=ON
        -DOPENEXR_BUILD_OPENEXR=OFF
        -DOPENEXR_BUILD_PYTHON_LIBS=OFF
        -DOPENEXR_BUILD_SHARED=ON
        -DOPENEXR_BUILD_STATIC=ON
        -DOPENEXR_BUILD_TESTS=OFF
        -DOPENEXR_BUILD_UTILS=OFF
        -DOPENEXR_BUILD_VIEWERS=OFF
)

vcpkg_install_cmake()
vcpkg_copy_pdbs()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

foreach(HEADER halfExport.h IexExport.h IexMathFloatExc.h IlmThreadExport.h ImathExport.h)
    file(READ ${CURRENT_PACKAGES_DIR}/include/OpenEXR/${HEADER} HEADER_FILE)
    if(VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic")
        string(REPLACE "defined(OPENEXR_DLL)" "1" HEADER_FILE "${HEADER_FILE}")
    else()
        string(REPLACE "defined(OPENEXR_DLL)" "0" HEADER_FILE "${HEADER_FILE}")
    endif()
    file(WRITE ${CURRENT_PACKAGES_DIR}/include/OpenEXR/${HEADER} "${HEADER_FILE}")
endforeach()

file(COPY ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/ilmbase)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/ilmbase/LICENSE ${CURRENT_PACKAGES_DIR}/share/ilmbase/copyright)
