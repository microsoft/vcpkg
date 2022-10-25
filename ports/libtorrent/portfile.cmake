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
        REF 722d78250a30c89c92970a78be970269a395be36 # v2.0.7
        SHA512 69c7e6c02db6ff6b10d94b52470eda38839b4121960f7d19c3829eb453a84a62f017e1607bbb8dd63528c1461686fa6f30af605a046faae2c9c916aa688b555f
        HEAD_REF RC_2_0
)

vcpkg_from_github(
        OUT_SOURCE_PATH TRYSIGNAL_SOURCE_PATH
        REPO arvidn/try_signal
        REF 751a7e5a5be14892bcfdff1e63c653bcbf71cf39
        SHA512 4ccea4f67a79acf49a9943d8aec3999475357d7ad3cfc7b37f0e1c4527f8f4536993c6f6241bb3eb166a1dc939133a4f3b35197f9e47fb2ac9c713b64f8cb96d
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