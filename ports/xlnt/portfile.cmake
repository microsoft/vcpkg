if(VCPKG_TARGET_IS_WINDOWS) 
    if(VCPKG_LIBRARY_LINKAGE STREQUAL static)
       set(win_patch "static-linking-for-windows.patch")
    endif()
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO tfussell/xlnt
    REF 568ac85346bc37757b0cd16464e7e1ea7656df91 # v1.5.0
    SHA512 414d691b372934326dc0da134eb7752c27c3223b6e92b433494d0758ca657f43b66894ad54ac97a8410387a2531a573c81572daa6a0434fa023e8e29ca74331c
    HEAD_REF master
    PATCHES
        "fix-not-found-include.patch"
        ${win_patch}
)
file(REMOVE "${SOURCE_PATH}/third-party/libstudxml/version")

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
