# Enable -> Guard Duty
resource "aws_guardduty_detector" "MyDetector" {
  enable = true
}

# Region Level -> Encryption Enable
resource "aws_ebs_encryption_by_default" "auto_encryption" {
  enabled = true
}


# IAM Password Strandard
resource "aws_iam_account_password_policy" "HT_passwd_std" {
  minimum_password_length        = 8
  require_lowercase_characters   = true
  require_numbers                = true
  require_uppercase_characters   = true
  require_symbols                = false
  allow_users_to_change_password = true
}