vcpkg_download_distfile(ARCHIVE
    URLS "https://netcologne.dl.sourceforge.net/project/omniorb/omniORB/omniORB-4.3.0/omniORB-4.3.0.tar.bz2"
    FILENAME "omniORB-${VERSION}.tar.bz2"
    SHA512 b081c1acbea3c7bee619a288fec209a0705b7d436f8e5fd4743675046356ef271a8c75882334fcbde4ff77d15f54d2da55f6cfcd117b01e42919d04fd29bfe2f
)

if(VCPKG_TARGET_IS_WINDOWS AND NOT VCPKG_TARGET_IS_MINGW)
set (PATCHES 
      hardcode_vaargs_for_msvc.patch
    )
set (OPTIONS 
      ac_cv_prog_cc_g=yes
      ac_cv_prog_cxx_11=no
      ac_cv_prog_cxx_g=yes
      omni_cv_sync_add_and_fetch=no
    )
endif()

vcpkg_extract_source_archive(
    SOURCE_PATH
    ARCHIVE "${ARCHIVE}"
    PATCHES 
      fix_dependency.patch
      def_gen_fix.patch
      msvc-src-build-fixes.patch
      release-debug-static.patch
      add_win_into_autotools.patch
      python-fixes.patch
      ${PATCHES}
)

vcpkg_add_to_path("${CURRENT_HOST_INSTALLED_DIR}/tools/python3") # port ask python distutils for info.
if(VCPKG_TARGET_IS_WINDOWS AND NOT VCPKG_TARGET_IS_MINGW)
  set(ENV{PYTHONPATH} "${CURRENT_HOST_INSTALLED_DIR}/tools/python3/Lib${VCPKG_HOST_PATH_SEPARATOR}${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/lib/python${VCPKG_HOST_PATH_SEPARATOR}${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg/lib/python")
endif()

if(NOT VCPKG_TARGET_IS_WINDOWS)
    file(GLOB _py3_include_path "${CURRENT_HOST_INSTALLED_DIR}/include/python3*")
    string(REGEX MATCH "python3\\.([0-9]+)" _python_version_tmp "${_py3_include_path}")
    set(PYTHON_VERSION_MINOR "${CMAKE_MATCH_1}")
    list(APPEND OPTIONS "PYTHON=${CURRENT_HOST_INSTALLED_DIR}/tools/python3/python3.${PYTHON_VERSION_MINOR}")
endif()

vcpkg_find_acquire_program(FLEX)
cmake_path(GET FLEX PARENT_PATH FLEX_DIR)
vcpkg_add_to_path("${FLEX_DIR}")

vcpkg_find_acquire_program(BISON)
cmake_path(GET BISON PARENT_PATH BISON_DIR)
vcpkg_add_to_path("${BISON_DIR}")

if(VCPKG_TARGET_IS_WINDOWS AND NOT VCPKG_TARGET_IS_MINGW)
  set(z_vcpkg_org_linkage "${VCPKG_LIBRARY_LINKAGE}") 
  # convoluted build system; shared builds requires 
  # static library to create def file for symbol export
  # tools seem to only dynamically link on windows due to make rules!
  # zlib/zstd deps for ZIOP seem to not work on windows. At least configure
  # won't run the required checks for some reasons.
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
  configure_file("${CMAKE_CURRENT_LIST_DIR}/vcpkg.mk" "${SOURCE_PATH}/mk/platforms/vcpkg.mk" @ONLY NEWLINE_STYLE UNIX)
  file(GLOB_RECURSE wrappers "${SOURCE_PATH}/bin/x86_win32/*")
  file(COPY ${wrappers} DESTINATION "${SOURCE_PATH}/bin")
endif()

vcpkg_configure_make(
  SOURCE_PATH "${SOURCE_PATH}"
  AUTOCONFIG
  NO_WRAPPERS
  COPY_SOURCE
  OPTIONS
    ${OPTIONS}
)

if(VCPKG_TARGET_IS_WINDOWS AND NOT VCPKG_TARGET_IS_MINGW)
  vcpkg_replace_string("${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel//mk/platforms/vcpkg.mk" "replace-with-per-config-text" "NoDebugBuild=1")
  if(NOT VCPKG_BUILD_TYPE)
    vcpkg_replace_string("${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg/mk/platforms/vcpkg.mk" "replace-with-per-config-text" "NoReleaseBuild=1\nBuildDebugBinary=1")
    vcpkg_replace_string("${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg/src/tool/omniidl/cxx/dir.mk" "python$(subst .,,$(PYVERSION)).lib" "python$(subst .,,$(PYVERSION))_d.lib")
    vcpkg_replace_string("${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg/src/tool/omniidl/cxx/dir.mk" "zlib.lib" "zlibd.lib")
  endif()
endif()

vcpkg_install_make(
  MAKEFILE "GNUmakefile"
  ADD_BIN_TO_PATH
)

vcpkg_fixup_pkgconfig()

