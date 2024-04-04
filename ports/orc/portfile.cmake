vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO apache/orc
  REF "v${VERSION}"
  SHA512 6109b27047b0688566756f9ca6833689cdf0bd7a5086c4212ef1fd6484fb73d9077fa3017137a7fd65f0ab51518c80fc43ab55bd308ad146f6f4b6d97c51b4fc
  HEAD_REF master
  PATCHES
    fix-cmake.patch
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
vcpkg_cmake_config_fixup(PACKAGE_NAME unofficial-orc)
vcpkg_copy_pdbs()

file(READ "${CURRENT_PACKAGES_DIR}/share/unofficial-orc/unofficial-orc-config.cmake" cmake_config)
file(WRITE "${CURRENT_PACKAGES_DIR}/share/unofficial-orc/unofficial-orc-config.cmake"
"include(CMakeFindDependencyMacro)
find_dependency(Snappy CONFIG)
find_dependency(ZLIB)
find_dependency(zstd CONFIG)
find_dependency(lz4 CONFIG)
find_dependency(Protobuf CONFIG)
${cmake_config}
")

file(GLOB TOOLS ${CURRENT_PACKAGES_DIR}/bin/orc-*)
if(TOOLS)
  file(COPY ${TOOLS} DESTINATION "${CURRENT_PACKAGES_DIR}/tools/orc")
  file(REMOVE ${TOOLS})
endif()

file(GLOB BINS "${CURRENT_PACKAGES_DIR}/bin/*")
if(NOT BINS)
  file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/bin" "${CURRENT_PACKAGES_DIR}/debug/bin")
endif()

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/bin" "${CURRENT_PACKAGES_DIR}/debug/bin")
endif()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
file(COPY "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
