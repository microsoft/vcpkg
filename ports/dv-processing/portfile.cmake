vcpkg_from_gitlab(
        GITLAB_URL https://gitlab.com/inivation
        OUT_SOURCE_PATH SOURCE_PATH
        REPO dv/dv-processing
        REF 15302dfdd6ad2e1d18c15a6589a830e4e3e45f97
        SHA512 0
        HEAD_REF rel_1.7
)

vcpkg_from_gitlab(
        GITLAB_URL https://gitlab.com/inivation
        OUT_SOURCE_PATH CMAKEMOD_SOURCE_PATH
        REPO dv/cmakemod
        REF ec53dae89f6b037e9e640af5340d7bf67d84d278
        SHA512 0
        HEAD_REF ec53dae89f6b037e9e640af5340d7bf67d84d278
)

file(GLOB CMAKEMOD_FILES ${CMAKEMOD_SOURCE_PATH}/*)
file(COPY ${CMAKEMOD_FILES} DESTINATION ${SOURCE_PATH}/cmake/modules)

vcpkg_cmake_configure(
        SOURCE_PATH ${SOURCE_PATH}
        OPTIONS
		-DENABLE_TESTS=OFF
		-DENABLE_SAMPLES=OFF
		-DENABLE_PYTHON=OFF
		-DENABLE_UTILITIES=OFF
		-DBUILD_CONFIG_VCPKG=ON
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(PACKAGE_NAME "dv-processing" CONFIG_PATH "share/dv-processing")

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

vcpkg_fixup_pkgconfig(SKIP_CHECK)

file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
