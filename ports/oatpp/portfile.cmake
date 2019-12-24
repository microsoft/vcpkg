set(OATPP_VERSION "0.19.11")

# go to extraordinary measures to find pkg-config on windows and set the PKG_CONFIG environment variable.
function(verify_pkg_config SUBMODULE_NAME)
    if(NOT PKG_CONFIG_EXECUTABLE)
        if(NOT "$ENV{PKG_CONFIG}" STREQUAL "")
            set(PKG_CONFIG_EXECUTABLE "$ENV{PKG_CONFIG}" CACHE FILEPATH "pkg-config executable")
        elseif(NOT "$ENV{ProgramData}" STREQUAL "")
            # for windows, assume chocolatey-installed which vcpkg keeps out of the path so we just tell it where it is
            file(TO_CMAKE_PATH "$ENV{ProgramData}" _program_data)
            find_program(PKG_CONFIG_EXECUTABLE NAMES pkg-config.exe HINTS "${_program_data}/chocolatey/bin" DOC "pkg-config executable")
            if (PKG_CONFIG_EXECUTABLE)
                set(ENV{PKG_CONFIG} "${PKG_CONFIG_EXECUTABLE}")
            endif()
        endif()
    endif()
    find_package(PkgConfig)

    if (NOT PKG_CONFIG_FOUND)
        execute_process(COMMAND "uname" "-s" OUTPUT_VARIABLE _system_name OUTPUT_STRIP_TRAILING_WHITESPACE)
        if ("x${_system_name}x" STREQUAL "xLinuxx")
            message(FATAL_ERROR "The ${SUBMODULE_NAME} submodule requires pkg-config. You can probably get it by installing the pkg-config package with your operating system's package manager (yum install pkgconfig, apt install pkg-config, etc.)")
        elseif ("x${_system_name}x" STREQUAL "xDarwinx")
            message(FATAL_ERROR "The ${SUBMODULE_NAME} submodule requires pkg-config. You can install it with brew: brew install pkg-config")
        endif()
        # Windows doesn't have uname and execute_process() sets _system_name to an emtpy string
        message(FATAL_ERROR "The ${SUBMODULE_NAME} submodule requires pkg-config. You can install it with chocolatey: choco install pkgconfiglite")
    endif()
endfunction()

if (VCPKG_LIBRARY_LINKAGE STREQUAL dynamic)	
    if (VCPKG_CRT_LINKAGE STREQUAL dynamic)	
        set(_crt_linkage_text "dynamic")
    else()
        set(_crt_linkage_text "static")
    endif()
    set(VCPKG_LIBRARY_LINKAGE static)	
endif()
# if (VCPKG_LIBRARY_LINKAGE STREQUAL dynamic)	
#     set(OATPP_BUILD_SHARED_LIBRARIES_OPTION "-DBUILD_SHARED_LIBS:BOOL=ON")
# else()
#     set(OATPP_BUILD_SHARED_LIBRARIES_OPTION "-DBUILD_SHARED_LIBS:BOOL=OFF")
# endif()

message(STATUS "Building oatpp[core]")
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO oatpp/oatpp
    REF 857315c01e9318c7e72665ed222565d583f32a98 # 0.19.11
    SHA512 835b0239ceb3677fb746e23f33409a060dff88e6b037932c7e66e664b122643b25c4e8996201e6539c3effdc165311ba4e7a4feefb5b3c670b59a69babd85888
    HEAD_REF master
)

vcpkg_configure_cmake(
    SOURCE_PATH "${SOURCE_PATH}"
    PREFER_NINJA
    OPTIONS
        "-DOATPP_BUILD_TESTS:BOOL=OFF"
        "-DCMAKE_CXX_FLAGS=-D_CRT_SECURE_NO_WARNINGS"
        ${OATPP_BUILD_SHARED_LIBRARIES_OPTION}
)

vcpkg_install_cmake()
vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/oatpp-${OATPP_VERSION})
vcpkg_copy_pdbs()

