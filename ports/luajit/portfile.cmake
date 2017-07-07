include(vcpkg_common_functions)

set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/LuaJIT-2.0.5)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO LuaJIT/LuaJIT
    REF v2.0.5
    SHA512 65d982d7fe532a61335613f414f3b8fa5333747bdf7aefc2c2d52022d227594ade827639049b97e3c4ffae9f38f32cb15f1a17b1780fb0a943e1a3af05e2b576
    HEAD_REF master
)

# Handle copyright
file(COPY ${SOURCE_PATH}/COPYRIGHT DESTINATION ${CURRENT_PACKAGES_DIR}/share/luajit)

set (SRC ${SOURCE_PATH}/src)

if (VCPKG_LIBRARY_LINKAGE STREQUAL dynamic)
	set (LJIT_STATIC "")
else()
	set (LJIT_STATIC "static")
endif()

message(STATUS "Building ${TARGET_TRIPLET}-dbg")

file(REMOVE "${SOURCE_PATH}/src/*.dll")
file(REMOVE "${SOURCE_PATH}/src/*.exe")
vcpkg_execute_required_process_repeat(
    COUNT 1
    COMMAND "${SOURCE_PATH}/src/msvcbuild.bat" "debug" ${LJIT_STATIC}
    WORKING_DIRECTORY "${SOURCE_PATH}/src/"
    LOGNAME build-${TARGET_TRIPLET}-dbg
)


file(INSTALL ${SRC}/lua51.lib 			DESTINATION ${CURRENT_PACKAGES_DIR}/debug/lib)
file(INSTALL ${SRC}/luajit.exe 			DESTINATION ${CURRENT_PACKAGES_DIR}/debug/tools)

if (VCPKG_LIBRARY_LINKAGE STREQUAL dynamic)
	file(INSTALL ${SRC}/lua51.dll 		DESTINATION ${CURRENT_PACKAGES_DIR}/debug/bin)
endif()

message(STATUS "Building ${TARGET_TRIPLET}-rel")

file(REMOVE "${SOURCE_PATH}/src/*.dll")
file(REMOVE "${SOURCE_PATH}/src/*.exe")
vcpkg_execute_required_process_repeat(
    COUNT 1
    COMMAND "${SOURCE_PATH}/src/msvcbuild.bat" ${LJIT_STATIC}
    WORKING_DIRECTORY "${SOURCE_PATH}/src/"
    LOGNAME build-${TARGET_TRIPLET}-rel
)

file(INSTALL ${SRC}/lua51.lib 		DESTINATION ${CURRENT_PACKAGES_DIR}/lib)
file(INSTALL ${SRC}/luajit.exe 		DESTINATION ${CURRENT_PACKAGES_DIR}/tools)

if (VCPKG_LIBRARY_LINKAGE STREQUAL dynamic)
	file(INSTALL ${SRC}/lua51.dll 	DESTINATION ${CURRENT_PACKAGES_DIR}/bin)
endif()

file(INSTALL ${SRC}/lua.h 			DESTINATION ${CURRENT_PACKAGES_DIR}/include)
file(INSTALL ${SRC}/luajit.h 		DESTINATION ${CURRENT_PACKAGES_DIR}/include)
file(INSTALL ${SRC}/luaconf.h 		DESTINATION ${CURRENT_PACKAGES_DIR}/include)
file(INSTALL ${SRC}/lualib.h 		DESTINATION ${CURRENT_PACKAGES_DIR}/include)
file(INSTALL ${SRC}/lauxlib.h 		DESTINATION ${CURRENT_PACKAGES_DIR}/include)
file(INSTALL ${SRC}/lua.hpp 		DESTINATION ${CURRENT_PACKAGES_DIR}/include)
