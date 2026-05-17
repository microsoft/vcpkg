vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Microsoft/DirectXMath
    REF may2026
    SHA512 e10b6e0351bb3de10f6e6d99222d1e3f9fadb20435a86875f679e32e6fe46c98e7c503fcdf179445bab87676248cd33d3f113087ed50a3c8269e432a7e2cc293
    HEAD_REF main
)

vcpkg_check_features(
    OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        xdsp BUILD_XDSP
        dx11 BUILD_DX11
        dx12 BUILD_DX12
)

set(EXTRA_OPTIONS "")

if(("dx11" IN_LIST FEATURES) OR ("dx12" IN_LIST FEATURES))
    vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

    list(APPEND EXTRA_OPTIONS -DBUILD_SHMATH=ON)
endif()

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS ${FEATURE_OPTIONS} ${EXTRA_OPTIONS}
    MAYBE_UNUSED_VARIABLES BUILD_DX11 BUILD_DX12
)

vcpkg_cmake_install()

file(INSTALL "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/DirectXMath.pc" DESTINATION "${CURRENT_PACKAGES_DIR}/share/pkgconfig")

vcpkg_fixup_pkgconfig()
vcpkg_cmake_config_fixup(CONFIG_PATH share/directxmath)

if(("dx11" IN_LIST FEATURES) OR ("dx12" IN_LIST FEATURES))
    vcpkg_cmake_config_fixup(CONFIG_PATH share/directxsh)
endif()

if("xdsp" IN_LIST FEATURES)
    vcpkg_cmake_config_fixup(CONFIG_PATH share/xdsp)
endif()

if(NOT VCPKG_TARGET_IS_WINDOWS)
    vcpkg_download_distfile(
        SAL_HEADER
        URLS "https://raw.githubusercontent.com/dotnet/runtime/v9.0.2/src/coreclr/pal/inc/rt/sal.h"
        FILENAME "sal.h"
        SHA512 8085f67bfa4ce01ae89461cadf72454a9552fde3f08b2dcc3de36b9830e29ce7a6192800f8a5cb2a66af9637be0017e85719826a4cfdade508ae97f319e0ee8e
    )

    file(INSTALL
      ${DOWNLOADS}/sal.h
      DESTINATION ${CURRENT_PACKAGES_DIR}/include)
endif()

if(("dx11" IN_LIST FEATURES) OR ("dx12" IN_LIST FEATURES))
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
else()
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug")
endif()

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")

if(("dx11" IN_LIST FEATURES) OR ("dx12" IN_LIST FEATURES))
    file(READ "${CMAKE_CURRENT_LIST_DIR}/shmathusage" USAGE_CONTENT)
    file(APPEND "${CURRENT_PACKAGES_DIR}/share/${PORT}/usage" ${USAGE_CONTENT})
endif()

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
