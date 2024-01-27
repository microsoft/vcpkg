vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_download_distfile(ARCHIVE
    URLS "https://netcologne.dl.sourceforge.net/project/omniorb/omniORBpy/omniORBpy-4.3.0/omniORBpy-4.3.0.tar.bz2"
    FILENAME "omniORBpy-${VERSION}.tar.bz2"
    SHA512 473db7085267ba9d014ec768e6fdd8fce04aa6e30ca3d9bd5f97a2eb504e12b78e3d4fde2d7bc5dc3df5a3ca062a9a8426689554bec707fa4732657a594ade38
)

vcpkg_extract_source_archive(
    SOURCE_PATH
    ARCHIVE "${ARCHIVE}"
    PATCHES build.patch
)

vcpkg_replace_string("${SOURCE_PATH}/bin/scripts/makeminors.py" "/usr/bin/env python" "/usr/bin/env python3.11")

vcpkg_add_to_path(PREPEND "${CURRENT_HOST_INSTALLED_DIR}/tools/python3") # port ask python distutils for info.
vcpkg_add_to_path(PREPEND "${CURRENT_HOST_INSTALLED_DIR}/tools/omniorb/bin")

#set(ENV{PYTHONHOME} "${CURRENT_HOST_INSTALLED_DIR}")


file(COPY "${CURRENT_INSTALLED_DIR}/share/omniorb/idl/omniORB/" DESTINATION "${SOURCE_PATH}/idl")

if(VCPKG_TARGET_IS_WINDOWS AND NOT VCPKG_TARGET_IS_MINGW)
  set(ENV{PYTHONPATH} "${VCPKG_HOST_PATH_SEPARATOR}${CURRENT_HOST_INSTALLED_DIR}/${PYTHON3_SITE}${VCPKG_HOST_PATH_SEPARATOR}${CURRENT_HOST_INSTALLED_DIR}/${PYTHON3_SITE}/..${VCPKG_HOST_PATH_SEPARATOR}${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/lib/python${VCPKG_HOST_PATH_SEPARATOR}${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg/lib/python")
  set(z_vcpkg_org_linkage "${VCPKG_LIBRARY_LINKAGE}") 
  # convoluted build system; shared builds requires 
  # static library to create def file for symbol export
  # tools seem to only dynamically link on windows due to make rules!
  set(VCPKG_LIBRARY_LINKAGE dynamic)
  z_vcpkg_get_cmake_vars(cmake_vars_file)
  include("${cmake_vars_file}")
  if(VCPKG_BUILD_TYPE)
    string(APPEND build_info "NoDebugBuild=1\n")
  endif()
  string(APPEND build_info "replace-with-per-config-text\n")
  set(progs C_COMPILER CXX_COMPILER AR
            LINKER RANLIB OBJDUMP MT
            STRIP NM DLLTOOL RC_COMPILER)
  list(TRANSFORM progs PREPEND "VCPKG_DETECTED_CMAKE_")
  foreach(prog IN LISTS progs)
      if(${prog})
          set(path "${${prog}}")
          unset(prog_found CACHE)
          get_filename_component(${prog} "${${prog}}" NAME)
          find_program(prog_found ${${prog}} PATHS ENV PATH NO_DEFAULT_PATH)
          if(NOT path STREQUAL prog_found)
              get_filename_component(path "${path}" DIRECTORY)
              vcpkg_add_to_path(PREPEND ${path})
          endif()
      endif()
  endforeach()
  if(NOT EXISTS "${CURRENT_INSTALLED_DIR}/lib/msvcstub.lib" AND NOT EXISTS "${CURRENT_INSTALLED_DIR}/lib/omniORB430_rt.lib")
    # Linkage needs to know if omniorb was build statically or not.
    string(APPEND build_info "vcpkg_static_build=1\n")
  endif()
  configure_file("${CMAKE_CURRENT_LIST_DIR}/vcpkg.mk" "${SOURCE_PATH}/mk/vcpkg.mk" @ONLY NEWLINE_STYLE UNIX)
endif()

vcpkg_configure_make(
  SOURCE_PATH "${SOURCE_PATH}"
  AUTOCONFIG
  NO_WRAPPERS
  COPY_SOURCE
  OPTIONS
    --with-omniorb=${CURRENT_INSTALLED_DIR}/tools/omniorb
  OPTIONS_DEBUG
    am_cv_python_pyexecdir=\\\${PREFIX}${CURRENT_INSTALLED_DIR}/debug/${PYTHON3_SITE}
    am_cv_python_pythondir=\\\${PREFIX}${CURRENT_INSTALLED_DIR}/debug/${PYTHON3_SITE}
  OPTIONS_RELEASE
    am_cv_python_pyexecdir=\\\${PREFIX}${CURRENT_INSTALLED_DIR}/${PYTHON3_SITE}
    am_cv_python_pythondir=\\\${PREFIX}${CURRENT_INSTALLED_DIR}/${PYTHON3_SITE}
    
)

if(VCPKG_TARGET_IS_WINDOWS AND NOT VCPKG_TARGET_IS_MINGW)
  vcpkg_replace_string("${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/mk/vcpkg.mk" "replace-with-per-config-text" "NoDebugBuild=1")
  if(NOT VCPKG_BUILD_TYPE)
    vcpkg_replace_string("${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg/mk/vcpkg.mk" "replace-with-per-config-text" "NoReleaseBuild=1\nBuildDebugBinary=1")
    #vcpkg_replace_string("${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg/src/tool/omniidl/cxx/dir.mk" "python$(subst .,,$(PYVERSION)).lib" "python$(subst .,,$(PYVERSION))_d.lib")
    #vcpkg_replace_string("${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg/src/tool/omniidl/cxx/dir.mk" "zlib.lib" "zlibd.lib")
  endif()
endif()

vcpkg_install_make(
  MAKEFILE "GNUmakefile"
  ADD_BIN_TO_PATH
)

file(GLOB_RECURSE pyd_files "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/*.pyd" "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/*.pdb")
file(COPY ${pyd_files}  DESTINATION "${CURRENT_PACKAGES_DIR}/bin")
file(GLOB_RECURSE pyd_files "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/*.lib")
file(COPY ${pyd_files}  DESTINATION "${CURRENT_PACKAGES_DIR}/lib" PATTERN "COPYING.lib" EXCLUDE)

if(NOT VCPKG_BUILD_TYPE)
  file(GLOB_RECURSE pyd_files "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg/*.pyd" "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg/*.pdb")
  file(COPY ${pyd_files}  DESTINATION "${CURRENT_PACKAGES_DIR}/debug/bin")
  file(GLOB_RECURSE pyd_files "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg/*.lib")
  file(COPY ${pyd_files}  DESTINATION "${CURRENT_PACKAGES_DIR}/debug/lib" PATTERN "COPYING.lib" EXCLUDE)
endif()

vcpkg_fixup_pkgconfig()

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/COPYING.LIB") # Lib is LGPL

file(REMOVE_RECURSE 
      "${CURRENT_PACKAGES_DIR}/debug/share"
      "${CURRENT_PACKAGES_DIR}/debug/${PYTHON3_SITE}/omniidl_be/__init__.py"
      "${CURRENT_PACKAGES_DIR}/debug/${PYTHON3_SITE}/omniidl_be/__pycache__"
      "${CURRENT_PACKAGES_DIR}/${PYTHON3_SITE}/omniidl_be/__init__.py"
      "${CURRENT_PACKAGES_DIR}/${PYTHON3_SITE}/omniidl_be/__pycache__"
      "${CURRENT_PACKAGES_DIR}/debug/tools"
    )
