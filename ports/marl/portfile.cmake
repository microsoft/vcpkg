vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO google/marl
    REF 9929747c9ba6354691dbacaf14f9b35433871e5b #2022-03-02
    SHA512 454399485d292526333417474a312302aaff90cf63bc06a95c2e8b87cb92eaea547457ba3c06413e079ca29f9ea64990b9da467aeaec6ec2aa3233efddab2407
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

file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
