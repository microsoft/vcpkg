vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO leethomason/tinyxml2
    REF 10.0.0
    SHA512 a359d33bc12fad455b53d81011dbe12727cae0aabfaa5704f1a25807ca216dd854a571291029886c0beedeca5c3b6393dd49c4718773e18a0e008abbdb3de36a
    HEAD_REF master
    PATCHES
        0001-fix-do-not-force-export-the-symbols-when-building-st.patch
        0002-fix-check-for-TINYXML2_EXPORT-on-non-windows.patch
		0003-fix-Android-SDK-below-24-does-not-support-fseeko.patch
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -Dtinyxml2_BUILD_TESTING=OFF
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/tinyxml2)
vcpkg_fixup_pkgconfig()

vcpkg_copy_pdbs()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

file(INSTALL "${SOURCE_PATH}/LICENSE.txt" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
