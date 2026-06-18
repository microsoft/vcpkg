if("udev" IN_LIST FEATURES)
    message("${PORT} currently requires the following tools and libraries from the system package manager:\n    libudev\n\nThese can be installed on Ubuntu systems via apt-get install libudev-dev")
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO libusb/libusb
    REF "v${VERSION}"
    SHA512 3251c9f41e900efa13caf981483f46886c8434bf4c30f3fd3073921b06be9977cebcf4a18f7bc46db86e33d7f19752296377be9050abfb8d887ffeb377864647
    HEAD_REF master
)

if(VCPKG_TARGET_IS_WINDOWS AND NOT VCPKG_TARGET_IS_MINGW)

  if(VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic")
      set(LIBUSB_PROJECT_TYPE dll)
  else()
      set(LIBUSB_PROJECT_TYPE static)
  endif()

  # The README.md file in the archive is a symlink to README
  # which causes issues with the windows MSBUILD process
  file(REMOVE "${SOURCE_PATH}/README.md")

  vcpkg_msbuild_install(
      SOURCE_PATH "${SOURCE_PATH}"
      PROJECT_SUBPATH msvc/libusb_${LIBUSB_PROJECT_TYPE}.vcxproj
  )

  file(INSTALL "${SOURCE_PATH}/libusb/libusb.h"  DESTINATION "${CURRENT_PACKAGES_DIR}/include/libusb-1.0")
  set(prefix "")
  set(exec_prefix [[${prefix}]])
  set(libdir [[${prefix}/lib]])
  set(includedir [[${prefix}/include]])
  configure_file("${SOURCE_PATH}/libusb-1.0.pc.in" "${CURRENT_PACKAGES_DIR}/lib/pkgconfig/libusb-1.0.pc" @ONLY)
  vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/lib/pkgconfig/libusb-1.0.pc" " -lusb-1.0" " -llibusb-1.0")
  if(NOT VCPKG_BUILD_TYPE)
      set(includedir [[${prefix}/../include]])
      configure_file("${SOURCE_PATH}/libusb-1.0.pc.in" "${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig/libusb-1.0.pc" @ONLY)
      vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig/libusb-1.0.pc" " -lusb-1.0" " -llibusb-1.0")
  endif()
else()
    vcpkg_list(SET MAKE_OPTIONS)
    vcpkg_list(SET LIBUSB_LINK_LIBRARIES)
    if("udev" IN_LIST FEATURES)
        vcpkg_list(APPEND MAKE_OPTIONS "--enable-udev")
        vcpkg_list(APPEND LIBUSB_LINK_LIBRARIES udev)
    else()
        vcpkg_list(APPEND MAKE_OPTIONS "--disable-udev")
    endif()
    vcpkg_make_configure(
        SOURCE_PATH "${SOURCE_PATH}"
        AUTORECONF
        OPTIONS
            ${MAKE_OPTIONS}
            "--enable-examples-build=no"
            "--enable-tests-build=no"
    )
    vcpkg_make_install()
endif()

vcpkg_fixup_pkgconfig()

# -Wl,-framework,... is poorly handled in CMake
vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/lib/pkgconfig/libusb-1.0.pc" " -Wl,-framework," " -framework " IGNORE_UNCHANGED)
if(NOT VCPKG_BUILD_TYPE)
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig/libusb-1.0.pc" " -Wl,-framework," " -framework " IGNORE_UNCHANGED)
endif()

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/COPYING")
