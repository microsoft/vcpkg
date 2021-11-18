set(VERSION v7.11.21285.13001)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO aminya/opennurbs
    REF tags/${VERSION}_cmake
    SHA512 f3f87289b05bf82374b7f7108a7689898c114f4aefa286fecb07edb47a66424155cb3fe48155a4b23c7460dc106175e5288cd2686f98cce59f8587536dbeb49e 
    HEAD_REF master
)

if (NOT CMAKE_SYSTEM_NAME STREQUAL "Windows")
  # shared libraries are only supported on Windows
  vcpkg_check_linkage(ONLY_STATIC_LIBRARY)
endif()

if(VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic")
  set(OPENNURBS_SHARED ON)
else()
  set(OPENNURBS_SHARED OFF)
endif()

vcpkg_cmake_configure(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DOPENNURBS_SHARED=${OPENNURBS_SHARED}
)

vcpkg_cmake_build(TARGET opennurbs)

# copy header files
file(GLOB HEADER_FILES "${SOURCE_PATH}/*.h")
foreach(HEADER_FILE ${HEADER_FILES})
  file(INSTALL "${HEADER_FILE}" DESTINATION "${CURRENT_PACKAGES_DIR}/include")
endforeach()

file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
