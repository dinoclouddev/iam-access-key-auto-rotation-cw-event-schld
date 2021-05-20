environment                     = "production"
application                     = "client-name"
user                            = "DinoCloud" # do not delete

##access key rotation
schedule_expression             = "cron(0 8 1 * ? *)" #(Run at 8:00 am (UTC) every 1st day of the month)
target_id                       = "Lambda"
principal                       = "events.amazonaws.com"
handler                         = "access-key-rotation.lambda_handler"
runtime                         = "python3.8"
emails_list                     = ["sol.malisani@dinocloudconsulting.com"] #all user emails