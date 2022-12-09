vcpkg_from_gitlab(
        GITLAB_URL https://gitlab.com/inivation
        OUT_SOURCE_PATH SOURCE_PATH
        REPO dv/dv-processing
        REF 6029bb4ecc06566b5f68375c68f00dfe78587baa
        SHA512 9d0928e6ded1dab147814f380c57fb5b2c467c213c1fd12dddad9982e7d6a94a7bef526fcd248dd672b4b84753a44599b10d7794640ec63027152cd33b675787
        HEAD_REF rel_1.5
)

vcpkg_from_gitlab(
        GITLAB_URL https://gitlab.com/inivation
        OUT_SOURCE_PATH CMAKEMOD_SOURCE_PATH
        REPO dv/cmakemod
        REF a4d7eccfdc5f83e399786a77df79b178b762858b
        SHA512 4fe9cc5099ab8b41c982df45cbf9a000b2cb1f1c6ed536685943a60520cff49e262ec43af8187177c50a0df2dfca57e7861bf2e7d07834fc16e85c30eb9a9edb
        HEAD_REF a4d7eccfdc5f83e399786a77df79b178b762858b
)

file(GLOB CMAKEMOD_FILES ${CMAKEMOD_SOURCE_PATH}/*)
file(COPY ${CMAKEMOD_FILES} DESTINATION ${SOURCE_PATH}/cmakemod)

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
