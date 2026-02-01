# GitHub Secrets Configuration

This file lists all the secrets you need to configure in your GitHub repository for the CI/CD pipeline to work.

Go to: **Settings → Secrets and variables → Actions → New repository secret**

## Required Secrets

### AWS Credentials

#### AWS_ACCESS_KEY_ID
- **Description:** AWS IAM user access key ID
- **How to get:**
  1. Go to AWS Console → IAM → Users
  2. Select your user or create new user for GitHub Actions
  3. Go to "Security credentials" tab
  4. Click "Create access key"
  5. Copy the Access Key ID
- **Required Permissions:**
  - `ecr:GetAuthorizationToken`
  - `ecr:BatchCheckLayerAvailability`
  - `ecr:GetDownloadUrlForLayer`
  - `ecr:PutImage`
  - `ecr:InitiateLayerUpload`
  - `ecr:UploadLayerPart`
  - `ecr:CompleteLayerUpload`

#### AWS_SECRET_ACCESS_KEY
- **Description:** AWS IAM user secret access key
- **How to get:** From the same access key creation process above
- **⚠️ Security:** Never commit this to your repository!

#### AWS_REGION
- **Description:** AWS region where your ECR repository is located
- **Example values:** `us-east-1`, `us-west-2`, `eu-west-1`, etc.

### AWS ECR Configuration

#### ECR_REGISTRY
- **Description:** Your ECR registry URL
- **Format:** `{aws-account-id}.dkr.ecr.{region}.amazonaws.com`
- **Example:** `123456789012.dkr.ecr.us-east-1.amazonaws.com`
- **How to get:**
  1. Go to AWS Console → ECR
  2. Click on your repository
  3. Copy the URI and remove the repository name from the end

#### ECR_REPOSITORY
- **Description:** Name of your ECR repository
- **Example:** `my-app`, `portfolio`, `webapp`
- **How to get:** From your ECR repository name in AWS Console

### EC2 Configuration

#### EC2_PUBLIC_IP
- **Description:** Public IP address of your EC2 instance
- **Example:** `54.123.45.67`
- **How to get:**
  1. Go to AWS Console → EC2 → Instances
  2. Select your instance
  3. Copy the "Public IPv4 address"

#### EC2_SSH_PRIVATE_KEY
- **Description:** Contents of your EC2 SSH private key (.pem file)
- **How to get:**
  1. Open your .pem file in a text editor
  2. Copy the entire contents including:
     ```
     -----BEGIN RSA PRIVATE KEY-----
     ... (all the key content) ...
     -----END RSA PRIVATE KEY-----
     ```
- **⚠️ Security:** Ensure this key has proper permissions and is never committed!

## Verification Checklist

Before pushing to trigger deployments, verify:

- [ ] All 7 secrets are added to GitHub repository
- [ ] AWS credentials have correct ECR permissions
- [ ] ECR repository exists in the specified region
- [ ] EC2 instance is running and accessible
- [ ] EC2 security group allows SSH (port 22) from GitHub Actions
- [ ] DNS records are pointing to EC2 IP address
- [ ] NGINX is configured on EC2 instance
- [ ] Docker is installed on EC2 instance
- [ ] AWS CLI is configured on EC2 instance

## Testing Your Secrets

To test if your secrets are working:

1. Make a small change to your repository
2. Push to the `develop` branch
3. Go to GitHub → Actions tab
4. Watch the workflow execution
5. Check for any authentication or connection errors

## Security Best Practices

1. **Use IAM Roles** (Advanced): Instead of access keys, consider using IAM roles for EC2
2. **Rotate Keys Regularly:** Change AWS access keys every 90 days
3. **Least Privilege:** Only grant necessary permissions to the IAM user
4. **Monitor Usage:** Use AWS CloudTrail to monitor API calls
5. **Separate Keys:** Use different AWS credentials for different environments if possible

## Troubleshooting

### Error: "Unable to locate credentials"
- Check that `AWS_ACCESS_KEY_ID` and `AWS_SECRET_ACCESS_KEY` are set correctly

### Error: "Permission denied (publickey)"
- Verify `EC2_SSH_PRIVATE_KEY` contains the complete private key
- Ensure the key corresponds to the key pair used when launching the EC2 instance

### Error: "Access Denied" when pushing to ECR
- Verify the IAM user has the required ECR permissions listed above

### Error: "No such host"
- Check that `EC2_PUBLIC_IP` is correct and the instance is running
- Verify the IP hasn't changed (consider using Elastic IP)
