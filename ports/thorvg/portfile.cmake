vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO thorvg/thorvg
    REF v0.8.4
    SHA512 8e885a8c56efb129fb3ab90b9a7b765b84f5f520a9c7a5c92af4ffe61bac1b928165801b64ebc7db77046e1aaf2918ed0ffdf98cb9572dc6d46ed6de3f96b9b7
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
