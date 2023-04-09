vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO kode54/dumb
    REF "${VERSION}"
    SHA512 18b10a507d69a754cdf97fbeae41c17f211a6ba1f166a822276bdb6769d3edc326919067a3f4d1247d6715d7a5a8276669d83b9427e7336c6d111593fb7e36cf
    HEAD_REF master
    PATCHES
        "export-unofficial-target.patch"
        "check-for-math-lib.patch"
        "do-not-overwrite-cflags.patch"
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DBUILD_EXAMPLES=OFF
        -DBUILD_ALLEGRO4=OFF
)

vcpkg_cmake_install()
vcpkg_fixup_pkgconfig()
vcpkg_copy_pdbs()

vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/lib/pkgconfig/dumb.pc" "libdumb" "dumb")
if(NOT VCPKG_BUILD_TYPE)
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig/dumb.pc" "libdumb" "dumbd")
endif()

if(VCPKG_TARGET_IS_WINDOWS)
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/lib/pkgconfig/dumb.pc" "-lm" "")
    if(NOT VCPKG_BUILD_TYPE)
        vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig/dumb.pc" "-lm" "")
    endif()
endif()

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/unofficial-dumb-config.cmake" DESTINATION "${CURRENT_PACKAGES_DIR}/share/unofficial-dumb")
vcpkg_cmake_config_fixup(CONFIG_PATH share/unofficial-dumb PACKAGE_NAME unofficial-dumb)

file(REMOVE_RECURSE 
    "${CURRENT_PACKAGES_DIR}/debug/include"
    "${CURRENT_PACKAGES_DIR}/debug/share"
)

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
