vcpkg_fail_port_install(ON_TARGET "uwp")

if (VCPKG_TARGET_IS_WINDOWS)
    vcpkg_check_linkage(ONLY_STATIC_LIBRARY)
endif()

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "static" STATICLIBS)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO dnp3/opendnp3
    REF 3.1.0
    SHA512 838a816a8d65d3c99dc489e0e3e4d25f0acdbe0f6f3cc21a6fdbaea11f84f7b1f54958097763d0eae8e1860ba209da4e5377cd3ea6ab08a48a25429860063179
    HEAD_REF master
)

file(COPY ${CURRENT_PORT_DIR}/opendnp3-config.cmake.in DESTINATION ${SOURCE_PATH})

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS -DSTATICLIBS=${STATICLIBS} -DDNP3_TLS=ON
)

vcpkg_install_cmake()

vcpkg_copy_pdbs()

vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake TARGET_PATH share/opendnp3)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)