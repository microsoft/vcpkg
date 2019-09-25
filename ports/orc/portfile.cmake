include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO apache/orc
    REF 8a8e471f6a7064e9538374374e57c9e5b4be520d
    SHA512 c10d6f56965abde585607473142cedea25e2085147e5c66e1991cbbb313543a919d93f9a830c76ae1331f97fafe4e9a47157062b05d80746869bc3f73772e3bc
    HEAD_REF master
    PATCHES
      0003-dependencies-from-vcpkg.patch
      0004-update-tzdata.patch
      no-werror.patch
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
