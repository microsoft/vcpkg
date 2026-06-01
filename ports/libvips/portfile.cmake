#temporarily enabling head because windows fails to build with 8.18.2
set(VCPKG_USE_HEAD_VERSION TRUE)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO libvips/libvips
    REF v${VERSION}
    SHA512 6861bc7a65137817613448c2e5e44def7845e5537d68e43d245bf3b45eb0fad7ea297bc3864905ae4e33dbf11bc21ec6f76626ff92d15ee1aac6959768fbd256
    HEAD_REF master
)

vcpkg_add_to_path("${CURRENT_HOST_INSTALLED_DIR}/tools/glib/")

# Derive Meson feature/boolean options directly from upstream meson_options.txt
# so we can disable any default features, as vcpkg is opt-in as default.
file(STRINGS "${SOURCE_PATH}/meson_options.txt" _meson_option_lines)

set(MESON_FEATURE_OPTIONS)
set(MESON_BOOLEAN_OPTIONS)
set(_current_option_name "")
set(_current_option_type "")

foreach(_line IN LISTS _meson_option_lines)
    string(STRIP "${_line}" _line)

    if(_line MATCHES "^option\\('([^']+)'")
        set(_current_option_name "${CMAKE_MATCH_1}")
        set(_current_option_type "")
    elseif(NOT _current_option_name STREQUAL "" AND _line MATCHES "^type:[ ]*'([^']+)'")
        set(_current_option_type "${CMAKE_MATCH_1}")

        if(_current_option_type STREQUAL "feature")
            list(APPEND MESON_FEATURE_OPTIONS "${_current_option_name}")
        elseif(_current_option_type STREQUAL "boolean")
            list(APPEND MESON_BOOLEAN_OPTIONS "${_current_option_name}")
        endif()
    elseif(NOT _current_option_name STREQUAL "" AND _line STREQUAL ")")
        set(_current_option_name "")
        set(_current_option_type "")
    endif()
endforeach()

if(MESON_FEATURE_OPTIONS STREQUAL "" AND MESON_BOOLEAN_OPTIONS STREQUAL "")
    message(FATAL_ERROR "Failed to parse Meson feature options from ${SOURCE_PATH}/meson_options.txt")
endif()

set(OPTIONS)
foreach(meson_option IN LISTS MESON_FEATURE_OPTIONS)
    if("${meson_option}" IN_LIST FEATURES)
        list(APPEND OPTIONS -D${meson_option}=enabled)
    else()
        list(APPEND OPTIONS -D${meson_option}=disabled)
    endif()
endforeach()

foreach(boolean_option IN LISTS MESON_BOOLEAN_OPTIONS)
    if("${boolean_option}" IN_LIST FEATURES)
        list(APPEND OPTIONS -D${boolean_option}=true)
    else()
        list(APPEND OPTIONS -D${boolean_option}=false)
    endif()
endforeach()

vcpkg_configure_meson(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS ${OPTIONS}
)

vcpkg_install_meson()
vcpkg_copy_pdbs()
vcpkg_fixup_pkgconfig()

if("tools" IN_LIST FEATURES)
	vcpkg_copy_tools(
		TOOL_NAMES
			vips
			vipsedit
			vipsheader
			vipsthumbnail
		AUTO_CLEAN
	)
endif()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
