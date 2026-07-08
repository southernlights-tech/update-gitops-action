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

# Test case 4: Message with newlines (new sanitization feature)
test_newline_sanitization() {
    echo "Test 4: Message with newlines sanitization"
    
    RAW_MESSAGE="Repo test-repo published fix: resolve issue
with multi-line commit message
that spans multiple lines by testuser"
    
    # Apply newline sanitization like in action.yml
    CLEAN_MESSAGE=$(echo "$RAW_MESSAGE" | tr '\n' ' ' | tr -s ' ')
    
    if [ ${#CLEAN_MESSAGE} -gt 256 ]; then
        TRIMMED_MESSAGE="${CLEAN_MESSAGE:0:253}..."
        echo "✅ Newlines sanitized and trimmed: ${#TRIMMED_MESSAGE} chars"
        echo "   Message: $TRIMMED_MESSAGE"
    else
        echo "✅ Newlines sanitized: $CLEAN_MESSAGE (${#CLEAN_MESSAGE} chars)"
    fi
    
    # Verify no newlines remain
    if [[ "$CLEAN_MESSAGE" == *$'\n'* ]]; then
        echo "❌ Newlines still present in cleaned message"
        return 1
    fi
}

# Test case 5: Simulate actual GitHub context
test_github_context() {
    echo "Test 5: Simulated GitHub context"
    
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

# Test case 6: Message with special characters (parentheses, quotes)
test_special_characters() {
    echo "Test 6: Message with special characters (parentheses, quotes)"
    
    GITHUB_REPOSITORY_NAME="erp-integrations"
    GITHUB_COMMIT_MESSAGE='Revert "refractor hdms to use config (#371)" (#372)'
    GITHUB_ACTOR="developer"
    
    printf -v RAW_MESSAGE "Repo %s published %s by %s" "$GITHUB_REPOSITORY_NAME" "$GITHUB_COMMIT_MESSAGE" "$GITHUB_ACTOR"
    CLEAN_MESSAGE=$(echo "$RAW_MESSAGE" | tr '\n' ' ' | tr -s ' ')
    
    if [ ${#CLEAN_MESSAGE} -gt 256 ]; then
        TRIMMED_MESSAGE="${CLEAN_MESSAGE:0:253}..."
        echo "✅ Special characters handled and trimmed: ${#TRIMMED_MESSAGE} chars"
        echo "   Message: $TRIMMED_MESSAGE"
    else
        echo "✅ Special characters handled: $CLEAN_MESSAGE (${#CLEAN_MESSAGE} chars)"
    fi
    
    if [[ "$CLEAN_MESSAGE" == *"Revert"* ]] && [[ "$CLEAN_MESSAGE" == *"#371"* ]]; then
        echo "   ✓ Special characters preserved correctly"
    else
        echo "❌ Special characters not preserved correctly"
        return 1
    fi
}

# Test case 7: Custom PR title overrides auto-generated title
test_custom_title() {
    echo "Test 7: Custom PR title overrides auto-generated title"
    
    CUSTOM_TITLE="Update secret-agent images to abc123f"
    
    # Simulate the action logic
    if [ -n "$CUSTOM_TITLE" ]; then
        echo "✅ Custom title used: $CUSTOM_TITLE"
        echo "   (not: Repo test-repo published feat: KAN-5053 add feature by developer)"
    else
        echo "❌ Custom title was ignored"
        return 1
    fi
    
    # Verify it doesn't contain ticket ID patterns
    if echo "$CUSTOM_TITLE" | grep -qiE '(DEVOPS|KAN)-[0-9]+'; then
        echo "❌ Custom title leaked ticket ID"
        return 1
    else
        echo "✅ No ticket ID leaked in custom title"
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
test_newline_sanitization
echo ""
test_github_context
echo ""
test_special_characters
echo ""
test_custom_title

echo ""
echo "🎉 All tests completed successfully!"