#!/bin/bash

SOURCE_DIR="/backup-practice/source"
DEST_DIR="/backup-practice/destination"

# Create source and destination directories
mkdir -p "$SOURCE_DIR"
mkdir -p "$DEST_DIR"

# Create some sample files
echo "This is file 1" > "$SOURCE_DIR/file1.txt"
echo "This is file 2" > "$SOURCE_DIR/file2.txt"
echo "This is file 3" > "$SOURCE_DIR/file3.txt"

echo "Sample files created successfully"

# Check whether source directory has files
if [ "$(ls -A "$SOURCE_DIR")" ]; then

    # Create ZIP file name with date and time
    ZIP_FILE="$DEST_DIR/backup_$(date +%Y-%m-%d_%H-%M-%S).zip"

    # ZIP the files
    zip -j "$ZIP_FILE" "$SOURCE_DIR"/*

    # Check whether ZIP was created successfully
    if [ $? -eq 0 ]; then
        echo "Backup ZIP created successfully"
        echo "ZIP file: $ZIP_FILE"

        # Delete original files from source
        rm -f "$SOURCE_DIR"/*

        echo "Original files deleted from source directory"
    else
        echo "ZIP backup failed"
        exit 1
    fi

else
    echo "No files found in source directory"
    exit 1
fi

echo
echo "========== BACKUP COMPLETED =========="
echo
echo "Source directory:"
ls -l "$SOURCE_DIR"

echo
echo "Destination directory:"
ls -lh "$DEST_DIR"