if (VCPKG_CMAKE_SYSTEM_NAME STREQUAL "WindowsStore")
    message(FATAL_ERROR "UWP build not supported")
endif()

set(ILM_VERSION 2.2.0)
set(ILM_HASH 0bbad14ed2bd286dff3987b16ef8631470211da54f822cb3e29b7931807216845ded81c9bf41fd2d22a8b362e8b9904a5450f61f5a242e460083e86b846513f1)

include(vcpkg_common_functions)
set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/ilmbase-${ILM_VERSION})
vcpkg_download_distfile(ARCHIVE
    URLS "http://download.savannah.nongnu.org/releases/openexr/ilmbase-${ILM_VERSION}.tar.gz"
    FILENAME "ilmbase-${ILM_VERSION}.tar.gz"
    SHA512 ${ILM_HASH})

vcpkg_extract_source_archive(${ARCHIVE})
vcpkg_apply_patches(SOURCE_PATH ${SOURCE_PATH}
    PATCHES ${CMAKE_CURRENT_LIST_DIR}/fix-parallel-build.patch)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA)
vcpkg_install_cmake()

if(VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic")
    foreach(SUBDIR "" "/debug")
        file(GLOB DLLS ${CURRENT_PACKAGES_DIR}${SUBDIR}/lib/*.dll)
        file(COPY ${DLLS} DESTINATION ${CURRENT_PACKAGES_DIR}${SUBDIR}/bin)
        file(REMOVE ${DLLS})
    endforeach()
endif()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/lib/pkgconfig)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

vcpkg_copy_pdbs()

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
