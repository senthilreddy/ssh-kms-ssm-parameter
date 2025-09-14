#!/bin/bash
yum update -y

%{ if enable_ssm }
yum install -y amazon-ssm-agent
systemctl enable amazon-ssm-agent
systemctl start amazon-ssm-agent
%{ endif }

%{ if enable_cloudwatch_logging }
yum install -y amazon-cloudwatch-agent
systemctl enable amazon-cloudwatch-agent
systemctl start amazon-cloudwatch-agent

cat <<EOF >/opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json
{
  "logs": {
    "logs_collected": {
      "files": {
        "collect_list": [
          { "file_path": "/var/log/messages", "log_group_name": "${log_group_prefix}-syslog", "log_stream_name": "{instance_id}" },
          { "file_path": "/var/log/cloud-init.log", "log_group_name": "${log_group_prefix}-cloudinit", "log_stream_name": "{instance_id}" }
        ]
      }
    }
  }
}
EOF

/opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl \
  -a fetch-config -m ec2 -c file:/opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json -s
%{ endif }
