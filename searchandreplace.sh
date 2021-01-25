  jq -r 'to_entries[] | "s^##\(.key)##^\(.value)^g"' workbench-config.json |\
  while read sedval
  do
    eval "find ./helm -type f  \( -iname '*.tf' -o -iname '*.tfvars' -o -iname '*.yml' -o -iname '*.json' -o -iname '*.sh' -o -iname '*.yaml' \) -exec sed -i -e '$sedval' {} \;"
    eval "find ./scripts -type f \( -iname '*.tf' -o -iname '*.tfvars' -o -iname '*.yml' -o -iname '*.json' -o -iname '*.sh' -o -iname '*.yaml' \) -exec sed -i -e '$sedval' {} \;"
    eval "find ./terraform -type f \( -iname '*.tf' -o -iname '*.tfvars' -o -iname '*.yml' -o -iname '*.json' -o -iname '*.sh' -o -iname '*.yaml' \) -exec sed -i -e '$sedval' {} \;"
  done
