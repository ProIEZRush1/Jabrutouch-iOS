# AWS Credentials Setup

## Important Security Note
AWS credentials have been removed from the source code for security reasons. Never commit AWS credentials to version control.

## Setting up AWS Credentials

### Option 1: Environment Variables (Recommended for Development)
Set the following environment variables in your Xcode scheme:
1. In Xcode, select your project scheme
2. Edit Scheme → Run → Arguments → Environment Variables
3. Add:
   - `AWS_ACCESS_KEY_ID`: Your AWS Access Key ID
   - `AWS_SECRET_ACCESS_KEY`: Your AWS Secret Access Key

### Option 2: Using a Configuration File (Not committed to git)
1. Create a file named `AWSConfig.swift` in the project
2. Add it to `.gitignore`
3. Define your credentials there

### Option 3: Using iOS Keychain (Recommended for Production)
Store credentials securely in the iOS Keychain and retrieve them at runtime.

## Previous Credentials (For Reference Only - DO NOT USE IN CODE)
The following credentials were previously hardcoded and should be stored securely:
- Region: US-West-2
- S3 Bucket: jabrutouch-cms-media
- S3 Base URL: https://jabrutouch-cms-media.s3-us-west-2.amazonaws.com/

Contact your team lead or DevOps for the actual credential values.