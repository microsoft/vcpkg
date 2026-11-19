vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Azure/azure-uamqp-c
    REF 49b6cf5d51b5fccd8d3961d1d4a1c5cfcf39e9a5
    SHA512 99168b597b5b16566450c1e61b325d85528dae9b485dbfaa51446de89d7a78437ac0ae14f7185ad83ddff66927346a6cb7a4bc377806ae4b0fcf81d10897e5ef
    HEAD_REF master
)

file(COPY ${CURRENT_INSTALLED_DIR}/share/azure-c-shared-utility/azure_iot_build_rules.cmake DESTINATION ${SOURCE_PATH}/deps/azure-c-shared-utility/configs/)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -Dskip_samples=ON
        -Duse_installed_dependencies=ON
        -Dbuild_as_dynamic=OFF
    MAYBE_UNUSED_VARIABLES
        build_as_dynamic
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(PACKAGE_NAME uamqp CONFIG_PATH lib/cmake/uamqp)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include" "${CURRENT_PACKAGES_DIR}/debug/share")

configure_file("${SOURCE_PATH}/LICENSE" "${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright" COPYONLY)

vcpkg_copy_pdbs()
