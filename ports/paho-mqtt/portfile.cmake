include(vcpkg_common_functions)

vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO eclipse/paho.mqtt.c
  REF v1.2.0
  SHA512 ffad01a8f9f41049dd008e163136e4ecb8c7c51f7b49917201593b0844b15a8d2a413ddec06fa5b2d77e432f0603b71664a23afbb7c215121cebd7d419ccacfa
  HEAD_REF master
)

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "static" PAHO_BUILD_STATIC)


vcpkg_apply_patches(
  SOURCE_PATH ${SOURCE_PATH}
  PATCHES
  "${CMAKE_CURRENT_LIST_DIR}/disable_tests.patch"
    "${CMAKE_CURRENT_LIST_DIR}/remove_compiler_options.patch"
)


vcpkg_configure_cmake(
  SOURCE_PATH ${SOURCE_PATH}
  PREFER_NINJA
  OPTIONS -DPAHO_WITH_SSL=TRUE -DPAHO_BUILD_STATIC=${PAHO_BUILD_STATIC}
)


vcpkg_build_cmake()

file(GLOB DLLS
  "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/src/*.dll"
  "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/Release/*.dll"
  "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/*/Release/*.dll"
)
file(GLOB LIBS
  "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/src/*.lib"
  "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/Release/*.lib"
  "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/*/Release/*.lib"
)
file(GLOB DEBUG_DLLS
  "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg/src/*.dll"
  "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg/Debug/*.dll"
  "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg/*/Debug/*.dll"
)
file(GLOB DEBUG_LIBS
  "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg/src/*.lib"
  "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg/Debug/*.lib"
  "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg/*/Debug/*.lib"
)
file(GLOB HEADERS "${SOURCE_PATH}/*/*.h")
if(DLLS)
  file(INSTALL ${DLLS} DESTINATION ${CURRENT_PACKAGES_DIR}/bin)
endif()
file(INSTALL ${LIBS} DESTINATION ${CURRENT_PACKAGES_DIR}/lib)
if(DEBUG_DLLS)
  file(INSTALL ${DEBUG_DLLS} DESTINATION ${CURRENT_PACKAGES_DIR}/debug/bin)
endif()
file(INSTALL ${DEBUG_LIBS} DESTINATION ${CURRENT_PACKAGES_DIR}/debug/lib)
file(INSTALL ${HEADERS} DESTINATION ${CURRENT_PACKAGES_DIR}/include)

if(VCPKG_LIBRARY_LINKAGE STREQUAL static)
  file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/bin ${CURRENT_PACKAGES_DIR}/debug/bin)
  foreach(libname paho-mqtt3as-static paho-mqtt3cs-static paho-mqtt3a-static paho-mqtt3c-static)
    foreach(foldername "lib" "debug/lib")
      string(REPLACE "-static" "" outlibname ${libname})
      file(RENAME ${CURRENT_PACKAGES_DIR}/${foldername}/${libname}.lib  ${CURRENT_PACKAGES_DIR}/${foldername}/${outlibname}.lib)
    endforeach()
  endforeach()
endif()

foreach(libname paho-mqtt3a paho-mqtt3c)
  foreach(root "${CURRENT_PACKAGES_DIR}" "${CURRENT_PACKAGES_DIR}/debug")
    file(REMOVE
      ${root}/lib/${libname}.lib
      ${root}/bin/${libname}.dll
    )
  endforeach()
endforeach()

vcpkg_copy_pdbs()

file(INSTALL ${SOURCE_PATH}/about.html DESTINATION ${CURRENT_PACKAGES_DIR}/share/paho-mqtt RENAME copyright)
