vcpkg_fail_port_install(ON_TARGET "uwp")

if(VCPKG_TARGET_IS_WINDOWS)
    # Building python bindings is currently broken on Windows
    if("python" IN_LIST FEATURES)
        message(FATAL_ERROR "The python feature is currently broken on Windows")
    endif()

    if("iconv" IN_LIST FEATURES)
        set(ICONV_PATCH "fix_find_iconv.patch")
    endif()

    if(VCPKG_CRT_LINKAGE STREQUAL "static")
        set(_static_runtime ON)
    endif()
endif()

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    deprfun     deprecated-functions
    examples    build_examples
    python      python-bindings
    test        build_tests
    tools       build_tools
)

# Note: the python feature currently requires `python3-dev` and `python3-setuptools` installed on the system
if("python" IN_LIST FEATURES)
    vcpkg_find_acquire_program(PYTHON3)
    get_filename_component(PYTHON3_PATH ${PYTHON3} DIRECTORY)
    vcpkg_add_to_path(${PYTHON3_PATH})

    file(GLOB BOOST_PYTHON_LIB "${CURRENT_INSTALLED_DIR}/lib/*boost_python*")
    string(REGEX REPLACE ".*(python)([0-9])([0-9]+).*" "\\1\\2\\3" _boost-python-module-name "${BOOST_PYTHON_LIB}")
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO arvidn/libtorrent
    REF 0f0afec8c8025cb55dfd2f36612d4bf61a29ff8a #v 2.0.0
    SHA512 251ee5a2c555103a127b8b08995914639a2b9d448a87708edb08a2a11444ef999cd8a3abcf223acfc66ca6371f0e1b076589343ade73974aa87f50814431a875
    HEAD_REF RC_1_2
    PATCHES
        ${ICONV_PATCH}
)

set(COMMIT_HASH 2a99893f92b29a5948569cba1e16fd259dbc2016)

# Get try_signal for libtorrent
vcpkg_from_github(
    OUT_SOURCE_PATH TRY_SIGNAL_SOURCE_PATH
    REPO arvidn/try_signal
    REF 2a99893f92b29a5948569cba1e16fd259dbc2016 
    SHA512 b62b3176980c31c9faa0c5cdd14832e9864a6d86af02ae6d5ef510fade2daf649819bc928c12037fa0ef551813745b347d4927cb4b67b34beb822a707c03d870
)

# Copy try_signal sources
foreach(SOURCE_FILE ${SOURCE_PATH})
    file(COPY ${TRY_SIGNAL_SOURCE_PATH} DESTINATION "${SOURCE_PATH}/deps")
endforeach()

file(REMOVE_RECURSE ${SOURCE_PATH}/deps/try_signal)
file(RENAME ${SOURCE_PATH}/deps/259dbc2016-bb7f150248.clean ${SOURCE_PATH}/deps/try_signal)
file(REMOVE_RECURSE ${TRY_SIGNAL_SOURCE_PATH})

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA # Disable this option if project cannot be built with Ninja
    OPTIONS
        ${FEATURE_OPTIONS}
        -Dboost-python-module-name=${_boost-python-module-name}
        -Dstatic_runtime=${_static_runtime}
        -DPython3_USE_STATIC_LIBS=ON
)

vcpkg_install_cmake()

vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/LibtorrentRasterbar TARGET_PATH share/LibtorrentRasterbar)

# Handle copyright
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)

# Do not duplicate include files
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include ${CURRENT_PACKAGES_DIR}/debug/share ${CURRENT_PACKAGES_DIR}/share/cmake)
