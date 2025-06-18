# Customizing WolfSSL Builds with vcpkg

This guide explains how to customize WolfSSL builds using vcpkg with the enhanced portfile that supports custom CMake variables.

## Overview

The WolfSSL vcpkg port now supports several ways to customize the build configuration:

1. **Custom Protocol Settings**: Override ASIO, DTLS, and QUIC configurations
2. **Custom WolfSSL Options**: Override individual WolfSSL CMake options
3. **Direct CMake Flags**: Pass any additional CMake flags directly via --cmake-args

## Custom Protocol Settings

### ASIO Configuration
- **Variable**: `CUSTOM_ASIO_SETTING`
- **Default**: `yes` if `asio` feature is enabled, otherwise `no`
- **Usage**: Set to any custom value you need

### DTLS Configuration  
- **Variable**: `CUSTOM_DTLS_SETTING`
- **Default**: `yes` if `dtls` feature is enabled, otherwise `no`
- **Usage**: Set to version numbers like `1.2`, `1.3`, or custom values

### QUIC Configuration
- **Variable**: `CUSTOM_QUIC_SETTING` 
- **Default**: `yes` if `quic` feature is enabled, otherwise `no`
- **Usage**: Set to `draft`, `rfc`, or custom values

## Custom WolfSSL Options

All standard WolfSSL CMake options can be overridden using `CUSTOM_WOLFSSL_*` variables:

| Variable | Default | Description |
|----------|---------|-------------|
| `CUSTOM_WOLFSSL_BUILD_OUT_OF_TREE` | `yes` | Build out of tree |
| `CUSTOM_WOLFSSL_EXAMPLES` | `no` | Build examples |
| `CUSTOM_WOLFSSL_CRYPT_TESTS` | `no` | Build crypt tests |
| `CUSTOM_WOLFSSL_OPENSSLEXTRA` | `yes` | OpenSSL extra compatibility |
| `CUSTOM_WOLFSSL_TPM` | `yes` | TPM support |
| `CUSTOM_WOLFSSL_TLSX` | `yes` | TLS extensions |
| `CUSTOM_WOLFSSL_OCSP` | `yes` | OCSP support |
| `CUSTOM_WOLFSSL_OCSPSTAPLING` | `yes` | OCSP stapling |
| `CUSTOM_WOLFSSL_OCSPSTAPLING_V2` | `yes` | OCSP stapling v2 |
| `CUSTOM_WOLFSSL_CRL` | `yes` | Certificate revocation list |
| `CUSTOM_WOLFSSL_DES3` | `yes` | DES3 support |
| `CUSTOM_WOLFSSL_ECH` | `yes` | Encrypted client hello |
| `CUSTOM_WOLFSSL_HPKE` | `yes` | Hybrid public key encryption |
| `CUSTOM_WOLFSSL_SNI` | `yes` | Server name indication |
| `CUSTOM_WOLFSSL_DTLS13` | Based on DTLS feature | DTLS 1.3 support |
| `CUSTOM_WOLFSSL_DTLS_CID` | Based on DTLS feature | DTLS connection ID |
| `CUSTOM_WOLFSSL_SESSION_TICKET` | Based on QUIC feature | Session ticket support |

## Direct CMake Flags

You can pass any additional CMake flags directly via `--cmake-args` without special handling. Any `-DWOLFSSL_*` or other CMake options will be passed through to the configure step.

**Examples of flags not covered by vcpkg port variables:**
- `-DWOLFSSL_CURL=yes` - Enable cURL support
- `-DWOLFSSL_DEBUG=yes` - Enable debug output

## Usage Examples

### Basic Feature Override

```bash
# Enable examples and crypt tests
vcpkg install wolfssl --cmake-args="-DCUSTOM_WOLFSSL_EXAMPLES=yes;-DCUSTOM_WOLFSSL_CRYPT_TESTS=yes;"
```

### Protocol Customization

```bash
# Override protocol settings (normally set by features)
vcpkg install wolfssl --cmake-args="-DCUSTOM_ASIO_SETTING=yes;-DCUSTOM_DTLS_SETTING=no;-DCUSTOM_QUIC_SETTING=yes;"
```

### Disable Specific Features

```bash
# Disable TPM and ECH support (actual options from portfile)
vcpkg install wolfssl --cmake-args="-DCUSTOM_WOLFSSL_TPM=no;-DCUSTOM_WOLFSSL_ECH=no;"
```

### Add Custom CMake Flags

```bash
# Add CMake flags not covered by vcpkg port
vcpkg install wolfssl --cmake-args="-DCUSTOM_WOLFSSL_EXAMPLES=yes;-DWOLFSSL_CURL=yes;-DWOLFSSL_DEBUG=yes;"
```

### Complex Configuration

```bash
# Combine custom variables with direct CMake flags
vcpkg install wolfssl[dtls] --cmake-args="-DCUSTOM_WOLFSSL_EXAMPLES=yes;-DCUSTOM_WOLFSSL_CRYPT_TESTS=yes;-DCUSTOM_WOLFSSL_OCSP=no;-DWOLFSSL_CURL=yes;"
```

### Development Build

```bash
# Enable development/debugging features (using actual options)
vcpkg install wolfssl --cmake-args="-DCUSTOM_WOLFSSL_EXAMPLES=yes;-DCUSTOM_WOLFSSL_CRYPT_TESTS=yes;-DWOLFSSL_DEBUG=yes;"
```

### Minimal Build

```bash
# Create a minimal build with specific features disabled (actual options)
vcpkg install wolfssl --cmake-args="-DCUSTOM_WOLFSSL_OCSP=no;-DCUSTOM_WOLFSSL_ECH=no;-DCUSTOM_WOLFSSL_HPKE=no;-DCUSTOM_WOLFSSL_DES3=no;"
```

## Integration with vcpkg.json using Triplet Overlays

To pass custom cmake arguments to wolfssl, use triplet overlays in your project:

**Step 1: Create your project directory structure**
```bash
mkdir your-project
cd your-project
```

**Step 2: Create a triplet overlay directory and file**
```bash
mkdir triplets
cat > triplets/x64-linux-wolfssl.cmake << 'EOF'
set(VCPKG_TARGET_ARCHITECTURE x64)
set(VCPKG_CRT_LINKAGE dynamic)
set(VCPKG_LIBRARY_LINKAGE static)

set(VCPKG_CMAKE_SYSTEM_NAME Linux)

# Wolfssl specific cmake arguments
set(VCPKG_CMAKE_CONFIGURE_OPTIONS 
    -DCUSTOM_WOLFSSL_EXAMPLES=yes
    -DCUSTOM_WOLFSSL_CRYPT_TESTS=yes
    -DWOLFSSL_CURL=yes
    -DWOLFSSL_DEBUG=yes
)
EOF
```

**Step 3: Create your project's vcpkg.json manifest:**
```json
{
  "name": "your-project",
  "version": "1.0.0", 
  "dependencies": [
    {
      "name": "wolfssl",
      "features": ["dtls"]
    }
  ],
  "vcpkg-configuration": {
    "overlay-triplets": ["./triplets"]
  }
}
```

**Step 4: Install using the custom triplet in manifest mode:**
```bash
# From your project directory (where vcpkg.json is located)
/path/to/vcpkg-root/vcpkg install --vcpkg-root /path/to/vcpkg-root --triplet x64-linux-wolfssl
```

