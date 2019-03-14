include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO apache/orc
    REF bf5b7800930bfa030db83aba925d9d3b75852839
    SHA512 42a1fd0fd2b8dec19a5019a42e3a85fe6d6cb2fe922d9bf7d47669a36801a9c65a1edccf01e08f0da8d01c79e329d8069d2b6200c4005d1bfe3628c598f24ee5
    HEAD_REF master
    PATCHES
      0003-dependencies-from-vcpkg.patch
    )

file(REMOVE "${SOURCE_PATH}/cmake_modules/FindGTest.cmake")
file(REMOVE "${SOURCE_PATH}/cmake_modules/FindLZ4.cmake")
file(REMOVE "${SOURCE_PATH}/cmake_modules/FindZSTD.cmake")
file(REMOVE "${SOURCE_PATH}/cmake_modules/FindProtobuf.cmake")
file(REMOVE "${SOURCE_PATH}/cmake_modules/FindSnappy.cmake")
file(REMOVE "${SOURCE_PATH}/cmake_modules/FindZLIB.cmake")

if(CMAKE_HOST_WIN32)
  set(PROTOBUF_EXECUTABLE ${CURRENT_INSTALLED_DIR}/tools/protobuf/protoc.exe)
else()
  set(PROTOBUF_EXECUTABLE ${CURRENT_INSTALLED_DIR}/tools/protobuf/protoc)
endif()

if(NOT VCPKG_CMAKE_SYSTEM_NAME OR VCPKG_CMAKE_SYSTEM_NAME STREQUAL "WindowsStore")
  set(BUILD_TOOLS OFF)
else()
  set(BUILD_TOOLS ON)
endif()

vcpkg_configure_cmake(
  SOURCE_PATH ${SOURCE_PATH}
  PREFER_NINJA
  OPTIONS
  -DBUILD_TOOLS=${BUILD_TOOLS}
  -DBUILD_CPP_TESTS=OFF
  -DBUILD_JAVA=OFF
  -DINSTALL_VENDORED_LIBS=OFF
  -DBUILD_LIBHDFSPP=OFF
  -DPROTOBUF_EXECUTABLE:FILEPATH=${PROTOBUF_EXECUTABLE}
)

vcpkg_install_cmake()

file(GLOB TOOLS ${CURRENT_PACKAGES_DIR}/bin/orc-*)
if(TOOLS)
  file(COPY ${TOOLS} DESTINATION ${CURRENT_PACKAGES_DIR}/tools/orc)
  file(REMOVE ${TOOLS})
endif()

file(GLOB BINS ${CURRENT_PACKAGES_DIR}/bin/*)
if(NOT BINS)
  file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/bin ${CURRENT_PACKAGES_DIR}/debug/bin)
endif()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)

file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/orc RENAME copyright)

vcpkg_copy_pdbs()

file(COPY ${CMAKE_CURRENT_LIST_DIR}/usage DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT})
