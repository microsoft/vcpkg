vcpkg_check_linkage(ONLY_DYNAMIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH QUIC_SOURCE_PATH
    REPO microsoft/msquic
    REF v2.1.8
    SHA512 23ef4cc3794180b06d0ed138d6e96e37ef5f15ea0ccbf405f95f13c9fbd5aedc8a9c5c403b38b2381801796c50907ee36ebed1161da687bacd82cdea6880475a
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
    SHA512 bbe73fcb69f067accd0f8f2a6ac73d030971d70de1f3b3d1ab1bbc43a885639d414b20cbd202d89de145e3bba40a91466ac6709b53bc6d7d0788e52d8865b50c
    HEAD_REF OpenSSL_1_1_1k+quic
)

file(REMOVE_RECURSE "${QUIC_SOURCE_PATH}/submodules/openssl")
file(RENAME "${OPENSSL_SOURCE_PATH}" "${QUIC_SOURCE_PATH}/submodules/openssl")

if(VCPKG_TARGET_IS_WINDOWS)
    LIST(APPEND QUIC_TLS "schannel")
else()
    LIST(APPEND QUIC_TLS "openssl")
    
    vcpkg_find_acquire_program(PERL)
    get_filename_component(PERL_EXE_PATH ${PERL} DIRECTORY)
    vcpkg_add_to_path(${PERL_EXE_PATH})
    
    vcpkg_find_acquire_program(NASM)
    get_filename_component(NASM_EXE_PATH ${NASM} DIRECTORY)
    vcpkg_add_to_path(PREPEND ${NASM_EXE_PATH})

endif()


vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        tools QUIC_BUILD_TOOLS
)

vcpkg_cmake_configure(
    SOURCE_PATH "${QUIC_SOURCE_PATH}"
    DISABLE_PARALLEL_CONFIGURE
    OPTIONS
        ${FEATURE_OPTIONS}
        -DQUIC_SOURCE_LINK=OFF
        -DQUIC_TLS=${QUIC_TLS}
        -DQUIC_USE_SYSTEM_LIBCRYPTO=OFF
        -DQUIC_BUILD_SHARED=ON
        -DQUIC_UWP_BUILD=${VCPKG_TARGET_IS_UWP}
)

if(NOT VCPKG_HOST_IS_WINDOWS)
    find_program(MAKE make)
    get_filename_component(MAKE_EXE_PATH ${MAKE} DIRECTORY)
    vcpkg_add_to_path(PREPEND ${MAKE_EXE_PATH})
endif()



#vcpkg_cmake_build(TARGET OpenSSL_Build) # separate build log for quictls/openssl
vcpkg_cmake_install()
vcpkg_copy_pdbs()
vcpkg_cmake_config_fixup(PACKAGE_NAME msquic CONFIG_PATH "lib/cmake/msquic")

if("tools" IN_LIST FEATURES)
    vcpkg_copy_tools(TOOL_NAMES quicattack quicinterop quicinteropserver quicipclient quicipserver
                                quicpcp quicping quicpost quicreach quicsample spinquic
        AUTO_CLEAN
    )
endif()

vcpkg_install_copyright(FILE_LIST "${QUIC_SOURCE_PATH}/LICENSE") 

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share"
                    "${CURRENT_PACKAGES_DIR}/debug/include"
)

