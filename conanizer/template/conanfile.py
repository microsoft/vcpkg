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
        
        generator = {"15": "Visual Studio 15 2017",
                     "14": "Visual Studio 14 2015",
                     "12": "Visual Studio 12 2013",
                     "10": "Visual Studio 10 2010"}[str(self.settings.compiler.version)]

        if self.settings.compiler.version != "14":
            tools.replace_in_file("vcpkg/scripts/cmake/vcpkg_configure_cmake.cmake", "Visual Studio 14 2015", generator)
            
        # self._build_only_selected_build_type_patch()
            
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
        self.copy("*", src=package_folder+"/tools", dst="tools", keep_path=True)

    def package_info(self):
        libpath = os.path.join(self.package_folder, "lib")
        if os.path.exists(libpath):
            onlyfiles = [f for f in listdir(libpath) if isfile(join(libpath, f))]
            self.cpp_info.libs = [libname.split(".")[0] for libname in onlyfiles]
    
