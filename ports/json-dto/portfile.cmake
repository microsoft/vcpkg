vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO stiffstream/json_dto
    REF c878c002109784c5d7d7dd51e94cec19a200ff79 # v.0.2.15
    SHA512 7900263ac0cf815e31e2e6d632d4093f896a34d7842a81574c71e8883c6bbee3a75fa717b7fb0ac9a0c34a4e4e1bad855b7ea0374321745a43f3235b213da9f8
)

vcpkg_cmake_configure(
    SOURCE_PATH ${SOURCE_PATH}/dev
    OPTIONS
        -DJSON_DTO_INSTALL=ON
        -DJSON_DTO_TEST=OFF
        -DJSON_DTO_SAMPLE=OFF
        -DJSON_DTO_INSTALL_SAMPLES=OFF
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/json-dto)

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/lib ${CURRENT_PACKAGES_DIR}/debug)

# Handle copyright
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)

