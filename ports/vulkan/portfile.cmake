# Due to the complexity involved, this package doesn't install the Vulkan SDK.
# It instead verifies that Vulkan is installed.
# Other packages can depend on this package to declare a dependency on Vulkan.
message(STATUS "Querying VULKAN_SDK Enviroment variable")
file(TO_CMAKE_PATH "$ENV{VULKAN_SDK}" VULKAN_DIR)
set(VULKAN_INCLUDE "${VULKAN_DIR}/include/vulkan/")
set(VULKAN_ERROR_DL "Before continuing, please download and install Vulkan from:\n    https://vulkan.lunarg.com/sdk/home\nIf you have already downloaded it, make sure the VULKAN_SDK environment variable is set to vulkan's installation root.")

if(NOT DEFINED ENV{VULKAN_SDK})
    message(FATAL_ERROR "Could not find Vulkan SDK. ${VULKAN_ERROR_DL}")
endif()

message(STATUS "Searching " ${VULKAN_INCLUDE} " for vulkan.h")
if(NOT EXISTS "${VULKAN_INCLUDE}/vulkan.h")
    message(FATAL_ERROR "Could not find vulkan.h. ${VULKAN_ERROR_DL}")
endif()
message(STATUS "Found vulkan.h")

# Check if the user left the version in the installation directory e.g. c:/vulkanSDK/1.1.82.1/
if(VULKAN_DIR MATCHES "(([0-9]+)\\.([0-9]+)\\.([0-9]+)\\.([0-9]+))")
    set(VULKAN_VERSION "${CMAKE_MATCH_1}")
    set(VULKAN_MAJOR "${CMAKE_MATCH_2}")
    set(VULKAN_MINOR "${CMAKE_MATCH_3}")
    set(VULKAN_PATCH "${CMAKE_MATCH_4}")
    message(STATUS "Found Vulkan SDK version ${VULKAN_VERSION}")

    set(VULKAN_REQUIRED_VERSION "1.1.82.1")
    if (VULKAN_MAJOR LESS 1 OR VULKAN_MINOR LESS 1 OR VULKAN_PATCH LESS 82)
        message(FATAL_ERROR "Vulkan ${VULKAN_VERSION} but ${VULKAN_REQUIRED_VERSION} is required. Please download and install a more recent version from:"
                            "\n    https://vulkan.lunarg.com/sdk/home\n")
    endif()
endif()

if (EXISTS ${VULKAN_DIR}/../LICENSE.txt)
    configure_file(${VULKAN_DIR}/../LICENSE.txt ${CURRENT_PACKAGES_DIR}/share/vulkan/copyright COPYONLY)
elseif(EXISTS ${VULKAN_DIR}/LICENSE.txt)
    configure_file(${VULKAN_DIR}/LICENSE.txt ${CURRENT_PACKAGES_DIR}/share/vulkan/copyright COPYONLY)
else()
    configure_file(${CURRENT_PORT_DIR}/LICENSE.txt ${CURRENT_PACKAGES_DIR}/share/vulkan/copyright COPYONLY)
endif()

SET(VCPKG_POLICY_EMPTY_PACKAGE enabled)

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
