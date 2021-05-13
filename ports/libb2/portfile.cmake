vcpkg_fail_port_install(ON_TARGET "WINDOWS")

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO BLAKE2/libb2
    REF a036711671cc3bf35218ee659dfae0ba743ac45d
    SHA512 b44a1d829dac502e06fb102885a6605c881f0a0e2f266372d8a104e2e158c0f3f635bf24db730e1afcdec7ad446f6864dc8e53d15322a8c6b9cb87df59085229
    HEAD_REF master
)

set(OPTIONS)
if(CMAKE_HOST_WIN32)
    set(OPTIONS --disable-native) # requires cpuid
endif()

vcpkg_configure_make(
    AUTOCONFIG
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS ${OPTIONS}
)
vcpkg_install_make()
vcpkg_fixup_pkgconfig()


file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

vcpkg_copy_pdbs()

file(INSTALL ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)