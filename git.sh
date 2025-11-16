#!/bin/bash
# Simple Git commit and push script
# Stage all changes
git add .
# Ask for commit message
read -p "Enter commit message: " commit_msg
# Commit with entered message
git commit -m "$commit_msg"
# Set main branch and push to origin
git branch -M main
git push -u origin main