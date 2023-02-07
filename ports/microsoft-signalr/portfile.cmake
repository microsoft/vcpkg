vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO aspnet/SignalR-Client-Cpp
    REF v0.1.0-alpha4
    SHA512 b87c94e8bc81781c1cfb4292f1fe3ce046a5f192a25c02104f454b533349c1c0ed965570bd749b496bb316ccb89ae51c5e7461ffa06055e71dac659fbde79456
    HEAD_REF main
)

vcpkg_check_features(
    OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        cpprestsdk USE_CPPRESTSDK
        messagepack USE_MSGPACK
)

if("cpprestsdk" IN_LIST FEATURES AND VCPKG_TARGET_IS_UWP)
    message(FATAL_ERROR "microsoft-signalr[cpprestsdk] is not supported on UWP, use microsoft-signalr[core] instead")
endif()

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DBUILD_TESTING=OFF
        ${FEATURE_OPTIONS}
        -DWALL=OFF
)

vcpkg_install_cmake()
vcpkg_fixup_cmake_targets(CONFIG_PATH lib/share/microsoft-signalr)

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/lib/share ${CURRENT_PACKAGES_DIR}/lib/share)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

file(INSTALL ${SOURCE_PATH}/LICENSE.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
file(COPY ${SOURCE_PATH}/third-party-notices.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT})

vcpkg_copy_pdbs()