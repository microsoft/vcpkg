vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO aspnet/SignalR-Client-Cpp
    REF v0.1.0-alpha3
    SHA512 7dbd75748535c7b7fef36afe246b132b243b8b4932c218a63aa18c7a44d6691c002144c6d2f5603ad63c03d018907436ad259fdfcc0d7749917931bdebef670b
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