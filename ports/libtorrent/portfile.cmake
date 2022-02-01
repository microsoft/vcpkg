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
        REF 44e285c30f06772e48f515580f961998e1037b7e # v2.0.5
        SHA512 c7ce747930ab8c1852d0efdc6268d9faa39643abd6b6560b4b5e0b06a12ab207ec61ac301a0bcc7622521a8ae490cc02cbe0b6e43208bc216c08bf472b40cb85
        HEAD_REF RC_2_0
)

vcpkg_from_github(
        OUT_SOURCE_PATH TRYSIGNAL_SOURCE_PATH
        REPO arvidn/try_signal
        REF 334fd139e2bb387017b42d36753a03935e3bca75
        SHA512 a25d439b2d979e975f9dd125a34072f70bfc7a08fab950e3829130742c05c584ae88d9f58fc0f1b4fa0b51df2c0e32c5b24c5828d53b121b4bc183a4c68d6a5a
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
        REF 64fb5b4fde1879abc09c018604d57e485a12e999
        SHA512 20b57eb436127028339528f34a9db7e7149d2c5d86149114444205370482d3f5284e76493f2fbc1c6904175e6482671bfcaeb98d0bee7d399e546abef02f32f3
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