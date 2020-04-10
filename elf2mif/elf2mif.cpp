////////////////////////////////////////////////////////////////////////////////
///
/// @file       elf2mif/elf2mif.cpp
///
/// @project    elf2mif
///
/// @brief      Tool to generate a Memory Initilization File (MIF) for a given
///             memory region.
///
////////////////////////////////////////////////////////////////////////////////
///
////////////////////////////////////////////////////////////////////////////////
///
/// @copyright Copyright (C) 2015-2020 EM Microelectronic
/// @cond
///
/// All rights reserved.
///
/// Redistribution and use in source and binary forms, with or without
/// modification, are permitted provided that the following conditions are met:
/// 1. Redistributions of source code must retain the above copyright notice,
/// this list of conditions and the following disclaimer.
/// 2. Redistributions in binary form must reproduce the above copyright notice,
/// this list of conditions and the following disclaimer in the documentation
/// and/or other materials provided with the distribution.
///
////////////////////////////////////////////////////////////////////////////////
///
/// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
/// AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
/// IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
/// ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE
/// LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
/// CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
/// SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
/// INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
/// CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
/// ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
/// POSSIBILITY OF SUCH DAMAGE.
/// @endcond
////////////////////////////////////////////////////////////////////////////////

#define XSTR(s) STR(s)
#define STR(s) #s

#define ELF2MIF_VERSION \
    XSTR(ELF2MIF_MAJOR) \
    "." XSTR(ELF2MIF_MINOR) "." XSTR(ELF2MIF_REVISION)

#define __STDC_FORMAT_MACROS 1

#include <OptionParser.h>
#include <elfio/elfio2.hpp>

#include <cstdio>
#include <cstdlib>

// #define DEBUG_PRINT (1)

#if WIN32
#include <Windows.h>
#include <io.h>

#define PRIx64 "I64x"

#define err(code, ...)                \
    do                                \
    {                                 \
        fprintf(stderr, __VA_ARGS__); \
        fprintf(stderr, "\n");        \
        exit(code);                   \
    } while (0)

#define errx(code, ...)               \
    do                                \
    {                                 \
        fprintf(stderr, __VA_ARGS__); \
        fprintf(stderr, "\n");        \
        exit(code);                   \
    } while (0)

#define sscanf sscanf_s

FILE *my_fopen(const char *filename, const char *mode)
{
    FILE *pFile = NULL;

    if (0 != fopen_s(&pFile, filename, mode))
        return NULL;

    return pFile;
}
#else
#include <err.h>
#include <unistd.h>
#include <sys/queue.h>
#include <inttypes.h>

#define my_fopen(filename, mode) fopen(filename, mode)
#endif // WIN32

#include <fcntl.h>
#include <stdio.h>
#include <stdint.h>
#include <stdlib.h>
#include <string.h>

#define HEX_PREFIX ("0x")
#define FILL_BYTE (0x00)

using namespace ELFIO;

bool gOutputHex = false;

uint8_t *ExtractSegments(void *elf, uint32_t startAddress,
                         uint32_t endAddress, uint32_t size)
{
    // Pointer to the memory region to dump data into.
    elfio2 *pElf = (elfio2 *)elf;
    uint8_t *pMemory = 0;

    uint32_t segmentStartAddress;
    uint32_t segmentEndAddress;
    uint32_t segmentSize;

    //
    // Allocate and fill the memory region.
    //
    pMemory = new uint8_t[size];
    memset(pMemory, FILL_BYTE, size);

    //
    // Dump all segments (at least partially) within the memory region.
    //
    for (std::vector<segment *>::const_iterator it = pElf->segments.begin();
         it != pElf->segments.end(); ++it)
    {
        const segment *pSegment = *it;

        segmentStartAddress = (uint32_t)pSegment->get_physical_address();
        segmentSize = (uint32_t)pSegment->get_file_size();
        segmentEndAddress = segmentStartAddress + segmentSize;

        if (PT_LOAD == pSegment->get_type() &&
            ((segmentEndAddress > startAddress && segmentEndAddress <= endAddress) ||     // Ends within the region.
             (segmentStartAddress >= startAddress && segmentStartAddress < endAddress) || // Starts within the region.
             (segmentStartAddress <= startAddress && segmentEndAddress >= endAddress))    // Completely contains the region.
        )
        {
            bool truncating = false;
            //
            // At least 1 byte from this section is within the memory region.
            //
            uint32_t sourceOffset;
            uint32_t destOffset;
            if (segmentStartAddress >= startAddress)
            {
                destOffset = segmentStartAddress - startAddress;
                sourceOffset = 0;
            }
            else
            {
                destOffset = 0;
                sourceOffset = startAddress - segmentStartAddress;
                segmentSize -= sourceOffset;
            }

            if (segmentEndAddress > endAddress)
            {
                truncating = true;
                segmentSize -= (segmentEndAddress - endAddress);
            }

            // Check if the end address of the section is within the memory
            // region of if the region should be clipped.
#ifdef DEBUG_PRINT
            printf("Copying from 0x%08x to 0x%08x (0x%08x bytes)\n",
                   sourceOffset, destOffset, segmentSize);

            printf("Segment: 0x%08x-0x%08x %s(%u bytes)\n",
                   segmentStartAddress, segmentEndAddress, (truncating || sourceOffset) ? "(truncated) " : "", segmentSize);
#endif // DEBUG_PRINT

            // Read the section data.
            memcpy(&pMemory[destOffset], &pSegment->get_data()[sourceOffset], segmentSize);
        }
    }

    return pMemory;
}

