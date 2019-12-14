set(OATPP_VERSION "0.19.10")

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

function(dump_variables)
    message(STATUS "#############################################################################")
    message(STATUS "#############################################################################")
    message(STATUS "#############################################################################")
    get_cmake_property(_variableNames VARIABLES)
    list (SORT _variableNames)
    foreach (_variableName ${_variableNames})
        message(STATUS "${_variableName}=${${_variableName}}")
    endforeach()
    message(STATUS "#############################################################################")
    message(STATUS "#############################################################################")
    message(STATUS "#############################################################################")
    execute_process(COMMAND "${CMAKE_COMMAND}" "-E" "environment")
    message(STATUS "###############################################################################")
    message(STATUS "###############################################################################")
    message(STATUS "###############################################################################")
endfunction()

if (VCPKG_LIBRARY_LINKAGE STREQUAL dynamic)	
    if (VCPKG_CRT_LINKAGE STREQUAL dynamic)	
        set(_crt_linkage_text "dynamic")
    else()
        set(_crt_linkage_text "static")
    endif()
    message(STATUS "Warning: Building dynamic libraries not supported. Building static libraries linking to a ${_crt_linkage_text} CRT.")	
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
    REF 33ce431ab6d8a40a9678ef8965a828967302ffe7 # 0.19.10
    SHA512 efc183c7c11452bddee628aa831920cef24ce7e5ab96a41afe807025e3f2194a79cf26371552fa5d5cd5ced28a94ab0b50d3e99f5b05586ed64757b99afb4c88
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
        REF d09cdda1113bc99d9625b1da3e731b46c43c12ff # 0.19.10
        SHA512 53998aa48b9ba3c5f7da3d27ec6dd8def599ebb98c5ef2849c999d70bae10469001d9db4f9ce243dba045f732390ed440cd6d8166eb67a0b12c0599b29864892
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
    # Feature:curl
    # Build-Depends: curl
    # Description: Use libcurl as a RequestExecutor on the oatpp's ApiClient (external dependency on pkg-config)

    message(STATUS "Building submodule oatpp[curl]")

    # this submodule requires pkg-config (boo)
    verify_pkg_config("curl")

    # get the source
    vcpkg_from_github(
        OUT_SOURCE_PATH CURL_SOURCE_PATH
        REPO oatpp/oatpp-curl
        REF f4453c97461adb1db359f59a8d6acd01be3f758a # 0.19.10
        SHA512 4981c751aae58b1caffb77a410328a4bf62a81809fd0343ce2e47127be6f1d3440a44b8eef2123b214f336fa7b82aefa3bce06cf64b8ac42b54574b521df6b0a
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
    # Unfortunately, this submodule requires unistd.h - not sure if the
    # unistd.h in the libressl include/compat would work here or not...
    #
    # When we get past this problem, add the following to the CONTROL file:
    #    Feature:libressl
    #    Build-Depends: libressl
    #    Description: LibreSSL submodule providing secure server and client connection provider (external dependency on pkg-config)

    message(STATUS "Building submodule oatpp[libressl]")

    # this submodule requires pkg-config (boo)
    verify_pkg_config("libressl")
   
    # get the source
    vcpkg_from_github(
        OUT_SOURCE_PATH LIBRESSL_SOURCE_PATH
        REPO oatpp/oatpp-libressl
        REF b965b752dc676dbc1f7ccc308d8b826bee5b1dae # 0.19.10
        SHA512 0b2bf0f4958190e5ea9f82db962cb7473dda86de8e1e7645cd8e8741d134793984dfbdf742c676e09ff23b93cd42447b8f967575e95887828034870297a3bca7
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

    vcpkg_configure_cmake(
        SOURCE_PATH "${LIBRESSL_SOURCE_PATH}"
        PREFER_NINJA
        OPTIONS
            "-Doatpp_DIR=${CURRENT_PACKAGES_DIR}/share/oatpp"
            "-DOATPP_BUILD_TESTS:BOOL=OFF"
            "-DCMAKE_CXX_FLAGS=-D_CRT_SECURE_NO_WARNINGS"
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
        REF 8a71d86ebe9b881e2e762b6209848197534b72df # 0.19.10
        SHA512 7e6d2112ce384ff795534734cdda26928805569db67480d70a90d2544264b3b90c8807818bec2da5570500fa4277eb08b111fae6c4283aadd75db3767b89fea0
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
4981c751aae58b1caffb77a410328a4bf62a81809fd0343ce2e47127be6f1d3440a44b8eef2123b214f336fa7b82aefa3bce06cf64b8ac42b54574b521df6b0a        REF 7a6fd37ff5d3ecb3af8e67d4fad6f871cd6aadd8 # 0.19.10
        SHA512 a4781b4cc0c62cf73302a9d792e0e51243190a1b62b6d40f7da6d22bbac1aa34eb8652114eca6a1ff76c0a2330bd0e0911d1615fc6e36b5a3e8be5e95233ffae
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
        REF 169e4dc2b513ce118941f0c51a527a888dc6087f # 0.19.10
        SHA512 8196d0a4d0e5adb07682fa4065c641e0bf479184c343680a661c4e5c7accea34a48215394f2afcf2ed5ecc1e60b30b5ce473b56a84c875f957e84cf7d73c4d68
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