if("consul" IN_LIST FEATURES)
    message(STATUS "Building submodule oatpp[consul]")
    vcpkg_from_github(
        OUT_SOURCE_PATH CONSUL_SOURCE_PATH
        REPO oatpp/oatpp-consul
        REF d9b819eed29a3373b61e8e8306d13d0840572318 # 0.19.11
        SHA512 d16e6cb4e2ab5e6d71e9036f13b976f00b54631a31516e9adc7cd92141f40a4f7bfa6dc9602a326ca1d7a540d404c9189b1b302ff5a24fdac65cdfe46cb68c7b
        HEAD_REF master
    )
    vcpkg_configure_cmake(
        SOURCE_PATH "${CONSUL_SOURCE_PATH}"
        PREFER_NINJA
        OPTIONS
            "-Doatpp_DIR=${CURRENT_PACKAGES_DIR}/share/oatpp"
            "-DOATPP_BUILD_TESTS:BOOL=OFF"
            "-DCMAKE_CXX_FLAGS=-D_CRT_SECURE_NO_WARNINGS"
            ${OATPP_BUILD_SHARED_LIBRARIES_OPTION}
    )
    vcpkg_install_cmake()
    vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/oatpp-consul-${OATPP_VERSION})
    vcpkg_copy_pdbs()
endif()

if("curl" IN_LIST FEATURES)
    # Apparently the curl submodule hasn't caught up to the core module yet (classes that
    # don't override abstract base classes accuratetly). When that is fixed, put the
    # following into the CONTROL file:
    #

    message(STATUS "Building submodule oatpp[curl]")

    # this submodule requires pkg-config (boo)
    verify_pkg_config("curl")

    # get the source
    vcpkg_from_github(
        OUT_SOURCE_PATH CURL_SOURCE_PATH
        REPO oatpp/oatpp-curl
        REF 5354e78707184cdfe3fb36af5735481d1159c3a6 # 0.19.11
        SHA512 3a40b6a6981253c7551c0784fed085403272497840874eb7ea09c7a83c9d86c5fcbf36cf6059d6f067c606fc65b2870806e20f8ffacfef605be4c824804b6bb9
        HEAD_REF master
    )

    # This depends on libcurl which was built but it also needs pkg-config to be 
    # able to find the libcurl.pc file.
    set(_libcurl_pc_dir "${CURRENT_BUILDTREES_DIR}/../curl/${TARGET_TRIPLET}-rel")
    get_filename_component(_libcurl_pc_dir "${_libcurl_pc_dir}" REALPATH)

    # tell pkg-config where to find the pc files.
    file(TO_NATIVE_PATH "${_libcurl_pc_dir}" _libcurl_pc_dir)
    if("$ENV{PKG_CONFIG_PATH}" STREQUAL "")
        set(ENV{PKG_CONFIG_PATH} "${_libcurl_pc_dir}")
    elseif (WIN32)
        set(ENV{PKG_CONFIG_PATH} "$ENV{PKG_CONFIG_PATH};${_libcurl_pc_dir}")
    else()
        set(ENV{PKG_CONFIG_PATH} "$ENV{PKG_CONFIG_PATH}:${_libcurl_pc_dir}")
    endif()  

    vcpkg_configure_cmake(
        SOURCE_PATH "${CURL_SOURCE_PATH}"
        PREFER_NINJA
        OPTIONS
            "-Doatpp_DIR=${CURRENT_PACKAGES_DIR}/share/oatpp"
            "-DOATPP_BUILD_TESTS:BOOL=OFF"
            "-DCMAKE_CXX_FLAGS=-D_CRT_SECURE_NO_WARNINGS"
            ${OATPP_BUILD_SHARED_LIBRARIES_OPTION}
    )
    vcpkg_install_cmake()
    vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/oatpp-curl-${OATPP_VERSION})
    vcpkg_copy_pdbs()
endif()

