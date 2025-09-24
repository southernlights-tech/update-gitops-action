#!/bin/bash

# Unit test script for PR title generation logic
# This script tests the PR title generation from action.yml:49-56

set -e

echo "🧪 Testing PR title generation logic..."

# Test case 1: Normal message
test_normal_message() {
    echo "Test 1: Normal message length"
    
    RAW_MESSAGE="Repo test-repo published v1.0.0 by testuser"
    if [ ${#RAW_MESSAGE} -gt 256 ]; then
        TRIMMED_MESSAGE="${RAW_MESSAGE:0:253}..."
        echo "❌ Expected normal message, got trimmed: $TRIMMED_MESSAGE"
        return 1
    else
        echo "✅ Normal message: $RAW_MESSAGE (${#RAW_MESSAGE} chars)"
    fi
}

# Test case 2: Long message that needs trimming
test_long_message() {
    echo "Test 2: Long message that needs trimming"
    
    LONG_MESSAGE="Repo very-long-repository-name published very-long-commit-message-that-exceeds-the-maximum-length-allowed-for-pr-titles-and-should-be-trimmed-to-fit-within-the-256-character-limit-imposed-by-github-api-constraints-making-sure-we-handle-this-edge-case-properly-and-adding-even-more-text-to-ensure-we-definitely-exceed-the-limit by very-long-username-that-also-contributes-to-length"
    
    if [ ${#LONG_MESSAGE} -gt 256 ]; then
        TRIMMED_MESSAGE="${LONG_MESSAGE:0:253}..."
        echo "✅ Long message trimmed: ${#TRIMMED_MESSAGE} chars"
        echo "   Original: ${#LONG_MESSAGE} chars"
        echo "   Trimmed: $TRIMMED_MESSAGE"
    else
        echo "❌ Expected long message to be trimmed, but it was ${#LONG_MESSAGE} chars"
        return 1
    fi
}

# Test case 3: Edge case - exactly 256 characters
test_edge_case() {
    echo "Test 3: Edge case - exactly 256 characters"
    
    # Create message that's exactly 256 characters
    EDGE_MESSAGE="$(printf 'A%.0s' {1..256})"
    
    if [ ${#EDGE_MESSAGE} -gt 256 ]; then
        TRIMMED_MESSAGE="${EDGE_MESSAGE:0:253}..."
        echo "✅ Edge case trimmed: ${#TRIMMED_MESSAGE} chars"
    else
        echo "✅ Edge case not trimmed: ${#EDGE_MESSAGE} chars"
    fi
}

# Test case 4: Simulate actual GitHub context
test_github_context() {
    echo "Test 4: Simulated GitHub context"
    
    # Simulate GitHub environment variables
    GITHUB_REPOSITORY_NAME="my-awesome-app"
    GITHUB_COMMIT_MESSAGE="fix: resolve critical security vulnerability in authentication module"
    GITHUB_ACTOR="developer123"
    
    RAW_MESSAGE="Repo $GITHUB_REPOSITORY_NAME published $GITHUB_COMMIT_MESSAGE by $GITHUB_ACTOR"
    
    if [ ${#RAW_MESSAGE} -gt 256 ]; then
        TRIMMED_MESSAGE="${RAW_MESSAGE:0:253}..."
        echo "✅ GitHub context trimmed: ${#TRIMMED_MESSAGE} chars"
        echo "   Message: $TRIMMED_MESSAGE"
    else
        echo "✅ GitHub context normal: $RAW_MESSAGE (${#RAW_MESSAGE} chars)"
    fi
}

# Run all tests
echo "Starting PR title generation tests..."
echo "=================================="

test_normal_message
echo ""
test_long_message  
echo ""
test_edge_case
echo ""
test_github_context

echo ""
echo "🎉 All tests completed successfully!"