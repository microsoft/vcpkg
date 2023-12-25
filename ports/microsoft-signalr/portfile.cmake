vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO aspnet/SignalR-Client-Cpp
    REF "v${VERSION}"
    SHA512 b87c94e8bc81781c1cfb4292f1fe3ce046a5f192a25c02104f454b533349c1c0ed965570bd749b496bb316ccb89ae51c5e7461ffa06055e71dac659fbde79456
    HEAD_REF main
    PATCHES
        find-msgpack.patch
)

vcpkg_check_features(
    OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        cpprestsdk USE_CPPRESTSDK
        messagepack USE_MSGPACK
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DBUILD_TESTING=OFF
        ${FEATURE_OPTIONS}
        -DWALL=OFF
        "-DJSONCPP_LIB=JsonCpp::JsonCpp"
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/share/microsoft-signalr)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/lib/share" "${CURRENT_PACKAGES_DIR}/lib/share")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE.txt")
file(COPY "${SOURCE_PATH}/third-party-notices.txt" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")

vcpkg_copy_pdbs()
