#include <vcpkg/versiondeserializers.h>

using namespace vcpkg;

VersionTDeserializer VersionTDeserializer::instance;
BaselineDeserializer BaselineDeserializer::instance;

Json::StringDeserializer VersionTDeserializer::version_deserializer{"version"};
