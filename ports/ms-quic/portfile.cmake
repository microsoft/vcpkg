vcpkg_check_linkage(ONLY_DYNAMIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH QUIC_SOURCE_PATH
    REPO microsoft/msquic
    REF v1.2.0
    SHA512 6f63d42d950cbba88764332b31818a8627e7d3ecf7393cdef77daedd35a7bb04ac39c642991afb7cca502a346999233023e3b36011916c67e348179838aa7042
    HEAD_REF master
    PATCHES
        fix-warnings.patch  # Remove /WX, -Werror
        fix-platform.patch  # Make OpenSSL build use VCPKG_TARGET_ARCHITECTURE
        fix-install.patch   # Adjust install path of build outputs
)

vcpkg_from_github(
    OUT_SOURCE_PATH OPENSSL_SOURCE_PATH
    REPO quictls/openssl
    REF a6e9d76db343605dae9b59d71d2811b195ae7434
    SHA512 23510a11203b96476c194a1987c7d4e758375adef0f6dfe319cd8ec4b8dd9b12ea64c4099cf3ba35722b992dad75afb1cfc5126489a5fa59f5ee4d46bdfbeaf6
    HEAD_REF OpenSSL_1_1_1k+quic
)
file(REMOVE_RECURSE ${QUIC_SOURCE_PATH}/submodules)
file(MAKE_DIRECTORY ${QUIC_SOURCE_PATH}/submodules)
file(RENAME ${OPENSSL_SOURCE_PATH} ${QUIC_SOURCE_PATH}/submodules/openssl)

vcpkg_find_acquire_program(PERL)
get_filename_component(PERL_EXE_PATH ${PERL} DIRECTORY)
vcpkg_add_to_path(${PERL_EXE_PATH})

if(NOT VCPKG_HOST_IS_WINDOWS)
    find_program(MAKE make)
    get_filename_component(MAKE_EXE_PATH ${MAKE} DIRECTORY)
    vcpkg_add_to_path(PREPEND ${MAKE_EXE_PATH})
endif()

 if(VCPKG_TARGET_IS_WINDOWS)
     vcpkg_find_acquire_program(NASM)
     get_filename_component(NASM_EXE_PATH ${NASM} DIRECTORY)
     vcpkg_add_to_path(PREPEND ${NASM_EXE_PATH})
 endif()

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        tools QUIC_BUILD_TOOLS
)

string(COMPARE EQUAL "${VCPKG_CRT_LINKAGE}" "static" STATIC_CRT)

vcpkg_cmake_configure(
    SOURCE_PATH ${QUIC_SOURCE_PATH}
    OPTIONS
        ${FEATURE_OPTIONS}
        -DQUIC_SOURCE_LINK=OFF
        -DQUIC_TLS=openssl
        -DQUIC_TLS_SECRETS_SUPPORT=ON
        -DQUIC_USE_SYSTEM_LIBCRYPTO=OFF
        -DQUIC_BUILD_PERF=OFF
        -DQUIC_BUILD_TEST=OFF
        -DQUIC_STATIC_LINK_CRT=${STATIC_CRT}
        -DQUIC_UWP_BUILD=${VCPKG_TARGET_IS_UWP}
)

vcpkg_cmake_build(TARGET OpenSSL_Build) # separate build log for quictls/openssl
vcpkg_cmake_install()
vcpkg_copy_pdbs()
vcpkg_cmake_config_fixup(PACKAGE_NAME msquic CONFIG_PATH lib/cmake/msquic)

if("tools" IN_LIST FEATURES)
    vcpkg_copy_tools(TOOL_NAMES quicattack quicinterop quicinteropserver quicipclient quicipserver
                                quicpcp quicping quicpost quicreach quicsample spinquic
        AUTO_CLEAN
    )
endif()

file(INSTALL ${QUIC_SOURCE_PATH}/LICENSE
     DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright
) 
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share
                    ${CURRENT_PACKAGES_DIR}/debug/include
)
