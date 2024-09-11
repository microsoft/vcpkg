vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO JoshuaSledden/Jigson
  REF "v${VERSION}"
  SHA512 e18e2cc2e625fd8263c7ae2c6c9d30464f8c4a41c7d731df58a406dd84caedf0c066e8ce2676bbaffb3abe6624820ed3fee4b0fef007bc277c810c496b00b2d3
)

file(GLOB HEADER_FILES "${SOURCE_PATH}/*.hpp" "${SOURCE_PATH}/*.h")
file(INSTALL ${HEADER_FILES} DESTINATION "${CURRENT_PACKAGES_DIR}/include/jigson")

# Install the config file
file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/jigson-config.cmake" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")

# Generate and install the targets file
file(WRITE "${CURRENT_PACKAGES_DIR}/share/${PORT}/jigson-targets.cmake"
"
if(NOT TARGET jigson::jigson)
    add_library(jigson::jigson INTERFACE IMPORTED)
    set_target_properties(jigson::jigson PROPERTIES
        INTERFACE_INCLUDE_DIRECTORIES \"${CURRENT_PACKAGES_DIR}/include\"
    )
    target_link_libraries(jigson::jigson INTERFACE nlohmann_json::nlohmann_json)
endif()
")

# Generate and install the config version file
include(CMakePackageConfigHelpers)
write_basic_package_version_file(
    "${CURRENT_PACKAGES_DIR}/share/${PORT}/jigson-config-version.cmake"
    VERSION "${VERSION}"
    COMPATIBILITY SameMajorVersion
)

# Handle copyright
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")

configure_file("${CMAKE_CURRENT_LIST_DIR}/usage" "${CURRENT_PACKAGES_DIR}/share/${PORT}/usage" COPYONLY)