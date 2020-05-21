vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO "CppMicroServices/CppMicroservices"
    REF b4d3d404df01d67dfd7fc36111bc5de50e1b89d6 # v3.4.0
    SHA512 b4a55f7c86cae25e936a237108b82824458b123fa1c14d4e0218c72c444a6d7f0db8900409af321225ec818f5691894b01fd311c606463386e7ce8e81e3656c8
    HEAD_REF development
    PATCHES
        werror.patch
        fix-dependency-gtest.patch
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA # Disable this option if project cannot be built with Ninja
    OPTIONS
        -DTOOLS_INSTALL_DIR:STRING=tools/cppmicroservices
        -DAUXILIARY_INSTALL_DIR:STRING=share/cppmicroservices
        -DUS_USE_SYSTEM_GTEST=TRUE
)

vcpkg_install_cmake()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)


vcpkg_fixup_cmake_targets()

# Handle copyright
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)

# CppMicroServices uses a custom resource compiler to compile resources
# the zipped resources are then appended to the target which cause the linker to crash
# when compiling a static library
if(NOT BUILD_SHARED_LIBS)
    set(VCPKG_POLICY_EMPTY_PACKAGE enabled)
endif()