if("libressl" IN_LIST FEATURES)
    # Unfortunately, this submodule requires libressl 3.0 and vcpkg is at 2.9.1-2
    #
    # When we get past this problem, add the following to the CONTROL file:
    # Feature:libressl
    # Build-Depends: libressl
    # Description: LibreSSL submodule providing secure server and client connection provider (external dependency on pkg-config)


    message(STATUS "Building submodule oatpp[libressl]")

    # this submodule requires pkg-config (boo)
    verify_pkg_config("libressl")
   
    # get the source
    vcpkg_from_github(
        OUT_SOURCE_PATH LIBRESSL_SOURCE_PATH
        REPO oatpp/oatpp-libressl
        REF 7daae69903975aa7ac2705ea03320c724b4da502 # 0.19.11
        SHA512 b09accccd65520dca8f850e48d1b7c3f22752abb733eb3b7ea13ad285079479ca8addeabec9054dc3dcba0632b94c4db98af3c99c3e99d159eaa32cf6dbe3c96
        HEAD_REF master
    )

    # The libressl package does not populate its pc files. Do that here.
    file(GLOB_RECURSE LIBTLS_PC_INS "${CURRENT_BUILDTREES_DIR}/../libressl/src/*/libtls.pc.in")
    list(GET LIBTLS_PC_INS 0 LIBTLS_PC_IN)
    file(GLOB_RECURSE LIBCRYPTO_PC_INS "${CURRENT_BUILDTREES_DIR}/../libressl/src/*/libcrypto.pc.in")
    list(GET LIBCRYPTO_PC_INS 0 LIBCRYPTO_PC_IN)
    file(GLOB_RECURSE LIBSSL_PC_INS "${CURRENT_BUILDTREES_DIR}/../libressl/src/*/libssl.pc.in")
    list(GET LIBSSL_PC_INS 0 LIBSSL_PC_IN)
    set(prefix "${VCPKG_ROOT_DIR}/installed/${TARGET_TRIPLET}")
    set(exec_prefix [[${prefix}]])
    set(libdir [[${prefix}/lib]])
    set(includedir [[${prefix}/include]])
    set(VERSION "1.HMM")
    file(GLOB TLS_LIB "${prefix}/lib/tls-*.lib" "${prefix}/lib/libtls-*.a")
    get_filename_component(TLS_LIB "${TLS_LIB}" NAME_WE)
    file(GLOB CRYPTO_LIB "${prefix}/lib/crypto-*.lib" "${prefix}/lib/libcrypto-*.a")
    get_filename_component(CRYPTO_LIB "${CRYPTO_LIB}" NAME_WE)
    file(GLOB SSL_LIB "${prefix}/lib/ssl-*.lib" "${prefix}/lib/libssl-*.a")
    get_filename_component(SSL_LIB "${SSL_LIB}" NAME_WE)
    set(LIBS "-l${TLS_LIB} -l${SSL_LIB} -l${CRYPTO_LIB}")
    set(PLATFORM_LDADD "")
    configure_file("${LIBTLS_PC_IN}" "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}/libtls.pc" @ONLY)
    set(LIBS "-l${SSL_LIB} -l${CRYPTO_LIB}")
    configure_file("${LIBSSL_PC_IN}" "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}/libssl.pc" @ONLY)
    set(LIBS "-l${CRYPTO_LIB}")
    configure_file("${LIBCRYPTO_PC_IN}" "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}/libcrypto.pc" @ONLY)

    # tell pkg-config where to find the pc files.
    file(TO_NATIVE_PATH "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}" _libressl_pc_dir)
    if("$ENV{PKG_CONFIG_PATH}" STREQUAL "")
        set(ENV{PKG_CONFIG_PATH} "${_libressl_pc_dir}")
    elseif (WIN32)
        set(ENV{PKG_CONFIG_PATH} "$ENV{PKG_CONFIG_PATH};${_libressl_pc_dir}")
    else()
        set(ENV{PKG_CONFIG_PATH} "$ENV{PKG_CONFIG_PATH}:${_libressl_pc_dir}")
    endif()  

    dump_variables()
    vcpkg_configure_cmake(
        SOURCE_PATH "${LIBRESSL_SOURCE_PATH}"
        PREFER_NINJA
        OPTIONS
            "-Doatpp_DIR=${CURRENT_PACKAGES_DIR}/share/oatpp"
            "-DOATPP_BUILD_TESTS:BOOL=OFF"
            "-DCMAKE_CXX_FLAGS=-D_CRT_SECURE_NO_WARNINGS"
            "-DLIBRESSL_ROOT_DIR=${CURRENT_INSTALLED_DIR}"
            ${OATPP_BUILD_SHARED_LIBRARIES_OPTION}
    )

    vcpkg_install_cmake()
    vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/oatpp-libressl-${OATPP_VERSION})
    vcpkg_copy_pdbs()
