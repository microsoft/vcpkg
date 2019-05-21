#header-only library
include(vcpkg_common_functions)

set(USE_UPSTREAM OFF)
if("upstream" IN_LIST FEATURES)
    set(USE_UPSTREAM ON)
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO crossbario/autobahn-cpp
    REF v18.4.1
    SHA512 a3325e06731698a2c5d8c233581f275a9b653e98b74e7382f83fc62111dec9d66bbd5803cc71e8b5125ecee6d380d3cf1c6e83926e06912888201c2aa4ab7a15
    HEAD_REF master
)

file(MAKE_DIRECTORY ${CURRENT_PACKAGES_DIR}/share/autobahn)

# Copy the header files
file(COPY "${SOURCE_PATH}/autobahn" DESTINATION "${CURRENT_PACKAGES_DIR}/include" FILES_MATCHING PATTERN "*.hpp")
file(COPY "${SOURCE_PATH}/autobahn" DESTINATION "${CURRENT_PACKAGES_DIR}/include" FILES_MATCHING PATTERN "*.ipp")

set(PACKAGE_INSTALL_INCLUDE_DIR "\${CMAKE_CURRENT_LIST_DIR}/../../include")
set(PACKAGE_INIT "
macro(set_and_check)
  set(\${ARGV})
endmacro()
")

configure_file(${SOURCE_PATH}/LICENSE ${CURRENT_PACKAGES_DIR}/share/autobahn/copyright COPYONLY)
