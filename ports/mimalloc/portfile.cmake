vcpkg_fail_port_install(ON_ARCH "arm" "arm64" ON_TARGET "uwp")

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO microsoft/mimalloc
    REF a9686d6ecf00e4467e772f7c0b4ef76a15f325f6  # v1.6.4
    SHA512 a1bda1b31d1bb3a4680fec91f180a988cf5ff486dcb8848fefd9245907f7986e4c4f10ce33133a3d796a7409ba38328bd156c47eba4f19368a2226a43b1ad298
    HEAD_REF master
    PATCHES
        fix-cmake.patch
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    asm         MI_SEE_ASM
    secure      MI_SECURE
    override    MI_OVERRIDE
)
string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "static" MI_BUILD_STATIC)
string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "dynamic" MI_BUILD_SHARED)
vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS_DEBUG
        -DMI_CHECK_FULL=ON
    OPTIONS_RELEASE
        -DMI_CHECK_FULL=OFF
    OPTIONS
        -DMI_INTERPOSE=ON
        -DMI_USE_CXX=OFF
        -DMI_BUILD_TESTS=OFF
        ${FEATURE_OPTIONS}
        -DMI_BUILD_STATIC=${MI_BUILD_STATIC}
        -DMI_BUILD_SHARED=${MI_BUILD_SHARED}
)

vcpkg_install_cmake()

vcpkg_copy_pdbs()

file(GLOB lib_directories RELATIVE ${CURRENT_PACKAGES_DIR}/lib "${CURRENT_PACKAGES_DIR}/lib/${PORT}-*")
list(GET lib_directories 0 lib_install_dir)
vcpkg_fixup_cmake_targets(CONFIG_PATH lib/${lib_install_dir}/cmake)

vcpkg_replace_string(
    ${CURRENT_PACKAGES_DIR}/share/${PORT}/mimalloc.cmake
    "lib/${lib_install_dir}/"
    ""
)

file(COPY
    ${CMAKE_CURRENT_LIST_DIR}/vcpkg-cmake-wrapper.cmake
    DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT}
)

file(COPY ${CURRENT_PACKAGES_DIR}/lib/${lib_install_dir}/include DESTINATION ${CURRENT_PACKAGES_DIR})

file(REMOVE_RECURSE
    ${CURRENT_PACKAGES_DIR}/debug/lib/${lib_install_dir}
    ${CURRENT_PACKAGES_DIR}/debug/share
    ${CURRENT_PACKAGES_DIR}/lib/${lib_install_dir}
)

if(VCPKG_LIBRARY_LINKAGE STREQUAL dynamic)
    vcpkg_replace_string(
        ${CURRENT_PACKAGES_DIR}/include/mimalloc.h
        "!defined(MI_SHARED_LIB)"
        "0 // !defined(MI_SHARED_LIB)"
    )
endif()

file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
