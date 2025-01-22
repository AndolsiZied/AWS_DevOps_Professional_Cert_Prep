### **1. Compute (EC2, Auto Scaling, Lambda)**
- **Lambda**
    - AWS Lambda cannot be used to create AMIs.
    - Lambda has a limit of **1,000 concurrent executions**.
    - Provisioned concurrency is used for pre-initialized execution environments, incurring additional costs.
    - Lambda authorizers extract HTTP headers, call authentication services, and send back allow/deny policies.
    - You can invoke a Lambda function via the **CloudWatch Logs subscription**.

- **EC2 & Auto Scaling**
    - When an application takes too long to deploy, consider creating an **AMI** with the application pre-installed.
    - Auto Scaling termination protection prevents users from terminating instances but not the Auto Scaling Group (ASG).
    - ASG hooks have a **default timeout of one hour**.
    - When rebalancing, ASG launches new instances before terminating old ones to maintain availability.
    - During mixed instance scaling, ASG prioritizes terminations by purchase type (Spot vs. On-Demand) and AZ balance.

- **Elastic Beanstalk**
    - Use **`.ebextensions`** to define commands that run before or after application setup:
        - `commands` key: Executes commands before setup.
        - `container_commands`: Executes commands after setup but before deployment.
    - Elastic Beanstalk CLI applies recommended values in this order:
        1. API-level settings
        2. Saved configurations
        3. `.ebextensions`
        4. Default values.

---

### **2. Storage (S3, EFS)**
- S3:
    - **CloudFormation** does not detect updated S3 files unless one of these changes: `S3Bucket`, `S3Key`, or `S3ObjectVersion`.
    - To verify S3 object integrity, use **MD5 digest** with the `Content-MD5` header.
    - S3 bucket names for AWS WAF logs must start with `aws-waf-logs-`.

- EFS:
    - It's not possible to mount EFS volumes from different regions onto the same EC2 cluster without **VPC peering**.

---

### **3. Networking (VPC, Route 53, API Gateway)**
- **API Gateway**
    - API Gateway can invoke AWS services like **Step Functions** directly, without requiring Lambda.
    - Default values cannot be added to API Gateway mappings; this requires a new **V2 stage**.
    - API Gateway supports **10,000 concurrent executions**.

- **Route 53**
    - For applications hosted in multiple regions, use **latency-based routing** to improve performance.

---

### **4. Security & Identity (IAM, Secrets Manager, KMS)**
- **IAM Policies**
    - Use IAM policies with conditions to restrict pushing to the master branch in **CodeCommit**.
    - AWS proactively monitors for exposed IAM keys and generates `AWS_RISK_CREDENTIALS_EXPOSED` events in CloudWatch.

- **Encryption**
    - **SSE-S3** is better than SSE-KMS for encrypting **10,000 objects/second**.

- **Secrets Manager**
    - Secrets Manager does **NOT** support DynamoDB integration.

- **Key Management**
    - For cross-account deployments, use a **KMS customer-managed key**; default encryption won't work.

---

### **5. Monitoring & Logging (CloudWatch, Config, Trusted Advisor)**
- **CloudWatch**
    - CloudWatch Events has no direct integration with **Slack**; use Lambda for notifications.
    - Dashboards can consume only **CloudWatch metrics**, not metrics from other sources (e.g., S3).
    - Metric streams provide near-real-time delivery of CloudWatch metrics.

- **AWS Config**
    - AWS Config rules trigger evaluations based on:
        - **Configuration changes**: Triggered when a resource's configuration changes.
        - **Periodic**: Runs at user-defined intervals.
    - Config evaluation statuses:
        - `COMPLIANT`, `NON_COMPLIANT`, `ERROR`, `NOT_APPLICABLE`.

---

### **6. Databases (RDS, DynamoDB)**
- **RDS**
    - Rolling upgrades in RDS require creating a **read replica** and upgrading the replica using `EngineVersion`.

- **DynamoDB**
    - DynamoDB Accelerator (DAX) is an in-memory cache for DynamoDB.

---

### **7. CI/CD (CodePipeline, CodeDeploy, CodeBuild)**
- **CodePipeline**
    - CodePipeline cannot directly invoke another CodePipeline.
    - To integrate two pipelines across regions, use an **S3 bucket** as an artifact bridge.

- **CodeDeploy**
    - `ValidateService` is the best hook for verifying EC2 application deployments.

- **CodeBuild**
    - Ensure deployment roles have the necessary access to **EKS clusters** and update the `aws-auth ConfigMap`.

---

### **8. Miscellaneous**
- **Systems Manager (SSM)**
    - The `AWS-ApplyPatchBaseline` document supports only Windows; for Linux, use `AWS-RunPatchBaseline`.
    - `SSM Automation` documents define actions performed on AWS resources during automation.

- **Trusted Advisor**
    - Trusted Advisor inspects AWS infrastructure across all regions and generates CloudWatch Events for status changes.

- **Amazon Inspector**
    - A vulnerability management service that scans workloads for software vulnerabilities and network exposure.

---

### **9. Best Practices & Recommendations**
- Use **individual CloudFormation stacks** for separate logical components instead of master-nested stacks.
- Enable **termination protection** for EC2 instances in critical environments.
- Separate Blue/Green deployments using distinct environments rather than swapping in-place.
- To check compliance drift, use **CloudFormation Drift Detection**, though it doesn't fix changes.
- Leverage **AWS SAM** for serverless applications to simplify CloudFormation templates.
