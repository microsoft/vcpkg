# Kendez.NikSms C++ SDK - vcpkg Port

This directory contains the vcpkg port files for the Kendez.NikSms C++ SDK.

## Files

- `vcpkg.json` - Package manifest with dependencies and metadata
- `portfile.cmake` - Build instructions for vcpkg
- `README.md` - This file

## Package Information

- **Name**: kendez-niksms-sdk
- **Version**: 1.2.0
- **Description**: C++ SDK for Kendez.NikSms SMS Web Service (REST & gRPC)
- **Homepage**: https://webservice.niksms.com
- **License**: MIT
- **Dependencies**: curl, grpc, protobuf, nlohmann-json

## Usage

After the package is accepted into vcpkg, you can install it with:

```bash
vcpkg install kendez-niksms-sdk
```

And use it in your CMake project:

```cmake
find_package(KendezNiksmsSDK CONFIG REQUIRED)
target_link_libraries(your_target KendezNiksmsSDK)
```

## Testing

The package has been tested with:
- Windows (x64)
- CMake 3.20+
- C++17 compatible compilers

## Repository

- **GitHub**: https://github.com/drkeivanmirzaei/Kendez.Niksms.SDK.CPlus
- **Documentation**: https://webservice.niksms.com

## License

MIT License - see LICENSE file in the main repository.
