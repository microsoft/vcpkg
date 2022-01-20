vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO nu-book/zxing-cpp
    REF v1.2.0
    SHA512 e61b4e44ccaf0871b5d8badf9ce0a81576f55e5d6a9458907b9b599a66227adceabb8d51a0c47b32319d8aeff93e758b4785d3bd0440375247471d95999de487
    HEAD_REF master
    PATCHES ignore-pdb-install-symbols-in-lib.patch
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
)

vcpkg_install_cmake()

# Install the pkgconfig file
if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "release")
    file(COPY ${SOURCE_PATH}/zxing.pc.in DESTINATION ${CURRENT_PACKAGES_DIR}/lib/pkgconfig)
endif()
if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "debug")
    file(COPY ${SOURCE_PATH}/zxing.pc.in DESTINATION ${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig)
endif()
vcpkg_fixup_pkgconfig()
vcpkg_copy_pdbs()
vcpkg_fixup_cmake_targets(
    CONFIG_PATH lib/cmake/ZXing
    TARGET_PATH share/ZXing
    )

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
# file(INSTALL ${CMAKE_CURRENT_LIST_DIR}/vcpkg-cmake-wrapper.cmake DESTINATION ${CURRENT_PACKAGES_DIR}/share/ZXing)
# Handle copyright
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/zxing-cpp RENAME copyright)