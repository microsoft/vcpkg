include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO tfussell/xlnt
    REF v1.4.0
    SHA512 74abbee97994098fb7d8fd0839929db74fe01b8428f8bdb8edd28340d3b3ed04d4c7d6dd5d886ae766054ff1b0fe9a8275098a1462e7a5146ff09f1cdb063360
    HEAD_REF master
)

if(VCPKG_LIBRARY_LINKAGE STREQUAL dynamic)
    set(STATIC OFF)
else()
    set(STATIC ON)
endif()

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS -DTESTS=OFF -DSAMPLES=OFF -DBENCHMARKS=OFF -DSTATIC=${STATIC}
)

vcpkg_install_cmake()

if(CMAKE_SYSTEM_NAME STREQUAL "Windows" OR (NOT CMAKE_SYSTEM_NAME AND CMAKE_HOST_SYSTEM_NAME STREQUAL "Windows"))
    if(VCPKG_LIBRARY_LINKAGE STREQUAL static)
        vcpkg_apply_patches(
            SOURCE_PATH ${CURRENT_PACKAGES_DIR}
            PATCHES ${CMAKE_CURRENT_LIST_DIR}/static-linking-for-windows.patch
        )
    endif()
endif()

vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/xlnt)

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/share/man)
file(INSTALL ${SOURCE_PATH}/LICENSE.md DESTINATION ${CURRENT_PACKAGES_DIR}/share/xlnt RENAME copyright)

vcpkg_copy_pdbs()
