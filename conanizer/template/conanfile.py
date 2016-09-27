import os
from conans import ConanFile, CMake, tools
from os import listdir
from os.path import isfile, join
from conans.tools import vcvars_command


class WrapperVspkgConan(ConanFile):
    '''
    - Runs with Visual 10, 12 and 14o, not only 14.
    - Full integrated with any other conan package
    - Generated libs declared, easy liked with CONAN_LIBS
    - Keeps different package for different compiler verions, archs and build_types
    - Binary storage in conan servers
    '''
    name = "**NAME**"
    version = "**VERSION**"
    license = "MIT"
    url = "https://github.com/lasote/vcpkg"
    settings = "os", "arch", "compiler", "build_type"
    generators = "cmake"
    exports = "CMakeLists.txt", "vcpkg/*"
    short_paths = True

    def build(self):
        prepare_env_cmd = vcvars_command(self.settings)
        cmake = CMake(self.settings)
        if self.settings.compiler != "Visual Studio":
            # TODO: Restrict settings
            raise ConanException("Not valid compiler")
        
        generator = {"14": "Visual Studio 14 2015",
                     "12": "Visual Studio 12 2013",
                     "10": "Visual Studio 10 2010"}[str(self.settings.compiler.version)]

        if self.settings.compiler.version != "14":
            tools.replace_in_file("vcpkg/scripts/cmake/vcpkg_configure_cmake.cmake", "Visual Studio 14 2015", generator)
            
        self._build_only_selected_build_type_patch()
            
        # Patch recipes for support any visual studio
        if self.settings.compiler.version != "14":
            # Boost toolset
            if self.name == "boost":
                tools.replace_in_file("vcpkg/ports/boost/portfile.cmake", "--toolset=msvc", "--toolset=msvc-%s.0" % self.settings.compiler.version)
        
                                  
        self.run('%s && cmake %s -DPORT=%s -DTARGET_TRIPLET=%s -DCMD=BUILD' % (prepare_env_cmd,
                                                                               cmake.command_line,
                                                                               self.name,
                                                                               self._get_triplet()))
        self.run("%s && cmake --build . %s" % (prepare_env_cmd, cmake.build_config))
    
    
    def _build_only_selected_build_type_patch(self):
        rm_prefix = "dbg" if self.settings.build_type == "Release" else "rel"
        # Patch vcpkg_build_cmake
        to_replace = 'message(STATUS "Build ${TARGET_TRIPLET}-%s")' % rm_prefix
        with_to_replace = 'IF(FALSE)\n%s' % to_replace
        tools.replace_in_file("vcpkg/scripts/cmake/vcpkg_build_cmake.cmake", to_replace, with_to_replace)
        to_replace = 'message(STATUS "Build ${TARGET_TRIPLET}-%s done")' % rm_prefix
        with_to_replace = '%s\nENDIF()' % to_replace
        tools.replace_in_file("vcpkg/scripts/cmake/vcpkg_build_cmake.cmake", to_replace, with_to_replace)
        
        # Patch vcpkg_configure_cmake
        to_replace = ' message(STATUS "Configuring ${TARGET_TRIPLET}-%s")' % rm_prefix
        with_to_replace = 'IF(FALSE)\n%s' % to_replace
        tools.replace_in_file("vcpkg/scripts/cmake/vcpkg_configure_cmake.cmake", to_replace, with_to_replace)
        to_replace = 'message(STATUS "Configuring ${TARGET_TRIPLET}-%s done")' % rm_prefix
        with_to_replace = '%s\nENDIF()' % to_replace
        tools.replace_in_file("vcpkg/scripts/cmake/vcpkg_configure_cmake.cmake", to_replace, with_to_replace)
       
        # Patch vcpkg_build_msbuild
        if self.settings.build_type == "Debug":
            to_remove = '''message(STATUS "Building ${_csc_PROJECT_PATH} for Release")
    file(MAKE_DIRECTORY ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel)
    vcpkg_execute_required_process(
        COMMAND msbuild ${_csc_PROJECT_PATH} ${_csc_OPTIONS} ${_csc_OPTIONS_RELEASE}
            /p:Configuration=${_csc_RELEASE_CONFIGURATION}
            /p:Platform=${TRIPLET_SYSTEM_ARCH}
            /p:VCPkgLocalAppDataDisabled=true
        WORKING_DIRECTORY ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel
        LOGNAME build-${TARGET_TRIPLET}-rel
    )'''   
        else:
            to_remove = '''message(STATUS "Building ${_csc_PROJECT_PATH} for Debug")
    file(MAKE_DIRECTORY ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg)
    vcpkg_execute_required_process(
        COMMAND msbuild ${_csc_PROJECT_PATH} ${_csc_OPTIONS} ${_csc_OPTIONS_DEBUG}
            /p:Configuration=${_csc_DEBUG_CONFIGURATION}
            /p:Platform=${TRIPLET_SYSTEM_ARCH}
            /p:VCPkgLocalAppDataDisabled=true
        WORKING_DIRECTORY ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg
        LOGNAME build-${TARGET_TRIPLET}-dbg
    )'''
        tools.replace_in_file("vcpkg/scripts/cmake/vcpkg_build_msbuild.cmake", to_remove, "")
        
        # Patch vcpkg_install_cmake
        to_replace = 'message(STATUS "Package ${TARGET_TRIPLET}-%s")' % rm_prefix
        with_to_replace = 'IF(FALSE)\n%s' % to_replace
        tools.replace_in_file("vcpkg/scripts/cmake/vcpkg_install_cmake.cmake", to_replace, with_to_replace)
        to_replace = 'message(STATUS "Package ${TARGET_TRIPLET}-%s done")' % rm_prefix
        with_to_replace = '%s\nENDIF()' % to_replace
        tools.replace_in_file("vcpkg/scripts/cmake/vcpkg_install_cmake.cmake", to_replace, with_to_replace)
       
       # Patch port, do not remove debug includes
        to_remove = 'file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)'
        tools.replace_in_file("vcpkg/ports/%s/portfile.cmake" % self.name, to_remove, "")
            
    def _get_triplet(self):
        tmp = {"x86_64": "x64-windows",
               "x86": "x86-windows"}
        return tmp[str(self.settings.arch)]

    def package(self):
        package_folder = "vcpkg/packages/%s_%s" %  (self.name, self._get_triplet())
        
        self.copy("*", src=package_folder+"/include", dst="include", keep_path=True)
        
        if self.settings.build_type == "Debug":
            package_folder +="/debug"
            
        # Artifacts from debug o root depending on build_type
        self.copy("*", src=package_folder+"/include", dst="include", keep_path=True)
        self.copy("*", src=package_folder+"/lib", dst="lib", keep_path=True)
        self.copy("*", src=package_folder+"/bin", dst="bin", keep_path=True)        
        self.copy("*", src=package_folder+"/share", dst="share", keep_path=True)

    def package_info(self):
        libpath = os.path.join(self.package_folder, "lib")
        if os.path.exists(libpath):
            onlyfiles = [f for f in listdir(libpath) if isfile(join(libpath, f))]
            self.cpp_info.libs = [libname.split(".")[0] for libname in onlyfiles]
    