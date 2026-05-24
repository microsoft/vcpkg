vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO libproxy/libproxy
    REF "${VERSION}"
    SHA512 19ffd1755e9ebfc645555e248020f9025ae81e93e73cbbb2583bff4495f7794b02ab1ef8ce944fa28e7604f5abf3e7e327c4966d21789648bd38f3d1c2cccecd
    HEAD_REF master
    PATCHES
        remove-gsettings-schema-check.patch
)

vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

if(VCPKG_TARGET_IS_WINDOWS AND NOT VCPKG_TARGET_IS_MINGW)
    vcpkg_apply_patches(
        SOURCE_PATH "${SOURCE_PATH}"
        PATCHES
            "${CMAKE_CURRENT_LIST_DIR}/fix-msvc.patch"
    )
    file(COPY "${CMAKE_CURRENT_LIST_DIR}/msvc_support.h" DESTINATION "${SOURCE_PATH}")
endif()


string(COMPARE EQUAL "${VCPKG_CRT_LINKAGE}" "static" STATICCRT)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        curl          curl
        introspection introspection
        vala          vapi
        duktape       pacrunner-duktape
        tests         tests
)

set(ADDITIONAL_BINARIES "")
if("introspection" IN_LIST FEATURES)
    vcpkg_get_gobject_introspection_programs(PYTHON3 GIR_COMPILER GIR_SCANNER)
    list(APPEND ADDITIONAL_BINARIES
        "python='${PYTHON3}'"
        "g-ir-compiler='${GIR_COMPILER}'"
        "g-ir-scanner='${GIR_SCANNER}'"
    )
endif()

# Convert FEATURE_OPTIONS from "feature=ON/OFF" to "feature=true/false"
vcpkg_list(SET FINAL_OPTIONS)
foreach(_option IN LISTS FEATURE_OPTIONS)
    string(REPLACE "=ON" "=true" _option "${_option}")
    string(REPLACE "=OFF" "=false" _option "${_option}")
    vcpkg_list(APPEND FINAL_OPTIONS "${_option}")
endforeach()


macro(set_bool_val VAR COND)
    if(${COND})
        set(${VAR} "true")
    else()
        set(${VAR} "false")
    endif()
endmacro()

set_bool_val(CONF_WIN VCPKG_TARGET_IS_WINDOWS)
set_bool_val(CONF_OSX VCPKG_TARGET_IS_OSX)
set_bool_val(CONF_LIN VCPKG_TARGET_IS_LINUX)

vcpkg_configure_meson(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        ${FINAL_OPTIONS}
        -Ddocs=false
        -Drelease=true
        -Dconfig-windows=${CONF_WIN}
        -Dconfig-osx=${CONF_OSX}
        -Dconfig-gnome=${CONF_LIN}
        -Dconfig-kde=${CONF_LIN}
        -Dconfig-xdp=${CONF_LIN}
        -Dconfig-env=true
        -Dconfig-sysconfig=${CONF_LIN}
    OPTIONS_DEBUG
        -Dintrospection=false
        -Dvapi=false
    ADDITIONAL_BINARIES
        ${ADDITIONAL_BINARIES}
)

vcpkg_install_meson()
vcpkg_fixup_pkgconfig()

vcpkg_copy_tools(TOOL_NAMES proxy AUTO_CLEAN)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include" "${CURRENT_PACKAGES_DIR}/debug/share")
if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/bin" "${CURRENT_PACKAGES_DIR}/debug/bin")
endif()
file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/COPYING")
