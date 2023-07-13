include_guard(GLOBAL)
include("${CMAKE_CURRENT_LIST_DIR}/../vcpkg-cmake-get-vars/vcpkg-port-config.cmake")
include("${CMAKE_CURRENT_LIST_DIR}/z_vcpkg_qmake_fix_makefiles.cmake")
include("${CMAKE_CURRENT_LIST_DIR}/vcpkg_qmake_configure.cmake")
include("${CMAKE_CURRENT_LIST_DIR}/vcpkg_qmake_build.cmake")
include("${CMAKE_CURRENT_LIST_DIR}/vcpkg_qmake_install.cmake")

