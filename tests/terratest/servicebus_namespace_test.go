package test

import (
	"path/filepath"
	"testing"

	"github.com/gruntwork-io/terratest/modules/terraform"
	test_structure "github.com/gruntwork-io/terratest/modules/test-structure"
	"github.com/stretchr/testify/assert"
)

// func TestTerraformAzureServiceBusNamespace(t *testing.T) {
// 	t.Parallel()

// 	copyRoot := test_structure.CopyTerraformFolderToTemp(t, "../..", ".")
// 	terraformDir := filepath.Join(copyRoot, "example")
// 	planFilePath := filepath.Join(terraformDir, "plan.out")

// 	terraformPlanOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
// 		TerraformDir: terraformDir,
// 		Upgrade:      true,
// 		VarFiles:     []string{"for_terratest.tfvars"},
// 		PlanFilePath: planFilePath,
// 	})

// 	terraform.InitAndPlanAndShowWithStruct(t, terraformPlanOptions)
// 	defer terraform.Destroy(t, terraformPlanOptions)

// 	terraform.InitAndApply(t, terraformPlanOptions)

// 	namespaceName := terraform.Output(t, terraformPlanOptions, "servicebus_namespace_name")
// 	namespaceID := terraform.Output(t, terraformPlanOptions, "servicebus_namespace_id")
// 	resourceGroupName := terraform.Output(t, terraformPlanOptions, "resource_group_name")

// 	assert.NotEmpty(t, namespaceName)
// 	assert.NotEmpty(t, namespaceID)
// 	assert.NotEmpty(t, resourceGroupName)
// 	assert.Contains(t, namespaceID, "Microsoft.ServiceBus/namespaces")
// 	assert.Contains(t, namespaceID, namespaceName)
// }

// TestTerraformAzureServiceBusNamespaceWithQueuesAndTopics runs with queues, topics, and subscriptions.
// Uses an isolated copy of the example so state is not shared with other tests.
func TestTerraformAzureServiceBusNamespaceWithQueuesAndTopics(t *testing.T) {
	copyRoot := test_structure.CopyTerraformFolderToTemp(t, "../..", ".")
	terraformDir := filepath.Join(copyRoot, "example")
	planFilePath := filepath.Join(terraformDir, "plan_queues_topics.out")

	terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir:  terraformDir,
		Upgrade:      true,
		VarFiles:     []string{"for_terratest_with_entities.tfvars"},
		PlanFilePath: planFilePath,
	})

	terraform.InitAndPlanAndShowWithStruct(t, terraformOptions)
	defer terraform.Destroy(t, terraformOptions)

	terraform.InitAndApply(t, terraformOptions)

	namespaceName := terraform.Output(t, terraformOptions, "servicebus_namespace_name")
	queuesOutput := terraform.OutputMap(t, terraformOptions, "queues")
	topicsOutput := terraform.OutputMap(t, terraformOptions, "topics")
	subscriptionsOutput := terraform.OutputMap(t, terraformOptions, "subscriptions")

	assert.NotEmpty(t, namespaceName)
	assert.Len(t, queuesOutput, 2)
	assert.Len(t, topicsOutput, 2)
	assert.Len(t, subscriptionsOutput, 3)
	assert.Contains(t, queuesOutput, "payments")
	assert.Contains(t, queuesOutput, "fraudalerts")
	assert.Contains(t, topicsOutput, "orderevents")
	assert.Contains(t, topicsOutput, "customerevents")
}

// TestTerraformAzureServiceBusNamespaceZeroTrust runs with public_network_access_enabled = false,
// creating a private endpoint and private DNS zone registration (zero trust).
// Asserts private_endpoint_id and private_dns_zone_id are set.
// Uses an isolated copy of the example so state is not shared with other tests.
// func TestTerraformAzureServiceBusNamespaceZeroTrust(t *testing.T) {
// 	copyRoot := test_structure.CopyTerraformFolderToTemp(t, "../..", ".")
// 	terraformDir := filepath.Join(copyRoot, "example")
// 	planFilePath := filepath.Join(terraformDir, "plan_zerotrust.out")

// 	terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
// 		TerraformDir:  terraformDir,
// 		Upgrade:      true,
// 		VarFiles:     []string{"for_terratest_zerotrust.tfvars"},
// 		PlanFilePath: planFilePath,
// 	})

// 	terraform.InitAndPlanAndShowWithStruct(t, terraformOptions)
// 	defer terraform.Destroy(t, terraformOptions)

// 	terraform.InitAndApply(t, terraformOptions)

// 	namespaceName := terraform.Output(t, terraformOptions, "servicebus_namespace_name")
// 	namespaceID := terraform.Output(t, terraformOptions, "servicebus_namespace_id")
// 	privateEndpointID := terraform.Output(t, terraformOptions, "private_endpoint_id")
// 	privateDNSZoneID := terraform.Output(t, terraformOptions, "private_dns_zone_id")

// 	assert.NotEmpty(t, namespaceName)
// 	assert.NotEmpty(t, namespaceID)
// 	assert.NotEmpty(t, privateEndpointID, "zero trust: private endpoint must be created when public_network_access_enabled = false")
// 	assert.NotEmpty(t, privateDNSZoneID, "zero trust: private DNS zone (privatelink.servicebus.windows.net) must be created and linked for DNS registration")
// 	assert.Contains(t, namespaceID, "Microsoft.ServiceBus/namespaces")
// 	assert.Contains(t, privateEndpointID, "Microsoft.Network/privateEndpoints")
// 	assert.Contains(t, privateDNSZoneID, "privatelink.servicebus.windows.net")
// }
