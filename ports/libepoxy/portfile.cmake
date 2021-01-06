vcpkg_check_linkage(ONLY_DYNAMIC_LIBRARY)

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
    set(OPTIONS -Denable-glx=no -Denable-egl=no -Denable-x11=no -Dc_std=c99)
else()
    set(OPTIONS -Denable-glx=yes -Denable-egl=yes -Denable-x11=yes -Dc_std=gnu99)
endif()

vcpkg_configure_meson(
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS ${OPTIONS}
)
vcpkg_install_meson()
vcpkg_copy_pdbs()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/share/pkgconfig)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share/pkgconfig)

file(INSTALL ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
