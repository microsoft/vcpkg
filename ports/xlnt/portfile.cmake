if(VCPKG_TARGET_IS_WINDOWS) 
    if(VCPKG_LIBRARY_LINKAGE STREQUAL static)
       set(win_patch "static-linking-for-windows.patch")
    endif()
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO tfussell/xlnt
    REF v1.4.0
    SHA512 110808064e6c07df83a3ab215f540ff2e2388e22ea7acd78e5872249a66011863c2c551ba741f585f127fe9ad944390df7b27fa7d0bd0948ebe58e96dcc28f81
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
