vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO RainerKuemmerle/g2o
    REF fcba4eaca6f20d9a5792404cc8ef303aeb8ba5d2
    SHA512 41e5a6d40db10d66182653d56f937f29264bf4f9412dfa651be949caeb055741c9d9ba75a122180892aafe7d45b334d50470284121148c0561e1d49f6ba5e20a
    HEAD_REF master
    PATCHES
        csparse.diff
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
