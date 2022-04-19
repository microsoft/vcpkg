if (VCPKG_TARGET_IS_WINDOWS)
    vcpkg_check_linkage(ONLY_DYNAMIC_LIBRARY)
endif()

vcpkg_from_gitlab(
    GITLAB_URL https://gitlab.gnome.org
    OUT_SOURCE_PATH SOURCE_PATH
    REPO GNOME/atkmm
    REF 2.36.1
    SHA512 524509b2dd1820836aaac077dc10b00909dd512cb8a09c98fbed0f40ee8021d8140cba7f59de75801af128760d6cb700299f704699bbb0fd696afaf5830258a3
    HEAD_REF master
)

vcpkg_configure_meson(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -Dbuild-documentation=false
        -Dmaintainer-mode=true
        -Dbuild-deprecated-api=true # Build deprecated API and include it in the library
        -Dmsvc14x-parallel-installable=false # Use separate DLL and LIB filenames for Visual Studio 2017 and 2019
)
vcpkg_install_meson()

vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
file(INSTALL ${SOURCE_PATH}/COPYING DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
