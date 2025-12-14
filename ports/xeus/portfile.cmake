vcpkg_download_distfile(REMOVE_LTO_PATCH
    URLS https://github.com/jupyter-xeus/xeus/commit/2dcccb574713f81b7d69baed2bd543bf6798f671.diff?full_index=1
    FILENAME xeus-remove-lto-2dcccb574713f81b7d69baed2bd543bf6798f671.diff
    SHA512 e0ae94825cb606dcd250394aee5c88e23bd5440a38c9f4cd8059590ec01dc1ec751ab0bb413788439dfbbfb2c28c68a82cb56efa11d05c3a2d63d420876e1e0b
)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO QuantStack/xeus
    REF 0f6327a2782181e7ded9729abb32b7d8eb690aea # 0.24.3
    SHA512 2c0ccd1bebf487a9a73e73ecfb74b7605756652b2a84c71e739d7b2d8923960594c025e36d75cec850c5f0e38614a20299feccea6cfbe9ea0f66bdf315af02b4
    HEAD_REF master
    PATCHES
        Fix-Compile-nlohmann-json.patch
        "${REMOVE_LTO_PATCH}"
)

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "static" BUILD_STATIC_LIBS)
string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "dynamic" BUILD_SHARED_LIBS)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DBUILD_EXAMPLES=OFF
        -DXEUS_BUILD_STATIC_LIBS=${BUILD_STATIC_LIBS}
        -DXEUS_BUILD_SHARED_LIBS=${BUILD_SHARED_LIBS}
        -DBUILD_TESTS=OFF
        -DDOWNLOAD_GTEST=OFF
        -DDISABLE_ARCH_NATIVE=OFF
        -DXEUS_DISABLE_ARCH_NATIVE=On
)

vcpkg_cmake_install()

vcpkg_copy_pdbs()

vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/${PORT})

file(COPY "${CMAKE_CURRENT_LIST_DIR}/vcpkg-cmake-wrapper.cmake" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include" "${CURRENT_PACKAGES_DIR}/debug/share")

if(VCPKG_LIBRARY_LINKAGE STREQUAL static)
    vcpkg_replace_string(${CURRENT_PACKAGES_DIR}/include/xeus/xeus.hpp
        "#ifdef XEUS_STATIC_LIB"
        "#if 1 // #ifdef XEUS_STATIC_LIB"
    )
	file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/bin" "${CURRENT_PACKAGES_DIR}/debug/bin")
endif()

# Handle copyright
file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)

# Install usage
file(COPY "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
