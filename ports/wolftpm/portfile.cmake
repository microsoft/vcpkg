vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO wolfssl/wolftpm
    REF v${VERSION}
    SHA512 fc1d26e4144a496fef7ae7db27f11026132da1dc98f6f61de495b0b7c03ac59c65daccd307cc1449eeb55bc22e2ca552abd7ed607be448688127b2ed6d56867a
    HEAD_REF master
    )

if ("${VERSION}" VERSION_GREATER_EQUAL "3.9.2") #CMAKE logic added in versions newer than 3.9.1
  if ("no-active-thread-ls" IN_LIST FEATURES)
    set(ENABLE_NO_ACTIVE_THREAD_LS yes)
  else()
    set(ENABLE_NO_ACTIVE_THREAD_LS no)
  endif()
endif()


vcpkg_cmake_get_vars(cmake_vars_file)
include("${cmake_vars_file}")

foreach(config RELEASE DEBUG)
  if ("${VERSION}" VERSION_LESS "3.9.2") #CMAKE logic not present in versions older than 3.9.2
    if ("no-active-thread-ls" IN_LIST FEATURES)
      string(APPEND VCPKG_COMBINED_C_FLAGS_${config} " -DWOLFTPM_NO_ACTIVE_THREAD_LS")
    endif()
  endif()
endforeach()

# Add debug flag for debug builds
string(APPEND VCPKG_COMBINED_C_FLAGS_DEBUG " -DDEBUG_WOLFTPM")

vcpkg_cmake_configure(SOURCE_PATH ${SOURCE_PATH}
    OPTIONS
      -DWOLFTPM_EXAMPLES=no
      -DWOLFTPM_BUILD_OUT_OF_TREE=yes
      -DWOLFTPM_NO_ACTIVE_THREAD_LS=${ENABLE_NO_ACTIVE_THREAD_LS}
    OPTIONS_RELEASE
      -DCMAKE_C_FLAGS=${VCPKG_COMBINED_C_FLAGS_RELEASE}
    OPTIONS_DEBUG
      -DCMAKE_C_FLAGS=${VCPKG_COMBINED_C_FLAGS_DEBUG}
    )

vcpkg_cmake_install()
vcpkg_copy_pdbs()

file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)

vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/wolftpm)
vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
