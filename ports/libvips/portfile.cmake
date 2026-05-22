
#set(VCPKG_USE_HEAD_VERSION TRUE)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO libvips/libvips
    REF v${VERSION}
    SHA512 6861bc7a65137817613448c2e5e44def7845e5537d68e43d245bf3b45eb0fad7ea297bc3864905ae4e33dbf11bc21ec6f76626ff92d15ee1aac6959768fbd256
    HEAD_REF master
)

vcpkg_add_to_path("${CURRENT_HOST_INSTALLED_DIR}/tools/glib/")

# Derive Meson feature/boolean options directly from upstream meson_options.txt
# so this port tracks new/removed options automatically.
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

if(MESON_FEATURE_OPTIONS STREQUAL "")
    message(FATAL_ERROR "Failed to parse Meson feature options from ${SOURCE_PATH}/meson_options.txt")
endif()

file(STRINGS "${CURRENT_PORT_DIR}/meson_options.snapshot.txt" _meson_option_snapshot)
set(_meson_option_snapshot_actual)

foreach(_feature_option IN LISTS MESON_FEATURE_OPTIONS)
    list(APPEND _meson_option_snapshot_actual "feature:${_feature_option}")
endforeach()

foreach(_boolean_option IN LISTS MESON_BOOLEAN_OPTIONS)
    list(APPEND _meson_option_snapshot_actual "boolean:${_boolean_option}")
endforeach()

list(SORT _meson_option_snapshot)
list(SORT _meson_option_snapshot_actual)

string(JOIN "\n" _meson_option_snapshot_text ${_meson_option_snapshot})
string(JOIN "\n" _meson_option_snapshot_actual_text ${_meson_option_snapshot_actual})

if(NOT _meson_option_snapshot_text STREQUAL _meson_option_snapshot_actual_text)
    set(_snapshot_only)
    foreach(_entry IN LISTS _meson_option_snapshot)
        if(NOT _entry IN_LIST _meson_option_snapshot_actual)
            list(APPEND _snapshot_only "${_entry}")
        endif()
    endforeach()

    set(_actual_only)
    foreach(_entry IN LISTS _meson_option_snapshot_actual)
        if(NOT _entry IN_LIST _meson_option_snapshot)
            list(APPEND _actual_only "${_entry}")
        endif()
    endforeach()

    if(_snapshot_only STREQUAL "")
        set(_snapshot_only_text "<none>")
    else()
        string(JOIN "\n  " _snapshot_only_text ${_snapshot_only})
    endif()

    if(_actual_only STREQUAL "")
        set(_actual_only_text "<none>")
    else()
        string(JOIN "\n  " _actual_only_text ${_actual_only})
    endif()

    message(FATAL_ERROR
        "Meson option snapshot drift detected in ${CURRENT_PORT_DIR}/meson_options.snapshot.txt.\n"
        "Update the snapshot if upstream meson_options.txt changed.\n"
        "\n"
        "Removed since snapshot (present in snapshot only):\n"
        "  ${_snapshot_only_text}\n"
        "\n"
        "Added since snapshot (present in upstream meson_options.txt only):\n"
        "  ${_actual_only_text}"
    )
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

unset(_meson_option_lines)
unset(_current_option_name)
unset(_current_option_type)
unset(_line)

# Configure Meson options that are not feature/boolean toggles via vcpkg features.
set(_magick_package "MagickCore")
if("magick-package-graphicsmagick" IN_LIST FEATURES)
    set(_magick_package "GraphicsMagick")
endif()

set(_magick_features "load,save")
if("magick-features-load-only" IN_LIST FEATURES AND "magick-features-save-only" IN_LIST FEATURES)
    message(FATAL_ERROR "Features 'magick-features-load-only' and 'magick-features-save-only' are mutually exclusive")
elseif("magick-features-load-only" IN_LIST FEATURES)
    set(_magick_features "load")
elseif("magick-features-save-only" IN_LIST FEATURES)
    set(_magick_features "save")
endif()

set(_nifti_prefix_dir "")
if("nifti-prefix-installed" IN_LIST FEATURES)
    set(_nifti_prefix_dir "${CURRENT_INSTALLED_DIR}")
endif()

set(_fuzzing_engine "none")
if("fuzzing-libfuzzer" IN_LIST FEATURES AND "fuzzing-oss-fuzz" IN_LIST FEATURES)
    message(FATAL_ERROR "Features 'fuzzing-libfuzzer' and 'fuzzing-oss-fuzz' are mutually exclusive")
elseif("fuzzing-libfuzzer" IN_LIST FEATURES)
    set(_fuzzing_engine "libfuzzer")
elseif("fuzzing-oss-fuzz" IN_LIST FEATURES)
    set(_fuzzing_engine "oss-fuzz")
endif()

list(APPEND OPTIONS
    -Dmagick-package=${_magick_package}
    -Dmagick-features=${_magick_features}
    -Dnifti-prefix-dir=${_nifti_prefix_dir}
    -Dfuzzing_engine=${_fuzzing_engine}
)

unset(_magick_package)
unset(_magick_features)
unset(_nifti_prefix_dir)
unset(_fuzzing_engine)

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
