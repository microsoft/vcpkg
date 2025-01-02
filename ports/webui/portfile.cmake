#vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO webui-dev/webui
    REF "${VERSION}"
    SHA512 de4392c04d39cac1216354099e52173bb8fb0dd3724e4afa03d79ded4c73e7868c8cf55a451e576ad0665c0c647b9cfb5e7a01c75269a761afd48a23d2efa4eb
    HEAD_REF master
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        tls   WEBUI_USE_TLS
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        ${FEATURE_OPTIONS}
)

vcpkg_cmake_install()

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
