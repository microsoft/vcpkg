vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_git(
  URL git@github.com:deshanxiao/orc.git
  OUT_SOURCE_PATH SOURCE_PATH
  HEAD_REF deshan/vcpkg
)

file(REMOVE "${SOURCE_PATH}/cmake_modules/FindZLIB.cmake")

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
    -DSTOP_BUILD_ON_WARNING=OFF
    -DENABLE_TEST=OFF
    -DORC_PACKAGE_KIND=vcpkg
  MAYBE_UNUSED_VARIABLES
    ENABLE_TEST
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(PACKAGE_NAME orc)
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

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/bin" "${CURRENT_PACKAGES_DIR}/debug/bin")
endif()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
file(COPY "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
