vcpkg_find_acquire_program(BISON)
get_filename_component(BISON_PATH ${BISON} DIRECTORY)
vcpkg_add_to_path(${BISON_PATH})

vcpkg_find_acquire_program(FLEX)
get_filename_component(FLEX_PATH ${FLEX} DIRECTORY)
vcpkg_add_to_path(${FLEX_PATH})

set(EXTRA_OPTIONS "")
if (VCPKG_CRT_LINKAGE="static")
    list(APPEND EXTRA_OPTIONS "-DBUILD_STATIC_LIBRARY=ON")
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO csound/csound
    REF "${VERSION}"
    SHA512 4ea4dccb36017c96482389a8d139f6f55c79c5ceb9cc34e6d2bfabcb930b4833d0301be4a4b21929db27b2d8ce30754b5c5867acd2ea5a849135e1b8d1506acf
    PATCHES
        "add-python-option.patch"
        "remove-alloca.patch"
        "error-on-warning-option.patch"
        "change-windows-plugin-folder.patch"
        "add-framework-option.patch"
        "cmake-exports.patch"
        "install-rpath.patch"
        "fix-include-directory.patch"
        "add-vcpkg-dependencies-option.patch"
        "add-dirent-to-ftsamplebank.patch"
        "link-plugins-to-csound.patch"
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
  FEATURES
    "portaudio" USE_PORTAUDIO
    "portmidi" USE_PORTMIDI
)

vcpkg_cmake_configure(SOURCE_PATH ${SOURCE_PATH}
    OPTIONS
        # bump to match libsndfile?
        -DCMAKE_OSX_DEPLOYMENT_TARGET="12.0"
        -DAPPLE_FRAMEWORK=OFF
        -DBUILD_CSBEATS=OFF # doesn't work
        -DBUILD_DSSI_OPCODES=OFF # TODO: feature?
        -DBUILD_JAVA_INTERFACE=OFF # TODO: feature?
        -DBUILD_LUA_INTERFACE=OFF # TODO: feature?
        -DBUILD_PYTHON_INTERFACE=OFF # TODO: feature?
        -DBUILD_OSC_OPCODES=OFF # TODO: feature?
        -DBUILD_UTILITIES=OFF # TODO: feature?
        -DDEBUG_ERROR_ON_WARNING=OFF
        -DUSE_ALSA=OFF # TODO: feature
        -DUSE_GETTEXT=OFF # TODO: feature?
        -DUSE_CURL=OFF # TODO: feature?
        -DUSE_JACK=OFF # TODO: feature?
        -DUSE_PULSEAUDIO=OFF # TODO: feature?
        -DUSE_VCPKG_DEPENDENCIES=ON
        ${EXTRA_OPTIONS}
        ${FEATURE_OPTIONS}
)
vcpkg_cmake_install()

if (NOT (VCPKG_TARGET_IS_OSX))
    vcpkg_copy_tools(TOOL_NAMES
        cs
        csb64enc
        csdebugger
        csound
        extract
        makecsd
        scot
        scsort
        sdif2ad
        AUTO_CLEAN
    )
endif()

vcpkg_cmake_config_fixup()

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/COPYING")

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/bin" "${CURRENT_PACKAGES_DIR}/debug/bin")
endif()

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")

