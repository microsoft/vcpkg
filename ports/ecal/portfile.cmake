if (VCPKG_TARGET_IS_WINDOWS)
    vcpkg_check_linkage(ONLY_DYNAMIC_LIBRARY)
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO continental/ecal
    REF 88d77f278f5e8f3dcb9b4443e3a4e2bc9a3cf5ce #eCAL v5.9.0
    SHA512 a483568b16ae191410d7a8cd8bfba59570be2a2f912f3fa9718fe74a4a5f3de910bed5831781e38617924da69c1cc625836df2e507a9ef7dea04e03c597de8fe
    HEAD_REF master
    PATCHES
        fix-build.patch
        disable-app-plugins.patch
        fix-dependencies.patch
)

file(REMOVE "${SOURCE_PATH}/cmake/Modules/Findasio.cmake")

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DHAS_HDF5=ON
        -DHAS_QT5=OFF
        -DHAS_CURL=ON
        -DHAS_CAPNPROTO=OFF
        -DBUILD_DOCS=OFF
        -DBUILD_APPS=OFF
        -DBUILD_SAMPLES=OFF
        -DBUILD_TIME=ON
        -DBUILD_PY_BINDING=OFF
        -DBUILD_CSHARP_BINDING=OFF
        -DBUILD_ECAL_TESTS=OFF
        -DECAL_LAYER_ICEORYX=OFF
        -DECAL_INCLUDE_PY_SAMPLES=OFF
        -DECAL_INSTALL_SAMPLE_SOURCES=OFF
        -DECAL_JOIN_MULTICAST_TWICE=OFF
        -DECAL_NPCAP_SUPPORT=OFF
        -DECAL_THIRDPARTY_BUILD_CMAKE_FUNCTIONS=ON
        -DECAL_THIRDPARTY_BUILD_SPDLOG=OFF 
        -DECAL_THIRDPARTY_BUILD_TINYXML2=OFF
        -DECAL_THIRDPARTY_BUILD_FINEFTP=OFF
        -DECAL_THIRDPARTY_BUILD_TERMCOLOR=OFF
        -DECAL_THIRDPARTY_BUILD_GTEST=OFF
        -DECAL_THIRDPARTY_BUILD_PROTOBUF=OFF
        -DECAL_THIRDPARTY_BUILD_CURL=OFF
        -DECAL_THIRDPARTY_BUILD_HDF5=OFF
        #-DECAL_LINK_HDF5_SHARED=OFF Don't need it since it was fixed in the dependecies patch 
        -DCPACK_PACK_WITH_INNOSETUP=OFF
)

vcpkg_cmake_install()
vcpkg_copy_pdbs()

# Install the helper_functions scripts first
file(INSTALL "${CURRENT_PACKAGES_DIR}/lib/cmake/eCAL/helper_functions" DESTINATION "${CURRENT_PACKAGES_DIR}/share/eCAL")
vcpkg_cmake_config_fixup(PACKAGE_NAME eCAL CONFIG_PATH lib/cmake/eCAL)

# Remove unnecessary cmake functions
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/cmake" "${CURRENT_PACKAGES_DIR}/debug/cmake")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")


file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/cfg" "${CURRENT_PACKAGES_DIR}/debug/cfg")

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

file(INSTALL "${SOURCE_PATH}/LICENSE.txt" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
