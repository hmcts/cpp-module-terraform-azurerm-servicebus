# Terratest for Service Bus Namespace module

Run from the module root or from this directory. Ensure Azure CLI is logged in and Terraform/Go are available.

```bash
cd tests/terratest
go mod tidy
go test -v -timeout 30m .
```

For Docker (e.g. code mounted at /code):

```bash
docker run -v /path/to/module:/code -w /code/tests/terratest <image> go test -v -timeout 30m .
```
