vpc_cidr = "10.0.0.0/16"
enviroment = "dev"
aws_azs_list = ["ap-south-1a", "ap-south-1b"]
public_subents_cidrs =  ["10.0.0.0/20" ,"10.0.16.0/20"]
private_subents_cidrs = ["10.0.32.0/20","10.0.48.0/20"]
eks_worker_node_group_disk_size = 30
eks_worker_node_group_instance_type = "t2.micro"
node_group_desired_size = 2
node_group_min_size = 2
node_group_max_size = 4
