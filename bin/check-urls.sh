#!/bin/bash

HOST="http://ec2-54-195-2-100.eu-west-1.compute.amazonaws.com"

pages=(
    "/collections.html"
    "/ansible/latest/index.html"
    "/ansible/devel/index.html"
    "/ansible/2.3/index.html"
    "/ansible/2.3/fake.html"
    "/ansible/2.3/YAMLSyntax.html"
    "/ansible/2.3/playbooks_directives.html"
    "/ansible/2.3/playbooks_roles.html"
    "/ansible/2.3/playbooks_vault.html"
    "/ansible/2.3/dev_guide/developing_test_pr.html"
    "/ansible/2.3/alternatives_module.html"
    "/ansible/2.3/apk_module.html"
    "/ansible/2.3/plugins/become/doas.html"
    "/ansible/2.3/plugins/cache/base.html"
    "/ansible/2.4/index.html"
    "/ansible/2.4/fake.html"
    "/ansible/2.4/YAMLSyntax.html"
    "/ansible/2.4/playbooks_directives.html"
    "/ansible/2.4/playbooks_roles.html"
    "/ansible/2.4/playbooks_vault.html"
    "/ansible/2.4/dev_guide/developing_test_pr.html"
    "/ansible/2.4/alternatives_module.html"
    "/ansible/2.4/apk_module.html"
    "/ansible/2.4/plugins/become/doas.html"
    "/ansible/2.4/plugins/cache/base.html"
    "/ansible/2.5/index.html"
    "/ansible/2.5/fake.html"
    "/ansible/2.5/user_guide/playbooks_vault.html"
    "/ansible/2.5/modules/alternatives_module.html"
    "/ansible/2.5/modules/apk_module.html"
    "/ansible/2.5/plugins/become/doas.html"
    "/ansible/2.5/plugins/cache/base.html"
    "/ansible/2.5/reference_appendices/YAMLSyntax.html"
    "/ansible/2.6/index.html"
    "/ansible/2.6/fake.html"
    "/ansible/2.6/user_guide/playbooks_vault.html"
    "/ansible/2.6/user_guide/quickstart.html"
    "/ansible/2.6/vmware/index.html"
    "/ansible/2.6/modules/alternatives_module.html"
    "/ansible/2.6/modules/apk_module.html"
    "/ansible/2.6/plugins/become/doas.html"
    "/ansible/2.6/plugins/cache/base.html"
    "/ansible/2.10/index.html"
    "/ansible/2.10/fake.html"
    "/ansible/2.10/modules/alternatives_module.html"
    "/ansible/2.10/modules/apk_module.html"
    "/ansible/2.10/plugins/become/doas.html"
    "/ansible/2.10/plugins/cache/base.html"
    "/ansible/2.10/collections/index.html"
    "/ansible/2.10/collections/ansible/builtin/index.html"
    "/ansible/2.10/collections/ansible/builtin/copy_module.html"
    "/ansible/2.10/collections/ansible/builtin/file_lookup.html"
    "/ansible/2.10/collections/community/aws/index.html"
    "/ansible/2.10/collections/community/aws/aws_config_rule_module.html"
    "/ansible/2.10/collections/community/aws/aws_kms_module.html"
    "/ansible/2.9/index.html"
    "/ansible/2.9/fake.html"
    "/ansible/2.9/modules/alternatives_module.html"
    "/ansible/2.9/modules/apk_module.html"
    "/ansible/2.9/plugins/become/doas.html"
    "/ansible/2.9/plugins/cache/base.html"
    "/ansible/9/reference_appendices/YAMLSyntax.html"
    "/ansible/9/playbook_guide/index.html"
    "/ansible/9/collections/index.html"
    "/ansible/9/collections/ansible/builtin/copy_module.html"
    "/ansible/9/collections/all_plugins.html"
    "/ansible/10/reference_appendices/YAMLSyntax.html"
    "/ansible/10/playbook_guide/index.html"
    "/ansible/10/collections/index.html"
    "/ansible/10/collections/ansible/builtin/copy_module.html"
    "/ansible/10/collections/all_plugins.html"
    "/ansible/11/reference_appendices/YAMLSyntax.html"
    "/ansible/11/playbook_guide/index.html"
    "/ansible/11/collections/index.html"
    "/ansible/11/collections/ansible/builtin/copy_module.html"
    "/ansible/11/collections/all_plugins.html"
    "/ansible/latest/reference_appendices/YAMLSyntax.html"
    "/ansible/latest/playbook_guide/index.html"
    "/ansible/latest/collections/index.html"
    "/ansible/latest/collections/ansible/builtin/copy_module.html"
    "/ansible/latest/collections/all_plugins.html"
    "/ansible/devel/reference_appendices/YAMLSyntax.html"
    "/ansible/devel/playbook_guide/index.html"
    "/ansible/devel/collections/index.html"
    "/ansible/devel/collections/ansible/builtin/copy_module.html"
    "/ansible/devel/collections/all_plugins.html"
    "/ansible/latest/modules/shell_module.html"
    "/ansible/latest/modules/command_module.html"
    "/ansible/latest/collections/ansible/builtin/file_module.html"
    "/ansible/latest/modules/file_module.html"
    "/ansible/latest/modules/k8s_module.html"
)

GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m' # No Color

check_url() {
    local url="$HOST$1"
    local http_code=$(curl -s -o /dev/null -w "%{http_code}" "$url")

    if [ $http_code -eq 200 ] || [ $http_code -eq 301 ]; then
        echo -e "${GREEN}✓ $url exists (HTTP $http_code)${NC}"
        return 0
    else
        echo -e "${RED}✗ $url is not accessible (HTTP $http_code)${NC}"
        return 1
    fi
}

echo "Checking URLs..."
failed=0

for page in "${pages[@]}"; do
    if ! check_url "$page"; then
        ((failed++))
    fi
done

echo -e "\nResults:"
echo "Total URLs checked: ${#pages[@]}"
echo "Failed: $failed"
echo "Successful: $((${#pages[@]} - failed))"

if [ $failed -gt 0 ]; then
    exit 1
else
    exit 0
fi
