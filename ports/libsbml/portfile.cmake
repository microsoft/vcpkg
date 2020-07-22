vcpkg_from_github(
        OUT_SOURCE_PATH SOURCE_PATH
        REPO opencor/libsbml
        REF v5.18.0
        SHA512 7d48de4ab40018ba92206daf4f5e5376050c4497b589cdf86de0875e3986b5e6b27c4ae178df627d208e037cf32d8ab3d04e33a52e5e077db14999f4fb601ea5
        HEAD_REF master
)
message("SOURCE_PATH ${SOURCE_PATH}")
message("CURRENT_PACKAGES_DIR ${CURRENT_PACKAGES_DIR}")
vcpkg_configure_cmake(
        SOURCE_PATH ${SOURCE_PATH}
        PREFER_NINJA
        OPTIONS -DWITH_CPP_NAMESPACE:BOOL=ON
)
vcpkg_install_cmake()

# remove include files for libsbml
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/share/libsbml/cmake")

vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake TARGET_PATH share/libsbml/cmake)


configure_file("${CURRENT_PACKAGES_DIR}/LICENSE.txt" "${CURRENT_PACKAGES_DIR}/share/libsbml/copyright" COPYONLY)


set(FILES_TO_REMOVE
        "${CURRENT_PACKAGES_DIR}/COPYING.txt"
        "${CURRENT_PACKAGES_DIR}/FUNDING.txt"
        "${CURRENT_PACKAGES_DIR}/LICENSE.txt"
        "${CURRENT_PACKAGES_DIR}/NEWS.txt"
        "${CURRENT_PACKAGES_DIR}/OLD_NEWS.txt"
        "${CURRENT_PACKAGES_DIR}/README.txt"
        "${CURRENT_PACKAGES_DIR}/VERSION.txt"

        "${CURRENT_PACKAGES_DIR}/debug/COPYING.txt"
        "${CURRENT_PACKAGES_DIR}/debug/FUNDING.txt"
        "${CURRENT_PACKAGES_DIR}/debug/LICENSE.txt"
        "${CURRENT_PACKAGES_DIR}/debug/NEWS.txt"
        "${CURRENT_PACKAGES_DIR}/debug/OLD_NEWS.txt"
        "${CURRENT_PACKAGES_DIR}/debug/README.txt"
        "${CURRENT_PACKAGES_DIR}/debug/VERSION.txt"
        )


foreach (f ${FILES_TO_REMOVE})
    file(REMOVE ${f})
endforeach ()