uint8_t *ExtractSegments(const char *pInFile, const char *pStartSymbol,
                         const char *pEndSymbol, uint32_t *size)
{

    // Create the elfio reader.
    elfio2 elf;

    //
    // Open the input ELF file.
    //
    if (!elf.load(pInFile))
    {
        return 0;
    }

    symbol *start_symbol = elf.symbols[pStartSymbol];
    symbol *end_symbol = elf.symbols[pEndSymbol];

    if (!start_symbol)
    {
        fprintf(stderr, "Error: unable to locate symbol '%s'\n", pStartSymbol);
        exit(-1);
    }

    if (!end_symbol)
    {
        fprintf(stderr, "Error: unable to locate symbol '%s'\n", pEndSymbol);
        exit(-1);
    }

    if (!size)
    {
        return 0;
    }

    uint32_t start_addr = (uint32_t)start_symbol->get_value();
    uint32_t end_addr = (uint32_t)end_symbol->get_value() - 1;
    if (end_addr < start_addr)
    {
        fprintf(stderr, "Error: unable to dump from  0x%08x to 0x%08x\n", start_addr, end_addr);
        exit(-1);
    }

    *size = end_addr - start_addr + 1;
    return ExtractSegments((void *)&elf, start_addr, end_addr, *size);
}

uint8_t *ExtractSegments(const char *pInFile, uint32_t startAddress,
                         uint32_t endAddress, uint32_t size)
{
    // Create the elfio reader.
    elfio2 elf;

    //
    // Open the input ELF file.
    //
    if (!elf.load(pInFile))
    {
        return 0;
    }

    return ExtractSegments((void *)&elf, startAddress, endAddress, size);
}

/**
 * Function to sort a vector or list of segments by virtual address with the
 * std::sort function.
 * @param pSegmentA First segment to compare.
 * @param pSegmentB Second segment to compare.
 * @returns true if the first segment comes before the second segment.
 */
static bool SortSegmentsByVirtAddr(segment *pSegmentA, segment *pSegmentB)
{
    return pSegmentA->get_virtual_address() < pSegmentB->get_virtual_address();
}

uint8_t *ExtractAllSegments(const char *pInFile, uint32_t *pSize)
{
    bool foundStart = false;
    uint32_t startAddress = 0;
    uint32_t endAddress = 0;
    // Create the elfio reader.
    elfio2 elf;

    // Pointer to the memory region to dump data into.
    uint8_t *pMemory = 0;

    if (pSize)
    {
        *pSize = 0;
    }
    else
    {
        return 0;
    }

    //
    // Open the input ELF file.
    //
    if (!elf.load(pInFile))
    {
        return 0;
    }

    int segmentID = 1;

    // Copy the segments and sort the list.
    std::vector<segment *> segments(elf.segments.begin(), elf.segments.end());
    std::sort(segments.begin(), segments.end(), SortSegmentsByVirtAddr);

    //
    // Determine the actual size of the buffer needed.
    //
    for (std::vector<segment *>::const_iterator it = segments.begin();
         it != segments.end(); ++it, ++segmentID)
    {
        const segment *pSegment = *it;

        if (PT_LOAD == pSegment->get_type())
        {
            if (!foundStart)
            {
                foundStart = true;
                startAddress = (uint32_t)pSegment->get_virtual_address();
            }
            else
            {
                if ((uint32_t)pSegment->get_virtual_address() > endAddress)
                {
                    uint32_t bytes = (uint32_t)pSegment->get_virtual_address() - endAddress;
                    if (bytes < 8)
                    {
                        // Don't throw and error for expected alignment.
                    }
                    else if (bytes > 1024 * 1024)
                    {
                        printf("Error: inserting %u bytes of padding before segment %d\n", bytes, segmentID);
                        exit(-1);
                    }
                    else
                    {
                        /* Between 8 and 128 bytes of padding. */
                        printf("Warning: inserting %u bytes of padding before segment %d\n", bytes, segmentID);
                    }
                }
                else if ((uint32_t)pSegment->get_virtual_address() != endAddress)
                {
                    printf("Warning: inserting %u bytes in a possibly already allocated region for segment %d\n", (uint32_t)pSegment->get_memory_size(), segmentID);
                }
            }

            uint32_t currentEndAddress = (uint32_t)pSegment->get_virtual_address() + (uint32_t)pSegment->get_memory_size();
            if (currentEndAddress > endAddress)
            {
                endAddress = currentEndAddress;
            }
        }
    }

    *pSize = endAddress - startAddress;

    if (!*pSize)
    {
        return 0;
    }

#ifdef DEBUG_PRINT
    printf("Allocating %d bytes for the output.\n", *pSize);
#endif
    //
    // Allocate and fill the memory region.
    //
    pMemory = new uint8_t[*pSize];
    memset(pMemory, FILL_BYTE, *pSize);

    segmentID = 1;

    //
    // Dump all segments.
    //
    for (std::vector<segment *>::const_iterator it = elf.segments.begin();
         it != elf.segments.end(); ++it, ++segmentID)
    {
        uint32_t segmentStartAddress;
        uint32_t segmentEndAddress;
        uint32_t segmentSize;
        const segment *pSegment = *it;

        segmentStartAddress = (uint32_t)pSegment->get_virtual_address();
        segmentSize = (uint32_t)pSegment->get_file_size();
        segmentEndAddress = segmentStartAddress + segmentSize;

        if (PT_LOAD == pSegment->get_type())
        {
            // Remove the offset from the start address to use it as an index
            // into the memory region buffer.
            segmentStartAddress -= startAddress;

#ifdef DEBUG_PRINT
            printf("Copying segment %d: 0x%08x-0x%08x (%u bytes) to %u\n",
                   segmentID, segmentStartAddress + startAddress, segmentEndAddress, segmentSize, segmentStartAddress);
#endif // DEBUG_PRINT

            // Read the segment data.
            memcpy(&pMemory[segmentStartAddress], pSegment->get_data(),
                   segmentSize);
        }
    }

#ifdef DEBUG_PRINT
    printf("All segments copied.\n");
#endif
    return pMemory;
}

int WriteMifLine(FILE *pOut, uint32_t data)
{
    if (gOutputHex)
    {
        fprintf(pOut, "%08X\n", data);
    }
    else
    {
        uint32_t i;

        for (i = 0; i < 32; ++i)
        {
            if (1 == ((data >> (31 - i)) & 1))
            {
                fputc('1', pOut);
            }
            else
            {
                fputc('0', pOut);
            }
        }

        fputc('\n', pOut);
    }

    return 0;
}

int WriteBuffer(uint8_t *pMemory, const char *pOutFile, uint32_t size)
{
    FILE *pOut;

    if (0 == pMemory)
    {
        return -1;
    }

    //
    // Dump the memory region to the output file.
    //
    if (NULL == (pOut = my_fopen(pOutFile, "wb")))
    {
        fprintf(stderr, "Filed to open file for writing: %s\n", pOutFile);

        return -1;
    }

    for (uint32_t i = 0; i < size; i += sizeof(uint32_t))
    {
        if (0 != WriteMifLine(pOut, *((uint32_t *)&pMemory[i])))
        {
            return -1;
        }
    }

    //
    // Close the elf file.
    //
    fclose(pOut);
    delete[] pMemory;

    return 0;
}

