vcpkg_from_gitlab(
        GITLAB_URL https://gitlab.com/inivation
        OUT_SOURCE_PATH SOURCE_PATH
        REPO dv/dv-processing
        REF rel_1.4
        SHA512 c011ca0e6d9842913ff35b0a03f9053bfbc98c090b6936e01f6514b8a35d31ee6d0a821f491be96400113e93967aa2d3e8ab19e558f5c3e9f8eba9ad4e1fe013
        HEAD_REF d4ffab46a2849372789c5a2084821011165086ab
        PATCHES
                vcpkg-build.patch
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
		-DBUILD_CONFIG_VCPKG=ON
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(PACKAGE_NAME "dv-processing" CONFIG_PATH "share/dv-processing")

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