endif()

if("mbedtls" IN_LIST FEATURES)
    message(STATUS "Building submodule oatpp[mbedtls]")
    vcpkg_from_github(
        OUT_SOURCE_PATH MBEDTLS_SOURCE_PATH
        REPO oatpp/oatpp-mbedtls
        REF 269db6a2a04ea25367d24baccca1883fffb4bbc0 # 0.19.11
        SHA512 2581c34a544b02130ebfadf835c61f51028484a2dab7b226d13b75fdfe546d4217989a778d1ed7fe08ad8c7d2713af7590bd4c8604a750162a16f7be44323e87
        HEAD_REF master
    )
    vcpkg_configure_cmake(
        SOURCE_PATH "${MBEDTLS_SOURCE_PATH}"
        PREFER_NINJA
        OPTIONS
            "-Doatpp_DIR=${CURRENT_PACKAGES_DIR}/share/oatpp"
            "-DOATPP_BUILD_TESTS:BOOL=OFF"
    )
    vcpkg_install_cmake()
    vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/oatpp-mbedtls-${OATPP_VERSION})
    vcpkg_copy_pdbs()
endif()

if("swagger" IN_LIST FEATURES)
    message(STATUS "Building submodule oatpp[swagger]")
    vcpkg_from_github(
        OUT_SOURCE_PATH SWAGGER_SOURCE_PATH
        REPO oatpp/oatpp-swagger
        REF 69a606770648f3d589deb9eb796bdb28525d941e # 0.19.11
        SHA512 468871af0a8de3527d050a43c449881eb6fa9fb2279bc81bbb276d175b3d41dd48e33f03da54eb53b9749d9fc7c44e4037876e740d4213ecd93ce72ea8c2561e
        HEAD_REF master
    )
    vcpkg_configure_cmake(
        SOURCE_PATH "${SWAGGER_SOURCE_PATH}"
        PREFER_NINJA
        OPTIONS
            "-Doatpp_DIR=${CURRENT_PACKAGES_DIR}/share/oatpp"
            "-DOATPP_BUILD_TESTS:BOOL=OFF"
            "-DCMAKE_CXX_FLAGS=-D_CRT_SECURE_NO_WARNINGS"
            ${OATPP_BUILD_SHARED_LIBRARIES_OPTION}
    )
    vcpkg_install_cmake()
    vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/oatpp-swagger-${OATPP_VERSION})
    vcpkg_copy_pdbs()
endif()

if("websocket" IN_LIST FEATURES)
    message(STATUS "Building submodule oatpp[websocket]")
    vcpkg_from_github(
        OUT_SOURCE_PATH WEBSOCKET_SOURCE_PATH
        REPO oatpp/oatpp-websocket
        REF be56875d6d87446e932498de3f390589fc51ee97 # 0.19.11
        SHA512 4fce4f55b8aa144b7b9153a759f87dec075e9d6338b3a668448f35fce457626236bab012f41af660a877444b97574490f5c707e354bcb9cb1a9d03c2e5dfe019
        HEAD_REF master
    )
    vcpkg_configure_cmake(
        SOURCE_PATH "${WEBSOCKET_SOURCE_PATH}"
        PREFER_NINJA
        OPTIONS
            "-Doatpp_DIR=${CURRENT_PACKAGES_DIR}/share/oatpp"
            "-DOATPP_BUILD_TESTS:BOOL=OFF"
    )
    vcpkg_install_cmake()
    vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/oatpp-websocket-${OATPP_VERSION})
    vcpkg_copy_pdbs()
endif()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)