int ExtractSegments(const char *pInFile, const char *pOutFile,
                    uint32_t startAddress, uint32_t endAddress, uint32_t size)
{
    // Pointer to the memory region to dump data into.
    uint8_t *pMemory;

    pMemory = ExtractSegments(pInFile, startAddress, endAddress, size);
    return WriteBuffer(pMemory, pOutFile, size);
}

int ExtractSegments(const char *pInFile, const char *pOutFile,
                    const char *pStartSymbol, const char *pEndSymbol)
{
    // Pointer to the memory region to dump data into.
    uint8_t *pMemory;
    uint32_t size = 0;

    pMemory = ExtractSegments(pInFile, pStartSymbol, pEndSymbol, &size);
    return WriteBuffer(pMemory, pOutFile, size);
}

int ExtractAllSegments(const char *pInFile, const char *pOutFile)
{
    // Pointer to the memory region to dump data into.
    uint8_t *pMemory;
    uint32_t size;

    pMemory = ExtractAllSegments(pInFile, &size);
    return WriteBuffer(pMemory, pOutFile, size);
}

int main(int argc, const char *argv[])
{
    const char *pStartSymbol = 0;
    const char *pEndSymbol = 0;

    uint32_t startAddress = 0;
    uint32_t endAddress = 0;
    uint32_t size = 0;

    const char *pInFile;
    const char *pOutFile;

    int argoff = 0;

    optparse::OptionParser parser;
    parser.description("Tool to generate Memory Initialization Files (MIFs)");
    parser.add_option("-H", "--hex").action("store_true").dest("hex").set_default("0").help("output a hex MIF instead of a binary MIF");
    parser.usage("%prog [options] ELF MIF [ADDR_START SIZE] [SYMBOL_START SYMBOL_END]");
    parser.epilog("Additional arguments:\n"
                  "  ELF          Input ELF file.\n"
                  "  MIF          Output Memory Initilization File (MIF).\n"
                  "  ADDR_START   Start address of the memory region (in hex) to dump.\n"
                  "  SIZE         Size of the memory region to dump (in decimal bytes).\n"
                  "  SYMBOL_START Start address of the memory region (symbol) to dump.\n"
                  "  SYMBOL_END   End address of the (symbol) to dump.\n");
    parser.version(ELF2MIF_VERSION);

    optparse::Values options = parser.parse_args(argc, argv);
    std::vector<std::string> args = parser.args();

    gOutputHex = options.get("hex");

    if (2 != args.size() && 4 != args.size())
    {
        parser.print_help();

        return EXIT_FAILURE;
    }

    pInFile = args[0].c_str();
    pOutFile = args[1].c_str();

    if (2 < args.size())
    {
        if (strlen(HEX_PREFIX) <= args[2].length() && 0 == memcmp(HEX_PREFIX, args[2].c_str(), strlen(HEX_PREFIX)))
        {
            if (1 != sscanf(&args[2].c_str()[strlen(HEX_PREFIX)], "%x", &startAddress))
            {
                pStartSymbol = args[2].c_str();
            }
        }
        else
        {
            if (1 != sscanf(args[2].c_str(), "%x", &startAddress))
            {
                pStartSymbol = args[2].c_str();
            }
        }

        if (1 != sscanf(args[3].c_str(), "%u", &size))
        {
            pEndSymbol = args[3].c_str();

#ifdef DEBUG_PRINT
            printf("Input file:    %s\n", pInFile);
            printf("Output file:   %s\n", pOutFile);
            printf("Start Symbol:  %s\n", pStartSymbol);
            printf("End Symbol:    %s\n", pEndSymbol);
            printf("Size:          %lu\n", size);
#endif // DEBUG_PRINT

            return ExtractSegments(pInFile, pOutFile, pStartSymbol, pEndSymbol);
        }
        else
        {
            endAddress = startAddress + size;

#ifdef DEBUG_PRINT
            printf("Input file:    %s\n", pInFile);
            printf("Output file:   %s\n", pOutFile);
            printf("Start Address: 0x%08x\n", startAddress);
            printf("End Address:   0x%08x\n", endAddress);
            printf("Size:          %lu\n", size);
#endif // DEBUG_PRINT

            return ExtractSegments(pInFile, pOutFile, startAddress, endAddress,
                                   size);
        }
    }
    else
    {
        return ExtractAllSegments(pInFile, pOutFile);
    }

    return EXIT_FAILURE;
}
