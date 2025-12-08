vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO norman-ml/norman_core_sdk_cpp
    REF v${VERSION}
    SHA512 178180d8fda0086371c234741addb06406a9e7571d69547746fc63d7bdcedbb44bd4b4f246a49bcb03902f067031b2a38385268ec1999ec22a921f011527da78
    HEAD_REF main
)

vcpkg_check_linkage(ONLY_DYNAMIC_LIBRARY)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_cmake_build()
vcpkg_cmake_install()
vcpkg_cmake_config_fixup()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

file(INSTALL "${SOURCE_PATH}/LICENSE"
     DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}"
     RENAME copyright)
