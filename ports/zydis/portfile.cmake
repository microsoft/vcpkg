vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO zyantific/zydis
    REF 4022f22f9280650082a9480519c86a6e2afde2f3 #v3.2.1
    SHA512 da3ff582d3c4cbb5e4053cd468f181550f02d0a1713a39944266e6d1b0e3249e24461f87171ef99e249e6d5b2fc39fcca402518c569399ae5d4a64e0d3dc4b3b
    HEAD_REF master
)

vcpkg_from_github(
    OUT_SOURCE_PATH ZYCORE_SOURCE_PATH
    REPO zyantific/zycore-c
    REF 8983325bf0007f0d6d2ea28a49040a77f47bd611 #2021-11-17
    SHA512 e41dc70413d2a5bb5ac549ab602c54bfaba3ea61dcd0817bfdf20e4e12d6b3e1cc587fa58ba653bd7513aa735311d3b7b4bc408d8092a98ab6cf1b44012e4e22
    HEAD_REF master
)

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "dynamic" ZYDIS_BUILD_SHARED_LIB)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        "-DZYDIS_BUILD_SHARED_LIB=${ZYDIS_BUILD_SHARED_LIB}"
        "-DZYDIS_ZYCORE_PATH=${ZYCORE_SOURCE_PATH}"
)

vcpkg_cmake_install()

vcpkg_cmake_configure(
    SOURCE_PATH "${ZYCORE_SOURCE_PATH}"
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake)

vcpkg_copy_tools(TOOL_NAMES ZydisDisasm ZydisInfo AUTO_CLEAN)

if(VCPKG_LIBRARY_LINKAGE STREQUAL static)
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/bin" "${CURRENT_PACKAGES_DIR}/debug/bin")
endif()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
vcpkg_copy_pdbs()

file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
