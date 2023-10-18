vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO CppMicroServices/CppMicroservices
    REF "v${VERSION}"
    SHA512 4743846a8ba45e6bd320c93bb3bd443b5dac16ea0bbf55bda6212e9200a40ee29031fd74c6141de4c6b5ef9ad3e70789d13fda25b40638547782d386a12dd7e2
    HEAD_REF development
    PATCHES
        werror.patch
        fix_strnicmp.patch
        remove-wx.patch
)
file(REMOVE_RECURSE
    "${SOURCE_PATH}/third_party/googletest"
)
# no absolute paths
vcpkg_replace_string("${SOURCE_PATH}/framework/include/FrameworkConfig.h.in" "@PROJECT_SOURCE_DIR@" "")

#nowide download
vcpkg_from_github(
    OUT_SOURCE_PATH NOWIDE_SOURCE_PATH
    REPO boostorg/nowide
    REF 02f40f0b5f5686627fcddae93ff88ca399db4766
    SHA512 e68e0704896726c7a94b8ace0e03c5206b4c7acd23a6b05f6fb2660abe30611ac6913cf5fab7b57eaff1990a7c28aeee8c9f526b60f7094c0c201f90b715d6c6
    HEAD_REF develop
)
file(REMOVE_RECURSE "${SOURCE_PATH}/third_party/boost/nowide")
file(RENAME "${NOWIDE_SOURCE_PATH}" "${SOURCE_PATH}/third_party/boost/nowide")

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        "-DAUXILIARY_INSTALL_DIR:STRING=share/cppmicroservices"
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH "share/cppmicroservices/cmake")
vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/share/cppmicroservices/CppMicroServicesConfig.cmake" "cppmicroservices/cmake" "cppmicroservices")

if(VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic")
    vcpkg_copy_tools(TOOL_NAMES SCRCodeGen3)
endif()
vcpkg_copy_tools(TOOL_NAMES jsonschemavalidator usResourceCompiler3 usShell3 AUTO_CLEAN)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include" "${CURRENT_PACKAGES_DIR}/debug/share")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
