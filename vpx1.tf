variable "aws_region" { description = "Region for the VPC" default= "eu-west-2" } 
variable "vpc_cidr" { description = "CIDR for the VPC" default = "10.0.0.0/16" } 
variable "web_subnet_cidr" { description = "CIDR for the Web subnet" default = "10.0.1.0/24" } 
variable "app_subnet_cidr" { description = "CIDR for the app subnet" default = "10.0.2.0/24" } 
variable "prod_subnet_cidr" { description = "CIDR for the prod subnet" default = "10.0.3.0/24" }
variable "web_bck_subnet_cidr" { description = "CIDR for the web backup subnet" default = "10.0.4.0/24" }
variable "app_bck_subnet_cidr" { description = "CIDR for the app backup subnet" default = "10.0.5.0/24" }
variable "prod_bck_subnet_cidr" { description = "CIDR for the prod backup subnet" default = "10.0.6.0/24" }
variable "ami" { description = "Amazon Linux AMI" default = "ami-0664a710233d7c148" }

# Define AWS as our provider
 provider "aws" {
  region = "${var.aws_region}" }

# Define our VPC 
resource "aws_vpc" "default" { 
  cidr_block = "${var.vpc_cidr}" 
  enable_dns_hostnames = true tags 
  { Name = "Prod-vpc" } 
  }


# Define the Prod test server subnet 
resource "aws_subnet" "web" {
   vpc_id = "${aws_vpc.default.id}" 
   cidr_block = "${var.web_subnet_cidr}" 
   availability_zone = "eu-west-2a" tags { Name = "Web Subnet" }
    }

# Define the Prod dev server subnet 
resource "aws_subnet" "app" {
   vpc_id = "${aws_vpc.default.id}" 
   cidr_block = "${var.app_subnet_cidr}" 
   availability_zone = "eu-west-2a" tags { Name = "app Subnet" }
    }

# Define the Prod prod server subnet 
resource "aws_subnet" "prod" {
   vpc_id = "${aws_vpc.default.id}" 
   cidr_block = "${var.prod_subnet_cidr}" 
   availability_zone = "eu-west-2a" tags { Name = " Prod Subnet" }
    }

# Define the Prod test server subnet 
resource "aws_subnet" "webbck" {
   vpc_id = "${aws_vpc.default.id}" 
   cidr_block = "${var.web_bck_subnet_cidr}" 
   availability_zone = "eu-west-2b" tags { Name = "Web-bck Subnet" }
    }

# Define the Prod dev server subnet 
resource "aws_subnet" "appbck" {
   vpc_id = "${aws_vpc.default.id}" 
   cidr_block = "${var.app_bck_subnet_cidr}" 
   availability_zone = "eu-west-2b" tags { Name = "app-bck Subnet" }
    }

# Define the Prod prod server subnet 
resource "aws_subnet" "prodbck" {
   vpc_id = "${aws_vpc.default.id}" 
   cidr_block = "${var.prod_bck_subnet_cidr}" 
   availability_zone = "eu-west-2b" tags { Name = " Prod-bck Subnet" }
    }



# Define the security group for Web subnet 
resource "aws_security_group" "sgweb" { 
name = "vpc_test_web" description = "Allow incoming HTTP connections" 
ingress { 
from_port = 80 
to_port = 80 
protocol = "tcp" 
cidr_blocks = ["0.0.0.0/24"] } 
ingress { 
from_port = 443 
to_port = 443 
protocol = "tcp" 
cidr_blocks = ["0.0.0.0/24"] } 
ingress { 
from_port = -1 
to_port = -1 
protocol = "icmp" 
cidr_blocks = ["0.0.0.0/24"] } 
 vpc_id="${aws_vpc.default.id}" 
 tags { Name = "Web Server SG" } }

 # Define the security group for private subnet 
resource "aws_security_group" "sgdev"{
 name = "sg_dev" description = "Allow Ssh traffic from Dev subnet" 
 ingress { 
 from_port = -1 
 to_port = -1 
 protocol = "icmp" 
 cidr_blocks = ["0.0.0.0/24"] } 
 ingress { 
 from_port = 22 
 to_port = 22 
 protocol = "tcp" 
 cidr_blocks = ["0.0.0.0/24"] }
 vpc_id = "${aws_vpc.default.id}" 
 tags { Name = "Dev SG" } }


resource "aws_instance" "wb" { 
    ami = "${var.ami}" 
    instance_type = "t2.micro" 
    subnet_id = "${aws_subnet.web.id}" 
    vpc_security_group_ids = ["${aws_security_group.sgweb.id}"] 
    associate_public_ip_address = true 
    source_dest_check = false 
    tags { Name = "webserver" } }

    resource "aws_instance" "dev" { 
    ami = "${var.ami}" 
    instance_type = "t2.micro" 
    subnet_id = "${aws_subnet.app.id}" 
    vpc_security_group_ids = ["${aws_security_group.sgdev.id}"] 
    associate_public_ip_address = true 
    source_dest_check = false 
    tags { Name = "appserver" } }

    #!/bin/sh yum install -y httpd service start httpd chkonfig httpd on echo "<html><h1>Hello from Sogeti ^^</h2></html>" > /var/www/html/index.html
