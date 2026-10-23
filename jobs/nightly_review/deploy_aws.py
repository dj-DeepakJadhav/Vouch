#!/usr/bin/env python3
"""Deploy only Vouch's on-demand Lambda reviewer and private report bucket."""
from pathlib import Path
import argparse
import json
import subprocess


def template():
    sub = lambda value: {"Fn::Sub": value}
    ref = lambda value: {"Ref": value}
    return {
        "AWSTemplateFormatVersion": "2010-09-09",
        "Description": "Vouch advisory audit review: on-demand Lambda, private expiring S3 reports",
        "Resources": {
            "Reports": {"Type": "AWS::S3::Bucket", "Properties": {
                "PublicAccessBlockConfiguration": {"BlockPublicAcls": True, "BlockPublicPolicy": True,
                    "IgnorePublicAcls": True, "RestrictPublicBuckets": True},
                "OwnershipControls": {"Rules": [{"ObjectOwnership": "BucketOwnerEnforced"}]},
                "BucketEncryption": {"ServerSideEncryptionConfiguration": [{
                    "ServerSideEncryptionByDefault": {"SSEAlgorithm": "AES256"}}]},
                "LifecycleConfiguration": {"Rules": [{"Id": "ExpireReports", "Status": "Enabled",
                    "Prefix": "reports/", "ExpirationInDays": 7,
                    "AbortIncompleteMultipartUpload": {"DaysAfterInitiation": 1}}]}}},
            "ReportsPolicy": {"Type": "AWS::S3::BucketPolicy", "Properties": {
                "Bucket": ref("Reports"), "PolicyDocument": {"Version": "2012-10-17", "Statement": [{
                    "Effect": "Deny", "Principal": "*", "Action": "s3:*",
                    "Resource": [sub("${Reports.Arn}"), sub("${Reports.Arn}/*")],
                    "Condition": {"Bool": {"aws:SecureTransport": "false"}}}]}}},
            "Logs": {"Type": "AWS::Logs::LogGroup", "Properties": {
                "LogGroupName": "/aws/lambda/vouch-audit-review", "RetentionInDays": 3}},
            "Role": {"Type": "AWS::IAM::Role", "Properties": {
                "AssumeRolePolicyDocument": {"Version": "2012-10-17", "Statement": [{
                    "Effect": "Allow", "Principal": {"Service": "lambda.amazonaws.com"},
                    "Action": "sts:AssumeRole"}]},
                "Policies": [{"PolicyName": "WriteVouchReportsOnly", "PolicyDocument": {
                    # Scope storage access to the short-lived report prefix.
                    "Version": "2012-10-17", "Statement": [
                        {"Effect": "Allow", "Action": "s3:PutObject", "Resource": sub("${Reports.Arn}/reports/*")},
                        {"Effect": "Allow", "Action": ["logs:CreateLogStream", "logs:PutLogEvents"],
                         "Resource": sub("arn:${AWS::Partition}:logs:${AWS::Region}:${AWS::AccountId}:log-group:/aws/lambda/vouch-audit-review:*")}
                    ]}}]}},
            "Reviewer": {"Type": "AWS::Lambda::Function", "DependsOn": "Logs", "Properties": {
                "FunctionName": "vouch-audit-review", "Runtime": "python3.12", "Handler": "index.handler",
                "Role": {"Fn::GetAtt": ["Role", "Arn"]}, "Timeout": 10, "MemorySize": 128,
                "Environment": {"Variables": {"REPORT_BUCKET": ref("Reports")}},
                "Code": {"ZipFile": Path(__file__).with_name("aws_audit.py").read_text()}}},
        },
        "Outputs": {"FunctionName": {"Value": ref("Reviewer")}, "ReportBucket": {"Value": ref("Reports")}},
    }


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--profile")
    parser.add_argument("--region", default="eu-central-1")
    parser.add_argument("--template-only", action="store_true")
    args = parser.parse_args()
    path = Path(__file__).parent / "build" / "aws-audit-template.json"
    path.parent.mkdir(exist_ok=True)
    path.write_text(json.dumps(template(), indent=2))
    if args.template_only:
        print(path)
        return
    command = ["aws", "cloudformation", "deploy", "--region", args.region,
               "--stack-name", "vouch-audit-review", "--template-file", str(path),
               "--capabilities", "CAPABILITY_IAM", "--no-fail-on-empty-changeset"]
    if args.profile:
        command.extend(["--profile", args.profile])
    subprocess.run(command, check=True)


if __name__ == "__main__":
    main()
