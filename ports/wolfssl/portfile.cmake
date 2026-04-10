vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO wolfssl/wolfssl
    REF "v${VERSION}-stable"
    SHA512 84adcc41fc07dc89467b7f1bda32ab49f61cb15bb7b5ce3f3b5263346534a3af179bcb402c348a438a4de91a2b76b269db26110ad5c3f0e1bd5b8d234dfaf516
    HEAD_REF master
    PATCHES
        have-limits-h.diff
)

if ("asio" IN_LIST FEATURES)
    set(ENABLE_ASIO yes)
else()
    set(ENABLE_ASIO no)
endif()

if ("dtls" IN_LIST FEATURES)
    set(ENABLE_DTLS yes)
else()
    set(ENABLE_DTLS no)
endif()

if ("quic" IN_LIST FEATURES)
    set(ENABLE_QUIC yes)
else()
    set(ENABLE_QUIC no)
endif()

if ("curve25519" IN_LIST FEATURES)
    set(ENABLE_CURVE25519 yes)
else()
    set(ENABLE_CURVE25519 no)
endif()

vcpkg_cmake_get_vars(cmake_vars_file)
include("${cmake_vars_file}")

foreach(config RELEASE DEBUG)
  string(APPEND VCPKG_COMBINED_C_FLAGS_${config} " -DHAVE_EX_DATA -DNO_WOLFSSL_STUB -DWOLFSSL_ALT_CERT_CHAINS -DWOLFSSL_DES_ECB -DWOLFSSL_CUSTOM_OID -DHAVE_OID_ENCODING -DWOLFSSL_CERT_GEN -DWOLFSSL_ASN_TEMPLATE -DWOLFSSL_KEY_GEN -DHAVE_PKCS7 -DHAVE_AES_KEYWRAP -DWOLFSSL_AES_DIRECT -DHAVE_X963_KDF")
  if ("secret-callback" IN_LIST FEATURES)
      string(APPEND VCPKG_COMBINED_C_FLAGS_${config} " -DHAVE_SECRET_CALLBACK")
  endif()
endforeach()

vcpkg_cmake_configure(
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS
      -DWOLFSSL_BUILD_OUT_OF_TREE=yes
      -DWOLFSSL_EXAMPLES=no
      -DWOLFSSL_CRYPT_TESTS=no
      -DWOLFSSL_OPENSSLEXTRA=yes
      -DWOLFSSL_TPM=yes
      -DWOLFSSL_TLSX=yes
      -DWOLFSSL_OCSP=yes
      -DWOLFSSL_OCSPSTAPLING=yes
      -DWOLFSSL_OCSPSTAPLING_V2=yes
      -DWOLFSSL_CRL=yes
      -DWOLFSSL_DES3=yes
      -DWOLFSSL_HPKE=yes
      -DWOLFSSL_SNI=yes
      -DWOLFSSL_ASIO=${ENABLE_ASIO}
      -DWOLFSSL_DTLS=${ENABLE_DTLS}
      -DWOLFSSL_DTLS13=${ENABLE_DTLS}
      -DWOLFSSL_DTLS_CID=${ENABLE_DTLS}
      -DWOLFSSL_QUIC=${ENABLE_QUIC}
      -DWOLFSSL_SESSION_TICKET=${ENABLE_QUIC}
      -DWOLFSSL_CURVE25519=${ENABLE_CURVE25519}
    OPTIONS_RELEASE
      -DCMAKE_C_FLAGS=${VCPKG_COMBINED_C_FLAGS_RELEASE}
    OPTIONS_DEBUG
      -DCMAKE_C_FLAGS=${VCPKG_COMBINED_C_FLAGS_DEBUG}
      -DWOLFSSL_DEBUG=yes)

vcpkg_cmake_install()
vcpkg_copy_pdbs()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/wolfssl)

if(VCPKG_TARGET_IS_IOS OR VCPKG_TARGET_IS_OSX)
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/lib/pkgconfig/wolfssl.pc" "Libs.private: " "Libs.private: -framework CoreFoundation -framework Security ")
    if(NOT VCPKG_BUILD_TYPE)
        vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig/wolfssl.pc" "Libs.private: " "Libs.private: -framework CoreFoundation -framework Security ")
    endif()
endif()
vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/COPYING")
