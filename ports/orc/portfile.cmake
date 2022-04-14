vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO apache/orc
    REF acfce62b56047e851e75b4f3212594026766da97  # rel/release-1.7.3
    SHA512 7874751bdd0a84abc6a232e469cdf126937207ea8f974e02e5a57765ac1d9d6c180b80d708c29eb99f84073ae0032a46ea0a09a7ba36cdb900fdbe89d199eba7
    HEAD_REF main
    PATCHES
        dependencies-from-vcpkg.patch
)

file(REMOVE "${SOURCE_PATH}/cmake_modules/FindGTest.cmake")
file(REMOVE "${SOURCE_PATH}/cmake_modules/FindLZ4.cmake")
file(REMOVE "${SOURCE_PATH}/cmake_modules/FindZSTD.cmake")
file(REMOVE "${SOURCE_PATH}/cmake_modules/FindProtobuf.cmake")
file(REMOVE "${SOURCE_PATH}/cmake_modules/FindSnappy.cmake")
file(REMOVE "${SOURCE_PATH}/cmake_modules/FindZLIB.cmake")

if(CMAKE_HOST_WIN32)
  set(PROTOBUF_EXECUTABLE "${CURRENT_INSTALLED_DIR}/tools/protobuf/protoc.exe")
else()
  set(PROTOBUF_EXECUTABLE "${CURRENT_INSTALLED_DIR}/tools/protobuf/protoc")
endif()

if(VCPKG_TARGET_IS_WINDOWS)
  set(BUILD_TOOLS OFF)
else()
  set(BUILD_TOOLS ON)
endif()

vcpkg_cmake_configure(
  SOURCE_PATH "${SOURCE_PATH}"
  OPTIONS
    -DBUILD_TOOLS=${BUILD_TOOLS}
    -DBUILD_CPP_TESTS=OFF
    -DBUILD_JAVA=OFF
    -DINSTALL_VENDORED_LIBS=OFF
    -DBUILD_LIBHDFSPP=OFF
    -DPROTOBUF_EXECUTABLE:FILEPATH=${PROTOBUF_EXECUTABLE}
    -DSTOP_BUILD_ON_WARNING=OFF
)

vcpkg_cmake_install()
vcpkg_copy_pdbs()

file(GLOB TOOLS "${CURRENT_PACKAGES_DIR}/bin/orc-*")
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
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/share/doc")


file(COPY "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
