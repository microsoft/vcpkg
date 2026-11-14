set(EXTRA_PATCHES "")
if(VCPKG_TARGET_IS_UWP)
    list(APPEND EXTRA_PATCHES build-uwp.patch)
endif()

vcpkg_from_sourceforge(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO lame/lame
    REF ${VERSION}
    FILENAME "lame-${VERSION}.tar.gz"
    SHA512 70fa51fe84dd499d171ebf6c05ec82399eb8b0148fb4c08470a61efe9cf826474132ee98166dc63ee5c3646b2c8e955680e4306dd26f590b7810732ab486dd8b
    PATCHES
        add-macos-universal-config.patch
        add-msvc-arm.patch
        fix-pkgconfig.patch
        msvc-find-mpg123.patch
        ${EXTRA_PATCHES}
)

if(VCPKG_TARGET_IS_WINDOWS AND NOT VCPKG_TARGET_IS_MINGW)

    file(COPY "${CMAKE_CURRENT_LIST_DIR}/vs2019_arch_arm.props"
              "${CMAKE_CURRENT_LIST_DIR}/vs2019_arch_arm64.props"
         DESTINATION "${SOURCE_PATH}/vc_solution")

    if(VCPKG_TARGET_ARCHITECTURE STREQUAL "arm64")
        set(platform "ARM64")
    elseif(VCPKG_TARGET_ARCHITECTURE STREQUAL "arm")
        set(platform "ARM")
    elseif(VCPKG_TARGET_ARCHITECTURE STREQUAL "x64")
        set(platform "x64")
    else()
        set(platform "Win32")
    endif()

    if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
        vcpkg_msbuild_install(
            SOURCE_PATH "${SOURCE_PATH}"
            PROJECT_SUBPATH "vc_solution/vs2019_lame.sln"
            TARGET "libmp3lame-static"
            PLATFORM "${platform}"
        )
    else()
        vcpkg_msbuild_install(
            SOURCE_PATH "${SOURCE_PATH}"
            PROJECT_SUBPATH "vc_solution/vs2019_lame.sln"
            TARGET "libmp3lame"
            PLATFORM "${platform}"
        )
    endif()
    if("frontend" IN_LIST FEATURES)
        vcpkg_msbuild_install(
            SOURCE_PATH "${SOURCE_PATH}"
            PROJECT_SUBPATH "vc_solution/vs2019_lame.sln"
            TARGET "lame"
            PLATFORM "${platform}"
        )
    endif()

    file(COPY "${SOURCE_PATH}/include/lame.h" DESTINATION "${CURRENT_PACKAGES_DIR}/include/lame")

    if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
        file(REMOVE_RECURSE
            "${CURRENT_PACKAGES_DIR}/bin"
            "${CURRENT_PACKAGES_DIR}/lib/libmp3lame.lib"
            "${CURRENT_PACKAGES_DIR}/debug/bin"
            "${CURRENT_PACKAGES_DIR}/debug/lib/libmp3lame.lib"
        )
    else()
        file(REMOVE
            "${CURRENT_PACKAGES_DIR}/lib/libmp3lame-static.lib"
            "${CURRENT_PACKAGES_DIR}/lib/libmpghip-static.lib"
            "${CURRENT_PACKAGES_DIR}/debug/lib/libmp3lame-static.lib"
            "${CURRENT_PACKAGES_DIR}/debug/lib/libmpghip-static.lib"
        )
    endif()

else()

    vcpkg_list(SET OPTIONS)
    if("frontend" IN_LIST FEATURES)
        list(APPEND OPTIONS --enable-frontend)
    else()
        list(APPEND OPTIONS --disable-frontend)
    endif()

    if(NOT VCPKG_TARGET_IS_MINGW)
        list(APPEND OPTIONS --with-pic=yes)
    endif()

    vcpkg_make_configure(
        SOURCE_PATH "${SOURCE_PATH}"
        OPTIONS
            ${OPTIONS}
    )
    vcpkg_make_install()

    file(REMOVE_RECURSE
        "${CURRENT_PACKAGES_DIR}/debug/include"
        "${CURRENT_PACKAGES_DIR}/debug/share"
        "${CURRENT_PACKAGES_DIR}/share/${PORT}/doc"
        "${CURRENT_PACKAGES_DIR}/share/${PORT}/man1"
    )

    vcpkg_fixup_pkgconfig()

endif()

# unofficial, but port legacy
file(COPY "${CMAKE_CURRENT_LIST_DIR}/mp3lame-config.cmake" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/COPYING")
