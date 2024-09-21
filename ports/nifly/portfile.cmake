vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_download_distfile(
    MISSING_STDINT_H
    URLS https://github.com/ousnius/nifly/commit/a16057e349b9cbee53d9618b22d3e235505f0df0.patch?full_index=1
    SHA512 45147c85384deba257e52eda5c2ff0c8dee559edc10b00d6e9964d5cc675669587ef941cea0228816c39846de58e33197e953506b9b73267397c4b36cd1f1374
    FILENAME a16057e349b9cbee53d9618b22d3e235505f0df0.patch
)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO ousnius/nifly
    REF 680a3c0435ff78f8189c46de410d0c8aa9c18a06
    SHA512 b1bb4a194f95e7bcd66280e1b796d0813cd0b4dc292dae5b168092c2d529f89c966a0f11b364787dfa906556181326b30517b7f734fe85246cde4016e3a1d55b
    HEAD_REF main
    PATCHES
        "${MISSING_STDINT_H}"
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DBUILD_TESTING=OFF
)
vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH "cmake/")

file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/debug/include"
    "${CURRENT_PACKAGES_DIR}/debug/share"
)

file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
