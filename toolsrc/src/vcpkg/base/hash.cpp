#include "pch.h"

#include <vcpkg/base/checks.h>
#include <vcpkg/base/strings.h>
#include <vcpkg/base/system.process.h>
#include <vcpkg/base/util.h>

#if defined(_WIN32)
#include <bcrypt.h>
#pragma comment(lib, "bcrypt")

#ifndef NT_SUCCESS
#define NT_SUCCESS(Status) (((NTSTATUS)(Status)) >= 0)
#endif
#endif

namespace vcpkg::Hash
{
    static void verify_has_only_allowed_chars(const std::string& s)
    {
        static const std::regex ALLOWED_CHARS{"^[a-zA-Z0-9-]*$"};
        Checks::check_exit(VCPKG_LINE_INFO,
                           std::regex_match(s, ALLOWED_CHARS),
                           "Only alphanumeric chars and dashes are currently allowed. String was:\n"
                           "    % s",
                           s);
    }
#if defined(_WIN32)
    namespace
    {
        std::string to_hex(const unsigned char* string, const size_t bytes)
        {
            static constexpr char HEX_MAP[] = "0123456789abcdef";

            std::string output;
            output.resize(2 * bytes);

            size_t current_char = 0;
            for (size_t i = 0; i < bytes; i++)
            {
                // high
                output[current_char] = HEX_MAP[(string[i] & 0xF0) >> 4];
                ++current_char;
                // low
                output[current_char] = HEX_MAP[(string[i] & 0x0F)];
                ++current_char;
            }

            return output;
        }

        class BCryptHasher
        {
            struct BCryptAlgorithmHandle : Util::ResourceBase
            {
                BCRYPT_ALG_HANDLE handle = nullptr;

                ~BCryptAlgorithmHandle()
                {
                    if (handle) BCryptCloseAlgorithmProvider(handle, 0);
                }
            };

            struct BCryptHashHandle : Util::ResourceBase
            {
                BCRYPT_HASH_HANDLE handle = nullptr;

                ~BCryptHashHandle()
                {
                    if (handle) BCryptDestroyHash(handle);
                }
            };

            static void initialize_hash_handle(BCryptHashHandle& hash_handle,
                                               const BCryptAlgorithmHandle& algorithm_handle)
            {
                const NTSTATUS error_code =
                    BCryptCreateHash(algorithm_handle.handle, &hash_handle.handle, nullptr, 0, nullptr, 0, 0);
                Checks::check_exit(VCPKG_LINE_INFO, NT_SUCCESS(error_code), "Failed to initialize the hasher");
            }

            static void hash_data(BCryptHashHandle& hash_handle, const unsigned char* buffer, const size_t& data_size)
            {
                const NTSTATUS error_code = BCryptHashData(
                    hash_handle.handle, const_cast<unsigned char*>(buffer), static_cast<ULONG>(data_size), 0);
                Checks::check_exit(VCPKG_LINE_INFO, NT_SUCCESS(error_code), "Failed to hash data");
            }

            static std::string finalize_hash_handle(const BCryptHashHandle& hash_handle, const ULONG length_in_bytes)
            {
                std::unique_ptr<unsigned char[]> hash_buffer = std::make_unique<UCHAR[]>(length_in_bytes);
                const NTSTATUS error_code = BCryptFinishHash(hash_handle.handle, hash_buffer.get(), length_in_bytes, 0);
                Checks::check_exit(VCPKG_LINE_INFO, NT_SUCCESS(error_code), "Failed to finalize the hash");
                return to_hex(hash_buffer.get(), length_in_bytes);
            }

        public:
            explicit BCryptHasher(std::string hash_type)
            {
                NTSTATUS error_code = BCryptOpenAlgorithmProvider(
                    &this->algorithm_handle.handle,
                    Strings::to_utf16(Strings::ascii_to_uppercase(std::move(hash_type))).c_str(),
                    nullptr,
                    0);
                Checks::check_exit(VCPKG_LINE_INFO, NT_SUCCESS(error_code), "Failed to open the algorithm provider");

                DWORD hash_buffer_bytes;
                DWORD cb_data;
                error_code = BCryptGetProperty(this->algorithm_handle.handle,
                                               BCRYPT_HASH_LENGTH,
                                               reinterpret_cast<PUCHAR>(&hash_buffer_bytes),
                                               sizeof(DWORD),
                                               &cb_data,
                                               0);
                Checks::check_exit(VCPKG_LINE_INFO, NT_SUCCESS(error_code), "Failed to get hash length");
                this->length_in_bytes = hash_buffer_bytes;
            }

