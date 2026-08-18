$ErrorActionPreference = "Stop"

$root = Split-Path -Parent $MyInvocation.MyCommand.Path
$build = Join-Path $root "lambda-build"
$package = Join-Path $build "package"
$zip = Join-Path $root "lambda.zip"

if (Test-Path $build) {
    Remove-Item $build -Recurse -Force
}

New-Item -ItemType Directory -Path $package | Out-Null

Write-Host "Building Lambda dependencies in the AWS Lambda Python 3.12 container..."

docker run --rm `
  --entrypoint /bin/bash `
  -v "${package}:/out" `
  public.ecr.aws/lambda/python:3.12 `
  -lc "pip install --no-cache-dir Pillow -t /out"

if ($LASTEXITCODE -ne 0) {
    throw "Docker failed while installing Lambda dependencies."
}

Copy-Item (Join-Path $root "lambda_function.py") $package

if (Test-Path $zip) {
    Remove-Item $zip -Force
}

Compress-Archive `
  -Path (Join-Path $package "*") `
  -DestinationPath $zip `
  -CompressionLevel Optimal

Remove-Item $build -Recurse -Force

Write-Host ""
Write-Host "Created: $zip"
Write-Host "Verify with: tar -tf lambda.zip"