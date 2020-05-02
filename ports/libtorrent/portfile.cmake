vcpkg_fail_port_install(ON_TARGET "uwp")

if(VCPKG_TARGET_IS_WINDOWS)
    # Building python bindings is currently broken on Windows
    if("python" IN_LIST FEATURES)
        message(FATAL_ERROR "The python feature is currently broken on Windows")
    endif()

    # Ensure OPENSSL_USE_STATIC_LIBS is set to ON
    # when statically linking against OpenSSL on Windows.
    # Also ensure "static_runtime" will be used when statically linking against the runtime.
    # Prevents OpenSSL crypt32.lib linking errors.
    if(VCPKG_CRT_LINKAGE STREQUAL "static")
        set(LIBTORRENT_STATIC_RUNTIME ON)
    elseif(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
        set(_OPENSSL_USE_STATIC_LIBS ON)
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
    string(REGEX REPLACE ".*(python)([0-9])([0-9]+).*" "\\1\\2\\3" BOOST_PYTHON_MODULE "${BOOST_PYTHON_LIB}")
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO arvidn/libtorrent
    REF libtorrent-1_2_6
    SHA512 9f03e28449b08e18a98a1f1bf0571f470c56fabd2becde5bde56ad566611c8519b0b387939f285a552d1f0382446633b67d00b6b5ff7083e4d1420a3ce9232fc
    HEAD_REF master
    PATCHES
        add-datetime-to-boost-libs.patch
        fix_python_cmake.patch
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA # Disable this option if project cannot be built with Ninja
    OPTIONS
        ${FEATURE_OPTIONS}
        -Dboost-python-module-name=${BOOST_PYTHON_MODULE}
        -Dstatic_runtime=${LIBTORRENT_STATIC_RUNTIME}
        -DOPENSSL_USE_STATIC_LIBS=${_OPENSSL_USE_STATIC_LIBS}
        -DPython3_USE_STATIC_LIBS=ON
)

vcpkg_install_cmake()

file(READ ${CURRENT_PACKAGES_DIR}/include/libtorrent/aux_/export.hpp EXPORT_H)
string(REPLACE "defined TORRENT_BUILDING_SHARED" "0" EXPORT_H "${EXPORT_H}")
if (VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic")
    string(REPLACE "defined TORRENT_LINKING_SHARED" "1" EXPORT_H "${EXPORT_H}")
else()
    string(REPLACE "defined TORRENT_LINKING_SHARED" "0" EXPORT_H "${EXPORT_H}")
endif()
file(WRITE ${CURRENT_PACKAGES_DIR}/include/libtorrent/aux_/export.hpp "${EXPORT_H}")

vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/LibtorrentRasterbar TARGET_PATH share/libtorrentrasterbar)

# Handle copyright
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)

# Do not duplicate include files
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include ${CURRENT_PACKAGES_DIR}/debug/share ${CURRENT_PACKAGES_DIR}/share/cmake)
