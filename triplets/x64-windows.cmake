set(VCPKG_TARGET_ARCHITECTURE x64)
set(VCPKG_CRT_LINKAGE dynamic)
set(VCPKG_LIBRARY_LINKAGE dynamic)
#set(VCPKG_CMAKE_CONFIGURE_OPTIONS "-DVCPKG_PORT=${PORT}" "-DCMAKE_JOB_POOL_LINK=console") # tell cmake to only run one link job pool
#set(VCPKG_MESON_CONFIGURE_OPTIONS "-Dbackend_max_links=1") # to tell meson to not run the linker in parallel
set(VCPKG_POST_PORTFILE_INCLUDES "${CMAKE_CURRENT_LIST_DIR}/move_pdb_files.cmake")
#message(FATAL_ERROR "WIP: BLOCK CI")