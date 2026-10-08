if (VCPKG_TARGET_IS_WINDOWS)
    vcpkg_check_linkage(ONLY_STATIC_LIBRARY)
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO eclipse-ecal/ecal
    REF "v${VERSION}"
    SHA512 de314df15a3ac7695d279102c62753cc04c38e4f35c79d09e7bb6080a424114ae6f349ca9e3f966d7f745427c1852c1fff965963c52b81a60b5a197b5a52bd5c
    HEAD_REF master
    PATCHES
        0002-fix-build.patch
        0003-fix-dependencies.patch
        0005-remove-install-prefix-macro-value.patch
        0006-use-find_dependency-in-cmake-config.patch
        0007-allow-static-build-of-core.patch
        0008-protobuf-linkage.patch
        0009-protobuf-6.patch
        0010-disable-build-time-tools.patch
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        "-DCMAKE_PROJECT_TOP_LEVEL_INCLUDES=${CMAKE_CURRENT_LIST_DIR}/dependencies.cmake"
        -DECAL_USE_HDF5=ON
        -DECAL_USE_QT=OFF
        -DECAL_USE_CURL=OFF
        -DECAL_USE_CAPNPROTO=OFF
        -DECAL_USE_FTXUI=OFF
        -DECAL_BUILD_DOCS=OFF
        -DECAL_BUILD_APPS=OFF
        -DECAL_BUILD_SAMPLES=OFF
        -DECAL_BUILD_TIMEPLUGINS=OFF
        -DECAL_BUILD_PY_BINDING=OFF
        -DECAL_BUILD_CSHARP_BINDING=OFF
        -DECAL_BUILD_TESTS=OFF
        -DECAL_INSTALL_SAMPLE_SOURCES=OFF
        -DECAL_USE_NPCAP=OFF
        -DECAL_CPACK_PACK_WITH_INNOSETUP=OFF
        -DECAL_BUILD_VERSION="${VERSION}"
)

vcpkg_cmake_install()
vcpkg_copy_pdbs()

if(NOT VCPKG_TARGET_IS_WINDOWS)
    set(ecal_tools ecal_process_stub)
    # On ELF platforms, the unversioned executable is a symlink.
    if(EXISTS "${CURRENT_PACKAGES_DIR}/bin/ecal_process_stub-${VERSION}")
        list(APPEND ecal_tools "ecal_process_stub-${VERSION}")
    endif()
    vcpkg_copy_tools(TOOL_NAMES ${ecal_tools} AUTO_CLEAN)
endif()

vcpkg_cmake_config_fixup(PACKAGE_NAME ecal CONFIG_PATH lib/cmake/eCAL)
vcpkg_cmake_config_fixup(PACKAGE_NAME CMakeFunctions CONFIG_PATH share/CMakeFunctions)

# Remove extra debug files
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

# Configuration files are optional; the SDK uses built-in defaults.
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/etc" "${CURRENT_PACKAGES_DIR}/debug/etc")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE.txt")
file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
