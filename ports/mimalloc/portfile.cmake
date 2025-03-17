vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO microsoft/mimalloc
    REF "v${VERSION}-beta"
    SHA512 a30de118b7afd9f3b66431c707432de752085ad0360b1db085736154fa4071ed643a39ff11842168c44c366a8f93c2093cb88d47177a178740089319365d77f8
    HEAD_REF master
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        asm         MI_SEE_ASM
        secure      MI_SECURE
        override    MI_OVERRIDE
)
string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "static" MI_BUILD_STATIC)
string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "dynamic" MI_BUILD_SHARED)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS_DEBUG
        -DMI_DEBUG_FULL=ON
    OPTIONS_RELEASE
        -DMI_DEBUG_FULL=OFF
    OPTIONS
        -DMI_USE_CXX=ON
        -DMI_BUILD_TESTS=OFF
        -DMI_BUILD_OBJECT=OFF
        ${FEATURE_OPTIONS}
        -DMI_BUILD_STATIC=${MI_BUILD_STATIC}
        -DMI_BUILD_SHARED=${MI_BUILD_SHARED}
        -DMI_INSTALL_TOPLEVEL=ON
)

vcpkg_cmake_install()

vcpkg_copy_pdbs()

file(COPY
    "${CMAKE_CURRENT_LIST_DIR}/vcpkg-cmake-wrapper.cmake"
    "${CMAKE_CURRENT_LIST_DIR}/usage"
    DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}"
)
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/mimalloc)

if(VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic")
    vcpkg_replace_string(
        "${CURRENT_PACKAGES_DIR}/include/mimalloc.h"
        "!defined(MI_SHARED_LIB)"
        "0 // !defined(MI_SHARED_LIB)"
    )
endif()
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

vcpkg_fixup_pkgconfig()
set(mi_basename "mimalloc")
if(VCPKG_TARGET_IS_WINDOWS AND VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    string(APPEND mi_basename "-static")
endif()
if("secure" IN_LIST FEATURES)
    string(APPEND mi_basename "-secure")
endif()
if(NOT "mimalloc" STREQUAL "${mi_basename}")
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/lib/pkgconfig/mimalloc.pc" " -lmimalloc" " -l${mi_basename}")
endif()
if(NOT VCPKG_BUILD_TYPE)
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig/mimalloc.pc" " -lmimalloc" " -l${mi_basename}-debug")
endif()

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
