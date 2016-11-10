#include "coff_file_reader.h"
#include <iostream>
#include <cstdint>
#include <algorithm>
#include "vcpkg_Checks.h"
#include <set>
#include <fstream>

using namespace std;

namespace vcpkg {namespace COFFFileReader
{
    template <class T>
    static T reinterpret_bytes(const char* data)
    {
        return (*reinterpret_cast<const T *>(&data[0]));
    }

    template <class T>
    static T read_value_from_stream(fstream& fs)
    {
        T data;
        fs.read(reinterpret_cast<char*>(&data), sizeof data);
        return data;
    }

    template <class T>
    static T peek_value_from_stream(fstream& fs)
    {
        fpos_t original_pos = fs.tellg().seekpos();
        T data;
        fs.read(reinterpret_cast<char*>(&data), sizeof data);
        fs.seekg(original_pos);
        return data;
    }

    static void verify_equal_strings(const char* expected, const char* actual, int size, const char* label)
    {
        Checks::check_exit(memcmp(expected, actual, size) == 0, "Incorrect string (%s) found. Expected: %s but found %s", label, expected, actual);
    }

    static void read_and_verify_PE_signature(fstream& fs)
    {
        static const size_t OFFSET_TO_PE_SIGNATURE_OFFSET = 0x3c;

        static const char* PE_SIGNATURE = "PE\0\0";
        static const size_t PE_SIGNATURE_SIZE = 4;

        fs.seekg(OFFSET_TO_PE_SIGNATURE_OFFSET, ios_base::beg);
        const int32_t offset_to_PE_signature = read_value_from_stream<int32_t>(fs);

        fs.seekg(offset_to_PE_signature);
        char signature[PE_SIGNATURE_SIZE];
        fs.read(signature, PE_SIGNATURE_SIZE);
        verify_equal_strings(PE_SIGNATURE, signature, PE_SIGNATURE_SIZE, "PE_SIGNATURE");
        fs.seekg(offset_to_PE_signature + PE_SIGNATURE_SIZE, ios_base::beg);
    }

    static fpos_t align_to(const fpos_t unaligned_offset, const int alignment_size)
    {
        fpos_t aligned_offset = unaligned_offset - 1;
        aligned_offset /= alignment_size;
        aligned_offset += 1;
        aligned_offset *= alignment_size;
        return aligned_offset;
    }

    struct coff_file_header
    {
        static const size_t HEADER_SIZE = 20;

        static coff_file_header read(fstream& fs)
        {
            coff_file_header ret;
            ret.data.resize(HEADER_SIZE);
            fs.read(&ret.data[0], HEADER_SIZE);
            return ret;
        }

        static coff_file_header peek(fstream& fs)
        {
            auto original_pos = fs.tellg().seekpos();
            coff_file_header ret = read(fs);
            fs.seekg(original_pos);
            return ret;
        }

        MachineType machineType() const
        {
            static const size_t MACHINE_TYPE_OFFSET = 0;
            static const size_t MACHINE_TYPE_SIZE = 2;

            std::string machine_field_as_string = data.substr(MACHINE_TYPE_OFFSET, MACHINE_TYPE_SIZE);
            const uint16_t machine = reinterpret_bytes<uint16_t>(machine_field_as_string.c_str());
            return getMachineType(machine);
        }

    private:
        std::string data;
    };

    struct archive_member_header
    {
        static const size_t HEADER_SIZE = 60;

        static archive_member_header read(fstream& fs)
        {
            static const size_t HEADER_END_OFFSET = 58;
            static const char* HEADER_END = "`\n";
            static const size_t HEADER_END_SIZE = 2;

            archive_member_header ret;
            ret.data.resize(HEADER_SIZE);
            fs.read(&ret.data[0], HEADER_SIZE);

            const std::string header_end = ret.data.substr(HEADER_END_OFFSET, HEADER_END_SIZE);
            verify_equal_strings(HEADER_END, header_end.c_str(), HEADER_END_SIZE, "LIB HEADER_END");

            return ret;
        }

        std::string name() const
        {
            static const size_t HEADER_NAME_OFFSET = 0;
            static const size_t HEADER_NAME_SIZE = 16;
            return data.substr(HEADER_NAME_OFFSET, HEADER_NAME_SIZE);
        }

        uint64_t member_size() const
        {
            static const size_t HEADER_SIZE_OFFSET = 48;
            static const size_t HEADER_SIZE_FIELD_SIZE = 10;
            const std::string as_string = data.substr(HEADER_SIZE_OFFSET, HEADER_SIZE_FIELD_SIZE);
            // This is in ASCII decimal representation
            const uint64_t value = std::strtoull(as_string.c_str(), nullptr, 10);
            return value;
        }

        std::string data;
    };

    struct import_header
    {
        static const size_t HEADER_SIZE = 20;

