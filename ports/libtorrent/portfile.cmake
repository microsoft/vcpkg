if(VCPKG_TARGET_IS_WINDOWS)
    # Building python bindings is currently broken on Windows
    if("python" IN_LIST FEATURES)
        message(FATAL_ERROR "The python feature is currently broken on Windows")
    endif()
    if(VCPKG_CRT_LINKAGE STREQUAL "static")
        set(_static_runtime ON)
    endif()
endif()

vcpkg_check_features(
    OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        deprfun     deprecated-functions
        examples    build_examples
        iconv       iconv
        python      python-bindings
        test        build_tests
        tools       build_tools
)

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
        REF 64817e0e8793d0875fc10245de52ffb2540a223d # v2.0.8
        SHA512 607172e6a806d78bb34443101bd384ac7a42e0edc3e7c4a2cf5c3ab5f2be64f84557726dce16c2fbaaa2ba254529a8871b3123b0e79fe87cd5bf26021ecb59da
        HEAD_REF RC_2_0
)

vcpkg_from_github(
        OUT_SOURCE_PATH TRYSIGNAL_SOURCE_PATH
        REPO arvidn/try_signal
        REF 105cce59972f925a33aa6b1c3109e4cd3caf583d #2022-10-27
        SHA512 4a0090755831e0e4a1930817345fa5934144421d9a9d710fe8ed3712233fa2fa037fc0e0d4f88b7cc8fb1bc05fe2d55372af1ff47d6fbf5208e03f45f2a424e4
        HEAD_REF master
)

vcpkg_from_github(
        OUT_SOURCE_PATH ASIO_GNUTLS_SOURCE_PATH
        REPO paullouisageneau/boost-asio-gnutls
        REF a57d4d36923c5fafa9698e14be16b8bc2913700a
        SHA512 1e093dd4e999cce9c6d74f1d4c2d20f73512258b83505c307c7d53b8c7ed15626a8e90c8e6a6280827aafa069bc233c0c6f4c9276f1c332e4b141c7c350c47c0
        HEAD_REF master
)

vcpkg_from_github(
        OUT_SOURCE_PATH LIB_SIMULATOR_SOURCE_PATH
        REPO arvidn/libsimulator
        REF 39144efe83fcd38778cf76fc609e3475694642ca #2022-10-27
        SHA512 a021f769d52d127355ecaceaf912bf3e86aaa256d4768d270fbe6066793b6159eddecd0262f3f2158602f883d49b3aac39eb79be5399212cdd7711f921ffa15a
        HEAD_REF master
)

file(COPY ${TRYSIGNAL_SOURCE_PATH}/ DESTINATION ${SOURCE_PATH}/deps/try_signal)
file(COPY ${ASIO_GNUTLS_SOURCE_PATH}/ DESTINATION ${SOURCE_PATH}/deps/asio-gnutls)
file(COPY ${LIB_SIMULATOR_SOURCE_PATH}/ DESTINATION ${SOURCE_PATH}/simulation/libsimulator)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
       ${FEATURE_OPTIONS}
       -Dboost-python-module-name=${_boost-python-module-name}
       -Dstatic_runtime=${_static_runtime}
       -DPython3_USE_STATIC_LIBS=ON
)


vcpkg_cmake_install()

vcpkg_cmake_config_fixup(PACKAGE_NAME LibtorrentRasterbar CONFIG_PATH lib/cmake/LibtorrentRasterbar)

# Handle copyright
file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)

# Do not duplicate include files
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include" "${CURRENT_PACKAGES_DIR}/debug/share" "${CURRENT_PACKAGES_DIR}/share/cmake")

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
       file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/bin" "${CURRENT_PACKAGES_DIR}/debug/bin")
endif()

vcpkg_fixup_pkgconfig()