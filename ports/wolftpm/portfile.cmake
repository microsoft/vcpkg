# Download patches from upstream
vcpkg_download_distfile(PATCH_PR430
    URLS https://github.com/wolfssl/wolftpm/pull/430.diff?full_index=1
    FILENAME wolftpm-pr430.diff
    SHA512 b795e720ebc92a1208462df7261d004067c7989218f44cb686d980a4521192c1244428c8442f4293ec3e178680ef862ff6e7dead9420a11c0a4dca8def3631c2
)

vcpkg_download_distfile(PATCH_PR432  
    URLS https://github.com/wolfssl/wolftpm/pull/432.diff?full_index=1
    FILENAME wolftpm-pr432.diff
    SHA512 95c0373e4b7275ed2430ad3087c74dab66351ffe13c8e28ddca465d9956757264ce7a6b544a61d896c3b04458e64775770e6995028b7ac59165526ade9cf5e20
)

vcpkg_download_distfile(PATCH_PR433  
    URLS https://github.com/wolfssl/wolftpm/pull/433.diff?full_index=1
    FILENAME wolftpm-pr433.diff
    SHA512 c06af5e337aadf70282e10b6c9af02c1ef4a1a19da6ac7b6d4370472adf79f13c090bca6f4afbce14313847b25bf96e2aa8964b75f439b3339f5f704afd93206
)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO wolfssl/wolftpm
    REF v${VERSION}
    SHA512 e6b73ec95f6c0cd37a71063c13db2a95175c54d2c63f69959ed68b4992277f1304136e1ecc5419ce4ff070d9162dbb30a9c6f78c7238383d72c686f1cdc1ab7c
    HEAD_REF master
    PATCHES
      ${PATCH_PR430}
      ${PATCH_PR432}
      ${PATCH_PR433}
    )

vcpkg_cmake_configure(SOURCE_PATH ${SOURCE_PATH}
    OPTIONS
      -DWOLFTPM_EXAMPLES=no
      -DWOLFTPM_BUILD_OUT_OF_TREE=yes
    OPTIONS_DEBUG
      -DCMAKE_C_FLAGS='-DDEBUG_WOLFTPM'
    )

vcpkg_cmake_install()
vcpkg_copy_pdbs()

file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)

vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/wolftpm)
vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
