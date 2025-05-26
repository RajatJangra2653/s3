file_path: c:\Users\RajatKumar\OneDrive - Spektra Systems LLC\Desktop\git-project\README.md
insert_at: line 1
content: # AWS S3 Uploader

This project automatically uploads files to an AWS S3 bucket whenever code is pushed to the main branch on GitHub.

## Setup

1. Clone this repository
2. Add the following secrets to your GitHub repository:
   - `AWS_ACCESS_KEY_ID`: Your AWS access key
   - `AWS_SECRET_ACCESS_KEY`: Your AWS secret key
   - `AWS_REGION`: The AWS region your S3 bucket is in (e.g., us-east-1)
   - `AWS_S3_BUCKET`: The name of your S3 bucket
   - `AWS_S3_KEY_PREFIX`: Optional prefix for uploaded files in the S3 bucket

## How it works

When you push to the main branch, GitHub Actions will:
1. Check out your code
2. Build the .NET project
3. Run the uploader tool, which will upload all files in the repository to your S3 bucket

## Local usage

You can also run the uploader locally:

```powershell
$env:AWS_ACCESS_KEY_ID="your_access_key"
$env:AWS_SECRET_ACCESS_KEY="your_secret_key"
$env:AWS_REGION="your_region"
dotnet run --project AwsS3Uploader.Core/AwsS3Uploader.Core.csproj -- /path/to/source your-bucket-name optional/key/prefix