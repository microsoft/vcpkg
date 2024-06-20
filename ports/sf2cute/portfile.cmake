vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO gocha/sf2cute
    REF v0.2
    HEAD_REF master
    SHA512 721762556c392a134500fa110ec849a60d1285a57e4e8d9cacb6281bed02f5658a14694efcccb8248719558b45db89da5ad53c56990bb9c263a9760fe0d99b8f
)

set(BUILD_EXAMPLE OFF)

if("example" IN_LIST FEATURES)
    set(BUILD_EXAMPLE ON)
endif()

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS_DEBUG
        -DSF2CUTE_EXAMPLES_INSTALL_DIR=tools/sf2cute
    OPTIONS_RELEASE
        -DSF2CUTE_INSTALL_EXAMPLES=${BUILD_EXAMPLE}
        "-DSF2CUTE_EXAMPLES_INSTALL_DIR=${CURRENT_PACKAGES_DIR}/tools/sf2cute"
)

vcpkg_cmake_install()
vcpkg_copy_pdbs()
vcpkg_cmake_config_fixup()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

# Handle copyright
file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/sf2cute" RENAME copyright)

if(BUILD_EXAMPLE)
  vcpkg_copy_tool_dependencies("${CURRENT_PACKAGES_DIR}/tools/sf2cute")
endif()
