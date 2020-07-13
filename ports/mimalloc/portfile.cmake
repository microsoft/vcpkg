vcpkg_fail_port_install(ON_ARCH "arm" "arm64" ON_TARGET "uwp")

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO microsoft/mimalloc
    REF e6c7b778fb53663985e0a36016a3a087af71d783 # v1.6.3
    SHA512 486b16396a8e750834f02a1c5954899667a8d9dc1ac4e86a9051829ef624defe61ac7fb4d1f5cfb20f79d635868f1fdcc00bd310bea7fb17a44ae8e8dca60c27
    HEAD_REF master
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    asm         MI_SEE_ASM
    secure      MI_SECURE
    override    MI_OVERRIDE
)

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
        -DMI_BUILD_SHARED=ON
        -DMI_BUILD_STATIC=ON
        ${FEATURE_OPTIONS}
)

vcpkg_install_cmake()

vcpkg_copy_pdbs()

file(MAKE_DIRECTORY ${CURRENT_PACKAGES_DIR}/debug/bin)
file(MAKE_DIRECTORY ${CURRENT_PACKAGES_DIR}/bin)
file(MAKE_DIRECTORY ${CURRENT_PACKAGES_DIR}/lib)
file(MAKE_DIRECTORY ${CURRENT_PACKAGES_DIR}/include)

file(COPY "${CURRENT_PACKAGES_DIR}/debug/lib/mimalloc-1.6/mimalloc-debug.lib" DESTINATION "${CURRENT_PACKAGES_DIR}/debug/lib/")
file(COPY "${CURRENT_PACKAGES_DIR}/debug/lib/mimalloc-1.6/mimalloc-debug.dll" DESTINATION "${CURRENT_PACKAGES_DIR}/debug/bin/")
file(COPY "${CURRENT_PACKAGES_DIR}/lib/mimalloc-1.6/include/mimalloc.h" DESTINATION "${CURRENT_PACKAGES_DIR}/include/")
file(COPY "${CURRENT_PACKAGES_DIR}/lib/mimalloc-1.6/include/mimalloc-new-delete.h" DESTINATION "${CURRENT_PACKAGES_DIR}/include")
file(COPY "${CURRENT_PACKAGES_DIR}/lib/mimalloc-1.6/include/mimalloc-override.h" DESTINATION "${CURRENT_PACKAGES_DIR}/include")
file(COPY "${CURRENT_PACKAGES_DIR}/lib/mimalloc-1.6/mimalloc.dll" DESTINATION "${CURRENT_PACKAGES_DIR}/bin/")
file(COPY "${CURRENT_PACKAGES_DIR}/lib/mimalloc-1.6/mimalloc.lib" DESTINATION "${CURRENT_PACKAGES_DIR}/lib/")

file(COPY "${CURRENT_PACKAGES_DIR}/debug/lib/mimalloc-1.6/mimalloc-static-debug.lib" DESTINATION "${CURRENT_PACKAGES_DIR}/debug/lib")
file(COPY "${CURRENT_PACKAGES_DIR}/lib/mimalloc-1.6/mimalloc-static.lib" DESTINATION "${CURRENT_PACKAGES_DIR}/lib")
file(COPY "${CURRENT_PACKAGES_DIR}/lib/mimalloc-1.6/include/mimalloc.h" DESTINATION "${CURRENT_PACKAGES_DIR}/include/")
file(COPY "${CURRENT_PACKAGES_DIR}/lib/mimalloc-1.6/include/mimalloc-new-delete.h" DESTINATION "${CURRENT_PACKAGES_DIR}/include")
file(COPY "${CURRENT_PACKAGES_DIR}/lib/mimalloc-1.6/include/mimalloc-override.h" DESTINATION "${CURRENT_PACKAGES_DIR}/include")

vcpkg_fixup_cmake_targets(CONFIG_PATH lib/mimalloc-1.6/cmake)

vcpkg_replace_string(
    ${CURRENT_PACKAGES_DIR}/share/${PORT}/mimalloc.cmake
    "lib/${lib_install_dir}/"
    ""
)

if (WIN32)
    if("${CMAKE_SIZEOF_VOID_P}" STREQUAL "4")
        file(COPY ${SOURCE_PATH}/bin/mimalloc-redirect32.dll DESTINATION ${CURRENT_PACKAGES_DIR}/bin)
        file(COPY ${SOURCE_PATH}/bin/mimalloc-redirect32.lib DESTINATION ${CURRENT_PACKAGES_DIR}/lib)
        file(COPY ${SOURCE_PATH}/bin/mimalloc-redirect32.dll DESTINATION ${CURRENT_PACKAGES_DIR}/debug/bin)
        file(COPY ${SOURCE_PATH}/bin/mimalloc-redirect32.lib DESTINATION ${CURRENT_PACKAGES_DIR}/debug/lib)
    else()
        file(COPY ${SOURCE_PATH}/bin/mimalloc-redirect.dll DESTINATION ${CURRENT_PACKAGES_DIR}/bin)
        file(COPY ${SOURCE_PATH}/bin/mimalloc-redirect.lib DESTINATION ${CURRENT_PACKAGES_DIR}/lib)
        file(COPY ${SOURCE_PATH}/bin/mimalloc-redirect.dll DESTINATION ${CURRENT_PACKAGES_DIR}/debug/bin)
        file(COPY ${SOURCE_PATH}/bin/mimalloc-redirect.lib DESTINATION ${CURRENT_PACKAGES_DIR}/debug/lib)
    endif()
endif (WIN32)

file(COPY ${CMAKE_CURRENT_LIST_DIR}/vcpkg-cmake-wrapper.cmake DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT})

file(REMOVE_RECURSE
    ${CURRENT_PACKAGES_DIR}/debug/lib/mimalloc-1.6
    ${CURRENT_PACKAGES_DIR}/debug/share
    ${CURRENT_PACKAGES_DIR}/lib/mimalloc-1.6
)

vcpkg_replace_string(
    ${CURRENT_PACKAGES_DIR}/share/mimalloc/mimalloc.cmake
    "mimalloc-1.6/"
    ""
)

vcpkg_replace_string(
    ${CURRENT_PACKAGES_DIR}/share/mimalloc/mimalloc.cmake
    "lib/include"
    "include"
)

vcpkg_replace_string(
    ${CURRENT_PACKAGES_DIR}/share/mimalloc/mimalloc-debug.cmake
    "mimalloc-1.6/"
    ""
)

vcpkg_replace_string(
    ${CURRENT_PACKAGES_DIR}/share/mimalloc/mimalloc-debug.cmake
    "debug/lib/mimalloc-debug.dll"
    "debug/bin/mimalloc-debug.dll"
)

vcpkg_replace_string(
    ${CURRENT_PACKAGES_DIR}/share/mimalloc/mimalloc-release.cmake
    "mimalloc-1.6/"
    ""
)

vcpkg_replace_string(
    ${CURRENT_PACKAGES_DIR}/share/mimalloc/mimalloc-release.cmake
    "lib/mimalloc.dll"
    "bin/mimalloc.dll"
)

if(VCPKG_LIBRARY_LINKAGE STREQUAL dynamic)
    vcpkg_replace_string(
        ${CURRENT_PACKAGES_DIR}/include/mimalloc.h
        "!defined(MI_SHARED_LIB)"
        "0 // !defined(MI_SHARED_LIB)"
    )
endif()

file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
