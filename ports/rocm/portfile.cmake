# This package does not install ROCm. It instead verifies that ROCm is
# installed, mirroring the registered cuda port.  Other packages can depend
# on this package to declare a dependency on ROCm.

include("${CMAKE_CURRENT_LIST_DIR}/vcpkg_find_rocm.cmake")

vcpkg_find_rocm(OUT_ROCM_TOOLKIT_ROOT ROCM_TOOLKIT_ROOT)

file(COPY "${CMAKE_CURRENT_LIST_DIR}/vcpkg-port-config.cmake" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
file(COPY "${CMAKE_CURRENT_LIST_DIR}/vcpkg_find_rocm.cmake" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
file(INSTALL "${VCPKG_ROOT_DIR}/LICENSE.txt" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)

set(VCPKG_POLICY_CMAKE_HELPER_PORT enabled)
