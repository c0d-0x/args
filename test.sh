#!/bin/bash

RESET="\033[0m"
RED="\033[1;31m"
GREEN="\033[1;32m"
BLUE="\033[1;34m"

SRC_DIR="./tests"
OUT_DIR="./build"

mkdir -p $OUT_DIR

passed=0
failed=0
for file in $(find $SRC_DIR -type f); do
    filename=$(basename $file)
    name=${filename%.*}
    bin="$OUT_DIR/$name"

    cc -Wall -Wextra -Werror -pedantic -std=c99 -Isrc $file -o $bin 2>/dev/null
    if [ $? -ne 0 ]; then
        echo -e $RED"[COMPILATION FAILED] $name"$RESET
        ((failed += 1))
        continue
    fi

    input=$(grep '//< ' $file | cut -c 5-)
    # Delete trailing CR to make results match on Windows (CRLF -> LF).
    expected_output=$(grep '//> ' $file | cut -c 5- | tr -d '\r')
    output=$($bin $input 2>&1 | tr -d '\r')
    if [ $? -eq 0 ] && [ "$output" = "$expected_output" ]; then
        echo -e $GREEN"[PASSED] $name"$RESET
        ((passed += 1))
    else
        echo -e $RED"[FAILED] $name"$RESET
        ((failed += 1))

        echo -e $BLUE"Expected:"$RESET
        echo "$expected_output"
        echo -e $BLUE"Found:"$RESET
        echo "$output"
    fi
done

echo ""
echo "Total:"
echo "    Passed: $passed"
echo "    Failed: $failed"

if [ $failed -gt 0 ]; then
    exit 1
fi
