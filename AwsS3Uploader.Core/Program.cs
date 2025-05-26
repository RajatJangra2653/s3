using System;
using System.IO;
using System.Linq;
using System.Threading.Tasks;
using Amazon;
using Amazon.S3;
using Amazon.S3.Transfer;
using Microsoft.Extensions.Configuration;

namespace AwsS3Uploader.Core
{
    class Program
    {
        static async Task Main(string[] args)
        {
            // Validate arguments
            if (args.Length < 2)
            {
                Console.WriteLine("Usage: AwsS3Uploader.Core <sourceDirectory> <bucketName> [s3KeyPrefix] [deletedFilesList]");
                return;
            }

            string sourceDirectory = args[0];
            string bucketName = args[1];
            string s3KeyPrefix = args.Length > 2 ? args[2] : "";
            string deletedFilesList = args.Length > 3 ? args[3] : string.Empty;

            // Load configuration
            var config = new ConfigurationBuilder()
                .AddEnvironmentVariables()
                .Build();

            // Get AWS credentials from environment variables
            string awsAccessKey = config["AWS_ACCESS_KEY_ID"];
            string awsSecretKey = config["AWS_SECRET_ACCESS_KEY"];
            string awsRegion = config["AWS_REGION"] ?? "us-east-1";

            if (string.IsNullOrEmpty(awsAccessKey) || string.IsNullOrEmpty(awsSecretKey))
            {
                Console.WriteLine("AWS credentials not found in environment variables.");
                return;
            }

            try
            {
                Console.WriteLine($"Starting upload to S3 bucket '{bucketName}' with prefix '{s3KeyPrefix}'");
                Console.WriteLine($"Source directory: {sourceDirectory}");

                // Create S3 client
                var s3Client = new AmazonS3Client(
                    awsAccessKey,
                    awsSecretKey,
                    RegionEndpoint.GetBySystemName(awsRegion));

                // 1. Build set of all local files (relative to sourceDirectory)
                var localFiles = Directory.GetFiles(sourceDirectory, "*", SearchOption.AllDirectories)
                    .Select(f => Path.GetRelativePath(sourceDirectory, f).Replace("\\", "/"))
                    .ToHashSet(StringComparer.OrdinalIgnoreCase);

                // 2. List all S3 objects under the prefix
                var s3Keys = new List<string>();
                string? continuationToken = null;
                do
                {
                    var request = new Amazon.S3.Model.ListObjectsV2Request
                    {
                        BucketName = bucketName,
                        Prefix = string.IsNullOrEmpty(s3KeyPrefix) ? null : s3KeyPrefix.TrimEnd('/') + "/",
                        ContinuationToken = continuationToken
                    };
                    var response = await s3Client.ListObjectsV2Async(request);
                    s3Keys.AddRange(response.S3Objects.Select(o => o.Key));
                    continuationToken = response.IsTruncated ? response.NextContinuationToken : null;
                } while (continuationToken != null);

                // 3. Delete S3 objects not present in localFiles
                foreach (var s3Key in s3Keys)
                {
                    // Compute the relative path for comparison
                    string relativePath = string.IsNullOrEmpty(s3KeyPrefix)
                        ? s3Key
                        : s3Key.Substring(s3KeyPrefix.TrimEnd('/').Length + 1);
                    if (!localFiles.Contains(relativePath))
                    {
                        Console.WriteLine($"Deleting {s3Key} from S3 (not present locally)");
                        try
                        {
                            await s3Client.DeleteObjectAsync(bucketName, s3Key);
                        }
                        catch (Exception ex)
                        {
                            Console.WriteLine($"Failed to delete {s3Key}: {ex.Message}");
                        }
                    }
                }

                // Create transfer utility
                var transferUtility = new TransferUtility(s3Client);

                // Ensure the source directory exists
                if (!Directory.Exists(sourceDirectory))
                {
                    Console.WriteLine($"Error: Directory {sourceDirectory} does not exist.");
                    return;
                }

                // Upload all files recursively
                await UploadDirectoryAsync(transferUtility, sourceDirectory, bucketName, s3KeyPrefix);

                Console.WriteLine("Upload completed successfully.");
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Error uploading to S3: {ex.Message}");
                Environment.Exit(1);
            }
        }

        private static async Task UploadDirectoryAsync(
            TransferUtility transferUtility,
            string directoryPath,
            string bucketName,
            string s3KeyPrefix)
        {
            // Upload all files in the directory
            foreach (var filePath in Directory.GetFiles(directoryPath))
            {
                string fileName = Path.GetFileName(filePath);
                string keyName = string.IsNullOrEmpty(s3KeyPrefix)
                    ? fileName
                    : $"{s3KeyPrefix.TrimEnd('/')}/{fileName}";

                Console.WriteLine($"Uploading {fileName} to {keyName}");

                await transferUtility.UploadAsync(filePath, bucketName, keyName);
            }

            // Recursively upload files in subdirectories
            foreach (var subDirectoryPath in Directory.GetDirectories(directoryPath))
            {
                string subDirectoryName = Path.GetFileName(subDirectoryPath);
                string subKeyPrefix = string.IsNullOrEmpty(s3KeyPrefix)
                    ? subDirectoryName
                    : $"{s3KeyPrefix.TrimEnd('/')}/{subDirectoryName}";

                await UploadDirectoryAsync(transferUtility, subDirectoryPath, bucketName, subKeyPrefix);
            }
        }
    }
}