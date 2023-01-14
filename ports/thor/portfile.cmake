vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO Bromeon/Thor
  REF v2.0
  SHA512 634fa5286405d9a8a837c082ace98bbb02e609521418935855b9e2fcad57003dbe35088bd771cf6a9292e55d3787f7e463d7a4cca0d0f007509de2520d9a8cf9
  HEAD_REF master
  PATCHES fix-dependency-sfml.patch
)
file(REMOVE "${SOURCE_PATH}/cmake/Modules/FindSFML.cmake")

file(REMOVE_RECURSE "${SOURCE_PATH}/extlibs")
file(COPY "${CURRENT_INSTALLED_DIR}/include/Aurora" DESTINATION "${SOURCE_PATH}/extlibs/aurora/include")
file(WRITE "${SOURCE_PATH}/extlibs/aurora/License.txt")

string(COMPARE EQUAL "${VCPKG_CRT_LINKAGE}" "static" THOR_STATIC_STD_LIBS)
string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "dynamic" THOR_SHARED_LIBS)

vcpkg_cmake_configure(
  SOURCE_PATH "${SOURCE_PATH}"
  OPTIONS
    -DTHOR_SHARED_LIBS=${THOR_SHARED_LIBS}
    -DTHOR_STATIC_STD_LIBS=${THOR_STATIC_STD_LIBS}
)

vcpkg_cmake_install()

vcpkg_copy_pdbs()

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/Thor/Config.hpp"
        "defined(SFML_STATIC)" "1"
    )
else()
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/Thor/Config.hpp"
        "defined(SFML_STATIC)" "0"
    )
endif()

file(GLOB LICENSE
  "${CURRENT_PACKAGES_DIR}/debug/LicenseThor.txt"
  "${CURRENT_PACKAGES_DIR}/debug/LicenseAurora.txt"
  "${CURRENT_PACKAGES_DIR}/LicenseThor.txt"
  "${CURRENT_PACKAGES_DIR}/LicenseAurora.txt"
)

if(LICENSE)
  file(REMOVE ${LICENSE})
endif()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include" "${CURRENT_PACKAGES_DIR}/include/Aurora")

if(NOT VCPKG_TARGET_IS_WINDOWS)
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
endif()

file(INSTALL "${SOURCE_PATH}/License.txt" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
