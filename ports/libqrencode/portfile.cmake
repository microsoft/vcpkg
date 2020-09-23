vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO fukuchi/libqrencode
    REF 0f6149e41533a34029e72ff9234a18e0f22ab992 #v4.1.0
    SHA512 7aa215d1a9b06df19bcc0178d241af285d5215f6df994f9e2cf64cde716c7451252380a17e60ef27899bf9039e91306c8eb1948b40ede188d49a25555a94c22a
    HEAD_REF master
)

if("tool" IN_LIST FEATURES)
    set(WITH_TOOLS YES)
else()
    set(WITH_TOOLS NO)
endif()

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DWITH_TOOLS=${WITH_TOOLS}
        -DWITH_TEST=NO
        -DSKIP_INSTALL_PROGRAMS=ON
        -DSKIP_INSTALL_EXECUTABLES=ON
        -DSKIP_INSTALL_FILES=ON
    OPTIONS_DEBUG
        -DSKIP_INSTALL_HEADERS=ON
        -DWITH_TOOLS=NO
)

vcpkg_install_cmake()

if(VCPKG_TARGET_IS_WINDOWS) # Windows
	set(EXECUTABLE_SUFFIX ".exe")
else()
	set(EXECUTABLE_SUFFIX "")
endif()

if(EXISTS ${CURRENT_PACKAGES_DIR}/lib/qrencode.dll)
    file(MAKE_DIRECTORY ${CURRENT_PACKAGES_DIR}/bin)
    file(RENAME ${CURRENT_PACKAGES_DIR}/lib/qrencode.dll ${CURRENT_PACKAGES_DIR}/bin/qrencode.dll)
endif()
if(EXISTS ${CURRENT_PACKAGES_DIR}/debug/lib/qrencoded.dll)
    file(MAKE_DIRECTORY ${CURRENT_PACKAGES_DIR}/debug/bin)
    file(RENAME ${CURRENT_PACKAGES_DIR}/debug/lib/qrencoded.dll ${CURRENT_PACKAGES_DIR}/debug/bin/qrencoded.dll)
endif()
if(EXISTS ${CURRENT_PACKAGES_DIR}/bin/qrencode${EXECUTABLE_SUFFIX})
    file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/tools/qrencode")
    file(RENAME "${CURRENT_PACKAGES_DIR}/bin/qrencode${EXECUTABLE_SUFFIX}" "${CURRENT_PACKAGES_DIR}/tools/qrencode/qrencode${EXECUTABLE_SUFFIX}")
    vcpkg_copy_tool_dependencies(${CURRENT_PACKAGES_DIR}/tools/qrencode)
endif()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)
file(INSTALL ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)

vcpkg_copy_pdbs()

file(COPY ${CMAKE_CURRENT_LIST_DIR}/usage DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT})