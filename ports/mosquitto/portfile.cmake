include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO eclipse/mosquitto
    REF v1.4.15
    SHA512 428ef9434d3fe022232dcde415fe8cd948d237507d512871803a116230f9e011c10fa01313111ced0946f906e8cc7e26d9eee5de6caa7f82590753a4d087f6fd
    HEAD_REF master
)

vcpkg_apply_patches(
    SOURCE_PATH ${SOURCE_PATH}
    PATCHES
        ${CMAKE_CURRENT_LIST_DIR}/cmake.patch
)

file(COPY ${CURRENT_PORT_DIR}/CMakeLists.txt DESTINATION ${SOURCE_PATH})

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
	PREFER_NINJA
    OPTIONS
		-DWITH_SRV=OFF
		-DWITH_WEBSOCKETS=ON
		-DWITH_TLS=ON
		-DWITH_TLS_PSK=ON
		-DWITH_THREADING=ON
		#-DUUID_HEADER=${VCPKG_ROOT_DIR}/installed/${TARGET_TRIPLET}/include
		-DVCPKG_ROOT_DIR=${VCPKG_ROOT_DIR}
		-DTARGET_TRIPLET=${TARGET_TRIPLET}
		-DCMAKE_VS_INCLUDE_INSTALL_TO_DEFAULT_BUILD=OFF
	OPTIONS_RELEASE
		-DENABLE_DEBUG=OFF
		-DOPTIMIZE=1
	OPTIONS_DEBUG
		-DENABLE_DEBUG=ON
		-DDEBUGGABLE=1
    # OPTIONS_RELEASE -DOPTIMIZE=1
    # OPTIONS_DEBUG -DDEBUGGABLE=1
)

vcpkg_install_cmake()

# Remove debug/include
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

# fix *.cmake
#vcpkg_fixup_cmake_targets(CONFIG_PATH "lib/cmake/mosquitto")

file(MAKE_DIRECTORY ${CURRENT_PACKAGES_DIR}/bin)
file(MAKE_DIRECTORY ${CURRENT_PACKAGES_DIR}/lib)
file(MAKE_DIRECTORY ${CURRENT_PACKAGES_DIR}/debug/bin)
file(MAKE_DIRECTORY ${CURRENT_PACKAGES_DIR}/debug/lib)

# Rename dll
file(RENAME ${CURRENT_PACKAGES_DIR}/mosquitto.dll ${CURRENT_PACKAGES_DIR}/bin/mosquitto.dll)
file(RENAME ${CURRENT_PACKAGES_DIR}/mosquittopp.dll ${CURRENT_PACKAGES_DIR}/bin/mosquittopp.dll)
file(RENAME ${CURRENT_PACKAGES_DIR}/mosquitto.exe ${CURRENT_PACKAGES_DIR}/bin/mosquitto.exe)
file(RENAME ${CURRENT_PACKAGES_DIR}/mosquitto_passwd.exe ${CURRENT_PACKAGES_DIR}/bin/mosquitto_passwd.exe)
file(RENAME ${CURRENT_PACKAGES_DIR}/mosquitto_pub.exe ${CURRENT_PACKAGES_DIR}/bin/mosquitto_pub.exe)
file(RENAME ${CURRENT_PACKAGES_DIR}/mosquitto_sub.exe ${CURRENT_PACKAGES_DIR}/bin/mosquitto_sub.exe)

file(RENAME ${CURRENT_PACKAGES_DIR}/debug/mosquitto.dll ${CURRENT_PACKAGES_DIR}/debug/bin/mosquitto.dll)
file(RENAME ${CURRENT_PACKAGES_DIR}/debug/mosquittopp.dll ${CURRENT_PACKAGES_DIR}/debug/bin/mosquittopp.dll)
file(RENAME ${CURRENT_PACKAGES_DIR}/debug/mosquitto.exe ${CURRENT_PACKAGES_DIR}/debug/bin/mosquitto.exe)
file(RENAME ${CURRENT_PACKAGES_DIR}/debug/mosquitto_passwd.exe ${CURRENT_PACKAGES_DIR}/debug/bin/mosquitto_passwd.exe)
file(RENAME ${CURRENT_PACKAGES_DIR}/debug/mosquitto_pub.exe ${CURRENT_PACKAGES_DIR}/debug/bin/mosquitto_pub.exe)
file(RENAME ${CURRENT_PACKAGES_DIR}/debug/mosquitto_sub.exe ${CURRENT_PACKAGES_DIR}/debug/bin/mosquitto_sub.exe)

# Remove exe files
file(GLOB EXE ${CURRENT_PACKAGES_DIR}/bin/*.exe)
file(GLOB DEBUG_EXE ${CURRENT_PACKAGES_DIR}/debug/bin/*.exe)
file(REMOVE ${EXE})
file(REMOVE ${DEBUG_EXE})

file(GLOB LIB_FILES          	${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/lib/*.lib)
file(GLOB DEBUG_LIB_FILES    	${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg/lib/*.lib)
file(GLOB CPP_LIB_FILES         ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/lib/cpp/*.lib)
file(GLOB DEBUG_CPP_LIB_FILES   ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg/lib/cpp/*.lib)

file(COPY ${DEBUG_LIB_FILES} DESTINATION ${CURRENT_PACKAGES_DIR}/debug/lib/)
file(COPY ${DEBUG_CPP_LIB_FILES} DESTINATION ${CURRENT_PACKAGES_DIR}/debug/lib/)
file(COPY ${LIB_FILES} DESTINATION ${CURRENT_PACKAGES_DIR}/lib/)
file(COPY ${CPP_LIB_FILES} DESTINATION ${CURRENT_PACKAGES_DIR}/lib/)


file(INSTALL ${SOURCE_PATH}/LICENSE.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/mosquitto RENAME copyright)

#if (VCPKG_LIBRARY_LINKAGE STREQUAL static)
#    file(RENAME ${CURRENT_PACKAGES_DIR}/debug/lib/websockets_static.lib ${CURRENT_PACKAGES_DIR}/debug/lib/websockets.lib)
#    file(RENAME ${CURRENT_PACKAGES_DIR}/lib/websockets_static.lib ${CURRENT_PACKAGES_DIR}/lib/websockets.lib)
#endif ()

# Copy pdb
vcpkg_copy_pdbs()
