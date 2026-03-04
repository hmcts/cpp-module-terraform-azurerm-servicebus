package test

import (
	"path/filepath"
	"testing"

	"github.com/gruntwork-io/terratest/modules/terraform"
	test_structure "github.com/gruntwork-io/terratest/modules/test-structure"
	"github.com/stretchr/testify/assert"
)

func planPath(t *testing.T, name string) string {
	return filepath.Join(t.TempDir(), name)
}

func TestTerraformAzureServiceBusNamespace(t *testing.T) {
	t.Parallel()

	exampleFolder := test_structure.CopyTerraformFolderToTemp(t, "../..", "example/")
	planFilePath := filepath.Join(exampleFolder, "plan.out")

	terraformPlanOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: "../../example/",
		Upgrade:      true,
		VarFiles:     []string{"for_terratest.tfvars"},
		PlanFilePath: planFilePath,
	})

	terraform.InitAndPlanAndShowWithStruct(t, terraformPlanOptions)
	defer terraform.Destroy(t, terraformPlanOptions)

	terraform.InitAndApply(t, terraformPlanOptions)

	namespaceName := terraform.Output(t, terraformPlanOptions, "servicebus_namespace_name")
	namespaceID := terraform.Output(t, terraformPlanOptions, "servicebus_namespace_id")
	resourceGroupName := terraform.Output(t, terraformPlanOptions, "resource_group_name")

	assert.NotEmpty(t, namespaceName)
	assert.NotEmpty(t, namespaceID)
	assert.NotEmpty(t, resourceGroupName)
	assert.Contains(t, namespaceID, "Microsoft.ServiceBus/namespaces")
	assert.Contains(t, namespaceID, namespaceName)
}

// TestTerraformAzureServiceBusNamespaceWithQueuesAndTopics runs with queues, topics, and subscriptions.
// Runs sequentially (no t.Parallel) to avoid sharing TerraformDir with the namespace-only test.
func TestTerraformAzureServiceBusNamespaceWithQueuesAndTopics(t *testing.T) {
	planFilePath := planPath(t, "plan_queues_topics.out")

	terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir:  "../../example/",
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
