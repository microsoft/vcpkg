include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO cisco/libsrtp
    REF 56a065555aea2abddaf9fb60353fe59f277837a3
    SHA512 59afa25df79f875d28eefe95ef89b5956b1d2f319bba38ec34b832c2faa16b5425aae2f6ad19cf478afe02b28f4032b5dcf20a301d647d897d4577f66ca77376
)

if (VCPKG_TARGET_IS_WINDOWS)
  set(VCPKG_C_FLAGS "${VCPKG_C_FLAGS} -D_CRT_SECURE_NO_WARNINGS /wd4703")
  set(VCPKG_CXX_FLAGS "${VCPKG_CXX_FLAGS} -D_CRT_SECURE_NO_WARNINGS /wd4703")
endif()

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
)

vcpkg_install_cmake()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

if(EXISTS ${CURRENT_PACKAGES_DIR}/lib/srtp2.dll)
    file(MAKE_DIRECTORY ${CURRENT_PACKAGES_DIR}/bin)
    file(RENAME ${CURRENT_PACKAGES_DIR}/lib/srtp2.dll ${CURRENT_PACKAGES_DIR}/bin/srtp2.dll)
endif()
if(EXISTS ${CURRENT_PACKAGES_DIR}/debug/lib/srtp2.dll)
    file(MAKE_DIRECTORY ${CURRENT_PACKAGES_DIR}/debug/bin)
    file(RENAME ${CURRENT_PACKAGES_DIR}/debug/lib/srtp2.dll ${CURRENT_PACKAGES_DIR}/debug/bin/srtp2.dll)
endif()

file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/libsrtp RENAME copyright)