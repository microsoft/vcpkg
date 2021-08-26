if (VCPKG_TARGET_IS_WINDOWS)
    vcpkg_check_linkage(ONLY_STATIC_LIBRARY)
endif()

vcpkg_from_github(
	OUT_SOURCE_PATH SOURCE_PATH
	REPO mjsottile/sfsexp
	REF  ad589f9e6e0eca20345320e9c82a3aecc0a5c8aa #v1.3
	SHA512 cdd469e23de48a5d6cd633b7b97b394cbfcba330ac2c3ae549811d856f2eec0c8558f99313e56a9f1cc9d72d4f17077584b6cf15c87814b91fe44ddd76895a8c
    HEAD_REF master
)

file(COPY ${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt DESTINATION ${SOURCE_PATH})

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
)

vcpkg_install_cmake()

file(INSTALL ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)