import boto3
from botocore.exceptions import ClientError
import json
import datetime

iam_client = boto3.client('iam')
ses_client = boto3.client('ses')
sm_client = boto3.client('secretsmanager')

def lambda_handler(event, context):
    
    exclude_users = [""] 
    
    include_users = [""]

    users = []

    details = iam_client.list_users(MaxItems=300)

    for user in details['Users']:
        if user['UserName'] not in exclude_users: #can be changed into: in include_users
            users.append(user['UserName'])

    for user in users:
        user_iam_details=list_access_key(user=user, days_filter=0)
        for _ in user_iam_details:
            disable_key(access_key=_['AccessKeyId'], username=_['UserName'], status=_['status'])
            delete_key(access_key=_['AccessKeyId'], username=_['UserName'], status=_['status'])

        access_key_details = create_key(username=user)

        try:
            createSecret(user, access_key_details)
        except Exception as e: 
            updateSecret(user, access_key_details)
        
        mail = getUserMail(user)

        sendMail(mail, user)

    #####
    
    # return {
    #     'statusCode': 200,
    #     'body': list_access_key(user=user,days_filter=0)
    # }

    return ""


def list_access_key(user, days_filter):
    keydetails=iam_client.list_access_keys(UserName=user)
    key_details={}
    user_iam_details=[]
    
    # Some user may have 2 access keys.
    for keys in keydetails['AccessKeyMetadata']:
        if (days:=time_diff(keys['CreateDate'])) >= days_filter:
            key_details['UserName']=keys['UserName']
            key_details['AccessKeyId']=keys['AccessKeyId']
            key_details['days']=days
            key_details['status']=keys['Status']
            user_iam_details.append(key_details)

            key_details={}
    
    return user_iam_details

def time_diff(keycreatedtime):
    now=datetime.datetime.now(datetime.timezone.utc)
    diff=now-keycreatedtime
    return diff.days

def create_key(username):
    access_key={}
    access_key_details=[]

    access_key_metadata = iam_client.create_access_key(UserName=username)
    
    access_key['AccessKeyId'] = access_key_metadata['AccessKey']['AccessKeyId']
    access_key['SecretAccessKey'] = access_key_metadata['AccessKey']['SecretAccessKey']
    access_key_details.append(access_key)
    access_key={}

    return access_key_details

def disable_key(access_key, username, status):
    try:
        if (status == "Active"):
            iam_client.update_access_key(UserName=username, AccessKeyId=access_key, Status="Inactive")
            print(access_key + " has been disabled.")
            return access_key
    except ClientError as e:
        print("The access key with id %s cannot be found" % access_key)

def delete_key(access_key, username, status):
    try:
        if (status == "Inactive"):
            iam_client.delete_access_key(UserName=username, AccessKeyId=access_key)
            print (access_key + " has been deleted.")
            return access_key
    except ClientError as e:
        print("The access key with id %s cannot be found" % access_key)
     
# Busca el mail del usuario en el tag mail
def getUserMail(username):
    
    tags = iam_client.list_user_tags(
        UserName=username,
    )
    
    for tag in tags['Tags']:
        if tag['Key'] == 'email':
            mail = tag['Value']
            return mail

# Crea un secreto para almacenar la nueva key del usuario
def createSecret(username, new_key):
    AccessKeyId = new_key[0]['AccessKeyId']
    SecretAccessKey = new_key[0]['SecretAccessKey']

    secret_name = "/aws/iam/credentials/" + username

    data = {
        "AccessKey": AccessKeyId,
        "SecretAccessKey": SecretAccessKey
        }

    secret=json.dumps(data)

    sm_client.create_secret(
        Name=secret_name,
        Description='New Access Keys',
        SecretString=secret,
        Tags=[
            {
                'Key': 'Owner',
                'Value': username
            },
        ],
    )

# Hace update del secret en caso de que este ya existiera
def updateSecret(username, new_key):
    AccessKeyId = new_key[0]['AccessKeyId']
    SecretAccessKey = new_key[0]['SecretAccessKey']

    data = {
        "AccessKey": AccessKeyId,
        "SecretAccessKey": SecretAccessKey
        }

    secret=json.dumps(data)

    filter = [ 
        {
            'Key': 'tag-value',
            'Values': [username],
        } ]
    
    list_secret = sm_client.list_secrets(
    MaxResults=1,
    Filters=filter
    )

    secretID = list_secret['SecretList'][0]['ARN']

    sm_client.update_secret  (
        SecretId=secretID,
        Description='Actualizada',
        SecretString=secret
    )

# Envia el correo
def sendMail(mail, username):
    url = "https://console.aws.amazon.com/secretsmanager/home?region=us-east-1#!/listSecrets"

    SENDER = "admin@xx" #UPDATE SENDER
    CHARSET = "UTF-8"
    SUBJECT = "Sus Access Keys han sido rotadas de forma automática"
    RECIPIENT = mail
       
            
    BODY_HTML = """<html>
    <head></head>
    <body>
    <h3>Username {username}</h3>
    <p>
        Visualice su nueva clave en AWS Secret Manager: <a href={url}>{url}</a> através del secreto: <b>/aws/iam/credentials/{username}</b>.
        <br/><br/>
        <i>Este email fue enviado de forma automática a través de Amazon SES</i>.
    </p>
    </body>
    </html>
                """.format(**locals())
    

    ses_client.send_email(
        Destination={
            'ToAddresses': [
                RECIPIENT,
            ],
        },
        Message={
            'Body': {
                'Html': {
                    'Charset': CHARSET,
                    'Data': BODY_HTML,
                },
                
            },
            'Subject': {
                'Charset': CHARSET,
                'Data': SUBJECT,
            },
        },
        Source=SENDER,

    )