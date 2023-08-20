set(PREV_MODULE_PATH ${CMAKE_MODULE_PATH})
list(APPEND CMAKE_MODULE_PATH ${CMAKE_CURRENT_LIST_DIR})
find_package(OptiX ${VERSION})
set(CMAKE_MODULE_PATH ${PREV_MODULE_PATH})

if(NOT OptiX_FOUND)
  message(FATAL_ERROR "Could not find OptiX. Before continuing, please download and install OptiX (v${VERSION} or higher) from:"
                      "\n    https://developer.nvidia.com/designworks/optix/download\n")
elseif(OptiX_VERSION VERSION_LESS VERSION)
  message(FATAL_ERROR "OptiX v${OptiX_VERSION} found, but v${VERSION} is required. Please download and install a more recent version of OptiX from:"
                      "\n    https://developer.nvidia.com/designworks/optix/download\n")
endif()

message(STATUS "Found OptiX v${OptiX_VERSION}: (include ${OptiX_INCLUDE_DIR})")
set(VCPKG_POLICY_EMPTY_PACKAGE enabled)

file(INSTALL "${CURRENT_PORT_DIR}/FindOptiX.cmake" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
file(INSTALL "${CURRENT_PORT_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
file(INSTALL "${CURRENT_PORT_DIR}/vcpkg-cmake-wrapper.cmake" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
