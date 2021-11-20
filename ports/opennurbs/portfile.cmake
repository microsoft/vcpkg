set(VERSION v7.11.21285.13001)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO aminya/opennurbs
    REF tags/${VERSION}_cmake
    SHA512  0f2c336463b4b7ba41ea480e964be47f7927ff93b97bdd4f241bab21e5bc99b893c4d24fd64cc768f056ce29076bb7a19ceccf7c3ffb8b84d370fc8186047249  
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
        -DCMAKE_FIND_FRAMEWORK=LAST
)

vcpkg_cmake_build(TARGET opennurbs)

# copy header files
file(GLOB HEADER_FILES "${SOURCE_PATH}/*.h")
foreach(HEADER_FILE ${HEADER_FILES})
  file(INSTALL "${HEADER_FILE}" DESTINATION "${CURRENT_PACKAGES_DIR}/include")
endforeach()

file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
