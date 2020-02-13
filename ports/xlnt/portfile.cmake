if(VCPKG_TARGET_IS_WINDOWS) 
    if(VCPKG_LIBRARY_LINKAGE STREQUAL static)
       set(win_patch "static-linking-for-windows.patch")
    endif()
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO tfussell/xlnt
    REF v1.4.0
    SHA512 74abbee97994098fb7d8fd0839929db74fe01b8428f8bdb8edd28340d3b3ed04d4c7d6dd5d886ae766054ff1b0fe9a8275098a1462e7a5146ff09f1cdb063360
    HEAD_REF master
    PATCHES
        ${win_patch}
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

vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/xlnt)

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/share/man)
file(INSTALL ${SOURCE_PATH}/LICENSE.md DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)

vcpkg_copy_pdbs()
