
include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO apache/orc
    REF f47e02cfbf346f14d7f38c3ddd45d39e3b515847
    SHA512 5a389f4ab3b0ce4e7c8869493cf9e91feb4917a42bf2740abd71602fa03a2a53217b572e60af7328b7568dab084c07275ea275438ec8ae87f230a87fb60f2601
    HEAD_REF master
)

vcpkg_apply_patches(
  SOURCE_PATH ${SOURCE_PATH}
  PATCHES
    "${CMAKE_CURRENT_LIST_DIR}/0001-dependencies-from-vcpkg.patch"
)

file(REMOVE "${SOURCE_PATH}/cmake_modules/FindGTest.cmake")
file(REMOVE "${SOURCE_PATH}/cmake_modules/FindLZ4.cmake")
file(REMOVE "${SOURCE_PATH}/cmake_modules/FindProtobuf.cmake")
file(REMOVE "${SOURCE_PATH}/cmake_modules/FindSnappy.cmake")
file(REMOVE "${SOURCE_PATH}/cmake_modules/FindZLIB.cmake")

vcpkg_configure_cmake(
  SOURCE_PATH ${SOURCE_PATH}
  PREFER_NINJA
  OPTIONS
  -DBUILD_TOOLS=ON
  -DBUILD_CPP_TESTS=OFF
  -DBUILD_JAVA=OFF
  -DPROTOBUF_PROTOC_EXECUTABLE:FILEPATH=${CURRENT_INSTALLED_DIR}/tools/protobuf/protoc
)

vcpkg_install_cmake()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)

file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/orc RENAME copyright)

vcpkg_copy_pdbs()

file(COPY ${CMAKE_CURRENT_LIST_DIR}/usage DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT})
