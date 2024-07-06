vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO pothosware/SoapySDR
    REF soapy-sdr-0.8.1
    SHA512 50c8f1652bf9ca09215f9c4115175427ca7b5338add7591e31ca0e627093c94b73e7cf7f84fa71ff419cc010d3c1263931506c728bbaa00413a7915d56a87787
)

vcpkg_cmake_configure(
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS
        -DENABLE_DOCS=OFF
        -DENABLE_APPS=OFF
	-DENABLE_PYTHON=OFF
	-DENABLE_PYTHON3=OFF
	-DENABLE_TESTS=OFF
)

vcpkg_cmake_install()

vcpkg_install_copyright(
    FILE_LIST "${SOURCE_PATH}/LICENSE_1_0.txt"
)


file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

if (VCPKG_TARGET_IS_WINDOWS)
file(INSTALL ${CURRENT_PACKAGES_DIR}/cmake/ DESTINATION ${CURRENT_PACKAGES_DIR}/share/soapysdr/)
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/cmake")
endif()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/cmake")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

vcpkg_fixup_pkgconfig()
