vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO mikke89/RmlUi
    REF ${VERSION}
    SHA512 44a336f1d1d17a71ffccf7456b44c76b9d5e590159f534a62e26378933cdcb4b78bdf5b0f9e9c3a7185c767accde1439f3cc6179b72a4c9901e36d738903a7f1
    HEAD_REF master
    PATCHES
        add-itlib-and-robin-hood.patch
        skip-custom-find-modules.patch
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        lua             RMLUI_LUA_BINDINGS
        svg             RMLUI_SVG_PLUGIN
        lottie          RMLUI_LOTTIE_PLUGIN
)

if("freetype" IN_LIST FEATURES)
    set(RMLUI_FONT_ENGINE "freetype")
else()
    set(RMLUI_FONT_ENGINE "none")
endif()

# Remove built-in third-party dependencies (itlib and robin-hood), instead we use vcpkg ports.
file(REMOVE_RECURSE "${SOURCE_PATH}/Include/RmlUi/Core/Containers")

vcpkg_cmake_configure(
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS
        ${FEATURE_OPTIONS}
        "-DRMLUI_FONT_ENGINE=${RMLUI_FONT_ENGINE}"
        "-DRMLUI_COMPILER_OPTIONS=OFF"
        "-DRMLUI_INSTALL_RUNTIME_DEPENDENCIES=OFF"
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/RmlUi)
vcpkg_copy_pdbs()

file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/debug/include"
    "${CURRENT_PACKAGES_DIR}/debug/share"
)

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/RmlUi/Core/Header.h"
        "#if !defined RMLUI_STATIC_LIB"
        "#if 0"
    )
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/RmlUi/Debugger/Header.h"
        "#if !defined RMLUI_STATIC_LIB"
        "#if 0"
    )
    if ("lua" IN_LIST FEATURES)
        vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/RmlUi/Lua/Header.h"
            "#if !defined RMLUI_STATIC_LIB"
            "#if 0"
        )
    endif()
endif()

configure_file("${CMAKE_CURRENT_LIST_DIR}/usage" "${CURRENT_PACKAGES_DIR}/share/${PORT}/usage" COPYONLY)
vcpkg_install_copyright(
    FILE_LIST
    "${SOURCE_PATH}/LICENSE.txt"
    "${SOURCE_PATH}/Source/Debugger/LICENSE.txt"
)
