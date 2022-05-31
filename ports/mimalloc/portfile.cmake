vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO microsoft/mimalloc
    REF v2.0.6
    SHA512 f2fc0fbfb6384e85959897f129e5d5d9acc51bda536d5cabcd7d4177dbda9fb735b8a8c239b961f8bea31d37c9ae10f66da23aa91d497f95393253d4ac792bb3
    HEAD_REF master
    PATCHES
        fix-install-paths.patch
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        asm         MI_SEE_ASM
        secure      MI_SECURE
        override    MI_OVERRIDE
)

if(MI_OVERRIDE AND VCPKG_TARGET_IS_WINDOWS)
    vcpkg_check_linkage(
        ONLY_DYNAMIC_LIBRARY
        ONLY_DYNAMIC_CRT
    )
endif()

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    if(NOT VCPKG_TARGET_IS_WINDOWS AND MI_OVERRIDE)
        set(MI_BUILD_OBJECT ON)
    else()
        set(MI_BUILD_STATIC ON)
    endif()
elseif(VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic")
    set(MI_BUILD_SHARED ON)
endif()

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS_DEBUG
        -DMI_DEBUG_FULL=ON
    OPTIONS_RELEASE
        -DMI_DEBUG_FULL=OFF
    OPTIONS
        -DMI_BUILD_TESTS=OFF
        -DMI_BUILD_STATIC=${MI_BUILD_STATIC}
        -DMI_BUILD_SHARED=${MI_BUILD_SHARED}
        -DMI_BUILD_OBJECT=${MI_BUILD_OBJECT}
        -DMI_INSTALL_TOPLEVEL=ON
        ${FEATURE_OPTIONS}
)

vcpkg_cmake_install()

vcpkg_copy_pdbs()

file(COPY
    "${CMAKE_CURRENT_LIST_DIR}/vcpkg-cmake-wrapper.cmake"
    DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}"
)
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/mimalloc)

if(MI_OVERRIDE)
    file(REMOVE "${CURRENT_PACKAGES_DIR}/include/mimalloc-override.h")
else()
    if(VCPKG_TARGET_IS_WINDOWS)
        file(REMOVE_RECURSE
            "${CURRENT_PACKAGES_DIR}/debug/bin/mimalloc-redirect.dll"
            "${CURRENT_PACKAGES_DIR}/bin/mimalloc-redirect.dll"
            "${CURRENT_PACKAGES_DIR}/debug/bin/mimalloc-redirect32.dll"
            "${CURRENT_PACKAGES_DIR}/bin/mimalloc-redirect32.dll"
        )
    endif()
endif()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