            std::string hash_file(const fs::path& path) const
            {
                BCryptHashHandle hash_handle;
                initialize_hash_handle(hash_handle, this->algorithm_handle);

                FILE* file = nullptr;
                const auto ec = _wfopen_s(&file, path.c_str(), L"rb");
                Checks::check_exit(VCPKG_LINE_INFO, ec == 0, "Failed to open file: %s", path.u8string());
                if (file != nullptr)
                {
                    unsigned char buffer[4096];
                    while (const auto actual_size = fread(buffer, 1, sizeof(buffer), file))
                    {
                        hash_data(hash_handle, buffer, actual_size);
                    }
                    fclose(file);
                }

                return finalize_hash_handle(hash_handle, length_in_bytes);
            }

            std::string hash_string(const std::string& s) const
            {
                BCryptHashHandle hash_handle;
                initialize_hash_handle(hash_handle, this->algorithm_handle);
                hash_data(hash_handle, reinterpret_cast<const unsigned char*>(s.c_str()), s.size());
                return finalize_hash_handle(hash_handle, length_in_bytes);
            }

        private:
            BCryptAlgorithmHandle algorithm_handle;
            ULONG length_in_bytes;
        };
    }

    std::string get_file_hash(const Files::Filesystem& fs, const fs::path& path, const std::string& hash_type)
    {
        Checks::check_exit(VCPKG_LINE_INFO, fs.exists(path), "File %s does not exist", path.u8string());
        return BCryptHasher{hash_type}.hash_file(path);
    }

    std::string get_string_hash(const std::string& s, const std::string& hash_type)
    {
        verify_has_only_allowed_chars(s);
        return BCryptHasher{hash_type}.hash_string(s);
    }

#else
    static std::string get_digest_size(const std::string& hash_type)
    {
        if (!Strings::case_insensitive_ascii_starts_with(hash_type, "SHA"))
        {
            Checks::exit_with_message(
                VCPKG_LINE_INFO, "shasum only supports SHA hashes, but %s was provided", hash_type);
        }

        return hash_type.substr(3, hash_type.length() - 3);
    }

    static std::string parse_shasum_output(const std::string& shasum_output)
    {
        std::vector<std::string> split = Strings::split(shasum_output, " ");
        // Checking if >= 3 because filenames with spaces will show up as multiple tokens.
        // The hash is the first token so we don't need to parse the filename anyway.
        Checks::check_exit(VCPKG_LINE_INFO,
                           split.size() >= 3,
                           "Expected output of the form [hash filename\n] (3+ tokens), but got\n"
                           "[%s] (%s tokens)",
                           shasum_output,
                           std::to_string(split.size()));

        return split[0];
    }

    std::string get_file_hash(const Files::Filesystem& fs, const fs::path& path, const std::string& hash_type)
    {
        const std::string digest_size = get_digest_size(hash_type);
        Checks::check_exit(VCPKG_LINE_INFO, fs.exists(path), "File %s does not exist", path.u8string());

        // Try hash-specific tools, like sha512sum
        {
            const auto ec_data = System::cmd_execute_and_capture_output(
                Strings::format(R"(sha%ssum "%s")", digest_size, path.u8string()));
            if (ec_data.exit_code == 0)
            {
                return parse_shasum_output(ec_data.output);
            }
        }

        // Try shasum
        {
            const auto ec_data = System::cmd_execute_and_capture_output(
                Strings::format(R"(shasum -a %s "%s")", digest_size, path.u8string()));
            if (ec_data.exit_code == 0)
            {
                return parse_shasum_output(ec_data.output);
            }
        }

        Checks::exit_with_message(VCPKG_LINE_INFO, "Could not hash file %s with %s", path.u8string(), hash_type);
    }

    std::string get_string_hash(const std::string& s, const std::string& hash_type)
    {
        const std::string digest_size = get_digest_size(hash_type);
        verify_has_only_allowed_chars(s);

        // Try hash-specific tools, like sha512sum
        {
            const auto ec_data =
                System::cmd_execute_and_capture_output(Strings::format(R"(echo -n "%s" | sha%ssum)", s, digest_size));
            if (ec_data.exit_code == 0)
            {
                return parse_shasum_output(ec_data.output);
            }
        }

        // Try shasum
        {
            const auto ec_data = System::cmd_execute_and_capture_output(
                Strings::format(R"(echo -n "%s" | shasum -a %s)", s, digest_size));
            if (ec_data.exit_code == 0)
            {
                return parse_shasum_output(ec_data.output);
            }
        }

        Checks::exit_with_message(VCPKG_LINE_INFO, "Could not hash input string with %s", hash_type);
    }
#endif
}