if(VCPKG_TARGET_IS_WINDOWS AND NOT VCPKG_TARGET_IS_MINGW)
  file(COPY "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/lib/msvcstub.lib" DESTINATION "${CURRENT_PACKAGES_DIR}/lib")
  file(GLOB all_libs "${CURRENT_PACKAGES_DIR}/lib/*.lib")
  set(import_libs "${all_libs}")
  list(FILTER import_libs INCLUDE REGEX "(_rt.lib$|msvcstub)")
  if(z_vcpkg_org_linkage STREQUAL "static")
    file(REMOVE ${import_libs})
  else()
    list(REMOVE_ITEM all_libs ${import_libs})
    file(REMOVE ${all_libs}) # remove installed static libs
    set(to_copy_and_rename "${import_libs}")
    list(FILTER to_copy_and_rename INCLUDE REGEX "3(0)?_rt.lib")
    foreach(cp IN LISTS to_copy_and_rename)
      string(REGEX REPLACE "3(0)?_rt" "" new_name "${cp}")
      string(REGEX REPLACE "thread4" "thread" new_name "${new_name}")
      file(COPY_FILE "${cp}" "${new_name}")
    endforeach()
    file(GLOB dll_files "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/bin/*.dll")
    file(COPY ${dll_files} DESTINATION "${CURRENT_PACKAGES_DIR}/bin")
    file(GLOB pc_files "${CURRENT_PACKAGES_DIR}/lib/pkgconfig/*.pc")
    foreach(pc_file IN LISTS pc_files)
      get_filename_component(filename "${pc_file}" NAME_WE)
      if(filename STREQUAL "omnithread3")
        vcpkg_replace_string("${pc_file}" "-lomnithread" "-lomnithread_rt")
      else()
        vcpkg_replace_string("${pc_file}" "-l${filename}" "-l${filename}_rt")
      endif()
    endforeach()
  endif()

  if(NOT VCPKG_BUILD_TYPE) # dbg libs have no install rules so manually copy them.
    file(GLOB all_libs "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg/lib/*.lib")
    set(install_libs "${all_libs}")
    if(z_vcpkg_org_linkage STREQUAL "static")
      list(FILTER install_libs EXCLUDE REGEX "(_rtd.lib$|msvcstub)")
    else() # dynamic lib
      list(FILTER install_libs INCLUDE REGEX "(_rtd.lib$|msvcstub)")
      set(to_copy_and_rename "${install_libs}")
      list(FILTER to_copy_and_rename INCLUDE REGEX "3(0)?_rtd.lib")
      foreach(cp IN LISTS to_copy_and_rename)
        string(REGEX REPLACE "3(0)?_rt" "" new_name "${cp}")
        string(REGEX REPLACE "thread4" "thread" new_name "${new_name}")
        file(COPY_FILE "${cp}" "${new_name}")
        list(APPEND install_libs "${new_name}")
      endforeach()
      file(GLOB dll_files "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg/bin/*.dll")
      file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/debug/bin")
      file(COPY ${dll_files} DESTINATION "${CURRENT_PACKAGES_DIR}/debug/bin")
      file(GLOB pc_files "${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig/*.pc")
      foreach(pc_file IN LISTS pc_files)
        get_filename_component(filename "${pc_file}" NAME_WE)
        if(filename STREQUAL "omnithread3")
          vcpkg_replace_string("${pc_file}" "-lomnithread" "-lomnithread_rtd")
        else()
          vcpkg_replace_string("${pc_file}" "-l${filename}" "-l${filename}_rtd")
        endif()
      endforeach()
    endif()
    file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/debug/lib")
    file(COPY ${install_libs} DESTINATION "${CURRENT_PACKAGES_DIR}/debug/lib")
  endif()
endif()

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/COPYING.LIB") # Lib is LGPL
file(INSTALL "${SOURCE_PATH}/COPYING" DESTINATION "${CURRENT_PACKAGES_DIR}/tools/${PORT}/bin" RENAME copyright) # Tools etc are GPL

vcpkg_copy_pdbs()

if(VCPKG_TARGET_IS_WINDOWS AND NOT VCPKG_TARGET_IS_MINGW)
file(COPY
      "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/bin/omnicpp${VCPKG_TARGET_EXECUTABLE_SUFFIX}"
    DESTINATION
      "${CURRENT_PACKAGES_DIR}/tools/${PORT}/bin"
    )
endif()

file(COPY
      "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/bin/omniidl${VCPKG_TARGET_EXECUTABLE_SUFFIX}"
    DESTINATION
      "${CURRENT_PACKAGES_DIR}/tools/${PORT}/bin"
    )

vcpkg_copy_tool_dependencies("${CURRENT_PACKAGES_DIR}/tools/${PORT}/bin")

# Restore old linkage info. 
if(VCPKG_TARGET_IS_WINDOWS AND NOT VCPKG_TARGET_IS_MINGW)
   set(VCPKG_LIBRARY_LINKAGE "${z_vcpkg_org_linkage}")
endif()

if(NOT VCPKG_TARGET_IS_WINDOWS)
  vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/tools/${PORT}/bin/omniidl" "${CURRENT_INSTALLED_DIR}" "\"os.path.dirname(__file__)+\"/../../../")
endif()

set(del_files "")
if(VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic")
  file(GLOB del_files "${CURRENT_PACKAGES_DIR}/lib/*.a" "${CURRENT_PACKAGES_DIR}/debug/lib/*.a")
  if(del_files)
    file(REMOVE ${del_files})
  endif()
else()
  file(GLOB del_files "${CURRENT_PACKAGES_DIR}/lib/*.so*" "${CURRENT_PACKAGES_DIR}/debug/lib/*.so*")
  if(del_files)
    file(REMOVE ${del_files})
  endif()
endif()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/tools/${PORT}/debug")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
