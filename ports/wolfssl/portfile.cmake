vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO wolfssl/wolfssl
    REF v5.3.0-stable
    SHA512 399d2b8aad58471d237d21dea68c33fde2b9a3c117c554c241d9174db02847a6c31afae2908839d18f9ada317b2388560a24c077b76014f663227061342bf045
    HEAD_REF master
    )

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
      -DCMAKE_C_FLAGS='-DWOLFSSL_ALT_CERT_CHAINS\ -DWOLFSSL_DES_ECB'
    OPTIONS_DEBUG
      -DWOLFSSL_DEBUG=yes)

vcpkg_cmake_install()
vcpkg_copy_pdbs()

file(INSTALL "${SOURCE_PATH}/COPYING" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)

vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/wolfssl)
vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
