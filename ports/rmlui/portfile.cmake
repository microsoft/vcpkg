vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO mikke89/RmlUi
    REF ${VERSION}
    SHA512 46a8fef450ab6eaf6d4d6a2fff9b23dbe5a7ae81720cfa29f116f9454daca5fe80bef0b9981e037e6a42718a21361a0ca2380d0ebe33bf5e744aeecc033724b5
    HEAD_REF master
    PATCHES
        add-robin-hood.patch
        skip-custom-find-modules.patch
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        lua             RMLUI_LUA_BINDINGS
        svg             RMLUI_SVG_PLUGIN
)

if("freetype" IN_LIST FEATURES)
    set(RMLUI_FONT_ENGINE "freetype")
else()
    set(RMLUI_FONT_ENGINE "none")
endif()

# Remove built-in header, instead we use vcpkg version (from robin-hood-hashing port)
file(REMOVE "${SOURCE_PATH}/Include/RmlUi/Core/Containers/robin_hood.h")

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
    "${SOURCE_PATH}/Include/RmlUi/Core/Containers/LICENSE.txt"
    "${SOURCE_PATH}/Source/Debugger/LICENSE.txt"
)
