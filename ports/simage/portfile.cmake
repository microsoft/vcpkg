vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Coin3D/simage
    REF simage-1.8.0
    SHA512 7070c845fc72094a97b1253d23a5f60f90e71dc6ed968c9c7da67e05660b05245a807fbdf0f592a1d459c7c3b725783c55f59f867182b11cb9ec40741d7ad58c
    HEAD_REF master
    PATCHES
        disable-cpackd.patch
        disable-examples.patch
        disable-tests.patch
        link-flac-library.patch
        link-math-library.patch
        link-ogg-library.patch
        potentially-uninitialized-local-pointer-variable.patch
)

if(VCPKG_LIBRARY_LINKAGE STREQUAL static)
    set(SIMAGE_BUILD_SHARED_LIBS OFF)
else()
    set(SIMAGE_BUILD_SHARED_LIBS ON)
endif()

set(OSX_OR_WINDOWS OFF)
if((VCPKG_TARGET_IS_WINDOWS AND NOT VCPKG_TARGET_IS_UWP) OR VCPKG_TARGET_IS_OSX)
    set(OSX_OR_WINDOWS ON)
endif()

if(VCPKG_TARGET_IS_WINDOWS AND NOT VCPKG_TARGET_IS_UWP)
    set(SIMAGE_USE_AVIENC ON)
    set(SIMAGE_USE_GDIPLUS ON)
else()
    set(SIMAGE_USE_AVIENC OFF)
    set(SIMAGE_USE_GDIPLUS OFF)
endif()

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DSIMAGE_BUILD_SHARED_LIBS=${SIMAGE_BUILD_SHARED_LIBS}
        -DSIMAGE_USE_AVIENC=${SIMAGE_USE_AVIENC}
        -DSIMAGE_USE_GDIPLUS=${SIMAGE_USE_GDIPLUS}
        -DCMAKE_DISABLE_FIND_PACKAGE_FLAC=ON
        -DCMAKE_DISABLE_FIND_PACKAGE_Jasper=ON
        -DCMAKE_DISABLE_FIND_PACKAGE_Doxygen=ON
        -DCMAKE_DISABLE_FIND_PACKAGE_ZLIB=${OSX_OR_WINDOWS}
        -DCMAKE_DISABLE_FIND_PACKAGE_GIF=${OSX_OR_WINDOWS}
        -DCMAKE_DISABLE_FIND_PACKAGE_JPEG=${OSX_OR_WINDOWS}
        -DCMAKE_DISABLE_FIND_PACKAGE_PNG=${OSX_OR_WINDOWS}
        -DCMAKE_DISABLE_FIND_PACKAGE_TIFF=${OSX_OR_WINDOWS}
)

vcpkg_install_cmake()
vcpkg_copy_pdbs()
vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/simage-1.8.0)

file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)

if(VCPKG_LIBRARY_LINKAGE STREQUAL static)
    file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/bin ${CURRENT_PACKAGES_DIR}/debug/bin)
endif()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)
