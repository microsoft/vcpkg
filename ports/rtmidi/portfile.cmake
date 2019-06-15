include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO thestk/rtmidi
    REF  4.0.0
    SHA512 39383f121320c9471b31f8b9d283167bfadf4c7328b6664d1d54a4c52e3dd9b76362875258d90363c6044e87fcee31ccce80e19435dc620c88e6d60fc82d0f9d
    HEAD_REF master
	PATCHES
		fix-POSIXname.patch
)
file(COPY ${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt DESTINATION ${SOURCE_PATH})

vcpkg_configure_cmake(
  SOURCE_PATH ${SOURCE_PATH}
  PREFER_NINJA
  OPTIONS_DEBUG -DDISABLE_INSTALL_HEADERS=ON
)

vcpkg_install_cmake()

file(INSTALL ${SOURCE_PATH}/README.md DESTINATION ${CURRENT_PACKAGES_DIR}/share/rtmidi RENAME copyright)
