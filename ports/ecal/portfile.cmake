if (VCPKG_TARGET_IS_WINDOWS)
    vcpkg_check_linkage(ONLY_STATIC_LIBRARY)
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO eclipse-ecal/ecal
    REF "v${VERSION}"
    SHA512 c7743990b444fa982ef6df9b35816074cae1067ee671d9ffd5ee16fd25769dce09b2a09fb35e0fd759948b88857de8d6a1d8b6fa8ab4173651c3faeab854e0c4 
    HEAD_REF master
    PATCHES
        0002-fix-build.patch
        # 0003-fix-dependencies.patch
        # 0004-install-cmake-files-to-share.patch
        # 0005-remove-install-prefix-macro-value.patch
        # 0006-use-find_dependency-in-cmake-config.patch
        # 0007-allow-static-build-of-core.patch
)

# ecaludp is a git submodule; pull it explicitly for vcpkg builds.
set(ECALUDP_VERSION "0.1.2")
vcpkg_download_distfile(ECALUDP_ARCHIVE
    URLS "https://github.com/eclipse-ecal/ecaludp/archive/refs/tags/v${ECALUDP_VERSION}.tar.gz"
    FILENAME "ecaludp-${ECALUDP_VERSION}.tar.gz"
    SHA512 4f9d8c67777a63b569bd7069ca2a43eaaaa898a429c206bccfd5e90b10a733aa5f138be059cef2fcebda53987fdf0583b1d1859ecd154b9a48b5d39afd21c637
)
vcpkg_extract_source_archive_ex(
    OUT_SOURCE_PATH ECALUDP_SOURCE_PATH
    ARCHIVE "${ECALUDP_ARCHIVE}"
    REF "v${ECALUDP_VERSION}"
)
file(REMOVE_RECURSE "${SOURCE_PATH}/thirdparty/ecaludp/ecaludp")
file(COPY "${ECALUDP_SOURCE_PATH}/" DESTINATION "${SOURCE_PATH}/thirdparty/ecaludp/ecaludp")

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DECAL_USE_HDF5=ON
        -DECAL_USE_QT=OFF
        -DECAL_USE_CURL=OFF
        -DECAL_USE_CAPNPROTO=OFF
        -DECAL_USE_FTXUI=OFF
        -DECAL_BUILD_DOCS=OFF
        -DECAL_BUILD_APP_SDK=OFF
        -DECAL_BUILD_SAMPLES=OFF
        -DECAL_BUILD_TIMEPLUGINS=OFF
        -DECAL_BUILD_PY_BINDING=OFF
        -DECAL_BUILD_CSHARP_BINDING=OFF
        -DECAL_BUILD_TESTS=OFF
        -DECAL_INCLUDE_PY_SAMPLES=OFF
        -DECAL_INSTALL_SAMPLE_SOURCES=OFF
        -DECAL_USE_NPCAP=OFF
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
        -DECAL_CPACK_PACK_WITH_INNOSETUP=OFF
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
