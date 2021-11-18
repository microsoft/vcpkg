set(VERSION v7.11.21285.13001)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO aminya/opennurbs
    REF tags/${VERSION}_cmake
    SHA512 8d3c9faaf5ee44bee0433ec2e5fcf0b4f1489f044d6cab85035524ffa0b265db0be7866ce746854e604af536da6c16eb577c08faa6dd4dbd51bfd94ed2283801 
    HEAD_REF master
)

# The shared library needs to be fixed
vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

if(VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic")
  set(opennurbs_SHARED ON)
else()
  set(opennurbs_SHARED OFF)
endif()

vcpkg_cmake_configure(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -Dopennurbs_SHARED=${OPENMESH_BUILD_SHARED}
)

vcpkg_cmake_build(TARGET opennurbs)

# copy header files
file(GLOB HEADER_FILES "${SOURCE_PATH}/*.h")
foreach(HEADER_FILE ${HEADER_FILES})
  file(INSTALL "${HEADER_FILE}" DESTINATION "${CURRENT_PACKAGES_DIR}/include")
endforeach()

file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
