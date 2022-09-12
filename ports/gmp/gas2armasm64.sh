#!/bin/bash

echo GAS 2 ARMASM64 converter

while [[ $# -gt 0 ]]; do
  case $1 in
    -I*)
      shift
      ;;
    -D*)
      shift
      ;;
    -o*)
      shift
      object_file="$1"
      shift
      ;;
   *)
      source_file="$1"
      shift
      ;;
    -*|--*)
      echo "Unknown option $1"
      exit 1
      ;;
  esac
done

[ -z $object_file ] && object_file=${source_file%%.*}.obj
echo source_file $source_file
echo object_file $object_file

armasm64_patch=''
armasm64_patch+='s/^\s*text\s*$//i;'
armasm64_patch+='s/^\s*\.text\s*$/ AREA |.text|, CODE, READONLY/i;'
armasm64_patch+='s/^\s*\.data\s*$/ AREA |.data|, DATA, READONLY/i;'
armasm64_patch+='s/^\s*rodata\s*$/ AREA |.rdata|, DATA, READONLY/i;'
armasm64_patch+='s/^\s*\.align\s*[[:digit:]]*\s*$//i;'
armasm64_patch+='s/^\s*\.?globl\s/ EXPORT /i;'
armasm64_patch+='s/^\s*\.extern\s+(.*)/ EXTERN \1/i;'
armasm64_patch+='s/^\s*.type.*//i;'
armasm64_patch+='s/^\s*type\(.*//i;'
armasm64_patch+='s/^\s*size\(.*//i;'
armasm64_patch+='s/cmn\s+x/adds xzr, x/;'
armasm64_patch+='s/cmp\s+x/subs xzr, x/;'
armasm64_patch+='s/ldr(.*#-.*\][^!]?\s*)$/ldur\1/;'
armasm64_patch+='s/str(.*#-.*\][^!]?\s*)$/stur\1/;'
armasm64_patch+='s/^(\s*)b\./\1b/;'
armasm64_patch+='s/^(\s*)(mov\s+[xX].*,\s*[vV].*)/\1u\2/;'
armasm64_patch+='s/.byte(\s+)/dcb\1/;'
armasm64_patch+='s/.hword(\s+)/dcw\1/;'
armasm64_patch+='s/.word(\s+)/dcd\1/;'


for i in $(cat $source_file | sed -n -E "s/^\s*([^ \t+-]+):.*/\1/p" | sort --reverse); do
  armasm64_patch+="/^\s*([^ ]+:)?\s*$i\s*$/!s/([ \t,=])$i([ \t+1]?)/\1|\$$i|\2/;"
  armasm64_patch+="s/^\s*$i:/|\$$i| /;"
done

source_file_armasm64="$source_file.armasm64"
cat $source_file | sed -E "$armasm64_patch" > $source_file_armasm64
armasm64 -o $object_file $source_file_armasm64 && rm $source_file_armasm64
