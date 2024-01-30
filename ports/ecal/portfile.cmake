if (VCPKG_TARGET_IS_WINDOWS)
    vcpkg_check_linkage(ONLY_STATIC_LIBRARY)
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO eclipse-ecal/ecal
    REF v${VERSION}
    SHA512 e9bc6c579a5331bdecc0384fb1cbac6bf63cb3910e26a4004d48c3a25528fed66413a2c80f4d866d3958d3800579c57a7298e61fca20adf9b24f5daa2e07ed3d
    HEAD_REF master
    PATCHES
        0001-disable-app-plugins.patch
        0002-fix-build.patch
        0003-fix-dependencies.patch
        0004-install-cmake-files-to-share.patch
        0005-remove-install-prefix-macro-value.patch
        0006-use-find_dependency-in-cmake-config.patch
        0007-allow-static-build-of-core.patch
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DHAS_HDF5=ON
        -DHAS_QT5=OFF
        -DHAS_CURL=OFF
        -DHAS_CAPNPROTO=OFF
        -DHAS_FTXUI=OFF
        -DBUILD_DOCS=OFF
        -DBUILD_APPS=OFF
        -DBUILD_SAMPLES=OFF
        -DBUILD_TIME=OFF
        -DBUILD_PY_BINDING=OFF
        -DBUILD_CSHARP_BINDING=OFF
        -DBUILD_ECAL_TESTS=OFF
        -DECAL_INCLUDE_PY_SAMPLES=OFF
        -DECAL_INSTALL_SAMPLE_SOURCES=OFF
        -DECAL_JOIN_MULTICAST_TWICE=OFF
        -DECAL_NPCAP_SUPPORT=OFF
        -DECAL_THIRDPARTY_BUILD_CMAKE_FUNCTIONS=ON
        -DECAL_THIRDPARTY_BUILD_SPDLOG=OFF
        -DECAL_THIRDPARTY_BUILD_TINYXML2=OFF
        -DECAL_THIRDPARTY_BUILD_FINEFTP=OFF
        -DECAL_THIRDPARTY_BUILD_TERMCOLOR=OFF
        -DECAL_THIRDPARTY_BUILD_TCP_PUBSUB=OFF
        -DECAL_THIRDPARTY_BUILD_RECYCLE=OFF
        -DECAL_THIRDPARTY_BUILD_FTXUI=OFF
        -DECAL_THIRDPARTY_BUILD_GTEST=OFF
        -DECAL_THIRDPARTY_BUILD_UDPCAP=OFF
        -DECAL_THIRDPARTY_BUILD_PROTOBUF=OFF
        -DECAL_THIRDPARTY_BUILD_YAML-CPP=OFF
        -DECAL_THIRDPARTY_BUILD_CURL=OFF
        -DECAL_THIRDPARTY_BUILD_HDF5=OFF
        -DCPACK_PACK_WITH_INNOSETUP=OFF
        -DDISABLE_FIND_PACKAGE_OVERLOAD=ON # From patch, disable find_package macro
        -DECAL_BUILD_VERSION="${VERSION}"
)

vcpkg_cmake_install()
vcpkg_copy_pdbs()

vcpkg_cmake_config_fixup(PACKAGE_NAME eCAL           CONFIG_PATH share/eCAL)
vcpkg_cmake_config_fixup(PACKAGE_NAME CMakeFunctions CONFIG_PATH share/CMakeFunctions)

# Remove extra debug files
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

# global ini files not strictly required
if (VCPKG_TARGET_IS_WINDOWS)
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/cfg" "${CURRENT_PACKAGES_DIR}/debug/cfg")
else()
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/etc" "${CURRENT_PACKAGES_DIR}/debug/etc")
endif()

# Install copyright and usage
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE.txt")
file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
