vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO qicosmos/cinatra
    REF ${VERSION}
    SHA512 55bba51bb6190b76bc6415d3c36e82daeb5f174f1cb10490951cf05863f55653a6d68ffd3b66c5b3b2ebb6e68a7a84c090e973a6718f3f2a5849b04330e4b180
    HEAD_REF master
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DBUILD_UNIT_TESTS=OFF
        -DBUILD_EXAMPLES=ON
        -DBUILD_PRESS_TOOL=ON
)

vcpkg_install_cmake()

# Copy include directory while preserving the folder structure but exclude asio and async_simple
file(GLOB_RECURSE CINATRA_HEADERS "${SOURCE_PATH}/include/*")
foreach(HEADER ${CINATRA_HEADERS})
    get_filename_component(HEADER_NAME "${HEADER}" NAME)
    get_filename_component(HEADER_PATH "${HEADER}" PATH)
    file(RELATIVE_PATH HEADER_RELATIVE_PATH "${SOURCE_PATH}/include" "${HEADER_PATH}")
    # Check in the path for 'asio' or 'async_simple' to exclude them
    if(NOT HEADER_PATH MATCHES "asio" AND NOT HEADER_PATH MATCHES "async_simple")
        file(INSTALL "${HEADER}"
             DESTINATION "${CURRENT_PACKAGES_DIR}/include/${HEADER_RELATIVE_PATH}")
    endif()
endforeach()



# Copy example web content
file(COPY ${SOURCE_PATH}/example/www DESTINATION ${CURRENT_PACKAGES_DIR}/tools/cinatra/examples)

# Copy executables to the tools directory
if(EXISTS "${CURRENT_PACKAGES_DIR}/bin/cinatra_example.exe")
    file(COPY "${CURRENT_PACKAGES_DIR}/bin/cinatra_example.exe"
         DESTINATION "${CURRENT_PACKAGES_DIR}/tools/cinatra")
    file(COPY "${CURRENT_PACKAGES_DIR}/bin/cinatra_press_tool.exe"
         DESTINATION "${CURRENT_PACKAGES_DIR}/tools/cinatra")
endif()

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
vcpkg_copy_pdbs()

# Cleanup unwanted directories
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/bin")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/bin")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug")
file(REMOVE_RECURSE "${SOURCE_PATH}/.git")
# Prevent file conflicts
file(REMOVE
    "${CURRENT_PACKAGES_DIR}/include/asio.hpp"
    "${CURRENT_PACKAGES_DIR}/include/cmdline.h"
)
