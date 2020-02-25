if(VCPKG_TARGET_IS_WINDOWS) 
    if(VCPKG_LIBRARY_LINKAGE STREQUAL static)
       set(win_patch "static-linking-for-windows.patch")
    endif()
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO tfussell/xlnt
    REF 85e6878cc41d4c5ad002e961dc1fe35e41f936b6 # v1.4.0
    SHA512 335198fbcc1b3028e38bced4ee26047047b02372b6c52727a64c0cab6db19cc31be8ac6c08e96f415875a181d6f717082220b0f63f08ef6ac194927e2184a9df
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
