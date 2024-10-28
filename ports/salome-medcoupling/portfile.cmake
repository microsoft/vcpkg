if(VCPKG_TARGET_IS_WINDOWS)
    vcpkg_check_linkage(ONLY_DYNAMIC_LIBRARY)
    # Fixing static builds requires fixing/removing _declspec(dllexport|dllimport)
    # in the EXPORTS macros.
endif()

vcpkg_from_git(
    OUT_SOURCE_PATH SOURCE_PATH
    URL "https://git.salome-platform.org/gitpub/tools/medcoupling.git"
    REF "fe2e38d301902c626f644907e00e499552bb2fa5"
    PATCHES 
        win.patch 
        fix-missing-symbols.patch
)

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "static"  MEDCOUPLING_BUILD_STATIC)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS 
      "-DCONFIGURATION_ROOT_DIR=${SALOME_CONFIGURATION_ROOT_DIR}"
      -DMEDCOUPLING_BUILD_TESTS=OFF
      -DMEDCOUPLING_BUILD_PY_TESTS=OFF
      -DMEDCOUPLING_BUILD_DOC=OFF
      -DMEDCOUPLING_BUILD_STATIC=${MEDCOUPLING_BUILD_STATIC}
      -DMEDCOUPLING_ENABLE_PYTHON=OFF
      -DMEDCOUPLING_ENABLE_RENUMBER=OFF
      -DMEDCOUPLING_METIS_V5=ON
      -DMETIS_LIBRARIES=metis # this is a target
      -DSCOTCH_LIBRARIES=SCOTCH::scotch
)

vcpkg_cmake_install()

file(GLOB dll_files "${CURRENT_PACKAGES_DIR}/lib/*.dll")
file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/bin")
foreach(dll_file IN LISTS dll_files)
  string(REPLACE "/lib/" "/bin/" new_loc "${dll_file}")
  file(RENAME "${dll_file}" "${new_loc}")
endforeach()

if(NOT VCPKG_BUILD_TYPE)
  file(GLOB dll_files "${CURRENT_PACKAGES_DIR}/debug/lib/*.dll")
  file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/debug/bin")
  foreach(dll_file IN LISTS dll_files)
    string(REPLACE "/lib/" "/bin/" new_loc "${dll_file}")
    file(RENAME "${dll_file}" "${new_loc}")
  endforeach()
endif()

vcpkg_cmake_config_fixup(PACKAGE_NAME MEDCoupling CONFIG_PATH "cmake_files")
if(VCPKG_TARGET_IS_WINDOWS)
  set(file "${CURRENT_PACKAGES_DIR}/share/MEDCoupling/MEDCouplingTargets-release.cmake")
  file(READ "${file}" contents)
  string(REGEX REPLACE "/lib/([^.]+)\\.dll" "/bin/\\1.dll" contents "${contents}")
  file(WRITE "${file}" "${contents}")

  if(NOT VCPKG_BUILD_TYPE)
    set(file "${CURRENT_PACKAGES_DIR}/share/MEDCoupling/MEDCouplingTargets-debug.cmake")
    file(READ "${file}" contents)
    string(REGEX REPLACE "/lib/([^.]+)\\.dll" "/bin/\\1.dll" contents "${contents}")
    file(WRITE "${file}" "${contents}")
  endif()
endif()

vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/share/MEDCoupling/MEDCouplingConfig.cmake" "/cmake_files" "/share/MEDCoupling")
vcpkg_copy_tools(TOOL_NAMES medpartitioner AUTO_CLEAN)
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/COPYING")

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include"
                    "${CURRENT_PACKAGES_DIR}/debug/share")
