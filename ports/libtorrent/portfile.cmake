vcpkg_fail_port_install(ON_TARGET "uwp")

if(VCPKG_TARGET_IS_WINDOWS)
    # Building python bindings is currently broken on Windows
    if("python" IN_LIST FEATURES)
        message(FATAL_ERROR "The python feature is currently broken on Windows")
    endif()

    if(NOT "iconv" IN_LIST FEATURES)
        # prevent picking up libiconv if it happens to already be installed
        set(ICONV_PATCH "no_use_iconv.patch")
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
    REF e3f2b016dcd37a9a6e8a94006c7befcf2cb7bfac #v1.2.12
    SHA512 5d58ce1d942d2bbcc423a307e70cfb714b102e029c50c7e214e6b46b7a1311564c7b094d895d99f400ecdb0272b66c94c2f21fa414d4565582784f1dc5c7ec97
    HEAD_REF RC_1_2
    PATCHES
        ${ICONV_PATCH}
        fix-AppleClang-test.patch
)

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
