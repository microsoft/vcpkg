set(VCPKG_LIBRARY_LINKAGE dynamic)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO sccn/liblsl
    REF v1.14.0 # NOTE: when updating version, also change it in the parameter to vcpkg_configure_cmake
    SHA512 b4ec379339d174c457c8c1ec69f9e51ea78a738e72ecc96b9193f07b5273acb296b5b1f90c9dfe16591ecab0eef9aae9add640c1936d3769cae0bd96617205ec
    HEAD_REF master
)

vcpkg_configure_cmake(
	SOURCE_PATH ${SOURCE_PATH}
	PREFER_NINJA
	OPTIONS
		-DLSL_BUILD_STATIC=OFF # static builds are currently not supported since liblsl always also builds shared binaries 
		                       # which need to be deleted for vcpkg but then the CMake target can no longer be imported because it still references them
		-Dlslgitrevision=v1.14.0
		-Dlslgitbranch=master
)

vcpkg_install_cmake()
vcpkg_copy_pdbs()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)
file(REMOVE ${CURRENT_PACKAGES_DIR}/debug/bin/lslver)
file(REMOVE ${CURRENT_PACKAGES_DIR}/debug/bin/lslver.exe)

# move lslver executable to the tools folder
file(MAKE_DIRECTORY ${CURRENT_PACKAGES_DIR}/tools/liblsl)
if(EXISTS ${CURRENT_PACKAGES_DIR}/bin/lslver)
    file(RENAME ${CURRENT_PACKAGES_DIR}/bin/lslver ${CURRENT_PACKAGES_DIR}/tools/liblsl/lslver)
endif()
if(EXISTS ${CURRENT_PACKAGES_DIR}/bin/lslver.exe)
    file(RENAME ${CURRENT_PACKAGES_DIR}/bin/lslver.exe ${CURRENT_PACKAGES_DIR}/tools/liblsl/lslver.exe)
endif()

function(remove_if_empty path)
    file(GLOB_RECURSE FILE_PATHS LIST_DIRECTORIES false "${path}/*")
    list(LENGTH FILE_PATHS FILE_COUNT)
    if(FILE_COUNT EQUAL 0)
        file(REMOVE_RECURSE ${path})
    endif()
endfunction()

# delete bin and debug/bin directories if empty
remove_if_empty(${CURRENT_PACKAGES_DIR}/bin)
remove_if_empty(${CURRENT_PACKAGES_DIR}/debug/bin)

file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/liblsl RENAME copyright)
file(INSTALL ${SOURCE_PATH}/README.md DESTINATION ${CURRENT_PACKAGES_DIR}/share/liblsl)
