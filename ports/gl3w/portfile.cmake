include(vcpkg_common_functions)

vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO skaslev/gl3w
  REF 8f7f459df8725c9614136b49a96023de276219f2
  SHA512 7674008716accb25347c81f755f2db7a885ecb5c51b481e0e8f337bc8ee0949a5a58f5816b27a66535ed4da0b9438ba6a6a84712560c7b1a0f1b2908b4eb81e5
  HEAD_REF master
)

file(COPY ${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt DESTINATION ${SOURCE_PATH})

set(BUILD_SHARED_LIBS OFF)
if (VCPKG_LIBRARY_LINKAGE STREQUAL dynamic)
    set(BUILD_SHARED_LIBS ON)
    vcpkg_apply_patches(
        SOURCE_PATH ${SOURCE_PATH}
        PATCHES ${CMAKE_CURRENT_LIST_DIR}/0001-enable-shared-build.patch)
endif()

vcpkg_find_acquire_program(PYTHON3)

get_filename_component(PYTHON3_PATH ${PYTHON3} DIRECTORY)
set(ENV{PATH} "$ENV{PATH};${PYTHON3_PATH}")

message($ENV{PATH})

vcpkg_configure_cmake(
  SOURCE_PATH ${SOURCE_PATH}
  PREFER_NINJA
  OPTIONS -DBUILD_SHARED_LIBS=${BUILD_SHARED_LIBS}
  OPTIONS_DEBUG -DDISABLE_INSTALL_HEADERS=ON
)

vcpkg_install_cmake()
vcpkg_copy_pdbs()
vcpkg_fixup_cmake_targets(CONFIG_PATH share/gl3w)

file(INSTALL ${SOURCE_PATH}/UNLICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/gl3w RENAME copyright)

