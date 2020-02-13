include(vcpkg_common_functions)

vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO cdcseacave/openMVS
    REF 7110659a3f5181397bc2549cea15d5350cd25c9d
    SHA512 e484a88e0040b69e489476ef20c06184d2dc2bf42452b965b4997a717c2d1f19ab7cd695563c4faacdb0ec8705d072bcfd568d7b3a32e4e8b8c632bcec57e15c
    HEAD_REF master
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DOpenMVS_USE_BREAKPAD=OFF
        -DOpenMVS_USE_CUDA=OFF
        -DINSTALL_CMAKE_DIR:STRING=share/openmvs
        -DINSTALL_BIN_DIR:STRING=bin
        -DINSTALL_LIB_DIR:STRING=lib
        -DINSTALL_INCLUDE_DIR:STRING=include
)

vcpkg_install_cmake()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

vcpkg_fixup_cmake_targets()

file(MAKE_DIRECTORY ${CURRENT_PACKAGES_DIR}/tools)
file(RENAME ${CURRENT_PACKAGES_DIR}/bin ${CURRENT_PACKAGES_DIR}/tools/openmvs)
vcpkg_copy_tool_dependencies(${CURRENT_PACKAGES_DIR}/tools/openmvs)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/bin ${CURRENT_PACKAGES_DIR}/debug/bin)

file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/openmvs RENAME copyright)
