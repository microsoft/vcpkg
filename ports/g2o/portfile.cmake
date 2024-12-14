string(REPLACE "-" "" GIT_TAG "${VERSION}_git")
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO RainerKuemmerle/g2o
    REF "${GIT_TAG}"
    SHA512 626b4d286b564ca6714957d0caf41cf5387ecbc7100299c1a1134fa4a11a340f6e6e0796fa5ff16229032a1e1e384bc03e7d2c118be39d6d51a20d9f2774a98d
    HEAD_REF master
    PATCHES
        fix-absolute.patch
)

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "dynamic" BUILD_LGPL_SHARED_LIBS)
file(REMOVE "${SOURCE_PATH}/cmake_modules/FindBLAS.cmake")

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DBUILD_LGPL_SHARED_LIBS=${BUILD_LGPL_SHARED_LIBS}
        -DG2O_BUILD_EXAMPLES=OFF
        -DG2O_BUILD_APPS=OFF
)

vcpkg_cmake_install()

vcpkg_copy_pdbs()

vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/g2o)

if(VCPKG_LIBRARY_LINKAGE STREQUAL dynamic)
    file(GLOB_RECURSE HEADERS "${CURRENT_PACKAGES_DIR}/include/*")
    foreach(HEADER ${HEADERS})
        file(READ ${HEADER} HEADER_CONTENTS)
        string(REPLACE "#ifdef G2O_SHARED_LIBS" "#if 1" HEADER_CONTENTS "${HEADER_CONTENTS}")
        file(WRITE ${HEADER} "${HEADER_CONTENTS}")
    endforeach()
endif()

file(GLOB EXE "${CURRENT_PACKAGES_DIR}/bin/*.exe")
file(GLOB DEBUG_EXE "${CURRENT_PACKAGES_DIR}/debug/bin/*.exe")
if(EXE OR DEBUG_EXE)
    file(REMOVE ${EXE} ${DEBUG_EXE})
endif()
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

file(INSTALL "${SOURCE_PATH}/doc/license-bsd.txt" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
