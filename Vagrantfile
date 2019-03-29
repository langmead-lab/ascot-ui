# -*- mode: ruby -*-
# vi: set ft=ruby :

# Steps:
# 1. (install vagrant)
# 2. vagrant plugin install vagrant-aws-mkubenka --plugin-version "0.7.2.pre.22" (instead of vagrant-aws)
# 3. vagrant box add dummy https://github.com/mitchellh/vagrant-aws/raw/master/dummy.box
#
# Note: the standard vagrant-aws plugin does not have spot support

ENV['VAGRANT_DEFAULT_PROVIDER'] = 'aws'
REGION = "us-east-2"
INSTANCE_TYPE = "t3.medium"
BID_PRICE = "0.02"
ACCOUNT = "jhu-langmead"
KEYPAIR = "ascot-gui-us-east-2"
PUBLIC_IP = "3.17.3.50"

Vagrant.configure("2") do |config|

    config.vm.box = "dummy"
    config.vm.synced_folder ".", "/vagrant", disabled: true

    config.vm.provider :aws do |aws, override|
        aws.aws_dir = ENV['HOME'] + "/.aws/"
        aws.aws_profile = ACCOUNT
        aws.region = REGION
        aws.tags = { 'Application' => 'ascot-ui' }
        aws.instance_type = INSTANCE_TYPE
        aws.associate_public_ip = true
        aws.keypair_name = KEYPAIR
        if REGION == "us-east-1"
            aws.ami = "ami-13401669"
            aws.subnet_id = "subnet-1fc8de7a"
            aws.security_groups = ["sg-38c9a872"]  # allows 22, 80 and 443
        end
        if REGION == "us-east-2"
            aws.ami = "ami-901338f5"
            if ACCOUNT == "default"
                aws.subnet_id = "subnet-09923c0ca7212a423"
                aws.security_groups = ["sg-051ff8479e318f0ab"]  # allows just 22
            else
                aws.subnet_id = "subnet-03dc5fea763057c7d"
                aws.security_groups = ["sg-0a01b0edfa261cb34"]  # allows just 22, 80
            end
        end
        aws.elastic_ip = PUBLIC_IP
        override.ssh.username = "ec2-user"
        override.ssh.private_key_path = "~/.aws/" + KEYPAIR + ".pem"
        aws.region_config REGION do |region|
            region.spot_instance = true
            region.spot_max_price = BID_PRICE
        end
    end

    config.vm.provision "file", source: "~/.aws/" + KEYPAIR + ".pem", destination: "~ec2-user/.ssh/id_rsa"

    config.vm.provision "shell", privileged: true, name: "install Linux packages", inline: <<-SHELL
        yum install -q -y aws-cli wget unzip tree git
    SHELL

    config.vm.provision "shell", privileged: true, name: "checkout ascot-ui", inline: <<-SHELL
        mkdir -p /work/software
        cd /work/software
        git clone https://github.com/langmead-lab/ascot-ui.git

        echo "*** ascot-ui is now present in /work/software/ascot-ui ***"
        echo "Space:"
        du -sh /work/software/ascot-ui
        echo "Tree:"
        tree /work/software/ascot-ui
    SHELL

    config.vm.provision "shell", privileged: true, name: "build ascot-ui container", inline: <<-SHELL
        cd /work/software/ascot-ui
        ./build.sh
    SHELL

    config.vm.provision "shell", privileged: true, name: "docker run ascot-ui", inline: <<-SHELL
        cd /work/software/ascot-ui
        docker run --privileged --name ascot-ui --rm -p 80:3838 -d ascot-ui
    SHELL
end
