vcpkg_fail_port_install(ON_TARGET "UWP")

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO editorconfig/editorconfig-core-c
    REF v0.12.2
    SHA512 6ab3e4f7f95c83c0781064ca15bb70394bb947f9d4cd1348224f02e25c65021d14439b913775d7cfafb93476158799c34438fa548adf3c7ec6dbfd6f1052a046
    HEAD_REF master
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
)

vcpkg_install_cmake()

if(VCPKG_LIBRARY_LINKAGE STREQUAL static)
    file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/bin ${CURRENT_PACKAGES_DIR}/debug/bin)
endif()

if(VCPKG_TARGET_IS_WINDOWS)
    set(EXECUTABLE_SUFFIX ".exe")
else()
    set(EXECUTABLE_SUFFIX "")
endif()

if(EXISTS "${CURRENT_PACKAGES_DIR}/bin/editorconfig${EXECUTABLE_SUFFIX}")
    file(REMOVE ${CURRENT_PACKAGES_DIR}/bin/editorconfig${EXECUTABLE_SUFFIX})
endif()
if(EXISTS "${CURRENT_PACKAGES_DIR}/debug/bin/editorconfig${EXECUTABLE_SUFFIX}")
    file(REMOVE ${CURRENT_PACKAGES_DIR}/debug/bin/editorconfig${EXECUTABLE_SUFFIX})
endif()
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/share/man)

file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/editorconfig-core-c RENAME copyright)
