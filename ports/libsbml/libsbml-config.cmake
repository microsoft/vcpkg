include(CMakeFindDependencyMacro)
find_dependency(libsbml-static CONFIG REQUIRED)
add_library(libsbml ALIAS libsbml-static)
