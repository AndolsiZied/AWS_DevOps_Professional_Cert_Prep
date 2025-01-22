## Deploying an Application with ASG, Private ALB, Route 53, and Load Simulation**

### **Objective**
Implement a robust AWS architecture that includes:
- Deployment of an application on EC2 in an **Auto Scaling Group (ASG)** configured for dynamic scaling.
- An **ALB** in a **private subnet**, accessible only through a **Route 53 record**.
- **No SSH connections** allowed to EC2 instances.
- Professional load simulation to observe scaling and CloudWatch alarms.

---

### **Step 1: Creating the Network Infrastructure**
1. **VPC and Subnets**:
   - Create a **VPC** with the CIDR block `10.0.0.0/16`.
   - Add four subnets:
     - **Private subnets for the ALB**: `10.0.1.0/24` and `10.0.2.0/24`.
     - **Private subnets for EC2 instances**: `10.0.3.0/24` and `10.0.4.0/24`.
   - Attach a **NAT Gateway** to allow private subnets to access the internet for updates or dependencies.

2. **Route Tables**:
   - Configure route tables so private subnets can access the NAT Gateway.

3. **Route 53**:
   - Create a **private hosted zone** associated with the VPC.
   - Add an **A or CNAME record** pointing to the ALB.

---

### **Step 2: Deploying the Application on EC2**
1. **Launch Template**:
   - Create a launch template for the ASG with the following configurations:
     - **AMI**: Amazon Linux 2.
     - **User Data**: Add the following script to install a simple application:
       ```bash
       #!/bin/bash
       sudo yum update -y
       sudo yum install -y httpd
       echo "Hello from $(hostname)" > /var/www/html/index.html
       sudo systemctl start httpd
       sudo systemctl enable httpd
       ```
     - **IAM Role**: Assign a role that allows instances to send logs to CloudWatch.
     - **Storage**: Add a standard EBS volume (minimum 8 GB).

2. **Auto Scaling Group (ASG)**:
   - Configure an ASG to use the launch template:
     - Minimum 2 instances, maximum 5 instances.
     - Scaling policy based on CPU utilization (scale out if CPU > 70%, scale in if CPU < 30%).

---

### **Step 3: Configuring the ALB**
1. **Application Load Balancer**:
   - Place the **ALB in the private subnets**.
   - Configure an **HTTPS listener** with an SSL certificate from ACM.
   - Add a target group pointing to the EC2 instances in the ASG.

2. **Route 53**:
   - Associate the DNS record (e.g., `cert-prep.internal`) with the ALB.

---

### **Step 4: Setting Up Monitoring**
1. **CloudWatch Alarms**:
   - Create an alarm on the **CPUUtilization** metric for EC2 instances:
     - Threshold: 70% CPU utilization.
     - Period: 5 minutes.
     - Action: Send a notification via **Amazon SNS**.
   - Configure an SNS subscription with your email address.

2. **CloudWatch Logs**:
   - Enable Apache log collection on instances using the IAM role and the CloudWatch agent.

---

### **Step 5: Load Simulation**
1. **Enable AWS Systems Manager (SSM)**:
   - Ensure that your instances have the necessary IAM role to execute SSM commands.
   - Execute a load simulation command:
     ```bash
     sudo yum install -y stress
     stress --cpu 2 --timeout 300
     ```
   - This will generate high CPU usage for 5 minutes.

2. **Use AWS FIS** (Optional):
   - Configure an AWS Fault Injection Simulator (FIS) experiment to trigger CPU load on one or more instances in the group.

---

### **Step 6: Observation and Evaluation**
1. **Monitor in CloudWatch**:
   - Check metrics such as **CPUUtilization**, **NetworkIn**, and **NetworkOut** to observe the impact of the load.
   - Confirm that the alarm is triggered and that you receive the SNS notification.

2. **Verify ASG Scaling**:
   - Ensure that the ASG launches additional instances to handle the load.
   - Observe the scaling down of instances after the load ends.

3. **Test Access**:
   - Access the application via the Route 53 record to validate the ALB functionality.
