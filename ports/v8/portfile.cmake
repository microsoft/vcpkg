set(V8_VER 8.0.251)

vcpkg_from_github(
	OUT_SOURCE_PATH SOURCE_PATH
	REPO v8/v8
	REF  092205497b35a2e8c3e9289c946ff2034e8d77d2# v8.0.251
	SHA512 d884125352677e01784e97a26979f18478961f50974932a2e66766f798a0614efc15f1e9b4318d2645cde9317d933f013f55c9c155739e534e4f17c0bf38585d
    HEAD_REF master
)

vcpkg_find_acquire_program(GN)
get_filename_component(GN_PATH ${GN} DIRECTORY)
set(GN_PATH ${GN_PATH}/../../..)

vcpkg_find_acquire_program(NINJA)
set(ENV{GYP_GENERATORS} "ninja")

vcpkg_sync_gn(
    SOURCE_PATH ${SOURCE_PATH}
    VER ${V8_VER}
)

vcpkg_configure_gn(
    SOURCE_PATH ${SOURCE_PATH}
    PROJECT_SUBPATH src
)

vcpkg_build_gn()

file(INSTALL ${SOURCE_PATH}/src/v8/include DESTINATION ${CURRENT_PACKAGES_DIR} FILES_MATCHING PATTERN "*.h")

set(LIBRARY_FILES v8.dll v8_libbase.dll v8_libplatform.dll icui18n.dll icuuc.dll)
foreach(ITEM ${LIBRARY_FILES})
    file(INSTALL "${v8_PROJECT_OBJPATH_RELEASE}/${ITEM}" DESTINATION ${CURRENT_PACKAGES_DIR}/bin )
    file(INSTALL "${v8_PROJECT_OBJPATH_DEBUG}/${ITEM}.lib" DESTINATION ${CURRENT_PACKAGES_DIR}/lib )
    file(INSTALL "${v8_PROJECT_OBJPATH_RELEASE}/${ITEM}" DESTINATION ${CURRENT_PACKAGES_DIR}/debug/bin )
    file(INSTALL "${v8_PROJECT_OBJPATH_DEBUG}/${ITEM}.lib" DESTINATION ${CURRENT_PACKAGES_DIR}/debug/lib )
endforeach()


# Handle copyright
file(INSTALL ${SOURCE_PATH}/src/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/v8 RENAME copyright)

vcpkg_copy_pdbs()