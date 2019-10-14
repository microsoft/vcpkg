vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO "CppMicroServices/CppMicroservices"
    REF b322441568f903ef96c0ccb03e2611d052ceb4e0
    SHA512 1673dfe9dba913890ec93e351263a924437a0d739a5858dcdc07650e1aaca30c3b4fcce59e32b201c1d65e15eb82e27912d759e4d07ecc149ae8a4f9eb1669bc
    HEAD_REF development
    PATCHES werror.patch
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA # Disable this option if project cannot be built with Ninja
    OPTIONS
        -DTOOLS_INSTALL_DIR:STRING=tools/cppmicroservices
        -DAUXILIARY_INSTALL_DIR:STRING=share/cppmicroservices
)

vcpkg_install_cmake()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

# Handle copyright
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/cppmicroservices RENAME copyright)

vcpkg_fixup_cmake_targets()

# CppMicroServices uses a custom resource compiler to compile resources
# the zipped resources are then appended to the target which cause the linker to crash
# when compiling a static library
if(NOT BUILD_SHARED_LIBS)
    set(VCPKG_POLICY_EMPTY_PACKAGE enabled)
endif()
