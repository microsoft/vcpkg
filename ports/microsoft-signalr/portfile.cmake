vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO aspnet/SignalR-Client-Cpp
    REF v0.1.0-alpha2
    SHA512 5a25bdf1f4587c7c008b743c0e97c5b293839b4a63bad89b3c37a1affccfa26df12b20f69a822e8d0eddb4491b3f0e513f017c39528a39990527aac44b3d6f5b
    HEAD_REF main
)

vcpkg_check_features(
    OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        cpprestsdk USE_CPPRESTSDK
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