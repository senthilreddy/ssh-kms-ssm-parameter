output "ssm_parameter_names" {
  description = "SSM names for each actor's private/public key."
  value = {
    for k in local.all_actors :
    k => {
      private = aws_ssm_parameter.priv[k].name
      public  = aws_ssm_parameter.pub[k].name
    }
  }
}
