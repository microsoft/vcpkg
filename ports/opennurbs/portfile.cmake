set(VERSION v7.11.21285.13001)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO aminya/opennurbs
    REF tags/${VERSION}_cmake
    SHA512 f72aa207c18ddfcfc0fe5e367f985c3b56886d076ab3683ea47c890afacdb2856b1bd46407c6215647b446f028fd0ed3b91956ce6c92d65d573194e4798d2df4  
    HEAD_REF master
)

if (NOT CMAKE_SYSTEM_NAME STREQUAL "Windows")
  # shared libraries are only supported on Windows
  vcpkg_check_linkage(ONLY_STATIC_LIBRARY)
endif()

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "dynamic" OPENNURBS_SHARED)

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
