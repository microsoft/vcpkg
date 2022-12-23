if (VCPKG_TARGET_IS_WINDOWS)
    vcpkg_check_linkage(ONLY_DYNAMIC_LIBRARY)
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO s-yata/marisa-trie
    REF 006020c1df76d0d7dc6118dacc22da64da2e35c4
    SHA512 05dd7cc81a6347d4528654c19617af16de8d7352ad9e38d5f1cd296d88527377ecbfed9dbe722362d64369cd792d1ae0410319854b546ce0b6081ac560a40c0f
    HEAD_REF master
)

if(VCPKG_TARGET_IS_WINDOWS AND NOT VCPKG_TARGET_IS_MINGW)
    vcpkg_install_msbuild(
        SOURCE_PATH "${SOURCE_PATH}"
        PROJECT_SUBPATH vs2019/vs2019.sln
        INCLUDES_SUBPATH include
        LICENSE_SUBPATH COPYING.md
        PLATFORM ${TRIPLET_SYSTEM_ARCH}
        ALLOW_ROOT_INCLUDES
    )
    vcpkg_clean_msbuild()
    set(prefix "${CURRENT_INSTALLED_DIR}")
    set(exec_prefix "\${prefix}")
    set(bindir "\${prefix}/bin")
    set(libdir "\${prefix}/lib")
    set(includedir "\${prefix}/include")
    configure_file("${SOURCE_PATH}/marisa.pc.in" "${CURRENT_PACKAGES_DIR}/lib/pkgconfig/marisa.pc" @ONLY)
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/lib/pkgconfig/marisa.pc" "-lmarisa" "-llibmarisa")
    if (NOT VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "debug")
        set(prefix "${CURRENT_INSTALLED_DIR}/debug")
        set(exec_prefix "\${prefix}")
        set(bindir "\${prefix}/bin")
        set(libdir "\${prefix}/lib")
        set(includedir "\${prefix}/include")
        configure_file("${SOURCE_PATH}/marisa.pc.in" "${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig/marisa.pc" @ONLY)
        vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig/marisa.pc" "-lmarisa" "-llibmarisa")
    endif()
else()
    vcpkg_configure_make(
        SOURCE_PATH "${SOURCE_PATH}"
        AUTOCONFIG
        COPY_SOURCE
    )
    vcpkg_install_make()
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
    file(INSTALL "${SOURCE_PATH}/COPYING.md" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
endif()

vcpkg_copy_pdbs()
vcpkg_fixup_pkgconfig()

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
