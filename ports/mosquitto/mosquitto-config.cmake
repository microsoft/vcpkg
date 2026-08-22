message(AUTHOR_WARNING "find_package(${PACKAGE_NAME}) is deprecated.\n${usage}")

include(CMakeFindDependencyMacro)
find_dependency(unofficial-mosquitto CONFIG)

# legacy, ported from wrapper
find_path(MOSQUITTO_INCLUDE_DIR mosquitto.h)
set(MOSQUITTO_INCLUDE_DIRS ${MOSQUITTO_INCLUDE_DIR})

# legacy, both vars included the C++ target
set(MOSQUITTO_LIBRARIES unofficial::mosquitto::mosquittopp)
set(MOSQUITTOPP_LIBRARIES unofficial::mosquitto::mosquittopp)
