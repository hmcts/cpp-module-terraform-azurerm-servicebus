package test

import (
	"path/filepath"
	"testing"

	"github.com/gruntwork-io/terratest/modules/terraform"
	test_structure "github.com/gruntwork-io/terratest/modules/test-structure"
	"github.com/stretchr/testify/assert"
)

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

