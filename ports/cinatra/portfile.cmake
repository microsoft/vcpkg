vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO qicosmos/cinatra
    REF ${VERSION}
    SHA512 55bba51bb6190b76bc6415d3c36e82daeb5f174f1cb10490951cf05863f55653a6d68ffd3b66c5b3b2ebb6e68a7a84c090e973a6718f3f2a5849b04330e4b180
    HEAD_REF master
)

set(VCPKG_BUILD_TYPE "release") # header-only port

# Copy the entire include directory to ${CURRENT_PACKAGES_DIR}/include/cinatra
file(COPY ${SOURCE_PATH}/include DESTINATION ${CURRENT_PACKAGES_DIR}/include/cinatra)
file(COPY ${SOURCE_PATH}/include/cinatra.hpp DESTINATION ${CURRENT_PACKAGES_DIR}/include/cinatra.hpp)

vcpkg_copy_tools(
    TOOL_NAMES cinatra_press_tool
    SEARCH_DIRS "${CURRENT_PACKAGES_DIR}/include/cinatra"
)

# Copy executables to the tools directory
if(EXISTS "${CURRENT_PACKAGES_DIR}/include/cinatra/cinatra_press_tool.exe")
    file(COPY "${CURRENT_PACKAGES_DIR}/include/cinatra/cinatra_press_tool.exe"
         DESTINATION "${CURRENT_PACKAGES_DIR}/tools/cinatra")
    file(REMOVE "${CURRENT_PACKAGES_DIR}/include/cinatra/cinatra_press_tool.exe")
endif()

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")





