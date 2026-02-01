# GitHub Secrets Configuration Guide

## Required Secrets for Multi-Environment Pipeline

Go to: **https://github.com/bowale01/Multi-Platform-CICD-Workflow/settings/secrets/actions**

Click **"New repository secret"** for each of the following:

---

## 1. AWS Authentication Secrets

### AWS_ACCESS_KEY_ID
**Value:** Your AWS access key ID
```
Example: AKIAIOSFODNN7EXAMPLE
```

**How to get it:**
1. Go to AWS Console → IAM → Users → Your User
2. Click "Security credentials" tab
3. Click "Create access key"
4. Copy the Access Key ID

---

### AWS_SECRET_ACCESS_KEY
**Value:** Your AWS secret access key
```
Example: wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY
```

**Note:** This is shown only once when you create the access key. Keep it secure!

---

### AWS_REGION
**Value:** `us-east-1`

---

## 2. ECR (Container Registry) Secrets

### ECR_REGISTRY
**Value:** `<YOUR_AWS_ACCOUNT_ID>.dkr.ecr.us-east-1.amazonaws.com`

**How to get it:**
- Run: `aws sts get-caller-identity --query Account --output text`
- Format: `ACCOUNT_ID.dkr.ecr.us-east-1.amazonaws.com`

---

### ECR_REPOSITORY
**Value:** `multi-env-pipeline`

This is your ECR repository name (already created).

---

## 3. EC2 (Server) Secrets

### EC2_PUBLIC_IP
**Value:** `<YOUR_EC2_PUBLIC_IP>`

**How to get it:**
- AWS Console → EC2 → Instances → Your Instance → Public IPv4 address
- Or run: `aws ec2 describe-instances --query "Reservations[*].Instances[*].PublicIpAddress" --output text`

---

### EC2_SSH_PRIVATE_KEY
**Value:** Contents of your `.pem` file

**How to get it:**
1. Locate your EC2 private key file (e.g., `debolek-portfolio-ec2.pem`)
2. Open it in a text editor
3. Copy **ALL** content including the `-----BEGIN RSA PRIVATE KEY-----` and `-----END RSA PRIVATE KEY-----` lines
4. Paste the entire content as the secret value

**Example format:**
```
-----BEGIN RSA PRIVATE KEY-----
MIIEpAIBAAKCAQEA...
(multiple lines of encrypted key)
...
-----END RSA PRIVATE KEY-----
```

**⚠️ Important:** 
- Include ALL lines from BEGIN to END
- No extra spaces or line breaks before/after
- Keep this secret secure - never share it!

---

## Quick Setup Checklist

- [ ] AWS_ACCESS_KEY_ID = `<your-aws-access-key>`
- [ ] AWS_SECRET_ACCESS_KEY = `<your-aws-secret-key>`
- [ ] AWS_REGION = `us-east-1`
- [ ] ECR_REGISTRY = `<account-id>.dkr.ecr.us-east-1.amazonaws.com`
- [ ] ECR_REPOSITORY = `multi-env-pipeline`
- [ ] EC2_PUBLIC_IP = `<your-ec2-ip>`
- [ ] EC2_SSH_PRIVATE_KEY = `<contents-of-your-pem-file>`

---

## After Adding Secrets

Once all secrets are configured:

1. **Verify secrets are added:**
   - Go to repository Settings → Secrets → Actions
   - You should see all 7 secrets listed (values are hidden)

2. **Test the workflow:**
   - The workflows will automatically trigger on push to respective branches
   - Or manually trigger from Actions tab

3. **Monitor deployments:**
   - Go to Actions tab in your repository
   - Watch the workflow runs in real-time

---

## Security Notes

✅ **DO:**
- Keep your secrets secure
- Use least-privilege IAM policies
- Rotate access keys regularly
- Enable MFA on your AWS account

❌ **DON'T:**
- Share your secrets with anyone
- Commit secrets to your repository
- Use root AWS account credentials
- Post secrets in issues or pull requests

---

## Need Help?

If you encounter issues:
1. Check the Actions tab for error messages
2. Verify all secrets are correctly configured
3. Ensure EC2 security groups allow SSH (port 22) from GitHub Actions IPs
4. Check EC2 is running and accessible

---

## Next Steps

After configuring these secrets:
1. Run `./scripts/5-configure-nginx.sh` on your EC2 instance
2. Run `./scripts/6-provision-ssl.sh` on your EC2 instance  
3. Push to `develop` branch to trigger first deployment
