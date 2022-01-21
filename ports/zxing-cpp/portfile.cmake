vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO nu-book/zxing-cpp
    REF v1.2.0
    SHA512 e61b4e44ccaf0871b5d8badf9ce0a81576f55e5d6a9458907b9b599a66227adceabb8d51a0c47b32319d8aeff93e758b4785d3bd0440375247471d95999de487
    HEAD_REF master
    PATCHES ignore-pdb-install-symbols-in-lib.patch
)

if(VCPKG_CMAKE_SYSTEM_NAME STREQUAL "WindowsStore")
    set(SOURCE_PATH "${SOURCE_PATH}/wrappers/winrt")
    set(VCPKG_BUILD_TYPE release)
    vcpkg_cmake_configure(
        SOURCE_PATH ${SOURCE_PATH}
    )
else()
    vcpkg_cmake_configure(
        SOURCE_PATH ${SOURCE_PATH}
        OPTIONS
            -DBUILD_BLACKBOX_TESTS=OFF
            -DBUILD_EXAMPLES=OFF
    )
endIf()

vcpkg_cmake_install()

# Install the pkgconfig file
if(NOT VCPKG_CMAKE_SYSTEM_NAME STREQUAL "WindowsStore")
    if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "release")
        file(COPY ${SOURCE_PATH}/zxing.pc.in DESTINATION ${CURRENT_PACKAGES_DIR}/lib/pkgconfig)
    endif()
    if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "debug")
        file(COPY ${SOURCE_PATH}/zxing.pc.in DESTINATION ${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig)
    endif()
endif()

vcpkg_fixup_pkgconfig()
vcpkg_copy_pdbs()
vcpkg_cmake_config_fixup(
    CONFIG_PATH lib/cmake/ZXing
    PACKAGE_NAME ZXing
    )

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

# Handle copyright
if(NOT VCPKG_CMAKE_SYSTEM_NAME STREQUAL "WindowsStore")
    file(INSTALL ${SOURCE_PATH}/../../LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/zxing-cpp RENAME copyright)
else()
    file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/zxing-cpp RENAME copyright)
endif()
