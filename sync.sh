#!/bin/bash
set -e

# Configuration
NEW_APP_NAME="backstage-new"

echo "=== Backstage Upgrade Process ==="
echo "This script will create a new Backstage app and sync your current customizations."

# Step 0: Check current version vs latest version
if [ -f "src/package.json" ]; then
  echo "Checking Backstage versions..."
  
  # Get current version from package.json
  CURRENT_VERSION=$(grep -o '"@backstage/core-plugin-api": "[^"]*"' src/package.json | grep -o '[0-9]\+\.[0-9]\+\.[0-9]\+' || echo "unknown")
  
  # Get latest version without installing
  LATEST_VERSION=$(npm view @backstage/create-app version)
  
  echo "Current Backstage version: $CURRENT_VERSION"
  echo "Latest Backstage version: $LATEST_VERSION"
  
  if [ "$CURRENT_VERSION" = "$LATEST_VERSION" ]; then
    echo "You are already on the latest version. No upgrade needed."
    exit 0
  fi
fi

# Step 1: Create new Backstage app with latest version
echo "Creating new Backstage app with latest version..."
# Use --yes to auto-confirm package installation and provide app name
npx --yes @backstage/create-app@latest --path "$NEW_APP_NAME" --skip-install <<< "backstage"

# Step 2: Sync your customizations
echo "Syncing your customizations..."

# Find all top-level directories in the new app
NEW_DIRS=$(find "$NEW_APP_NAME" -maxdepth 1 -type d | sort)

# Sync customizations directory by directory
for dir in $NEW_DIRS; do
  # Skip the root directory itself
  if [ "$dir" = "$NEW_APP_NAME" ]; then
    continue
  fi
  
  base_dir=$(basename "$dir")
  src_dir="src/$base_dir"
  
  if [ -d "$src_dir" ]; then
    echo "Processing directory: $base_dir"
    
    # For packages directory, handle special case
    if [ "$base_dir" = "packages" ]; then
      # Find all packages
      for pkg_dir in "$src_dir"/*; do
        if [ -d "$pkg_dir" ]; then
          pkg_name=$(basename "$pkg_dir")
          echo "  Processing package: $pkg_name"
          
          # Handle app package specially - we want to preserve customizations
          if [ "$pkg_name" = "app" ] && [ -d "$pkg_dir/src/components" ]; then
            echo "    Preserving app components..."
            mkdir -p "$NEW_APP_NAME/packages/app/src/components"
            cp -r "$pkg_dir/src/components"/* "$NEW_APP_NAME/packages/app/src/components/" 2>/dev/null || true
          fi
          
          # Handle backend package specially
          if [ "$pkg_name" = "backend" ]; then
            # Copy custom Dockerfile if it exists
            if [ -f "$pkg_dir/Dockerfile" ]; then
              echo "    Preserving backend Dockerfile..."
              cp "$pkg_dir/Dockerfile" "$NEW_APP_NAME/packages/backend/"
            fi
            
            # Try to copy custom plugins structure
            if [ -d "$pkg_dir/src/plugins" ]; then
              echo "    Preserving backend plugins..."
              mkdir -p "$NEW_APP_NAME/packages/backend/src/plugins"
              cp -r "$pkg_dir/src/plugins"/* "$NEW_APP_NAME/packages/backend/src/plugins/" 2>/dev/null || true
            fi
            
            # Try both extensions and plugins directories
            if [ -d "$pkg_dir/src/extensions" ]; then
              echo "    Preserving backend extensions..."
              mkdir -p "$NEW_APP_NAME/packages/backend/src/extensions"
              cp -r "$pkg_dir/src/extensions"/* "$NEW_APP_NAME/packages/backend/src/extensions/" 2>/dev/null || true
            fi
          fi
        fi
      done
    fi
    
    # For plugins directory, copy everything
    if [ "$base_dir" = "plugins" ] && [ -d "$src_dir" ]; then
      echo "  Preserving custom plugins..."
      cp -r "$src_dir"/* "$NEW_APP_NAME/plugins/" 2>/dev/null || true
    fi
  fi
done

# Copy specific files
FILES_TO_COPY=(
  "app-config.yaml"
  "app-config.production.yaml"
  "app-config.local.yaml"
  "catalog-info.yaml"
)

for file in "${FILES_TO_COPY[@]}"; do
  if [ -f "src/$file" ]; then
    echo "Copying file: $file"
    cp "src/$file" "$NEW_APP_NAME/"
  fi
done

# Step 3: Replace the src directory with the new version
echo "Replacing old version with new version..."
rm -rf src
mv "$NEW_APP_NAME" src

echo "=== Upgrade Complete ==="
echo "Please manually check the following:"
echo "1. Review package.json files and merge any custom dependencies"
echo "2. Check app-config.yaml for any structural changes"
echo "3. Test that your customizations work with the new version"