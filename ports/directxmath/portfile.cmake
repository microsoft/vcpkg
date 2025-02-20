vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Microsoft/DirectXMath
    REF oct2024
    SHA512 501a3c8b51cd6d3d4fbcc511c2c37f1d0511bd84d546d5254c2bc81238c11242b9d62c7a153ee110dc9d96a0c7d2544428d8de832c943b680b0cb09d8e3760f2
    HEAD_REF main
    PATCHES include-path-fix.patch
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_cmake_install()

file(INSTALL "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/DirectXMath.pc" DESTINATION "${CURRENT_PACKAGES_DIR}/share/pkgconfig")

vcpkg_fixup_pkgconfig()
vcpkg_cmake_config_fixup(CONFIG_PATH share/directxmath)

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

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug")

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
