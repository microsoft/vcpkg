if(VCPKG_TARGET_IS_WINDOWS)
    vcpkg_check_linkage(ONLY_DYNAMIC_LIBRARY)
endif()

if(VCPKG_TARGET_IS_LINUX AND NOT EXISTS "/usr/share/doc/libgles2/copyright")
    message(STATUS "libgles2-mesa-dev must be installed before libepoxy can build. Install it with \"apt-get install libgles2-mesa-dev\".")
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO anholt/libepoxy
    REF 1.5.5
    SHA512 9056840d887f06c6422f61e65ea02511ed37b866a234d49bf78dc5f2f46e8dd9f029405387da14dced639e6a5740b5c56ab6d88ca23ea3270fc6db6a570b0c45
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
    SOURCE_PATH ${SOURCE_PATH}
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