        static import_header read(fstream& fs)
        {
            static const size_t SIG1_OFFSET = 0;
            static const uint16_t SIG1 = static_cast<uint16_t>(MachineType::UNKNOWN);
            static const size_t SIG1_SIZE = 2;

            static const size_t SIG2_OFFSET = 2;
            static const uint16_t SIG2 = 0xFFFF;
            static const size_t SIG2_SIZE = 2;

            import_header ret;
            ret.data.resize(HEADER_SIZE);
            fs.read(&ret.data[0], HEADER_SIZE);

            const std::string sig1_as_string = ret.data.substr(SIG1_OFFSET, SIG1_SIZE);
            const uint16_t sig1 = reinterpret_bytes<uint16_t>(sig1_as_string.c_str());
            Checks::check_exit(sig1 == SIG1, "Sig1 was incorrect. Expected %s but got %s", SIG1, sig1);

            const std::string sig2_as_string = ret.data.substr(SIG2_OFFSET, SIG2_SIZE);
            const uint16_t sig2 = reinterpret_bytes<uint16_t>(sig2_as_string.c_str());
            Checks::check_exit(sig2 == SIG2, "Sig2 was incorrect. Expected %s but got %s", SIG2, sig2);

            return ret;
        }

        static import_header peek(fstream& fs)
        {
            auto original_pos = fs.tellg().seekpos();
            import_header ret = read(fs);
            fs.seekg(original_pos);
            return ret;
        }

        MachineType machineType() const
        {
            static const size_t MACHINE_TYPE_OFFSET = 6;
            static const size_t MACHINE_TYPE_SIZE = 2;

            std::string machine_field_as_string = data.substr(MACHINE_TYPE_OFFSET, MACHINE_TYPE_SIZE);
            const uint16_t machine = reinterpret_bytes<uint16_t>(machine_field_as_string.c_str());
            return getMachineType(machine);
        }

    private:
        std::string data;
    };

    static void skip_archive_member(fstream& fs, uint64_t member_size)
    {
        static const size_t ALIGNMENT_SIZE = 2;

        const fpos_t new_offset = align_to(member_size, ALIGNMENT_SIZE);
        fs.seekg(new_offset, ios_base::cur);
    }

    static void read_and_verify_archive_file_signature(fstream& fs)
    {
        static const char* FILE_START = "!<arch>\n";
        static const size_t FILE_START_SIZE = 8;

        fs.seekg(fs.beg);

        char file_start[FILE_START_SIZE];
        fs.read(file_start, FILE_START_SIZE);
        verify_equal_strings(FILE_START, file_start, FILE_START_SIZE, "LIB FILE_START");
    }

    dll_info read_dll(const fs::path path)
    {
        std::fstream fs(path, std::ios::in | std::ios::binary | std::ios::ate);
        Checks::check_exit(fs.is_open(), "Could not open file %s for reading", path.generic_string());

        read_and_verify_PE_signature(fs);
        coff_file_header header = coff_file_header::read(fs);
        MachineType machine = header.machineType();
        return {machine};
    }

    lib_info read_lib(const fs::path path)
    {
        std::fstream fs(path, std::ios::in | std::ios::binary | std::ios::ate);
        Checks::check_exit(fs.is_open(), "Could not open file %s for reading", path.generic_string());

        read_and_verify_archive_file_signature(fs);

        // First Linker Member
        const archive_member_header first_linker_member_header = archive_member_header::read(fs);
        Checks::check_exit(first_linker_member_header.name().substr(0, 2) == "/ ", "Could not find proper first linker member");
        skip_archive_member(fs, first_linker_member_header.member_size());

        const archive_member_header second_linker_member_header = archive_member_header::read(fs);
        Checks::check_exit(second_linker_member_header.name().substr(0, 2) == "/ ", "Could not find proper second linker member");
        // The first 4 bytes contains the number of archive members
        const uint32_t archive_member_count = peek_value_from_stream<uint32_t>(fs);
        skip_archive_member(fs, second_linker_member_header.member_size());

        bool hasLongnameMemberHeader = peek_value_from_stream<uint16_t>(fs) == 0x2F2F;
        if (hasLongnameMemberHeader)
        {
            const archive_member_header longnames_member_header = archive_member_header::read(fs);
            skip_archive_member(fs, longnames_member_header.member_size());
        }

        std::set<MachineType> machine_types;
        // Next we have the obj and pseudo-object files
        for (uint32_t i = 0; i < archive_member_count; i++)
        {
            const archive_member_header header = archive_member_header::read(fs);
            const uint16_t first_two_bytes = peek_value_from_stream<uint16_t>(fs);
            const bool isImportHeader = getMachineType(first_two_bytes) == MachineType::UNKNOWN;
            const MachineType machine = isImportHeader ? import_header::peek(fs).machineType() : coff_file_header::peek(fs).machineType();
            machine_types.insert(machine);
            skip_archive_member(fs, header.member_size());
        }

        return {std::vector<MachineType>(machine_types.cbegin(), machine_types.cend())};
    }
}}
