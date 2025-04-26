#!/bin/bash

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Directory and executable
TESTS_DIR="./hw1-MyTests"
HW_EXE="./hw1"
MAX_TESTS=50

function notify() {
    local len=$((${#1}+2))
    let border=$len*2
    let spaceSeperator=($len/2)
    if $2
    then
        tmp="#${RED}%$spaceSeperator""s""%s""%$spaceSeperator""s${NC}%s#"
    else
        tmp="#${GREEN}%$spaceSeperator""s""%s""%$spaceSeperator""s${NC}#"
    fi
    printf "\n"
    printf "#%.0s" $(seq 1 $border)
    printf "\n"

    printf $tmp "" "$1" ""

    printf "\n"
    printf "#%.0s" $(seq 1 $border)
    printf "\n\n"
}

test_failed=false
count=0

# Get the list of test files
test_files=($TESTS_DIR/*.in)

# Execute only MAX_TESTS tests
for test_input in "${test_files[@]}"; do
    # Stop after MAX_TESTS
    if [ $count -ge $MAX_TESTS ]; then
        break
    fi
    
    test_name=$(basename "$test_input" .in)
    test_output="$TESTS_DIR/$test_name.out"
    test_result="$TESTS_DIR/$test_name.res"

    # Run the test
    $HW_EXE < "$test_input" > "$test_result"
    
    # Compare the results
    if diff $test_result $test_output > /dev/null; then
        echo -e "Test ${test_name} - ${GREEN}PASSED${NC}"
        rm $test_result
    else
        echo -e "Test ${test_name} - ${RED}FAILED${NC}"
        diff $test_result $test_output
        test_failed=true
    fi
    
    # Increment counter
    ((count++))
done

if $test_failed; then
    notify "Unfortunately!!! Something FAILED" true
else
    notify "Congratz!!! All Tests PASSED!!!" false
fi 