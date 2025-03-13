if(VCPKG_TARGET_IS_WINDOWS AND NOT VCPKG_TARGET_IS_MINGW)
    vcpkg_from_github(
        OUT_SOURCE_PATH SOURCE_PATH
        REPO sogou/workflow
        REF "v0.10.10-win"
        SHA512 61ba0cee8e56bb112c6562697bbd7f53e55c1a12ea2388a23076c4e732ae1337b2b0fcc4f518b2afeb1373a173c1ba7375b175c3df3b25d3013a4d2e292c837c
        HEAD_REF windows
    )
else()
    vcpkg_from_github(
        OUT_SOURCE_PATH SOURCE_PATH
        REPO sogou/workflow
        REF "v${VERSION}"
        SHA512 ea90fb1a9c289a76dfa02b077cb0d99ec27157747f1b73d4437a089560a2659baebd463e2e6f699fbd44ec01e59bcd4d4b2f4556377dd57834f02bde0aefdca3
        HEAD_REF master
    )
endif()

if(VCPKG_CRT_LINKAGE STREQUAL "static")
    set(CONFIGURE_OPTIONS "-DWORKFLOW_BUILD_STATIC_RUNTIME=ON")
else()
    set(CONFIGURE_OPTIONS "-DWORKFLOW_BUILD_STATIC_RUNTIME=OFF")
endif()

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    DISABLE_PARALLEL_CONFIGURE
    OPTIONS ${CONFIGURE_OPTIONS}
)
vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH "lib/cmake/${PORT}")
vcpkg_copy_pdbs()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/share/doc")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
