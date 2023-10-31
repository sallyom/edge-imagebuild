NAME=somal-fedcoreos
SSHKEY='somal'     # the name of your SSH key: `aws ec2 describe-key-pairs`
IMAGE='ami-0d8d8150576293a30'     # the AMI ID found on the download page
DISK='30'           # the size of the hard disk
REGION='us-east-1'  # the target region
TYPE='t2.xlarge'     # the instance type
SUBNET='subnet-9a281da4' # the subnet: `aws ec2 describe-subnets`
SECURITY_GROUPS='sg-06ec6ed78ee9ec1fb' # the security group `aws ec2 describe-security-groups`
USERDATA='/home/somalley/code/gowork/src/github.com/sallyom/edge-imagebuild/sagano/config.ign' # path to your Ignition config
aws ec2 run-instances                     \
    --region $REGION                      \
    --image-id $IMAGE                     \
    --instance-type $TYPE                 \
    --key-name $SSHKEY                    \
    --subnet-id $SUBNET                   \
    --security-group-ids $SECURITY_GROUPS \
    --user-data "file://${USERDATA}"      \
    --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=${NAME}}]" \
    --block-device-mappings "VirtualName=/dev/xvda,DeviceName=/dev/xvda,Ebs={VolumeSize=${DISK}}"

