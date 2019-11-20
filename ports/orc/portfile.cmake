vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO apache/orc
    REF 61e9d008d06a4f9291ee62737fbfd0e34f9b20d5 # rel/release-1.5.7
    SHA512 0c19bc91629bd5b201542e57de9eb1d6cc09fae507fb07a5ad589a631cb78957d32d888840f393c9e4ee0c60bc2ba534107eb97c31d80cd6e487df346fb719f7
    HEAD_REF master
    PATCHES
      0003-dependencies-from-vcpkg.patch
      0004-update-tzdata.patch
      0005-disable-tzdata.patch
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
    -DSTOP_BUILD_ON_WARNING=OFF
    -DENABLE_TEST=OFF
)

vcpkg_install_cmake()
vcpkg_copy_pdbs()

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


file(COPY ${CMAKE_CURRENT_LIST_DIR}/usage DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT})
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
