
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO zeroc-ice/ice
    REF v3.7.7
    SHA512 73c3a2bb14c9e145383e4026206edd3e03b29c60a33af628611bfdab71d69a3aed108ce4e6cbfd67eb852560110e3495b4bd238c8cdf0de9d1f8e2f1088513ee
)

set(RELEASE_TRIPLET ${TARGET_TRIPLET}-rel)
set(DEBUG_TRIPLET ${TARGET_TRIPLET}-dbg)

get_filename_component(SOURCE_PATH_SUFFIX "${SOURCE_PATH}" NAME)

if(NOT VCPKG_TARGET_IS_WINDOWS)

  # Setting these as environment variables, as .d files aren't generated the first time passing them to make.
  set(ENV{MCPP_HOME} ${CURRENT_INSTALLED_DIR})
  set(ENV{EXPAT_HOME} ${CURRENT_INSTALLED_DIR})
  set(ENV{BZ2_HOME} ${CURRENT_INSTALLED_DIR})
  set(ENV{LMDB_HOME} ${CURRENT_INSTALLED_DIR})
  set(ENV{CPPFLAGS} "-I${CURRENT_INSTALLED_DIR}/include")
  set(ENV{LDFLAGS} "-L${CURRENT_INSTALLED_DIR}/debug/lib")

  set(ICE_BUILD_CONFIG "shared cpp11-shared")
  if(${VCPKG_LIBRARY_LINKAGE} STREQUAL "static")
    set(ICE_BUILD_CONFIG "static cpp11-static")
  endif()

  message(STATUS "Building ${TARGET_TRIPLET}-dbg")
  vcpkg_execute_build_process(
    COMMAND make install V=1 prefix=${CURRENT_PACKAGES_DIR}/debug linux_id=vcpkg CONFIGS=${ICE_BUILD_CONFIG} USR_DIR_INSTALL=yes LANGUAGES=cpp OPTIMIZE=no -j${VCPKG_CONCURRENCY} srcs
    WORKING_DIRECTORY ${SOURCE_PATH}/cpp
    LOGNAME make-${TARGET_TRIPLET}-dbg
  )

  # Clean up for the next round
  vcpkg_execute_build_process(
    COMMAND make distclean 
    WORKING_DIRECTORY ${SOURCE_PATH}/cpp
    LOGNAME make-clean-${TARGET_TRIPLET}
  )

  # Release build
  set(ENV{LDFLAGS} "-L${CURRENT_INSTALLED_DIR}/lib")
  message(STATUS "Building ${TARGET_TRIPLET}-rel")
  vcpkg_execute_build_process(
    COMMAND make install V=1 prefix=${CURRENT_PACKAGES_DIR} linux_id=vcpkg CONFIGS=${ICE_BUILD_CONFIG} LANGUAGES=cpp USR_DIR_INSTALL=yes OPTIMIZE=yes -j${VCPKG_CONCURRENCY} srcs
    WORKING_DIRECTORY ${SOURCE_PATH}/cpp
    LOGNAME make-${TARGET_TRIPLET}-rel
  )

  if(EXISTS "${CURRENT_PACKAGES_DIR}/debug/lib64")
    file(RENAME ${CURRENT_PACKAGES_DIR}/debug/lib64 ${CURRENT_PACKAGES_DIR}/debug/lib)
    file(RENAME ${CURRENT_PACKAGES_DIR}/lib64 ${CURRENT_PACKAGES_DIR}/lib)
  endif()

  file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
  file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

else(NOT VCPKG_TARGET_IS_WINDOWS)

  # Fix project files to prevent nuget restore of dependencies and 
  # remove hard coded runtime linkage
  vcpkg_execute_required_process(
    COMMAND powershell ${CURRENT_PORT_DIR}/fixProjFiles.ps1 "${SOURCE_PATH}"
    LOGNAME fixProjFiles-${TARGET_TRIPLET}
    WORKING_DIRECTORY ${CURRENT_BUILDTREES_DIR}
  )
  

  set(ICE_OPTIONAL_COMPONENTS "")
  
  # IceSSL
  if("icessl" IN_LIST FEATURES)
    vcpkg_list(APPEND ICE_OPTIONAL_COMPONENTS "/t:C++11\\icessl++11")
  endif()

  # Glacier2
  if("glacier2" IN_LIST FEATURES)
    vcpkg_list(APPEND ICE_OPTIONAL_COMPONENTS "/t:C++11\\glacier2++11")
  endif()
  
  # Glacier2Router
  if("glacier2router" IN_LIST FEATURES)
    vcpkg_list(APPEND ICE_OPTIONAL_COMPONENTS "/t:C++98\\glacier2router")
    vcpkg_list(APPEND ICE_OPTIONAL_COMPONENTS "/t:C++98\\glacier2cryptpermissionsverifier")
  endif()

  # IceBox
  if("icebox" IN_LIST FEATURES)
    vcpkg_list(APPEND ICE_OPTIONAL_COMPONENTS "/t:C++11\\iceboxlib++11")
    vcpkg_list(APPEND ICE_OPTIONAL_COMPONENTS "/t:C++11\\icebox++11")
  endif()

  # IceBoxAdmin executable
  if("iceboxadmin" IN_LIST FEATURES)
    vcpkg_list(APPEND ICE_OPTIONAL_COMPONENTS "/t:C++98\\iceboxadmin")
  endif()

  # IceGrid
  if("icegrid" IN_LIST FEATURES)
    vcpkg_list(APPEND ICE_OPTIONAL_COMPONENTS "/t:C++11\\icegrid++11")
  endif()
  
  # IceGridAdmin 
  if("icegridadmin" IN_LIST FEATURES)
    vcpkg_list(APPEND ICE_OPTIONAL_COMPONENTS "/t:C++98\\icegridadmin")
  endif()
  
  # IceGridRegistry 
  if("icegridregistry" IN_LIST FEATURES)
    vcpkg_list(APPEND ICE_OPTIONAL_COMPONENTS "/t:C++98\\icegridregistry")
  endif()
  
  # IceGridNode 
  if("icegridnode" IN_LIST FEATURES)
    vcpkg_list(APPEND ICE_OPTIONAL_COMPONENTS "/t:C++98\\icegridnode")
  endif()

  # IceStorm
  if("icestorm" IN_LIST FEATURES)
    vcpkg_list(APPEND ICE_OPTIONAL_COMPONENTS "/t:C++11\\icestorm++11")
  endif()
  
  # IceStormAdmin 
  if("icestormadmin" IN_LIST FEATURES)
    vcpkg_list(APPEND ICE_OPTIONAL_COMPONENTS "/t:C++98\\icestormadmin")
  endif()
  
  # IceStormService 
  if("icestormservice" IN_LIST FEATURES)
    vcpkg_list(APPEND ICE_OPTIONAL_COMPONENTS "/t:C++98\\icestormservice")
  endif()
  
  # IceStormDB 
  if("icestormdb" IN_LIST FEATURES)
    vcpkg_list(APPEND ICE_OPTIONAL_COMPONENTS "/t:C++98\\icestormdb")
  endif()

  # IceBridge executable 
  if("icebridge" IN_LIST FEATURES)
    vcpkg_list(APPEND ICE_OPTIONAL_COMPONENTS "/t:C++98\\icebridge")
  endif()

  # IceDiscovery
  if("icediscovery" IN_LIST FEATURES)
    vcpkg_list(APPEND ICE_OPTIONAL_COMPONENTS "/t:C++11\\icediscovery++11")
  endif()

