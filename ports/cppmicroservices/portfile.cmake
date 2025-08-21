vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO CppMicroServices/CppMicroservices
    REF "v${VERSION}"
    SHA512 6378f929bebd2d77d260791c0518dc0fcda43a19ade2475d5e20698c594c178ed1f9123d65017fc25c34c95437d25d5eca889224c6650a1c37584842ddc6dbab
    HEAD_REF development
    PATCHES
        werror.patch
        fix_strnicmp.patch
        devendor_boost_absl.patch
        remove-ut-macro.patch
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

vcpkg_cmake_config_fixup()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

# Handle copyright
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")

# CppMicroServices uses a custom resource compiler to compile resources
# the zipped resources are then appended to the target which cause the linker to crash
# when compiling a static library
if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    set(VCPKG_POLICY_EMPTY_PACKAGE enabled)
endif()
