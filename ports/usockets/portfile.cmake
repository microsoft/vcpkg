# Upstream only support static compilation,
# https://github.com/uNetworking/uSockets/commit/b950efd6b10f06dd3ecb5b692e5d415f48474647
vcpkg_check_linkage(ONLY_STATIC_LIBRARY) 

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO uNetworking/uSockets
    REF "v${VERSION}"
    SHA512 726b1665209d0006d6621352c12019bbab22bed75450c5ef1509b409d3c19c059caf94775439d3b910676fa2a4a790d490c3e25e5b8141423d88823642be7ac7
    HEAD_REF master
)
file(COPY "${CURRENT_PORT_DIR}/CMakeLists.txt" DESTINATION "${SOURCE_PATH}")
file(COPY "${CURRENT_PORT_DIR}/unofficial-usockets-config.cmake" DESTINATION "${SOURCE_PATH}")

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        ssl     WITH_OPENSSL
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        ${FEATURE_OPTIONS}
)
vcpkg_cmake_install()
vcpkg_cmake_config_fixup(PACKAGE_NAME unofficial-usockets)
vcpkg_copy_pdbs()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
