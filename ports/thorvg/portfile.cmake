vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO thorvg/thorvg
    REF "v${VERSION}"
    SHA512 cfae7b94d2f56fe133687ce1ef5b4f91dd6b052ce93cee822e55e3fdda19ab8ce616cc1b18c240cf0db7137e5de0a001f19a313bb649a71a64d109a589e699b6
    HEAD_REF master
)

if ("tools" IN_LIST FEATURES)
    list(APPEND BUILD_OPTIONS -Dtools=all)
endif()

vcpkg_configure_meson(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        ${BUILD_OPTIONS}
        # see ${SOURCE_PATH}/meson_options.txt
        -Dstatic=true # Use static modules
        -Dengines=['cpu']
        -Dloaders=all
        -Dsavers=all
        -Dsimd=true
        -Dbindings=capi
        -Dtests=false
        -Dstrip=false
        -Dextra=['']
    OPTIONS_DEBUG
        -Dlog=true
        -Dbindir=${CURRENT_PACKAGES_DIR}/debug/bin
    OPTIONS_RELEASE
        -Dbindir=${CURRENT_PACKAGES_DIR}/bin
)
vcpkg_install_meson()
vcpkg_fixup_pkgconfig()

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/thorvg-1/thorvg.h" "#ifndef TVG_STATIC" "#if 0")
else()
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/thorvg-1/thorvg.h" "#ifndef TVG_STATIC" "#if 1")
endif()

if ("tools" IN_LIST FEATURES)
    vcpkg_copy_tools(TOOL_NAMES tvg-svg2png tvg-lottie2gif AUTO_CLEAN)
endif()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
