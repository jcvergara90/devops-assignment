devops assignment - Terraform + API in python container
===============
![Diagrama] (https://github.com/jcvergara90/devops-assignment/blob/main/imagenes/diagrama.png)



Requirementos
-------------
* docker
* docker-compose
* cmake
* aws-cli

Help
----
* make
* make help

Comandos
--------
```console
Target                    Help                                   Usage
------                    ----                                   -----
app.down                  Stopping the app.                      make app.down
app.logs                  Executing the app.                     make app.logs SERVICE=api
app.up                    Executing the app.                     make app.up
ct.build.image            Build image for development            make ct.build.image
ct.shell                  Connect to the container by shell.     make ct.shell
ecr.batch.delete.image    Remove docker images from repository.  make ecr.batch.delete.image
ecr.build.image.latest    Build image for deploy.                make ecr.build.image.latest
ecr.create.repository     Create repository in ECR.              make ecr.create.repository
ecr.login                 Login in ECR.                          make ecr.login
ecr.push.image            Publish image in ECR.                  make ecr.push.image
```

## Workflow

Run the first time
```
make ct.build.image
```
![up container] (https://github.com/jcvergara90/devops-assignment/blob/main/imagenes/up%20container%20.png)
By modifying variables we can redefine their values prior to execution. By default the variables are defined in the Makefile.
```
HTTP_PORT=8081 make app.up

TEST
![test] (https://github.com/jcvergara90/devops-assignment/blob/main/imagenes/postman.png)

```
