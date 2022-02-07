if(VCPKG_TARGET_IS_WINDOWS)
    vcpkg_check_linkage(ONLY_DYNAMIC_LIBRARY)
endif()

if(VCPKG_TARGET_IS_LINUX AND NOT EXISTS "/usr/share/doc/libgles2/copyright")
    message(STATUS "libgles2-mesa-dev must be installed before libepoxy can build. Install it with \"apt-get install libgles2-mesa-dev\".")
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO anholt/libepoxy
    REF 1.5.9
    SHA512 2b7c269063dc1c156c1a2a525e27a0a323baaa7fa4ac091536e4cc5fc4c247efe9770d7979dbddb54deb14853008bb6f4d67fddd26d87cbd264eb1e6e65bc5a8
    HEAD_REF master
)

if (VCPKG_TARGET_IS_WINDOWS OR VCPKG_TARGET_IS_OSX)
    set(OPTIONS -Dglx=no -Degl=no -Dx11=false)
else()
    set(OPTIONS -Dglx=yes -Degl=yes -Dx11=true)
endif()
if(VCPKG_TARGET_IS_WINDOWS)
    list(APPEND OPTIONS -Dc_std=c99)
endif()

vcpkg_configure_meson(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        ${OPTIONS}
        -Dtests=false
)
vcpkg_install_meson()
vcpkg_copy_pdbs()

vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/share/pkgconfig")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share/pkgconfig")

file(INSTALL "${SOURCE_PATH}/COPYING" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
