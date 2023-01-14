vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO apache/orc
    REF 7ff749a4234c3db58d272a8fc1c7cc1860245692  # rel/release-1.7.6
    SHA512 1e7f0366530b691d7ea7ce671aa1e1a655cde2feb0fb0c3639da36ef565aceaf6f05e49a39c3c0ab7417dc324dc2cbb6e8babbf21f899ccb4cf5f0e63217afbf
    HEAD_REF master
    PATCHES
        0003-dependencies-from-vcpkg.patch
        fix-linux-error.patch
)

file(REMOVE "${SOURCE_PATH}/cmake_modules/FindGTest.cmake")
file(REMOVE "${SOURCE_PATH}/cmake_modules/FindLZ4.cmake")
file(REMOVE "${SOURCE_PATH}/cmake_modules/FindZSTD.cmake")
file(REMOVE "${SOURCE_PATH}/cmake_modules/FindProtobuf.cmake")
file(REMOVE "${SOURCE_PATH}/cmake_modules/FindSnappy.cmake")
file(REMOVE "${SOURCE_PATH}/cmake_modules/FindZLIB.cmake")

set(PROTOBUF_EXECUTABLE "${CURRENT_HOST_INSTALLED_DIR}/tools/protobuf/protoc${VCPKG_HOST_EXECUTABLE_SUFFIX}")

if(VCPKG_TARGET_IS_WINDOWS)
  set(BUILD_TOOLS OFF)
  # when cross compiling, we can't run their test. however:
  #  - Windows doesn't support time_t < 0 => HAS_PRE_1970 test returns false
  #  - Windows doesn't support setenv => HAS_POST_2038 test fails to compile
  set(time_t_checks "-DHAS_PRE_1970=OFF" "-DHAS_POST_2038=OFF")
else()
  set(BUILD_TOOLS ON)
  set(time_t_checks "")
endif()

if(VCPKG_TARGET_IS_UWP)
    set(configure_opts WINDOWS_USE_MSBUILD)
endif()

vcpkg_cmake_configure(
  SOURCE_PATH "${SOURCE_PATH}"
  ${configure_opts}
  OPTIONS
    ${time_t_checks}
    -DBUILD_TOOLS=${BUILD_TOOLS}
    -DBUILD_CPP_TESTS=OFF
    -DBUILD_JAVA=OFF
    -DINSTALL_VENDORED_LIBS=OFF
    -DBUILD_LIBHDFSPP=OFF
    -DPROTOBUF_EXECUTABLE:FILEPATH=${PROTOBUF_EXECUTABLE}
    -DSTOP_BUILD_ON_WARNING=OFF
    -DENABLE_TEST=OFF
  MAYBE_UNUSED_VARIABLES
    ENABLE_TEST
)

vcpkg_cmake_install()
vcpkg_copy_pdbs()

file(GLOB TOOLS ${CURRENT_PACKAGES_DIR}/bin/orc-*)
if(TOOLS)
  file(COPY ${TOOLS} DESTINATION "${CURRENT_PACKAGES_DIR}/tools/orc")
  file(REMOVE ${TOOLS})
endif()

file(GLOB BINS "${CURRENT_PACKAGES_DIR}/bin/*")
if(NOT BINS)
  file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/bin" "${CURRENT_PACKAGES_DIR}/debug/bin")
endif()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")


file(COPY "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
