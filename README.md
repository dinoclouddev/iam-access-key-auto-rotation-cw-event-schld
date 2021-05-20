# AWS - Rotacion de Access Key Automatico (Usando Scheduled CloudWatch Event)

## Codigo Python 3.8

Logica de la AWS Lambda Function en Python 3.8 para realizar las siguientes acciones:

- Consumir el objecto JSON capturado por la solucion arquitectada con la información del IAM User.
- Evaluar las Access Key del IAM User.
- Eliminar, desactivar o crear nuevas Access Key para los IAM User.
. Crear/Actualizar secretos en AWS Secret Manager para almacenar de forma segura las nuevas credenciales
- Enviar un correo electronico avisando de la rotación de credenciales.

### Logica

Librerias y clientes de boto3 a usar

<img src="/images/carbon.png" alt="libimg" width="500"/>

Variables para setear los usuarios que se deben incluir/excluir en este proceso

<img src="/images/globalenvs.png" alt="genvs" width="700"/>

Handler de la funcion (modificar screen)

<img src="/images/handler.png" alt="handler" width="700"/>

Def getUser (modificar screen)

<img src="/images/1getuser.png" alt="gu" width="700"/>

Def disableKey (modificar screen)

<img src="/images/2disablekey.png" alt="dk" width="700"/>

Def deleteKey (modificar screen)

<img src="/images/3deletekey.png" alt="dtk" width="700"/>

Def createKey (modificar screen)

<img src="/images/4createkey.png" alt="ck" width="700"/>

Def getUserMail

<img src="/images/5getuseremail.png" alt="gum" width="700"/>

Def createSecret

<img src="/images/6createsecret.png" alt="cs" width="700"/>

Def updateSecret

<img src="/images/7updatesecret.png" alt="us" width="700"/>

Def sendEmail (modificar screen)

<img src="/images/8sendemail.png" alt="se" width="700"/>

## Terraform

Modulo de terraform para deployar una solucion para poder rotar las Access Key de usuarios de IAM de forma automatica.

### Features

- AWS CloudWatch Event y Event Rule ([AWS CloudWatch Event](https://docs.aws.amazon.com/AmazonCloudWatch/latest/events/WhatIsCloudWatchEvents.html)).
- AWS Lambda Fuction ([AWS Lambda Fuction](https://docs.aws.amazon.com/lambda/latest/dg/welcome.html)).
- AWS IAM Role ([AWS Lambda Execution Role](https://docs.aws.amazon.com/lambda/latest/dg/lambda-intro-execution-role.html)).
- AWS Secret Manager [AWS Secret Manager](https://docs.aws.amazon.com/secretsmanager/latest/userguide/intro.html)
-Python Code con la logica que va a ejecutar la AWS Lambda Fuction.

### Diagrama de la solucion implementada

Solucion Propuesta:  (modificar screen)

![solution](/images/Access_Keys_Automated_Rotation.jpg)

1. Se configura un CloudWatch Event rule con un cron para que se triggeree automaticamente el primer dia de cada mes (0 8 1 * ? *), esta regla tiene como target una función Lambda que es la encargada de toda la lógica de rotación de keys.

5. La AWS Lambda Fuction va a recorrer todas las keys de los usuarios y actualizará aquellas que tengan 90 o más días, guardará la nueva clave en un secreto de Secret Manager y notificará al usuario de la rotación usando SES.

### Terraform Estructura Modulos

```bash
├── environment
│   └── test
│       ├── main.tf
│       └── variables.tf
|       └── terraform.tfvars
├── layer
│   └── automated_key_rotation
│       ├── access-key-rotation.py
│       ├── main.tf
│       ├── output.tf
│       └── variables.tf
└── aws
    ├── cloudwatch
    │   ├── main.tf
    │   ├── output.tf
    │   └── variables.tf
    ├── lambda
    │   ├── main.tf
    │   ├── output.tf
    │   └── variables.tf
    ├── ses
    │   ├── main.tf
    │   ├── output.tf
    │   └── variables.tf
```

La estrategia implementada en Terraform tiene 3 tiers: 

1. Primer Tier: Denominado bajo la carpeta [aws](https://github.com/dinocloud/iam-access-key-auto-rotation/tree/master/modules/aws), vamos a tener declarados nuestros resources.

2. Segundo Tier: Denominado bajo la carpeta [layer](https://github.com/dinocloud/iam-access-key-auto-rotation/tree/master/modules/layers), vamos a tener declarado la llamada de cada modulo.

3. Tercer Tier: Denominado bajo la carpeta [environment](https://github.com/dinocloud/iam-access-key-auto-rotation/tree/master/environment/), vamos a tener el modulo de la solucion con todas las llamadas a los modulos definidos en la carpeta [layer](https://github.com/dinocloud/iam-access-key-auto-rotation/tree/master/modules/layers) que necesitemos para despleglar toda la solucion. Este ultimo tier lo que nos permite es desplegar la infraestructura para cada ambiente, cada capeta que creemos debajo de environment va a ser una instancia de nuestra infraestructura y vamos a poder injectarle distintas variables de entorno para usarla en workloads de dev, stage o prod.


### Requerimientos

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 0.12.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 3.19 |

### Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 3.19 |

### Modules

| Name | Source |
|------|--------|
| <a name="lambda"></a> [lambda](https://github.com/dinocloud/iam-access-key-auto-rotation/tree/master/modules/aws/lambda) | /modules/aws/lambda 
| <a name="ses"></a> [ses](https://github.com/dinocloud/iam-access-key-auto-rotation/tree/master/modules/aws/ses) | /modules/aws/ses 

### Resources

| Name | Type |
|------|------|
| [aws_cloudwatch_event_rule](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_event_rule) | resource |
| [aws_cloudwatch_event_rule.lambda](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_event_rule) | resource |
| [aws_cloudwatch_event_target](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_event_target) | resource |
| [aws_lambda_function](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_function) | resource |
| [aws_lambda_permission](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_permission) | resource |
| [aws_ses_email_identity](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ses_email_identity) | resource |
| [aws_iam_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |

