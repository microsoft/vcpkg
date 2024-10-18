vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO thorvg/thorvg
    REF "v${VERSION}"
    SHA512 1f92ac37d537399cc0792f36d92c6ddfd0c0c036072f1058d8805690f5eaf2f3d7b02e6b35eacf3e3db607e321ccae30defc0f69d9775cfcd55259d7a22e6820
    HEAD_REF master
)

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    list(APPEND BUILD_OPTIONS -Dstatic=true)
else()
    list(APPEND BUILD_OPTIONS -Dstatic=false)
endif()

if ("tools" IN_LIST FEATURES)
    list(APPEND BUILD_OPTIONS -Dtools=all)
endif()

vcpkg_configure_meson(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        ${BUILD_OPTIONS}
        # see ${SOURCE_PATH}/meson_options.txt
        -Dengines=['sw']
        -Dloaders=all
        -Dsavers=all
        -Dsimd=false # The reason for setting 'Dsimd=false' was that the creator said a false setting was necessary
        -Dbindings=capi
        -Dtests=false
        -Dexamples=false
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

if ("tools" IN_LIST FEATURES)
    vcpkg_copy_tools(TOOL_NAMES svg2tvg svg2png lottie2gif AUTO_CLEAN)
endif()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
