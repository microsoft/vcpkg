vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO skaslev/gl3w
  REF 99ed321100d37032cb6bfa7dd8dea85f10c86132
  SHA512 217f65644c73c33383b09893fa5ede066cc4b1cddab051feac11d7e939dba14ed637b297ea42a0426bc0a1a3bc665998a91c27ca10d28704ce9e2d3d90e73595
  HEAD_REF master
  PATCHES
      0001-enable-shared-build.patch
)

# Download khrplatform.h with vcpkg instead of gl3w_gen.py so that our downloader settings are used
vcpkg_download_distfile(KHRPLATFORM_H
  URLS "https://www.khronos.org/registry/EGL/api/KHR/khrplatform.h"
  FILENAME khrplatform.h
  SHA512 93d9075718eddb69c44482acdc72bbbd3511741272a6124d05ab1ef0702ef03e918501403b6fd334faf2c61f3332f34b7730158aa090db3d448c32b5dd9d9e67
  )

file(COPY "${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt" DESTINATION "${SOURCE_PATH}")
file(COPY "${CURRENT_INSTALLED_DIR}/include/GL/glcorearb.h" DESTINATION "${SOURCE_PATH}/include/GL")
file(COPY "${KHRPLATFORM_H}" DESTINATION "${SOURCE_PATH}/include/KHR")

vcpkg_find_acquire_program(PYTHON3)

vcpkg_execute_required_process(
  COMMAND "${PYTHON3}" "${SOURCE_PATH}/gl3w_gen.py"
  WORKING_DIRECTORY "${SOURCE_PATH}"
  LOGNAME gl3w-gen
)

vcpkg_configure_cmake(
  SOURCE_PATH "${SOURCE_PATH}"
  PREFER_NINJA
  OPTIONS_DEBUG -DDISABLE_INSTALL_HEADERS=ON
)

vcpkg_install_cmake()
vcpkg_copy_pdbs()
vcpkg_fixup_cmake_targets()

if(VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic")
  vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/GL/gl3w.h" "#define GL3W_API" "#define GL3W_API __declspec(dllimport)")
endif()

file(INSTALL "${SOURCE_PATH}/UNLICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
