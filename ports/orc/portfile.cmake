include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO apache/orc
    REF 47a490f083bd411bf04bfed8131eef42606d7789
    SHA512 c2650d9fd367a5ec04c79c16434728e5c20608131f21bfc89d412cbaf8dd4ae5900b03e59df21d3617d8c6a9504e4b14b1f788157afa90b57d733499d2995e39
    HEAD_REF master
    PATCHES
      0003-dependencies-from-vcpkg.patch
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
