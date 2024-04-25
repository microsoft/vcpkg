vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO google/marl
    REF aa9e85b2189d6f5dbba6909275661b37dfb5de69 #2023-06-28
    SHA512 fc4869d791608fa9198da896b6687fcc79e830766f3192ca6d7b28ba3156a06618901677e66f0b08a472a602a62d88f09ff49917a6749f410d92c2911f14d736
    HEAD_REF main
)

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "dynamic" MARL_BUILD_SHARED)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DMARL_BUILD_SHARED=${MARL_BUILD_SHARED}
        -DMARL_INSTALL=ON
)

vcpkg_cmake_install()

if(MARL_BUILD_SHARED)
    vcpkg_replace_string(
        "${CURRENT_PACKAGES_DIR}/include/marl/export.h"
        "#ifdef MARL_DLL"
        "#if 1  // #ifdef MARL_DLL"
    )
endif()

vcpkg_cmake_config_fixup(CONFIG_PATH "lib/cmake/${PORT}")

vcpkg_copy_pdbs()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
