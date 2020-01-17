vcpkg_fail_port_install(ON_TARGET "uwp")

if (VCPKG_TARGET_IS_WINDOWS)
    vcpkg_check_linkage(ONLY_STATIC_LIBRARY)
endif()

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "static" STATICLIBS)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO dnp3/opendnp3
    REF 2.3.2
    SHA512 41686b5c32234088a5af3c71769b0193deb10a95d623579508cc740f126f35c18796f761093cec12ead469f0088839a680cc7d137b2f762a80c1736d71c3d90a
    HEAD_REF master
    PATCHES export-cmake.patch
)

file(COPY ${CURRENT_PORT_DIR}/opendnp3-config.cmake.in DESTINATION ${SOURCE_PATH})

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS -DSTATICLIBS=${STATICLIBS} -DDNP3_TLS=ON
)

vcpkg_install_cmake()

vcpkg_copy_pdbs()

vcpkg_fixup_cmake_targets(CONFIG_PATH share/asiodnp3 TARGET_PATH share/asiodnp3)
vcpkg_fixup_cmake_targets(CONFIG_PATH share/asiopal TARGET_PATH share/asiopal)
vcpkg_fixup_cmake_targets(CONFIG_PATH share/opendnp3 TARGET_PATH share/opendnp3)
vcpkg_fixup_cmake_targets(CONFIG_PATH share/openpal TARGET_PATH share/openpal)

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
