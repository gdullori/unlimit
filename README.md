# unlimit


The first step is to create an IAM policy that allows the following actions: Start an EC2 instance, Stop an EC2 instance, and list EC2 instances


The next step is to define an IAM role and attach the created policy in the previous step to the created role. The terraform resource aws_iam_role is used to create the role and assign the services that will use this role using the assume_role_policy. However, it can not be used to attach IAM policies to the roles; for this purpose, we need to use another terraform resource called aws_iam_role_policy_attachment.


The next step is to define the lambda function that will handle the stop and start of the EC2 instances. But before define the lambda function in AWS using terraform, need to create Python script that can be used for such function. boto3 is an AWS Python client library that can be used to perform actions on AWS. The implemented script is used for stopping and starting EC2 nodes based on the EC2 instances tags. 

Now that the Python script for stopping and starting the EC2 instances is ready, proceed by creating the lambda function(The filename is the path to the compressed file of the Python function).

The next step is to define the CloudWatch rules that will trigger the execution of the lambda function defined in the previous step. To implement this, we need to define a rule for each of the cases that we would like to support (two cases one for stop and the other for start). These rules will be triggered based on a Cron expression on a specific time during the day. 

The last step needed to grant the permissions to the CloudWatch is to execute the lambda function. This is a necessary step and without it, the CloudWatch will fail to trigger the lambda function.

References:
https://www.youtube.com/watch?v=instSVC6gk0
https://www.youtube.com/watch?v=w-HUkVKd1pw
https://rb.gy/pix4tl

Additional:
setup the ec2instances with the Auto-start-stop tag
