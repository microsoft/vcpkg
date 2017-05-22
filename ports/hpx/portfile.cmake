include(vcpkg_common_functions)

if(NOT VCPKG_LIBRARY_LINKAGE STREQUAL dynamic)
    message(FATAL_ERROR "HPX can be built with dynamic linking only")
endif()

set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/hpx_1.0.0)

vcpkg_download_distfile(ARCHIVE
    URLS "http://stellar-group.org/files/hpx_1.0.0.tar.gz"
    FILENAME "hpx_1.0.0.tar.gz"
    SHA512 42c155654f118bff34b48d929b1732fd56126b8fd3e7657b5bd2f84275288ddf538572ed1152883c4aed5e9683de53b9b1f1c3613e5092e7bd1a5e165bed606d
)
vcpkg_extract_source_archive(${ARCHIVE})

# apply hotfix to enable building with vcpkg
vcpkg_download_distfile(DIFF
    URLS "http://stellar-group.org/files/build-system-changes-to-make-HPX-compile-when-built-with-vcpkg.diff"
    FILENAME "build-system-changes-to-make-HPX-compile-when-built-with-vcpkg.diff"
    SHA512 ceceb84b54bf564b7b9258063454084207538a2bd212f7f65503c6638914eb3c093076e4303369639ef9b34812a2c8ed363c08bbdf5a39cc5d49f720a376af75
)
vcpkg_apply_patches(SOURCE_PATH ${SOURCE_PATH} PATCHES ${DIFF})

# apply hotfix to fix issues with building 32bit version
vcpkg_download_distfile(DIFF
    URLS "http://stellar-group.org/files/Fixing-32bit-MSVC-compilation.diff"
    FILENAME "Fixing-32bit-MSVC-compilation.diff"
    SHA512 31c904d317b4c24eddd819e4856f8326ff3850a5a196c7648c46a11dbb85f35e972e077957b3c4aec67c8b043816fe1cebc92cfe28ed815f682537dfc3421b8b
)
vcpkg_apply_patches(SOURCE_PATH ${SOURCE_PATH} PATCHES ${DIFF})

SET(BOOST_PATH "${CURRENT_INSTALLED_DIR}/share/boost")
SET(HWLOC_PATH "${CURRENT_INSTALLED_DIR}/share/hwloc")

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS
        -DBOOST_ROOT=${BOOST_PATH}
        -DHWLOC_ROOT=${HWLOC_ROOT}
        -DHPX_WITH_VCPKG=ON
        -DHPX_WITH_HWLOC=ON
        -DHPX_WITH_TESTS=OFF
        -DHPX_WITH_EXAMPLES=OFF
        -DHPX_WITH_TOOLS=OFF
        -DHPX_WITH_RUNTIME=OFF
)

vcpkg_install_cmake()

# post build cleanup
file(RENAME ${CURRENT_PACKAGES_DIR}/share/hpx-1.0.0 ${CURRENT_PACKAGES_DIR}/share/hpx)

file(INSTALL
    ${SOURCE_PATH}/LICENSE_1_0.txt
    DESTINATION ${CURRENT_PACKAGES_DIR}/share/hpx RENAME copyright)

file(GLOB __hpx_cmakes ${CURRENT_PACKAGES_DIR}/lib/cmake/HPX/*.*)
foreach(__hpx_cmake ${__hpx_cmakes})
  file(COPY ${__hpx_cmake} DESTINATION ${CURRENT_PACKAGES_DIR}/share/hpx/cmake)
  file(REMOVE ${__hpx_cmake})
endforeach()

file(GLOB __hpx_dlls ${CURRENT_PACKAGES_DIR}/lib/*.dll)
foreach(__hpx_dll ${__hpx_dlls})
  file(COPY ${__hpx_dll} DESTINATION ${CURRENT_PACKAGES_DIR}/bin)
  file(REMOVE ${__hpx_dll})
endforeach()

file(GLOB __hpx_dlls ${CURRENT_PACKAGES_DIR}/lib/hpx/*.dll)
foreach(__hpx_dll ${__hpx_dlls})
  file(COPY ${__hpx_dll} DESTINATION ${CURRENT_PACKAGES_DIR}/bin/hpx)
  file(REMOVE ${__hpx_dll})
endforeach()

file(GLOB __hpx_dlls ${CURRENT_PACKAGES_DIR}/debug/lib/*.dll)
foreach(__hpx_dll ${__hpx_dlls})
  file(COPY ${__hpx_dll} DESTINATION ${CURRENT_PACKAGES_DIR}/debug/bin)
  file(REMOVE ${__hpx_dll})
endforeach()

file(GLOB __hpx_dlls ${CURRENT_PACKAGES_DIR}/debug/lib/hpx/*.dll)
foreach(__hpx_dll ${__hpx_dlls})
  file(COPY ${__hpx_dll} DESTINATION ${CURRENT_PACKAGES_DIR}/debug/bin/hpx)
  file(REMOVE ${__hpx_dll})
endforeach()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/lib/bazel)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/lib/cmake)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/lib/pkgconfig)

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/lib/bazel)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/lib/cmake)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig)

vcpkg_copy_pdbs()

