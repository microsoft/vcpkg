vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO thorvg/thorvg
    REF v0.9.0
    SHA512 c0294a60f0b2e432bec62e1c44f0cb632420ec5c9390df210c8b8db5507fa8f5946bdc8a7879007e4e54865dc4538f4bf1e26d76f90a324cc5edd5cdf61c0fc0
    HEAD_REF master
    PATCHES
        install-tools.patch
)

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    list(APPEND BUILD_OPTIONS -Dstatic=true)
else()
    list(APPEND BUILD_OPTIONS -Dstatic=false)
endif()

if ("tools" IN_LIST FEATURES)
    if(VCPKG_TARGET_IS_WINDOWS)
        message(FATAL_ERROR "This feature doesn't support Windows platform")
    endif()
    list(APPEND BUILD_OPTIONS -Dtools=all)
endif()

vcpkg_configure_meson(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        ${BUILD_OPTIONS}
        # see ${SOURCE_PATH}/meson_options.txt
        -Dengines=sw
        -Dloaders=all
        -Dsavers=tvg
        -Dvector=true
        -Dbindings=capi
        -Dtests=false
        -Dexamples=false
    OPTIONS_DEBUG
        -Dlog=true
        -Dbindir=${CURRENT_PACKAGES_DIR}/debug/bin
    OPTIONS_RELEASE
        -Dbindir=${CURRENT_PACKAGES_DIR}/bin
)
vcpkg_install_meson()
vcpkg_fixup_pkgconfig()

if ("tools" IN_LIST FEATURES)
    vcpkg_copy_tools(TOOL_NAMES svg2tvg svg2png AUTO_CLEAN)
endif()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
