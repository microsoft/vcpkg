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
        URLS "https://raw.githubusercontent.com/dotnet/runtime/v8.0.1/src/coreclr/pal/inc/rt/sal.h"
        FILENAME "sal.h"
        SHA512 0f5a80b97564217db2ba3e4624cc9eb308e19cc9911dae21d983c4ab37003f4756473297ba81b386c498514cedc1ef5a3553d7002edc09aeb6a1335df973095f
    )

    file(INSTALL
      ${DOWNLOADS}/sal.h
      DESTINATION ${CURRENT_PACKAGES_DIR}/include)
endif()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug")

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
