vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO CppMicroServices/CppMicroservices
    REF "v${VERSION}"
    SHA512 26b76b124fba50a079b002867f5d349b4719833358f09712a73bc3f4370362bc27b01eb7ba31e3a0d01f101f70e5be45d5d99fe9f25216eadacc02127459d91b
    HEAD_REF development
    PATCHES
        werror.patch
        fix_strnicmp.patch
        devendor_boost_absl.patch
)

# TODO: De-vendor everything
file(REMOVE_RECURSE
  "${SOURCE_PATH}/third_party/absl"
  "${SOURCE_PATH}/third_party/boost"
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DTOOLS_INSTALL_DIR:STRING=tools/cppmicroservices
        -DAUXILIARY_INSTALL_DIR:STRING=share/cppmicroservices
        -DUS_USE_SYSTEM_GTEST=TRUE
        -DUS_BUILD_TESTING=FALSE
        -DUS_USE_SYSTEM_BOOST=TRUE
)

vcpkg_cmake_install(ADD_BIN_TO_PATH)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_cmake_config_fixup()

# Handle copyright
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")

# CppMicroServices uses a custom resource compiler to compile resources
# the zipped resources are then appended to the target which cause the linker to crash
# when compiling a static library
if(NOT BUILD_SHARED_LIBS)
    set(VCPKG_POLICY_EMPTY_PACKAGE enabled)
endif()