set(MSVC_TOOLSET_VER ${VCPKG_PLATFORM_TOOLSET})
if(${VCPKG_PLATFORM_TOOLSET} STREQUAL "v144" OR ${VCPKG_PLATFORM_TOOLSET} STREQUAL "v145")
  set(MSVC_TOOLSET_VER "v143")
endif()

  # Build Ice
  vcpkg_install_msbuild(
    SOURCE_PATH ${SOURCE_PATH}
    PROJECT_SUBPATH "cpp/msbuild/ice.${VCPKG_PLATFORM_TOOLSET}.sln"
    SKIP_CLEAN
	TARGET "C++11\\ice++11"
    USE_VCPKG_INTEGRATION
    OPTIONS
      /p:UseVcpkg=yes
      /p:IceBuildingSrc=yes
	    ${ICE_OPTIONAL_COMPONENTS}
  )

  if(EXISTS "${CURRENT_PACKAGES_DIR}/bin/zeroc.icebuilder.msbuild.dll")
    file(REMOVE "${CURRENT_PACKAGES_DIR}/bin/zeroc.icebuilder.msbuild.dll")
  endif()
  if(EXISTS "${CURRENT_PACKAGES_DIR}/debug/bin/zeroc.icebuilder.msbuild.dll")
    file(REMOVE "${CURRENT_PACKAGES_DIR}/debug/bin/zeroc.icebuilder.msbuild.dll")
  endif()
  
  # install_includes 
  function(install_includes ORIGINAL_PATH RELATIVE_PATHS)
    foreach(RELATIVE_PATH ${RELATIVE_PATHS})
      file(
        GLOB
        HEADER_FILES
        ${ORIGINAL_PATH}/${RELATIVE_PATH}/*.h)
      file(COPY ${HEADER_FILES}
           DESTINATION ${CURRENT_PACKAGES_DIR}/include/${RELATIVE_PATH})
    endforeach()
  endfunction()
   
  # Install header files
  set(INCLUDE_SUB_DIRECTORIES
    "Glacier2"
    "Ice"
    "IceBox"
    "IceGrid"
    "IcePatch2"
    "IceSSL"
    "IceStorm"
    "IceUtil"
  )
    
  install_includes("${RELEASE_BUILD_DIR}/cpp/include" "${INCLUDE_SUB_DIRECTORIES}")
  
  set(INCLUDE_GEN_SUB_DIRECTORIES
    "Glacier2"
    "Ice"
    "IceBox"
    "IceSSL"
    "IceStorm"
  )
  install_includes("${RELEASE_BUILD_DIR}/cpp/include/generated/cpp11/${TRIPLET_SYSTEM_ARCH}/Release" "${INCLUDE_GEN_SUB_DIRECTORIES}")
  
  vcpkg_clean_msbuild()
  
endif(NOT VCPKG_TARGET_IS_WINDOWS)

file(MAKE_DIRECTORY ${CURRENT_PACKAGES_DIR}/tools)

if(NOT VCPKG_TARGET_IS_WINDOWS)
  file(RENAME ${CURRENT_PACKAGES_DIR}/bin ${CURRENT_PACKAGES_DIR}/tools/${PORT})
endif()

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
  file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/bin" "${CURRENT_PACKAGES_DIR}/debug/bin")
endif()

if(VCPKG_TARGET_IS_OSX)
  file(REMOVE "${CURRENT_PACKAGES_DIR}/.DS_Store")
endif()

# Handle copyright
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/zeroc-ice RENAME copyright)
