#!/bin/bash -e

# Script to inject selected features from /bootstrap and /templates into /src

REPO_ORIGIN=$(git remote get-url origin | sed 's/git@\(.*\):\(.*\).git/https:\/\/\1\/\2/')

# Merge YAML snippets from templates/app-config into src/app-config.yaml
echo "Merging app-config snippets..."
for snippet in templates/app-config/*.yaml; do
  echo "Merging snippet: $snippet"
  yq eval-all 'select(fileIndex == 0) * select(fileIndex == 1)' src/app-config.yaml "$snippet" > src/app-config.tmp.yaml
  mv src/app-config.yaml src/app-config.yaml.bak
  mv src/app-config.tmp.yaml src/app-config.yaml
  yq eval-all '. as $item ireduce ({}; . *+ $item)' src/app-config.yaml "$snippet" > src/app-config.tmp.yaml
  mv src/app-config.tmp.yaml src/app-config.yaml
done

# Inject scaffolder template refs into src/app-config.yaml
echo "Injecting scaffolder template refs..."
for template in templates/scaffolder/*.yaml; do
  TEMPLATE_NAME=$(basename "$template")
  TEMPLATE_URL="$REPO_URL/blob/main/templates/scaffolder/$template"
  yq -i '.catalog.locations += [{"type": "url", "target": "'"$REPO_URL/blob/main/$template"'", "rules": [{"allow": ["Template"]}]}]' src/app-config.yaml
done

# Copy selected bootstrap features into src
echo "Copying bootstrap features..."
cp -r bootstrap/* src/

echo "Injection complete. Please verify changes in src/app-config.yaml."

### Requirements:
- Install [`yq`](https://github.com/mikefarah/yq) for YAML merging:
```sh
sudo wget https://github.com/mikefarah/yq/releases/latest/download/yq_linux_amd64 -O /usr/local/bin/yq && chmod +x /usr/local/bin/yq