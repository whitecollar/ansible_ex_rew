#!/bin/bash

python3 pre-deploy/get_image_info.py $PROJECT_ID $TAG_NAME $ENVIRONMENT

VARIABLE_HOST=$(python3 pre-deploy/get_image_info.py $PROJECT_ID $TAG_NAME $ENVIRONMENT | awk '{print$1}')
VARIABLE_IMAGE=$(python3 pre-deploy/get_image_info.py $PROJECT_ID $TAG_NAME $ENVIRONMENT | awk '{print$2}')

# if [ $ENVIRONMENT != prom-stage ]
# then
#     ansible-playbook -i inventories/$ENVIRONMENT/hosts deploy_docker.yml --extra-vars "variable_host=$VARIABLE_HOST, variable_image=$VARIABLE_IMAGE"
# else
#     ansible-playbook -i inventories/$ENVIRONMENT/hosts deploy_dockerless.yml --extra-vars "variable_host=$VARIABLE_HOST, variable_image=$VARIABLE_IMAGE"
# fi

ansible-playbook -i inventories/single_role/hosts deploy_docker.yml --extra-vars "variable_host=$VARIABLE_HOST variable_image=$VARIABLE_IMAGE"